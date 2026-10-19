---
name: model-preflight
description: Check whether the selected model and effort fit the task before starting it, state a one-sentence verdict, and offer an independent agent or pause for a session switch when needed. Use at the start of every new task or question, coding or not, including summarizing a web page or document, research, drafting, everyday advice, and medical, legal, or financial questions. Use it again when a task grows into a different one, such as a question whose stakes rise, a second repository, or a failure still unexplained after reading the code. Applies in Claude chat, Cowork, Claude Code, Codex, ChatGPT Work, and ChatGPT Chat. When a model preflight hook block is already present, follow its delivery instructions; it may direct you to read this policy.
---

# Model Preflight

Before each new task or question, check whether the active model and effort fit it, say in one
sentence which setting you are keeping or recommending, and consider an independent agent before
asking the user to switch the session. Pause says how to run the check, Triggers says what moves
the setting, and Tiers maps the result to a model on the surface you are running in.

This skill carries the same policy as the plugin's hook. Use the route for the current surface:
Claude, OpenAI agent surfaces (Codex and ChatGPT Work), or ordinary ChatGPT Chat. Where a hook
block is present, follow its delivery instructions: it supplies the rules inline or directs you to
read the selected policy. Where only the skill loads, apply the check at each new task and each
Re-check moment. Loading the skill does not establish that a command hook runs on that surface.

A tier above what the task warrants is as much a mismatch as one below it, because the quota is
spent whether or not the answer would differ.

## Pause

At the start of every new task, compare the active model and effort with what the task warrants,
before answering and before any skill or mode announcement, tool call, file operation, plan, or
delegated work.

If the hook directs you to read its selected policy file, that policy read is the only bootstrap
tool action allowed before the verdict. Apply only its Escalate, Downshift, and Re-check bullets
and its `## Tiers` and `## Pause` sections. If the file cannot be read, report that preflight could
not load; do not claim it ran. No other task work precedes the verdict.

State the verdict in one sentence before beginning, whether or not a change is warranted: the setting
you are keeping or recommending, the closest trigger, and why it does or does not apply. A check
nobody can see cannot be corrected, and a session that never shows one is indistinguishable from a
session that never ran it.

If the ChatGPT Chat route requires picker information before a concrete recommendation can be
made, ask its discovery question once and wait. This replaces the switch template until a
supported choice is established; do not invent a model name or begin task work while waiting.

When recommending a move to the current surface's top tier, including an independent agent,
briefly explain the task-specific benefit and expected allowance impact. Use current, relevant
provider facts or comparable observed usage when available. Otherwise describe the pressure
qualitatively and mark uncertainty. State remaining allowance only when the host or user supplies
it; if it is unknown, say so. Do not infer it from the plan, token totals, or API-equivalent cost.
Do not invent task prices, quota percentages, effort multipliers, or guaranteed savings, and do
not add a network lookup to every preflight just to produce a number.

For that top-tier recommendation, keep one primary choice. When a viable way to conserve usage
exists, offer at most one alongside it and explain the scope or quality tradeoff. Prefer an option
that meets the user's stated budget preference: a bounded expert agent, a narrower task, or a supported lower model or
effort. Higher effort on a cheaper model is not automatically cheaper overall or equally capable.
Offer only available settings and authorized work. If no viable conservation option exists, say
so rather than present an inadequate setting as equivalent. Apply the delegation rules below to
any proposed agent.

Before recommending a session switch on an agent surface, apply Delegation under Tiers. If the
task fits an independent agent at a different model or effort and the main session can still
handle the handoff and result, offer that agent first. This applies to stronger and cheaper
settings. Keep the main session's setting, name one agent model and exposed effort, explain the
bounded task and what will return, then end the turn with: "Start that agent?" Wait for explicit
approval before spawning it. An explicit delegation request or existing delegation authorization
covering that work needs no additional approval. An offer alone does not authorize a spawn.

After approval, give the agent a short brief with the necessary context, scope, tools, and output.
Select its model and effort before spawning it. The agent performs the assigned work at those
settings without asking the user to switch the main session's picker. Return its findings and
any verification limits here. If it needs user decisions, loses required access, or leaves work
that the main session's setting cannot handle, run preflight on the remaining work. Do not repeat
the completed delegation approval or proceed on an inadequate setting after an offer is declined.

