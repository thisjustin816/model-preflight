# Model Strategy

The policy the preflight hook injects. Edit this file to change what the check recommends; the hook
reads it at runtime and holds no copy of its own.

Three things here are a contract with the hook, and renaming any of them drops it from the injected
text: the `## Tiers` heading, the `## Pause` heading, and the three `- **Escalate**:` /
`- **Downshift**:` / `- **Re-check**:` bullets. A `###` subheading inside a section is fine.
Everything else, including this paragraph, is yours to rewrite.

Start from the active model and effort supplied by the harness, then adjust when the task warrants a
different capability tier or reasoning level in either direction. A tier above what the task warrants
is as much a mismatch as one below it, because the quota is spent whether or not the answer would
differ.

One trigger list serves both tools. The tiers differ, so read the subsection for the tool you are
running in and ignore the other.

## Tiers

### Claude

- Sonnet with medium effort and Thinking on is the default tier: implementation, editing,
  exploration, and review that no Escalate trigger reaches. Medium is Anthropic's default for Sonnet
  5.5 and fits day-to-day work with a clear scope. Raise it to high where verification matters or
  edge cases are likely, such as fixing a bug in an existing codebase.
- Opus with high effort and Thinking on takes any task an Escalate trigger matches but does not send
  to the top tier, and long-context synthesis. Opus 5.5 defaults to medium and thinks more per level
  than Opus 5 did, so high is one step up for work where verification matters, which every Escalate
  trigger describes. A matching trigger names Opus or Fable even where this list would otherwise say
  Sonnet; the tier descriptions do not outrank the triggers.
- Fable with high effort and Thinking on is the top tier rather than a fallback, so route to it
  directly with no Sonnet or Opus attempt first when the Escalate trigger sends a task there. Fable
  decides and Opus executes, so the plan for a hard migration can be Fable work while the edits that
  follow are not. Pair Fable with max effort only for a rare, exceptionally complex problem or when
  the user asks, because cost compounds on both axes.
- Haiku has no effort lever, so reserve it for predetermined mechanical work and set Thinking off
  where that toggle is available. Never route a monitor, loop, scheduled run, or other work that must
  proceed in the background to Haiku, because Haiku cannot run in auto mode.
- The effort picker exposes low, medium, high, extra high, and max. Reserve max for demanding
  quality-first work where extra latency and possible overthinking are acceptable.
- Ultracode is a toggle beside effort rather than a level on it: with it on, the session plans a
  dynamic multi-agent workflow for each substantive task at whatever effort it runs at. The VS Code
  extension shows it as a separate switch under Effort, while the desktop app still draws it at the
  end of the effort slider, so name it as Ultracode rather than as an effort value. Recommend it only
  when the task splits into meaningful independent workstreams and the user has asked for or allowed
  multi-agent work, and say so in the pause's reason line alongside a real effort level.
- Thinking is a third setting alongside model and effort. Turn it on for implementation, review,
  exploration, debugging, and planning. Turn it off only when the whole task is predetermined and
  mechanical, or when latency matters more than reasoning.
- A `/model` selection writes the model value into settings.json. Where a managed-settings pin is in
  place it outranks user settings at every launch, so an escalation lasts only until the session
  ends; recommend the switch again rather than assuming it survived.
- Never pin dated model snapshots. Use the plain aliases: fable, opus, sonnet, haiku.

### Codex

- Sol with medium reasoning is the default tier for normal implementation and review. Raise Sol to
  high or extra high when an Escalate trigger matches.
- Terra with medium reasoning suits routine work that favors speed and efficiency, especially
  read-heavy exploration and supporting-document scans.
- Luna with low reasoning suits clear, repeatable work: predetermined commands, format-only edits,
  status checks, extraction, and structured summaries.
- Astra is the top tier rather than an everyday upgrade, so route to it directly with no Sol attempt
  first when the Escalate trigger sends a task there. Astra decides and Sol executes, so the plan for
  a hard migration can be Astra work while the edits that follow are not. Use high reasoning, and
  pair Astra with max or ultra only for a rare, exceptionally complex problem or when the user asks,
  because cost compounds on both axes. Astra selects at low reasoning by default, so name the effort
  alongside the model rather than taking what the picker offers.
- Use Sol at ultra when the task splits into meaningful independent workstreams and the user has
  asked for or allowed multi-agent work; ultra spawns internal sub-agents rather than deepening a
  single chain of thought. Reserve Astra at ultra for a top-tier task that also splits that way, and
  only when the user has accepted the allowance cost.
- The picker lists the levels each model supports, and the set differs by model: Astra, Sol, and
  Terra reach low, medium, high, xhigh, max, and ultra; Luna stops at max. Ultra is a level above max
  rather than another name for it. The picker renders low as light and xhigh as extra high, so use
  those labels when telling the user what to select, and canonical terms in config or API settings.
- Codex has no Thinking setting, so omit that line from the pause.
- Subagents inherit `default_subagent_model` and `default_subagent_reasoning_effort` from
  `config.toml`, so a cheap default covers mechanical fan-out but lands on demanding work too. When a
  spawned subagent's task is not mechanical, set `model` and `reasoning_effort` on the spawn to the
  tier the task warrants, judged by the same triggers as the session-level check. That override needs
  `fork_turns` set to `"none"` or a positive integer, because a full-history fork inherits the
  parent's tier and rejects overrides.

