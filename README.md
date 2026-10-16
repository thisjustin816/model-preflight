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

The plugin carries the policy two ways: a `UserPromptSubmit` hook on hosts that can run it,
and a skill holding the same policy for other surfaces.

The policy has separate routes for Claude, OpenAI agent surfaces (Codex and ChatGPT Work), and
ordinary ChatGPT Chat. Work shares the agent tier mapping and uses its native GUI controls. Chat
uses only choices established in its own picker; it does not inherit Sol or Luna recommendations.
If a concrete Chat recommendation needs unknown picker details, preflight asks once and waits
before task work. Once a supported choice is known, the usual single-choice switch pause applies.

| Surface | Policy carrier | Delivery limits |
| :- | :- | :- |
| Claude Code | Plugin hook and skill | Hook needs the scripts and shell prerequisites in its execution environment |
| Claude Cowork | Plugin hook and skill | Hook needs those same prerequisites; use the skill where they are absent |
| Claude chat on web or Desktop | Plugin skill | Plugin hooks and subagents do not run in chat |
| Local Codex CLI or desktop | Trusted plugin hook and skill | Both orchestration and execution must support local hooks |
| Local ChatGPT Work | Trusted plugin hook and skill | Requires local orchestration, available scripts, and shell prerequisites |
| Hosted or cloud-orchestrated Work | Plugin skill | Plugin command hooks do not run, even when tools execute locally |
| ChatGPT Chat | Plugin skill | Work/Codex command-hook assumptions do not apply |
| Codex IDE extension | Separately installed filesystem skill | Plugins are unsupported; marketplace installation does not install this fallback |

