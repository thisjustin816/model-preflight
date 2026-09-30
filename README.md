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

## Where it runs

The plugin carries the policy two ways: a `UserPromptSubmit` hook that injects it into every turn,
and a skill holding the same text for surfaces that do not run hooks.

| Surface | What loads | How reliable |
| :- | :- | :- |
| Claude Code | Hook and skill | Every turn, from the hook |
| Codex | Hook and skill | Every turn, once you trust the hook (see [Codex caveats](#codex-caveats)) |
| Cowork | Hook and skill | Every turn where the hook's shell tools exist; the skill otherwise |
| claude.ai chat | Skill only | Best effort: Claude applies a skill when it judges one relevant, so a task can start without the check |

In chat and Cowork the pause names the model menu and its effort or extended thinking control,
since there is no `/model` command there.

The triggers cover everyday chat as well as code. Summaries, drafting, explanations, and everyday
advice stay on the default tier. Medical, legal, financial, or safety questions, research that has
to reconcile conflicting sources, and synthesis across long documents escalate. Quick facts and
reformatting suit the smallest model.

## Requirements

The hook runs on either of two runtimes and needs one of them:

- PowerShell 7 on PATH as `pwsh`, which it prefers.
- A POSIX `sh` with `awk`, `sed`, and `find`, which it falls back to when `pwsh` is missing. macOS,
  Linux, and Git Bash on Windows all have these.

The hook command is `pwsh ... || sh ...`, which parses the same in bash, PowerShell 7, and
`cmd.exe`, so it works whichever shell the tool launches hooks with. With neither runtime present,
the tool reports a failed hook command on every prompt. The skill needs nothing.

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

The skill is instructions only and runs nothing.

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

The policy lives in [skills/model-preflight/SKILL.md](skills/model-preflight/SKILL.md), which is
both the skill and the file the hook reads at runtime. Edit it and the next turn uses it. Nothing
needs rebuilding, and neither hook script holds a copy.

The tier table there is one person's mapping of task shapes to models. Yours will differ. Rewrite
the `## Tiers` section and leave the rest, or rewrite all of it.

To drive the hook from a file of your own instead, set `MODEL_PREFLIGHT_RULES` to its path. The
full resolution order is:

1. `$MODEL_PREFLIGHT_RULES`
2. `$HOME/.agents/model-strategy.md`
3. `$HOME/.codex/AGENTS.md`
4. `$HOME/.claude/model-strategy.md`
5. the skill bundled with this plugin

The first file that actually carries all three marker bullets wins. A candidate carrying none of
them, or only some, is skipped rather than treated as a policy, so a global `AGENTS.md` written
for something else costs nothing. If you already keep model guidance in one of these, the plugin
picks it up with no configuration. The skill always carries the bundled policy, so on surfaces
where only the skill loads, your own file does not reach the session.

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

The POSIX port takes the same input, with the rules file as an optional first argument:

```sh
echo '{"session_id":"test"}' | sh ./scripts/add-model-preflight-context.sh
```

Point either at a rules file that does not exist to confirm the NOTE appears. A check that cannot
fail proves nothing when it passes.

`tests/Test-HookParity.ps1` runs both scripts against the same inputs and fails if their injected
text differs by a character. CI runs it on Linux, macOS, and Windows.

In a live session, the tell is a one-sentence verdict before the first tool call. No verdict means
the hook is not firing.

## Codex caveats

Codex skips a plugin's hooks until you review and trust the current hook definition, and a new
plugin version counts as a new definition. After installing or updating, review and trust the hook
in Codex, or no verdict will appear. Codex still reads the skill, but only when it judges it
relevant.

Some Codex builds run only the global hooks file and ignore plugin hooks. If no verdict appears
after trusting, add the hook to `~/.codex/hooks.json` yourself, using the absolute path to the
installed plugin:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "pwsh -NoProfile -File \"<plugin-path>/scripts/Add-ModelPreflightContext.ps1\" || sh \"<plugin-path>/scripts/add-model-preflight-context.sh\"",
            "statusMessage": "Checking model fit"
          }
        ]
      }
    ]
  }
}
```

Codex also renders injected context as a visible developer message in some versions, so the block
may appear in your transcript rather than staying in the background. It is noisy, not broken.