When the main session's model or effort should change, this is a mandatory pause that overrides
normal autonomy and continuation instructions, auto mode included. The user has asked for this pause
as part of the work, so stopping here is delivering the task rather than departing from it. Give
one short reason tied to the task, then use this format:

Recommended: **MODEL** with **EFFORT**.

Thinking: **ON or OFF**.

I'll pause here. Switch to that setting, then reply **y**.

Those lines, with the omissions and optional usage context below, are the output. Substitute a
value for every capitalized placeholder and copy nothing else from this template, including the
words that describe when a line applies. Give exactly one primary model and, where available,
one effort. A top-tier recommendation may also carry the brief allowance context and single
viable conservation option described above; do not offer a ladder of models or efforts. Put that
context and option before the final pause line. When an option is offered, use this final line:
"I'll pause here. Switch to the recommended setting, then reply **y**, or choose the conservation
option." Preserve the bold formatting on every setting. Recommend effort only when the selected
model and surface expose that control; otherwise drop `with **EFFORT**`. The Thinking line applies
only on Claude surfaces where the selected model exposes a changeable Thinking control. Omit it
when Thinking is fixed on or the control is absent,
and omit it on OpenAI surfaces. Do not ask the user to change a fixed setting. End the turn
immediately after these lines. Do not answer the question, call tools, delegate work, edit files,
draft a plan, or continue queued or background actions.

After a session-switch pause, `y` (case-insensitive) completes the recommended switch handshake
even if the active setting cannot be verified. An explicit choice of the offered conservation
option approves that path and its stated tradeoff; silence or a vague concern about usage does
not. If the option uses the current setting or an explicitly approved agent, proceed within that
scope. If it needs a main-session picker change, use the switch handshake for the chosen setting.
Do not repeat the original recommendation after either completed handshake. Reassess only if
the remaining task or evidence changes; an accepted narrower scope or quality tradeoff is not a
blanket waiver for later work. If the user replaces the task while paused, evaluate that task anew.

On agent surfaces, skip this session-level check when the user directly invokes a skill or command
whose runtime definition assigns a model or effort, or whose whole procedure is one of the one-off
tasks the Downshift bullet describes. Let a runtime assignment apply where the tool has one, and
route the rest as that bullet says, without a model-switch prompt. Detect an assignment from the
runtime definition rather than maintaining a command allowlist, and apply the normal preflight if
the task expands beyond the routed workflow.

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
  user's own health, money, or legal position. A matching task takes the escalated tier for the
  current surface under Tiers, unless it is one hard question, decided once, whose wrong answer
  is expensive to undo or slow to surface: adjudicating an exploit path, choosing an
  architecture that locks in a data model, an API contract, or an infrastructure topology,
  explaining an intermittent concurrency or ordering failure, planning a migration whose rollback
  costs more than the migration, or settling a major medical, legal, or financial decision that is
  hard to reverse. A matching task on which the escalated tier has already made a serious attempt
  and failed to explain or resolve it qualifies as well. Those take the current surface's top
  tier instead. Breadth alone stays with the escalated tier; a refactor stays there no matter how
  many files it spans.
