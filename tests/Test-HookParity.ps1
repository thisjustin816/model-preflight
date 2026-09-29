#Requires -Version 7.0

<#
.SYNOPSIS
    Checks that the PowerShell hook and its POSIX port inject the same context.

.DESCRIPTION
    Runs both hook scripts against the same rules files and compares the decoded additionalContext
    of each, for the full block on a session's first turn and the short reminder on its second. The
    cases cover the bundled skill, a copy of it with CRLF line endings, a file carrying only two of
    the three marker bullets, and a missing file, which must produce the NOTE.

    Throws when any case differs, naming the case and the first character where the outputs part.

.PARAMETER ShPath
    The sh executable to run the port with. Defaults to sh on PATH, then to the one Git for Windows
    installs, since Windows rarely has sh on PATH.

.PARAMETER ShScriptPath
    The POSIX script to test. Defaults to the one in this repository; pointing it at a modified copy
    is how to confirm the test can fail.

.EXAMPLE
    ./tests/Test-HookParity.ps1
#>

[CmdletBinding()]
param(
    [String]$ShPath,

    [String]$ShScriptPath = (Join-Path $PSScriptRoot '../scripts/add-model-preflight-context.sh')
)

begin {
    $ErrorActionPreference = 'Stop'

    function Get-HookContext {
        <#
        .SYNOPSIS
        Internal: run one hook script for one turn and return its decoded additionalContext. A script
        ending in .ps1 runs under pwsh; anything else runs under the sh at Shell.
        #>
        param(
            [String]$ScriptPath,
            [String]$Shell,
            [String]$SessionId,
            [String]$RulesPath
        )
        $hookInput = @{ session_id = $SessionId } | ConvertTo-Json -Compress
        $output = if ($ScriptPath.EndsWith('.ps1')) {
            $hookInput | pwsh -NoProfile -File $ScriptPath -RulesPath $RulesPath
        }
        else {
            $hookInput | & $Shell $ScriptPath $RulesPath
        }
        if ($LASTEXITCODE -ne 0) {
            throw "$ScriptPath exited with code $LASTEXITCODE for $RulesPath."
        }
        ($output | ConvertFrom-Json).hookSpecificOutput.additionalContext
    }
}

process {
    $repoRoot = Join-Path $PSScriptRoot '..'
    $pwshScript = Join-Path $repoRoot 'scripts/Add-ModelPreflightContext.ps1'
    $skillPath = Join-Path $repoRoot 'skills/model-preflight/SKILL.md'

    if (-not $ShPath) {
        $ShPath = (Get-Command sh -ErrorAction SilentlyContinue)?.Source
    }
    if (-not $ShPath -and $IsWindows) {
        $gitCommand = (Get-Command git -ErrorAction SilentlyContinue)?.Source
        if ($gitCommand) {
            $ShPath = Join-Path (Split-Path (Split-Path $gitCommand)) 'usr/bin/sh.exe'
        }
    }
    if (-not $ShPath -or -not (Test-Path $ShPath)) {
        throw 'No sh found. Pass -ShPath, or install Git for Windows on Windows.'
    }

    # GetTempPath takes no path argument, so the provider-path trap does not apply to it.
    $fixtureDir = New-Item -ItemType Directory -Path (
        Join-Path ([System.IO.Path]::GetTempPath()) "model-preflight-parity-$(New-Guid)"
    )

    # Git for Windows keeps awk, sed, and the rest beside its sh but off PATH, so the port finds none
    # of them unless that directory leads PATH, as it does inside Git Bash.
    $originalPath = $env:PATH
    $env:PATH = ((Split-Path $ShPath) + [System.IO.Path]::PathSeparator + $env:PATH)

    try {
        $crlfPath = Join-Path $fixtureDir.FullName 'crlf.md'
        Set-Content -Path $crlfPath -NoNewline -Value (
            (Get-Content -Path $skillPath) -join "`r`n"
        )

        $partialPath = Join-Path $fixtureDir.FullName 'partial.md'
        Set-Content -Path $partialPath -Value (
            Get-Content -Path $skillPath | Where-Object { $_ -notmatch '^\s*-\s\*\*Downshift\*\*:' }
        )

        # Forward slashes, so both implementations receive, and echo into any NOTE, the same string.
        $cases = [ordered]@{
            'bundled skill'    = $skillPath
            'CRLF line ending' = $crlfPath
            'partial bullets'  = $partialPath
            'missing file'     = Join-Path $fixtureDir.FullName 'missing.md'
        }

        $failures = foreach ($case in $cases.GetEnumerator()) {
            $rulesPath = $case.Value -replace '\\', '/'
            $sessionIds = @{ pwsh = "parity-$(New-Guid)"; sh = "parity-$(New-Guid)" }
            foreach ($turn in 1, 2) {
                $pwshContext = Get-HookContext `
                    -ScriptPath $pwshScript `
                    -SessionId $sessionIds.pwsh `
                    -RulesPath $rulesPath
                $shContext = Get-HookContext `
                    -ScriptPath $ShScriptPath `
                    -Shell $ShPath `
                    -SessionId $sessionIds.sh `
                    -RulesPath $rulesPath
                $label = "$($case.Key), turn $turn"
                if ($pwshContext -ceq $shContext) {
                    Write-Host "Pass: $label"
                    continue
                }
                $index = 0
                while ($index -lt [Math]::Min($pwshContext.Length, $shContext.Length) -and
                    $pwshContext[$index] -ceq $shContext[$index]) {
                    $index++
                }
                "$label differs at character $index (pwsh $($pwshContext.Length) chars, sh $($shContext.Length))"
            }
        }
    }
    finally {
        $env:PATH = $originalPath
        Remove-Item -Recurse -Force -Path $fixtureDir.FullName
    }

    if ($failures) {
        throw ("Hook outputs differ:`n" + ($failures -join "`n"))
    }
}
