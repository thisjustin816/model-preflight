#Requires -Version 7.0

<#
.SYNOPSIS
    Injects a model preflight check into every Claude Code and Codex turn.

.DESCRIPTION
    Reads the model strategy from a markdown rules file at runtime, so the injected policy is a file
    the user maintains rather than a copy held inside this script. Both tools call UserPromptSubmit
    the same way and read the same hookSpecificOutput.additionalContext response, so one script
    serves both.

    The full block goes out on the first turn and every fifth turn after; a shorter reminder goes
    between. The reminder carries the Re-check bullet, because a task that grows mid-session is the
    case a per-task check misses.

    add-model-preflight-context.sh beside this script is a POSIX port for hosts without pwsh. The
    two must produce the same additionalContext, which tests/Test-HookParity.ps1 checks.

    Three things in the rules file are a contract: the `## Tiers` and `## Pause` headings, and the
    `- **Escalate**:` / `- **Downshift**:` / `- **Re-check**:` bullets. The matcher wants an indented
    bullet, a bold marker, and a colon. All three bullets have to be present for a file to be used at
    all, so a bullet reshaped away from that form takes the whole file out of the running and the next
    candidate is read instead. A renamed heading is narrower: that section alone drops out of the
    injected text, with no signal beyond its absence.

    Pointing RulesPath at a wider instruction file works: anything outside those headings and
    bullets is ignored, so a file that carries the triggers but no `## Tiers` section injects the
    triggers alone. That is the right result when the tiers already reach the session another way.

.PARAMETER RulesPath
    A rules file to read instead of the default order: $env:MODEL_PREFLIGHT_RULES,
    $HOME/.agents/model-strategy.md, $HOME/.codex/AGENTS.md, $HOME/.claude/model-strategy.md, then
    the skill bundled with this plugin. The first file carrying all three marker bullets wins, so a
    candidate carrying none or only some of them is skipped rather than treated as a policy. An
    explicit path is used on its own, with no fallback, so a typo surfaces as the NOTE rather than
    as silently different policy.

.NOTES
    Dry run: pipe {"session_id":"test"} to this script and read hookSpecificOutput.additionalContext.
    Pass -RulesPath pointing at a missing file to confirm the NOTE appears.
#>

[CmdletBinding()]
param(
    [String]$RulesPath
)

begin {
    $ErrorActionPreference = 'Stop'

    function Get-TriggerLine {
        <#
        .SYNOPSIS
        Internal: extract one `- **Marker**: ...` bullet, joining wrapped continuation lines into a
        single string.
        #>
        param(
            [String[]]$Lines,
            [String]$Marker
        )
        for ($i = 0; $i -lt $Lines.Count; $i++) {
            if ($Lines[$i] -notmatch "^\s*-\s\*\*$Marker\*\*:") {
                continue
            }
            $text = $Lines[$i] -replace '^\s*-\s*', ''
            $j = $i + 1
            while ($j -lt $Lines.Count -and $Lines[$j] -match '^\s+\S' -and $Lines[$j] -notmatch '^\s*-\s') {
                $text = ($text + ' ' + $Lines[$j].Trim())
                $j++
            }
            return $text
        }
    }

    function Get-InstructionSection {
        <#
        .SYNOPSIS
        Internal: return the body under a `## <Heading>` up to the next `##` heading or horizontal
        rule. A `###` subheading stays part of the body.
        #>
        param(
            [String[]]$Lines,
            [String]$Heading
        )
        $start = -1
        for ($i = 0; $i -lt $Lines.Count; $i++) {
            if ($Lines[$i] -match "^##\s+$Heading\s*$") {
                $start = $i + 1
                break
            }
        }
        if ($start -lt 0) {
            return
        }
        $body = for ($i = $start; $i -lt $Lines.Count; $i++) {
            if ($Lines[$i] -match '^(##\s|---\s*$)') {
                break
            }
            $Lines[$i]
        }
        ($body -join "`n").Trim()
    }
}