- **Downshift**: the active tier is above what the task warrants. A new task that no Escalate trigger
  reaches uses the current surface's default tier under Tiers: in code, everyday implementation,
  editing, and review; outside code, explanations, drafting, everyday advice, and
  summarizing a web page or an ordinary document. A session sitting above that recommends a change
  when the remaining work justifies its switching overhead. Distinguish a model switch from an
  effort-only change. A model switch can require the conversation to be processed on the new model;
  cache reuse depends on the current provider and client. An effort-only change can preserve or
  invalidate the cache depending on the model, client, and how that change is sent. Use relevant
  documentation or observed behavior when available and state uncertainty otherwise. Do not assume
  either a full conversation reread or a free effort change. Compare the expected usage and latency
  benefit with that supported overhead; a new conversation or a series of tasks can make a change
  worthwhile. Unknown switching costs alone do not justify keeping an excessive setting indefinitely.
  A whole task that is predetermined and mechanical and will hold the session for a while, such as a
  format-only pass across a tree, a batch of renames, a series of status checks, or a run of quick
  facts, lookups, or reformatting, recommends that surface's mechanical tier on the same test.
  A one-off task, such as a single rename, a status check, a known command, a directly invoked
  commit-and-push skill, or a single quick fact, is never worth a pause, and in a long session
  neither is any other task too small to repay its switching overhead: hand it to a subagent on the
  cheaper tier where Delegation under Tiers favors one and a short brief justifies the handoff;
  otherwise keep it on the session model.
  Say in the verdict whether you are switching, delegating, or staying. A directly invoked skill
  whose definition pins a model runs on that pin with no pause.
  The user's own switch upward covers the task it was made for and nothing after it, so do not keep
  the tier because the user recently chose it; once that task is done, the same test decides
  whether to come back down. Escalation is exempt from this break-even test: follow the required
  task tier even when switching has a cost. In Claude Code, use Haiku for background work only when
  the selected model and runtime support the execution mode the work needs. Haiku 5.5 supports auto
  mode on supported clients and providers; Haiku 4.5 does not. If support is unknown, keep a model
  known to support that mode.
  Model support does not authorize background work, delegation, or permission changes.
- **Re-check**: run the check again, and state the verdict again, when a fix exposes an adjacent
  defect, when a second round of review findings lands on a file you already changed, when the work
  reaches a second repository or component, when a general question turns into one about the user's
  own health, money, or legal position, when the user questions the approach or the result, or when
  you have investigated a failure and still cannot explain it. A task rarely announces that it has
  become a different task, and these are the moments where it has. Each of these is also an Escalate
  trigger, so a re-check that finds one normally ends in a switch up rather than in keeping the
  tier. Reviewing or verifying work the session already produced is where staying put is most
  tempting and least often right. Use the current surface's escalated tier under Tiers; its top
  tier applies only under the Escalate bullet's one-hard-question exception.

## Tiers

Determine the current surface before mapping the task tier to a model. Use Claude for Claude Code,
Cowork, and Claude chat; OpenAI agent surfaces for Codex and ChatGPT Work; and ChatGPT Chat for
ordinary Chat. Apply only that route. Model names, controls, and access established on another
surface do not establish what this one offers. A matching trigger outranks the tier examples.
Delegation applies only where the runtime exposes subagents and the user's permissions allow it.

### Claude

- **Haiku at low where effort is available**: the mechanical tier for quick facts, simple lookups,
  reformatting, and predetermined mechanical work. Haiku 5.5 supports effort; older Haiku models
  can lack it, so use a model-only pause there. Leave Thinking on where the model requires it. Turn it off for
  this tier only where the selected model and surface expose that choice.
- **Sonnet at medium, Thinking on**: the default tier. In code, implementation, editing,
  exploration, and review; outside code, explanations, drafting, everyday advice, and summaries of a
  web page or a document. Medium is Anthropic's default for Sonnet 5.5 and fits work with a clear
  scope. Raise it to high where verification matters or edge cases are likely, such as fixing a bug
  in an existing codebase or checking a summary against its source.
- **Opus at high, Thinking on**: the escalated tier for any task an Escalate trigger matches but
  does not send to the top tier, including long-context synthesis. Opus 5.5 defaults to medium
  and thinks more per level than Opus 5 did, so high is one step up for work where verification matters, which every Escalate
  trigger describes.
- **Fable at high, Thinking on**: the top tier rather than a fallback, so route to it directly with
  no Sonnet or Opus attempt first when the Escalate trigger sends a task there. Fable decides and
  Opus executes, so the plan for a hard migration, or the decision in a hard personal choice, can be
  Fable work while what follows is not. Pair Fable with max effort only for a rare, exceptionally
  complex problem or when the user asks, because cost compounds on both axes.

Settings on every Claude surface:

