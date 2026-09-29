---
name: model-preflight
description: Check whether the selected model and effort fit the task before starting it, state a one-sentence verdict, and pause for the user to switch when they do not. Use at the start of every new task or question, coding or not, including summarizing a web page or document, research, drafting, everyday advice, and medical, legal, or financial questions. Use it again when a task grows into a different one, such as a question whose stakes rise, a second repository, or a failure still unexplained after reading the code. Applies in claude.ai chat, Cowork, Claude Code, and Codex. Skip it when a model preflight block from this plugin's hook is already in the turn's context, because the hook carries this same policy.
---

# Model Preflight

Before each new task or question, check whether the active model and effort fit it, say in one
sentence which setting you are keeping or recommending, and stop for the user to switch when they do
not fit. Pause says how to run the check, Triggers says what moves the setting, and Tiers maps the
result to a model on the surface you are running in.

This skill carries the same policy the plugin's hook injects in Claude Code, Codex, and Cowork. In
claude.ai chat, where plugin hooks do not run, it is the only carrier, so run the check yourself at
each new task and at each Re-check moment. Where the hook's block is already in the turn, follow
that and skip this.

A tier above what the task warrants is as much a mismatch as one below it, because the quota is
spent whether or not the answer would differ.

## Pause

At the start of every new task, compare the active model and effort with what the task warrants,
before answering and before any skill or mode announcement, tool call, file operation, plan, or
delegated work.

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
the turn immediately after these lines. Do not answer the question, call tools, delegate work, edit
files, draft a plan, or continue queued or background actions.

Resume only after the user's next message says `y` (case-insensitive). Treat that reply as the
completed handshake even if the active setting cannot be verified, and as the same task rather than a
new model check. Do not repeat the same recommendation after resuming. If the user replaces the task
while paused, evaluate the replacement as a new task.

In Claude Code and Codex, skip this session-level check when the user directly invokes a skill or
command whose definition assigns a model or effort, or whose whole procedure is one bounded
mechanical command as the Downshift bullet describes. Let a runtime assignment apply where the tool
has one, and route the rest as that bullet says, without a model-switch prompt. Detect an assignment
from the runtime definition rather than maintaining a command allowlist, and apply the normal
preflight if the task expands beyond the routed workflow.

## Triggers

Use these task shapes when deciding whether the active setting should change. Do not wait for
certainty that a switch would help, and do not dismiss a matching trigger because the current model
is probably adequate.

- **Escalate**: in code, security-sensitive work, meaning judging a security finding or changing how
  code handles untrusted input, auth, secrets, or permissions, as opposed to prose that merely
  mentions them; a bug still unexplained after actually reading the code involved, not merely
  not-yet-investigated; a migration or refactor spanning several files; and infrastructure changes
  that destroy or replace resources. Outside code, advice with real medical, legal, financial, or
  safety consequences, such as reading symptoms, test results, a prescription, a contract, or a tax
  question; research that has to reconcile many sources or conflicting evidence; and synthesis
  across a long document or several documents. Anywhere, design or decision work with several
  interacting tradeoffs, and a task that has outgrown its first shape, such as a second round of
  review findings on a file you already changed, a fix that exposed an adjacent defect, scope
  reaching a second repository or component, or a general question turning into one about the
  user's own health, money, or legal position. A matching task takes the escalated tier, Claude Opus
  at high or Codex Sol at high or extra high, unless it is one hard question, decided once, whose
  wrong answer is expensive to undo or slow to surface: adjudicating an exploit path, choosing an
  architecture that locks in a data model, an API contract, or an infrastructure topology,
  explaining an intermittent concurrency or ordering failure, planning a migration whose rollback
  costs more than the migration, or settling a major medical, legal, or financial decision that is
  hard to reverse. A matching task on which the escalated tier has already made a serious attempt
  and failed to explain or resolve it qualifies as well. Those take the top tier instead, Claude
  Fable or Codex Astra. Breadth alone stays with the escalated tier; a refactor is Opus work no
  matter how many files it spans.
- **Downshift**: the active tier is above what the task warrants. A new task that no Escalate trigger
  reaches is default-tier work, Claude Sonnet at medium or Codex Sol at medium: in code, everyday
  implementation, editing, and review; outside code, explanations, drafting, everyday advice, and
  summarizing a web page or an ordinary document. A session sitting above that pauses to recommend
  it; the user's own switch upward covers the task it was made for and nothing after it, so do not
  keep the tier because the user recently chose it. A whole task that is predetermined and
  mechanical and will hold the session for a while, such as a format-only pass across a tree, a
  batch of renames, a series of status checks, or a run of quick facts, lookups, or reformatting,
  recommends Haiku or Luna. One bounded mechanical command, such as a single rename, a status check,
  a known command, a directly invoked commit-and-push skill, or a single quick fact, is routed
  rather than paused on: the skill's model pin where the tool has one, otherwise a subagent on the
  cheap default tier with only the steps that need the user's answer kept in the main session, or
  the session model itself when delegation would cost more than it saves, which in chat is always.
  In Claude Code, a monitor, loop, scheduled run, or other work that must proceed in the background
  never goes to Haiku, because Haiku cannot run in auto mode.