process {
    $hookInput = [Console]::In.ReadToEnd()

    $sessionId = 'unknown'
    try {
        $parsedInput = $hookInput | ConvertFrom-Json -ErrorAction Stop
        if ($parsedInput.session_id) {
            $sessionId = ($parsedInput.session_id -replace '[^\w-]', '_')
        }
    }
    catch {
        Write-Debug "Hook input parse failed: $_"
    }

    # $env:TEMP exists only on Windows; GetTempPath is the cross-platform fallback and takes no
    # provider path, so it is safe where a [System.IO.Path] call taking one would not be.
    $stateDir = Join-Path ($env:TEMP ?? [System.IO.Path]::GetTempPath()) 'model-preflight'
    $turn = 1
    try {
        $null = New-Item -ItemType Directory -Force -Path $stateDir
        $counterFile = Join-Path $stateDir "$sessionId.count"
        if (Test-Path $counterFile) {
            $turn = ([Int](Get-Content $counterFile -TotalCount 1)) + 1
        }
        Set-Content -Path $counterFile -Value $turn
        Get-ChildItem $stateDir -Filter '*.count' |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
            Remove-Item -Force
    }
    catch {
        $turn = 1
    }

    # A global AGENTS.md is checked before the bundled copy because someone already keeping model
    # guidance there should not have to maintain a second copy. It is skipped rather than used when it
    # does not carry all three marker bullets, so an AGENTS.md written for anything else costs nothing.
    $candidatePaths = $RulesPath ? @($RulesPath) : @(
        $env:MODEL_PREFLIGHT_RULES
        (Join-Path $HOME '.agents/model-strategy.md')
        (Join-Path $HOME '.codex/AGENTS.md')
        (Join-Path $HOME '.claude/model-strategy.md')
        (Join-Path $PSScriptRoot '../skills/model-preflight/SKILL.md')
    ).Where({ $_ })

    $escalate = $null
    $downshift = $null
    $recheck = $null
    $tiers = $null
    $pause = $null
    foreach ($candidate in $candidatePaths) {
        try {
            $ruleLines = Get-Content $candidate
        }
        catch {
            Write-Debug "Could not read ${candidate}: $_"
            continue
        }
        $candidateEscalate = Get-TriggerLine -Lines $ruleLines -Marker 'Escalate'
        $candidateDownshift = Get-TriggerLine -Lines $ruleLines -Marker 'Downshift'
        $candidateRecheck = Get-TriggerLine -Lines $ruleLines -Marker 'Re-check'
        # All three or none. The preamble promises a strategy below it either way, so a file carrying
        # only some of the bullets injects one with no escalation or downshift in it that still reads
        # to the session as the whole policy.
        if (-not ($candidateEscalate -and $candidateDownshift -and $candidateRecheck)) {
            continue
        }
        $escalate = $candidateEscalate
        $downshift = $candidateDownshift
        $recheck = $candidateRecheck
        $tiers = Get-InstructionSection -Lines $ruleLines -Heading 'Tiers'
        $pause = Get-InstructionSection -Lines $ruleLines -Heading 'Pause'
        break
    }

    $missingNote = ''
    if (-not $recheck) {
        $missingNote = (
            "`n`nNOTE: no complete model strategy could be read from " + ($candidatePaths -join ', ') +
            '. A rules file has to carry all three of the Escalate, Downshift and Re-check bullets, ' +
            'and one carrying only some of them is skipped. The preflight is running without its ' +
            'trigger list. Tell the user, so the rules file gets restored or MODEL_PREFLIGHT_RULES ' +
            'is pointed somewhere valid.'
        )
    }

    if (($turn % 5) -eq 1) {
        $sections = @(
            @'
Before starting a new task, apply the model strategy below before any skill announcement, plan, or
tool call. A new task starts when a message introduces a goal, file, or scope not already in play.
Before your first tool call on a new task, state the verdict in one sentence in your reply: the
setting you are keeping or recommending, the single trigger closest to the task, and why it does or
does not apply. Silence is not a verdict. If a trigger applies, pause as described below.
'@
            $escalate ? "$escalate Pause even if you are confident the current model can handle it." : $null
            $downshift
            $recheck
            $tiers ? "## Tiers`n`n$tiers" : $null
            $pause ? "## Pause`n`n$pause" : $null
            @'
The check is not limited to the first action of a task. The Re-check bullet above names the moments
where a task has quietly become a different one. At each of them, run the check again and state the
verdict again, and if a trigger now matches, stop at the next safe boundary and pause before
continuing.
'@
        ).Where({ $_ })
        $additionalContext = (($sections -join "`n`n") + $missingNote)
    }
    else {
        $additionalContext = (
            @'
Model preflight: if this message starts a new task (a goal, file, or scope not already in play), or a
Re-check moment has occurred since the last verdict, state the verdict in one sentence in your reply:
the setting you are keeping or recommending, the closest trigger, and why it does or does not apply.
Silence is not a verdict. If a trigger applies, deliver the mandatory pause exactly as the model
strategy specifies; it overrides autonomy and continuation instructions, auto mode included.
'@ + ($recheck ? "`n`n$recheck" : '') + $missingNote
        )
    }

    @{
        hookSpecificOutput = @{
            hookEventName     = 'UserPromptSubmit'
            additionalContext = $additionalContext
        }
    } | ConvertTo-Json -Depth 3 -Compress
}