- **Effort** can run low, medium, high, extra high, and max, depending on the selected model and
  surface. Recommend only levels exposed there; API support does not establish picker support.
  Reserve max for demanding quality-first work where extra latency and possible overthinking
  are acceptable.
- **Thinking** can be fixed on or separately selectable, depending on the selected model and
  surface. Where selectable, turn it on for implementation, review, exploration, debugging,
  planning, research, and advice. Turn it off only when the whole task is predetermined and
  mechanical, or when latency matters more than reasoning. Leave it on where required and omit
  its pause line when the user cannot change it.
- **Where to switch** depends on the surface, so name the control the user will see. In claude.ai
  chat and Cowork, use the native model menu and whatever effort or extended thinking controls
  it exposes; there is no `/model` command. In Claude Code, use `/model` and `/effort`, or the
  extension's picker. Name a Thinking switch only where that model and surface offer one.

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

### OpenAI agent surfaces: Codex and ChatGPT Work

Resolve the Sol tier before naming a model. Prefer GPT-6.1 Sol (`gpt-6.1-sol`) only when it is the
active model reported by the current host, or the user has confirmed it is selectable in the
current account, workspace, and surface's native picker. Otherwise use GPT-6 Sol (`gpt-6-sol`).
Release announcements, plan eligibility, local defaults, cached or bundled catalogs, and access
through another surface do not establish current access. If access is unknown, use the fallback
without repeatedly asking the user to check. Discard earlier confirmation when the account,
workspace, or surface changes, or the user reports losing access. For subagent choices, establish
access in that runtime too; the parent's model alone does not prove subagent support. Both Sol
versions are the same tier, so let an existing 6 Sol session finish a small task when switching to
6.1 would not repay the supported switching overhead described under Downshift.

- Sol with medium reasoning is the default tier for implementation, review, explanations,
  drafting, and ordinary research. When access is established, prefer GPT-6.1 Sol for repeated,
  long-running work across code, apps, and documents, including code cleanup, flaky-test fixes,
  and CI improvement. The escalated tier uses the selected Sol model at high or extra high.
  Keep Astra for the top-tier cases defined by the Escalate trigger.
- Terra with medium reasoning suits routine work that favors speed and efficiency, especially
  read-heavy exploration and supporting-document scans.
- Luna with low reasoning is the mechanical tier for clear, repeatable work: predetermined
  commands, format-only edits, status checks, extraction, and structured summaries.
- Astra is the top tier rather than an everyday upgrade, so route to it directly with no Sol attempt
  first when the Escalate trigger sends a task there. Astra decides and Sol executes, so the plan for
  a hard migration can be Astra work while the edits that follow are not. Use high reasoning, and
  pair Astra with max or ultra only for a rare, exceptionally complex problem or when the user asks,
  because cost compounds on both axes. Astra selects at low reasoning by default, so name the effort
  alongside the model rather than taking what the picker offers.
- Use Sol at ultra when the task splits into meaningful independent workstreams and the user has
  asked for or allowed multi-agent work, and that model's current picker exposes ultra; ultra
  spawns internal sub-agents rather than deepening a single chain of thought. Reserve Astra at
  ultra for a top-tier task that also splits that way, and only when the user has accepted the
  allowance cost.
- Recommend only effort levels exposed by the selected model on the current surface. Availability
  differs by model, client, and workspace settings; API effort support does not establish product
  picker support. Ultra, where offered, is above max. The picker renders low as light and xhigh as
  extra high, so use those labels when telling the user what to select, and canonical terms in
  config or API settings.
- In an interactive Codex CLI session, use `/model`. In Work and GUI clients, name the model and
  reasoning controls actually exposed beneath the composer, including Advanced where available.
  Do not apply CLI commands or `config.toml` instructions to hosted Work. Omit the Claude
  Thinking line.
- In Codex runtimes that support local subagent configuration, subagents inherit
  `default_subagent_model` and `default_subagent_reasoning_effort` from `config.toml`, so a cheap
  default covers mechanical fan-out but lands on demanding work too. When a spawned subagent's
  task is not mechanical, set `model` and `reasoning_effort` on the spawn to the tier the task
  warrants, judged by the same triggers as the session-level check. That override needs
  `fork_turns` set to `"none"` or a positive integer, because a full-history fork inherits the
  parent's tier and rejects overrides.

