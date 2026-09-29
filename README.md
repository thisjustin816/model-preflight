# Model Preflight

Checks the session model and effort against the task before work starts, says out loud which it
picked, and stops for you to switch when they do not match.

The problem it solves is quiet mismatch in both directions. A session left on a small model walks
into a security review or a cross-repo refactor and does it badly. A session left on a top-tier
model answers a status question and spends the quota anyway. Neither announces itself, and a check
that happens silently in the model's head is indistinguishable from one that never happened.

So the check is visible. Every new task gets one sentence naming the setting being kept or
recommended and the trigger closest to the task. When the setting is wrong, the session stops and
waits for you rather than proceeding on the assumption you would have agreed.

Works in Claude Code and Codex. Both call `UserPromptSubmit` the same way and read the same
response, so one hook script serves both.

## Requirements

PowerShell 7 on PATH as `pwsh`. Check with:

```powershell
pwsh -Version
```

Without it the hook cannot run, and the tool reports a failed hook command on every prompt. Install
it from <https://github.com/PowerShell/PowerShell> if the check above fails.

## Install

Claude Code:

```powershell
claude plugin marketplace add thisjustin816/model-preflight
claude plugin install model-preflight@thisjustin816
```

Codex:

```powershell
codex plugin marketplace add https://github.com/thisjustin816/model-preflight
codex plugin add model-preflight@thisjustin816
```

Start a new session afterward. A plugin installed mid-session does not load into it.

To update, run `claude plugin update model-preflight@thisjustin816`, or re-run the Codex add
command, which replaces the installed copy in place.

## What it reads and writes

The hook makes no network calls and sends nothing anywhere. On each prompt it:

- Reads the first rules file it finds in the order listed under
  [Changing what it recommends](#changing-what-it-recommends). That includes
  `$HOME/.codex/AGENTS.md`, which it uses only if that file carries all three marker bullets.
- Writes a one-line turn counter per session to `model-preflight/<session-id>.count` in the
  system temp directory, and deletes counters older than seven days. The counter drives the
  full-block and reminder cadence.
- Prints the injected text to stdout, where the tool reads it as additional context.

## How it differs from similar plugins

Several plugins route models from a `UserPromptSubmit` hook. The two nearest:

- [claude-model-router-hook](https://github.com/tzachbon/claude-model-router-hook) classifies
  prompts with regular expressions and warns, or optionally rewrites the model for the next
  session. It is Claude Code only and does not stop the turn.
- [model-picker](https://github.com/Tatendaz/model-picker) runs in both tools and suggests a model
  and effort, using a remote classifier that receives a snapshot of the prompt. It does not stop
  the turn either.

This plugin differs in three ways. The session model does the judging, against a policy you can
read and edit in markdown, so no prompt text leaves the machine. It states a verdict on every new
task, including when no switch is needed. And when a switch is warranted it ends the turn and waits
for your `y`, because a suggestion the model keeps working past arrives too late to matter.

## What it injects

On the first turn of a session and every fifth turn after, the full block: the trigger list, the
tier table, and the pause format. Between those, a short reminder carrying the Re-check line alone.

The cadence exists because the failure this guards against is not forgetting the rule at the start
of a session. It is a task growing into a different task around turn 12, long after the opening
instructions have scrolled out of attention. The reminder is small enough to repeat and carries the
part that matters mid-session.

## Changing what it recommends

The policy lives in [rules/model-strategy.md](rules/model-strategy.md), read at runtime. Edit that
file and the next turn uses it. Nothing needs rebuilding, and the script holds no copy.

The tier table there is one person's mapping of task shapes to models. Yours will differ. Rewrite
the `## Tiers` section and leave the rest, or rewrite all of it.

To drive the hook from a file of your own instead, set `MODEL_PREFLIGHT_RULES` to its path. The
full resolution order is:

1. `$env:MODEL_PREFLIGHT_RULES`
2. `$HOME/.agents/model-strategy.md`
3. `$HOME/.codex/AGENTS.md`
4. `$HOME/.claude/model-strategy.md`
5. the copy bundled with this plugin

The first file that actually carries all three marker bullets wins. A candidate carrying none of
them, or only some, is skipped rather than treated as a policy, so a global `AGENTS.md` written
for something else costs nothing. If you already keep model guidance in one of these, the plugin
picks it up with no configuration.

Three things in whatever file you point it at are a contract:

- The `## Tiers` heading.
- The `## Pause` heading.
- Bullets starting `- **Escalate**:`, `- **Downshift**:`, and `- **Re-check**:`.

Anything else in the file is ignored, which makes a wider instruction file usable as the source. A
file carrying the three bullets but no `## Tiers` section injects the triggers alone, and that is
the right result when your tier table already reaches the session another way, such as a global
instructions file the tool loads on its own.

Rename a heading and that section drops out. Reshape one of the three bullets and the file stops
qualifying at all, so the next candidate in the order is used instead. The hook appends a NOTE when
no candidate qualifies, so a rules file it cannot use reports itself rather than going quiet.

## Checking it works

Run the hook directly and read what it would inject:

```powershell
'{"session_id":"test"}' |
    pwsh -NoProfile -File ./scripts/Add-ModelPreflightContext.ps1 |
    ConvertFrom-Json |
    ForEach-Object { $_.hookSpecificOutput.additionalContext }
```

Point `-RulesPath` at a file that does not exist to confirm the NOTE appears. A check that cannot
fail proves nothing when it passes.

In a live session, the tell is a one-sentence verdict before the first tool call. No verdict means
the hook is not firing.

## Codex caveats

Two known issues, both worth checking rather than assuming:

Plugin-bundled hooks do not fire in every Codex version. Some builds execute only the global hooks
file. If no verdict appears in a Codex session after installing, add the hook to `~/.codex/hooks.json`
yourself, using the absolute path to the installed script:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "pwsh -NoProfile -File \"<plugin-path>/scripts/Add-ModelPreflightContext.ps1\""
          }
        ]
      }
    ]
  }
}
```

Codex also renders injected context as a visible developer message in some versions, so the block
may appear in your transcript rather than staying in the background. It is noisy, not broken.