These are carrier capabilities, not a guarantee that the model follows the instructions. A skill
can be selected explicitly; automatic relevance selection can miss it. A hook can deliver context
that the model fails to apply. Provider references: [Claude plugins](https://support.claude.com/en/articles/13837440-use-plugins-in-claude),
[OpenAI plugin surfaces](https://learn.chatgpt.com/docs/plugins), and
[cloud hook limits](https://learn.chatgpt.com/docs/hooks).

In Claude chat and Cowork the pause names the native model menu and the effort or extended thinking
controls it exposes, since there is no `/model` command there. OpenAI GUI routes use their native
controls. Each route omits controls that the selected model fixes or does not offer.

The triggers cover everyday chat as well as code. Summaries, drafting, explanations, and everyday
advice stay on the default tier. Medical, legal, financial, or safety questions, research that has
to reconcile conflicting sources, and synthesis across long documents escalate. Quick facts and
reformatting suit the smallest model.

## Requirements

The hook runs on either of two runtimes and needs one of them:

- PowerShell 7 on PATH as `pwsh`, which it prefers.
- A POSIX `sh` with standard utilities including `awk`, `sed`, `find`, and `wc`, which it falls back
  to when `pwsh` is missing.
  Python 3 decodes picker metadata on this path; without it the policy still loads and reports
  the current settings as unknown. The PowerShell implementation needs no Python dependency.

The hook command is `pwsh ... || sh ...`, which parses the same in bash, PowerShell 7, and
`cmd.exe`, so it works whichever shell the tool launches hooks with. With neither runtime present,
the tool reports a failed hook command on every prompt. The skill needs nothing.

## Install

### Claude Code

```powershell
claude plugin marketplace add thisjustin816/model-preflight
claude plugin install model-preflight@thisjustin816
```

### Local Codex CLI or desktop

```powershell
codex plugin marketplace add https://github.com/thisjustin816/model-preflight
codex plugin add model-preflight@thisjustin816
```

The CLI also provides a `/plugins` browser. Start a new local session after installing or updating
so it loads the intended plugin version, then review and trust its hook where required.

To update, run `claude plugin update model-preflight@thisjustin816`, or re-run the Codex add
command, which replaces the installed copy in place.

### Claude chat and Cowork

Open Customize, then Plugins. Add this repository as a marketplace using
`https://github.com/thisjustin816/model-preflight`, and install Model Preflight from it. Account
plugins follow the signed-in account; supported Claude Code versions can sync them at startup.
API-key and cloud-provider sessions use their own installation path. Select the skill through
the `/` or `+` menu in chat or Cowork when you want to ensure it is loaded. See the
[Claude installation guide](https://support.claude.com/en/articles/13837440-use-plugins-in-claude)
for account, client-version, and organization restrictions.

### ChatGPT Chat and Work

Use the native Plugins tab to install an entry available to your account or workspace, start a
new chat, and select Model Preflight's skill with `@` or ask to use it. This repository's local
marketplace commands do not publish it to the universal directory or install it into a hosted
workspace. Repository-marketplace distribution varies by surface; use the source your workspace
or account exposes. See the [plugin installation guide](https://learn.chatgpt.com/docs/plugins)
and [packaging and distribution guide](https://developers.openai.com/plugins/build/plugins).

Web installation does not place shell scripts in an execution environment. Hosted Work uses the
skill for this plugin's preflight; a web install cannot enable its command hook. See the
[script deployment and trust requirements](https://developers.openai.com/plugins/build/plugins)
and [cloud-orchestration restrictions](https://learn.chatgpt.com/docs/hooks).

The IDE extension needs a separately installed filesystem skill to use this policy. Follow its
[skill discovery instructions](https://learn.chatgpt.com/docs/build-skills); plugin support
in the CLI or desktop app does not establish plugin support in the IDE.

## Releases

The Claude and Codex plugin manifests carry the same `MAJOR.MINOR.PATCH` version. Versions follow
[Semantic Versioning](https://semver.org/); the `0.x` series is still in initial development. A
release is an annotated `vMAJOR.MINOR.PATCH` tag on the tested `main` commit. Published tags do not
move.

For each release, update both manifests in the pull request and run
`python scripts/check_release_version.py` with the test suite. After the change reaches `main`,
tag that commit and push the tag:

```sh
git tag -a vX.Y.Z -m "Model Preflight X.Y.Z"
git push origin vX.Y.Z
```

Replace `X.Y.Z` with the version in the manifests. The tag is created only after the pull request
is merged, so it points to the commit users install.

The tag build checks that its name matches both manifests. Marketplace entries that pin a commit
can move to the tagged commit after its changes are reviewed.

## What it reads and writes

Every hook invocation includes a current-settings header, including the short reminder turns.
The hook accepts top-level `model` and `reasoning_effort` fields when the host supplies them.
Codex can also supply `transcript_path`, `session_id`, and `turn_id`. When effort is missing,
the reader can recover it from a Codex `turn_context` record only when the session ID and exact
turn ID match, and the recorded model agrees with any model supplied by the hook. It can also
recover a missing model while reading that matching record. It never takes an earlier turn's
setting or a local CLI default. Missing, unreadable, or unmatched metadata is reported as unknown.

Claude Code's `UserPromptSubmit` schema does not supply the same active model and effort fields.
Its model field belongs to `SessionStart`, while its effort object is documented for tool-context
events. This plugin does not track those events or reconstruct current Claude picker settings
from earlier session records. A Claude prompt can therefore load preflight successfully while
its header reports unknown model and effort. See the [Claude hook input contract](https://code.claude.com/docs/en/hooks).
On a surface that only loads the skill, no hook metadata header is produced. Unknown metadata
does not establish a mismatch or prove which models are selectable.

Only model and effort are injected; transcript messages and credentials are not printed. This
requires a host that actually runs the hook. Loading the policy through AGENTS.md alone cannot
produce picker metadata. A recommendation to change model or effort ends the turn and waits for
the user's `y`; injection does not change the picker automatically.

The hook does not enumerate available models. The Work/Codex policy prefers GPT-6.1 Sol only
when the host reports it as active or the user confirms it is selectable in their current account,
workspace, and surface's native picker. Unknown or unavailable 6.1 access uses GPT-6 Sol, without
repeated availability prompts. A release announcement, configured default, or cached model catalog
does not establish access. Confirmation expires when the account, workspace, or surface changes,
or the user reports losing access; subagent access must be established for that runtime too.

The hook makes no network calls and sends nothing anywhere. On each prompt it:

- Reads current model metadata from hook input and, when necessary, only the matching turn's
  settings from the host-provided transcript.

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

On the first turn of a session and every fifth turn after, the hook prepares the trigger list, tier
table, and pause format. Between those, it prepares a short reminder carrying the Re-check line.
Every message, including its metadata, is limited to 2,000 UTF-8 bytes to stay below host output
limits even for multibyte text.

When the prepared message exceeds that budget, the hook sends the selected policy's absolute path
and explicitly directs the model to read it before the verdict or other work. That policy read is
the only bootstrap exception to the rule requiring a verdict before tool calls. The model applies
only the three trigger bullets and the `## Tiers` and `## Pause` sections. If it cannot read the
file, it reports that preflight could not load. A path too long to fit produces a bounded failure
note; missing-policy diagnostics are also kept within the budget.

The cadence exists because the failure this guards against is not forgetting the rule at the start
of a session. It is a task growing into a different task around turn 12, long after the opening
instructions have scrolled out of attention. The reminder is small enough to repeat and carries the
part that matters mid-session.

## Changing what it recommends

To refresh recommendations from current model information, follow the
[model policy maintenance procedure](docs/model-policy-maintenance.md). Use it for each model
release or control change that could affect the policy, and when asked to review the latest
guidance. It covers both vendors, separates product availability from account access, and records
why each switching criterion changes or stays the same.

The policy lives in [skills/model-preflight/SKILL.md](skills/model-preflight/SKILL.md), which is
both the skill and the file the hook reads at runtime. Edit it and the next turn uses it. Nothing
needs rebuilding, and neither hook script holds a copy.

The tier table there is one person's mapping of task shapes to models. Yours will differ. Rewrite
the `## Tiers` section and leave the rest, or rewrite all of it.

In Work and Codex, when access is established, GPT-6.1 Sol is preferred within the Sol tier for
repeated, long-running work across code, apps, and documents. Code cleanup, flaky-test fixes, and
CI improvements are useful examples. Medium remains the starting effort for normal work; existing escalation triggers raise
it to high or extra high, and the top-tier cases still use Astra. An existing 6 Sol session can
finish a small task when switching would cost more than it saves. See the official
[model guidance](https://learn.chatgpt.com/docs/models?surface=web) and
[software maintenance examples](https://developers.openai.com/blog/maintaining-software-with-the-gpt-6-family).
Use the effort levels exposed by the current Work or Codex picker; API controls can differ.

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

In a live session, look for a one-sentence verdict before task work, or the Chat route's picker
question when a concrete recommendation needs it. On hook-enabled surfaces, confirm in the host's
hook diagnostics that the enabled, trusted hook ran and delivered its context. An oversized policy
reference also requires the model to read the selected file before the verdict.

If context arrived but the model omitted preflight, delivery worked and compliance failed. If
the hook did not run, check registration, trust, execution support, and shell prerequisites. On
skill-only surfaces, select the skill explicitly and confirm it loaded. A visible verdict alone
does not prove a hook ran, and a missing verdict alone does not identify the failure.

## Codex caveats

On supported local Codex hosts, plugin hooks need trust for their current definition. After an
install or update, check registration and trust before relying on hook delivery. The skill can
still produce a verdict without the hook. See the [hook trust contract](https://developers.openai.com/plugins/build/plugins).

For a local Codex build confirmed to read only the global hooks file and ignore plugin hooks,
register the hook in `~/.codex/hooks.json` using the absolute path to the installed plugin:

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