### ChatGPT Chat

Use the same task difficulty triggers, mapped only to native choices established in this chat.
Do not recommend Sol or Luna from the Work/Codex route. For routine work, the default tier is the
available general-purpose choice. The mechanical tier is a faster choice, used only when switching
repays its supported switching overhead. For an Escalate trigger, the escalated tier is an available
reasoning choice; reserve the strongest available choice for the existing top-tier exception. Name
a specific model or mode only when its availability and role are established. Use only exposed effort controls and
omit the Claude Thinking line.

If a concrete recommendation requires picker information you lack, ask once for the current choices
and controls, then wait before task work. Do not invent a recommendation or repeatedly ask the same
question in an unchanged context. Once a supported choice is established, use the normal
switch pause described above. Discard earlier picker information when the account, workspace, or
surface changes, or the user reports losing access. If the needed capability is unavailable, state the
limitation and request direction rather than claiming the current choice meets it. Use native Chat controls; do not
prescribe CLI commands, local config discovery, or delegation without an exposed capability.

### Delegation, where the runtime exposes subagents

A subagent can put a different tier on an independent task while the main session keeps its
setting. Use a fresh context with a short brief where the runtime supports it. Its startup,
instructions, tool use, and the main session's handoff and verification all consume usage; do not
promise a saving without evidence.

- Delegate work that stands on its own and can be briefed in a few sentences, when at least one of
  these holds: it warrants a different tier or effort than the session, including a bounded hard
  investigation on a stronger model or a mechanical step on a cheaper one late in a long
  session; its raw output is bulky and only a conclusion needs to come back, such as a broad search,
  a log dump, or a scan of many files; or it splits into independent workstreams that can run at
  once.
- Keep it in the foreground when it depends on context that would take longer to brief than to
  use, when it needs the user's answers along the way, when it is judgment about the conversation in
  progress, when frequent progress updates or steering need the main session, or when it is small
  enough that the startup costs more than the work. Read-only work is a useful candidate, but
  bounded edits can qualify when ownership and verification are clear.
- Give a subagent the tier its own task warrants by the same triggers, not the session's: a
  mechanical step goes cheap, and a delegated review or investigation that an Escalate trigger
  matches goes up. In Claude Code, set the model on the spawn or in the agent definition; in a
  supporting Codex runtime, use the subagent settings above. On other agent surfaces, use only
  the delegation and model controls actually exposed there; do not assume local configuration
  applies.
- Fan out no wider than the number of independent workstreams, and keep the steps that need the
  user's answer in the main session.

Offer only agents the current runtime can actually spawn with the required model, effort, tools,
and permissions. A provider's API or another product's picker does not establish those capabilities.
Use the offer and approval flow in Pause unless the work is already authorized for delegation.

Where the runtime exposes no subagents, the choice is only between switching and staying.

On every surface, use the lowest exposed reasoning effort that reliably handles the task.

## Editing This Policy

For model releases, control changes, or a request to refresh recommendations, follow the
[model policy maintenance procedure](../../docs/model-policy-maintenance.md). It defines the
source checks, evidence record, criteria review, and verification before publication.

The hook reads this file at runtime and holds no copy of its own, so an edit here takes effect on
the next turn. Its inline policy contains only the three trigger bullets and the `## Tiers` and
`## Pause` sections, in that order. Context over 2,000 UTF-8 bytes becomes a reference to the
selected file; the model reads and applies those same parts. Anything preflight needs belongs in
one of them; the introduction above reaches only a session that loads this file as a skill. The contract
with the hook is the `## Tiers` heading, the `## Pause` heading, and the three `- **Escalate**:` /
`- **Downshift**:` / `- **Re-check**:` bullets. Renaming a heading drops that section from the
injected text; reshaping a bullet stops the file qualifying at all. A bullet ends at the next line
that starts with `- `, so a trigger cannot hold a nested list. A `###` subheading or a plain
paragraph inside a section is fine, and everything else is yours to rewrite.