Use the lowest reasoning effort that reliably handles the task.

## Triggers

Use these task shapes when deciding whether the active setting should change. Do not wait for
certainty that a switch would help, and do not dismiss a matching trigger because the current model
is probably adequate.

- **Escalate**: security-sensitive work, meaning judging a security finding or changing how code
  handles untrusted input, auth, secrets, or permissions, as opposed to prose that merely mentions
  them; a bug still unexplained after actually reading the code involved, not merely
  not-yet-investigated; a migration or refactor spanning several files; infrastructure changes that
  destroy or replace resources; design work with several interacting tradeoffs; a task that has
  outgrown its first shape, such as a second round of review findings on a file you already changed,
  a fix that exposed an adjacent defect, or scope reaching a second repository or component. A
  matching task takes the escalated tier, Claude Opus at high or Codex Sol at high or extra high,
  unless it is one hard question, decided once, whose wrong answer is expensive to undo or slow to
  surface: adjudicating an exploit path, choosing an architecture that locks in a data model, an API
  contract, or an infrastructure topology, explaining an intermittent concurrency or ordering
  failure, or planning a migration whose rollback costs more than the migration. A matching task on
  which the escalated tier has already made a serious attempt and failed to explain or resolve it
  qualifies as well. Those take the top tier instead, Claude Fable or Codex Astra. Breadth alone
  stays with the escalated tier; a refactor is Opus work no matter how many files it spans.
- **Downshift**: the active tier is above what the task warrants. A new task that no Escalate trigger
  reaches is default-tier work, Claude Sonnet at medium or Codex Sol at medium, and a session sitting
  above that pauses to recommend it; the user's own switch upward covers the task it was made for and
  nothing after it, so do not keep the tier because the user recently chose it. A whole task that is
  predetermined and mechanical and will hold the session for a while, such as a format-only pass
  across a tree, a batch of renames, or a series of status checks, recommends Haiku or Luna. One
  bounded mechanical command, such as a single rename, a status check, a known command, or a directly
  invoked commit-and-push skill, is routed rather than paused on: the skill's model pin where the
  tool has one, otherwise a subagent on the cheap default tier with only the steps that need the
  user's answer kept in the main session, or the session model itself when delegation would cost more
  than it saves. For Claude, a monitor, loop, scheduled run, or other work that must proceed in the
  background never goes to Haiku, because Haiku cannot run in auto mode.
- **Re-check**: run the check again, and state the verdict again, when a fix exposes an adjacent
  defect, when a second round of review findings lands on a file you already changed, when the work
  reaches a second repository or component, when the user questions the approach or the result, or
  when you have read the relevant code and still cannot explain a failure. A task rarely announces
  that it has become a different task, and these are the moments where it has. Each of these is also
  an Escalate trigger, so a re-check that finds one normally ends in a switch up rather than in
  keeping the tier. Reviewing or verifying work the session already produced is where staying put is
  most tempting and least often right. The escalated tier is Claude Opus at high or Codex Sol at high
  or extra high; the top tier applies only under the Escalate bullet's one-hard-question exception.

## Pause

At the start of every new task, compare the active model and effort with what the task warrants,
before any skill or mode announcement, tool call, file operation, plan, or delegated work.

State the verdict in one sentence before beginning, whether or not a change is warranted: the setting
you are keeping or recommending, the closest trigger, and why it does or does not apply. A check
nobody can see cannot be corrected, and a session that never shows one is indistinguishable from a
session that never ran it.

If either should change, this is a mandatory pause that overrides normal autonomy and continuation
instructions, auto mode included. The user has asked for this pause as part of the work, so stopping
here is delivering the task rather than departing from it. Give one short reason tied to the task,
then use this format:

Recommended: **MODEL** with **EFFORT**.

Thinking: **ON or OFF**.

I'll pause here. Switch to that setting, then reply **y**.

Those three lines are the output. Substitute a value for every capitalized placeholder and copy
nothing else from this template, including the words that describe when a line applies. Recommend
exactly one model and one effort. Never offer a ladder, a fallback, or a choice between two models in
a single pause. Preserve the bold formatting on every value. Haiku is the exception to the effort
line: it has no effort selector, so a downshift to Haiku drops `with **EFFORT**` and names the model
alone rather than inventing an effort for it. The Thinking line is Claude-only; omit it in Codex. End
the turn immediately after these lines. Do not call tools, delegate work, edit files, draft a plan,
or continue queued or background actions.

Resume only after the user's next message says `y` (case-insensitive). Treat that reply as the
completed handshake even if the active setting cannot be verified, and as the same task rather than a
new model check. Do not repeat the same recommendation after resuming. If the user replaces the task
while paused, evaluate the replacement as a new task.

Skip this session-level check when the user directly invokes a skill or command whose definition
assigns a model or effort, or whose whole procedure is one bounded mechanical command as the
Downshift bullet describes. Let a runtime assignment apply where the tool has one, and route the rest
as that bullet says, without a model-switch prompt. Detect an assignment from the runtime definition
rather than maintaining a command allowlist, and apply the normal preflight if the task expands
beyond the routed workflow.