- **Re-check**: run the check again, and state the verdict again, when a fix exposes an adjacent
  defect, when a second round of review findings lands on a file you already changed, when the work
  reaches a second repository or component, when a general question turns into one about the user's
  own health, money, or legal position, when the user questions the approach or the result, or when
  you have investigated a failure and still cannot explain it. A task rarely announces that it has
  become a different task, and these are the moments where it has. Each of these is also an Escalate
  trigger, so a re-check that finds one normally ends in a switch up rather than in keeping the
  tier. Reviewing or verifying work the session already produced is where staying put is most
  tempting and least often right. The escalated tier is Claude Opus at high or Codex Sol at high or
  extra high; the top tier applies only under the Escalate bullet's one-hard-question exception.

## Tiers

Read the subsection for the tool you are running in and ignore the other. Claude covers Claude
Code, Cowork, and claude.ai chat; Codex covers the Codex CLI and app. A matching trigger outranks
the descriptions here, so a task a trigger sends to Opus or Fable goes there even where a tier below
names it as an example.

### Claude

- **Haiku**: quick facts, simple lookups, reformatting text, and predetermined mechanical work. It
  has no effort lever, so the pause names the model alone, and Thinking goes off.
- **Sonnet at medium, Thinking on**: the default tier. In code, implementation, editing,
  exploration, and review; outside code, explanations, drafting, everyday advice, and summaries of a
  web page or a document. Medium is Anthropic's default for Sonnet 5.5 and fits work with a clear
  scope. Raise it to high where verification matters or edge cases are likely, such as fixing a bug
  in an existing codebase or checking a summary against its source.
- **Opus at high, Thinking on**: any task an Escalate trigger matches but does not send to the top
  tier, including long-context synthesis. Opus 5.5 defaults to medium and thinks more per level than
  Opus 5 did, so high is one step up for work where verification matters, which every Escalate
  trigger describes.
- **Fable at high, Thinking on**: the top tier rather than a fallback, so route to it directly with
  no Sonnet or Opus attempt first when the Escalate trigger sends a task there. Fable decides and
  Opus executes, so the plan for a hard migration, or the decision in a hard personal choice, can be
  Fable work while what follows is not. Pair Fable with max effort only for a rare, exceptionally
  complex problem or when the user asks, because cost compounds on both axes.

Settings on every Claude surface:

- **Effort** runs low, medium, high, extra high, and max. Reserve max for demanding quality-first
  work where extra latency and possible overthinking are acceptable.
- **Thinking** is a third setting alongside model and effort. Turn it on for implementation,
  review, exploration, debugging, planning, research, and advice. Turn it off only when the whole
  task is predetermined and mechanical, or when latency matters more than reasoning.
- **Where to switch** depends on the surface, so name the control the user will see. In claude.ai
  chat and Cowork, the user picks from the model menu and its effort or extended thinking control;
  there is no `/model` command. In Claude Code, `/model` and `/effort` set them, and the VS Code
  extension also offers a picker with a Thinking switch.

Claude Code only:

- **Ultracode** is a toggle beside effort rather than a level on it: with it on, the session plans a
  dynamic multi-agent workflow for each substantive task at whatever effort it runs at. The VS Code
  extension shows it as a separate switch under Effort, while the desktop app's Code tab still draws
  it at the end of the effort slider, so name it as Ultracode rather than as an effort value.
  Recommend it only when the task splits into meaningful independent workstreams and the user has
  asked for or allowed multi-agent work, and say so in the pause's reason line alongside a real
  effort level.
- A `/model` selection writes the model value into settings.json. Where a managed-settings pin is
  in place it outranks user settings at every launch, so an escalation lasts only until the session
  ends; recommend the switch again rather than assuming it survived. In config, use the plain
  aliases fable, opus, sonnet, and haiku, never a dated snapshot.

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

On either tool, use the lowest reasoning effort that reliably handles the task.

## Editing This Policy

The hook reads this file at runtime and holds no copy of its own, so an edit here takes effect on
the next turn. It injects only the three trigger bullets and the `## Tiers` and `## Pause`
sections, in that order, so anything a Claude Code, Codex, or Cowork session needs belongs in one of
them; the introduction above reaches only a session that loads this file as a skill. The contract
with the hook is the `## Tiers` heading, the `## Pause` heading, and the three `- **Escalate**:` /
`- **Downshift**:` / `- **Re-check**:` bullets. Renaming a heading drops that section from the
injected text; reshaping a bullet stops the file qualifying at all. A bullet ends at the next line
that starts with `- `, so a trigger cannot hold a nested list. A `###` subheading or a plain
paragraph inside a section is fine, and everything else is yours to rewrite.
