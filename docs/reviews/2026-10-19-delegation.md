# Delegation and policy review fixes

Reviewed October 19, 2026, against commit `1fda8dd` and the published 1.0.0 policy.
Release target: 1.1.0.

## Scope and decision

Offer one independent agent before recommending a main-session model or effort switch when a
short brief can carry the task and the main session can handle the handoff and returned result.
The agent can use a stronger or cheaper setting. Keep interactive decisions and work that depends
on the conversation in the main session.

The maintainer approved this delegation change and the R1 usage-context follow-up. Tier
assignments and the recommended session-switch `y` handshake are retained. A top-tier prompt
also explains allowance impact and may offer one viable conservation path with its tradeoff.
The user's explicit choice approves that path; a required picker change still needs its switch
handshake. A new delegation offer waits for explicit approval unless delegation for that work
is already authorized. Approval of an agent does not change the main session's picker.

The existing Pause and Delegation sections carry the behavior. Both hook implementations refer
to that policy for delegation approval and session-switch pauses. The README, plugin manifests,
marketplace description, and hook description describe the same choices.

The maintainer also approved R2: both hook wrappers defer staying, delegation approval, and
session-switch decisions to the selected policy. They do not append a mandatory pause to an
escalation trigger or independently order a pause when a trigger matches. The policy's tier
requirements and approval gates remain in force.

The maintainer approved R3's switching-cost qualification. Downshift decisions distinguish model
changes from effort-only changes and use documented or observed cache behavior for the current
model, provider, and client. Unknown behavior is stated explicitly. The policy assumes neither a
full conversation reread nor a free effort change. Small-task switching overhead still matters;
escalation continues to follow the required task tier.

## Evidence and limits

Sources checked October 19, 2026:

- [OpenAI subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) documents
  independent agent contexts, model and effort selection, and delegation permissions. It does
  not establish account-specific access to a model.
- [Claude subagents](https://code.claude.com/docs/en/sub-agents) documents separate contexts,
  selectable models, tool access, and returning results to the main conversation.
- [Claude model configuration](https://code.claude.com/docs/en/model-config) documents model
  inheritance and explicit subagent model settings.
- [OpenAI pricing and usage](https://learn.chatgpt.com/docs/pricing) separates subscription
  allowance from API prices and explains why task consumption varies.
- [Claude effort](https://platform.claude.com/docs/en/build-with-claude/effort) describes effort
  tradeoffs and recommends workload-specific evaluation. It distinguishes cache-preserving
  per-message effort changes from top-level changes that invalidate cached prefixes; support
  varies by model and provider, and API support does not establish a native client's behavior.

The offer is a maintainer routing choice. No paid model comparison or live delegation was run.
The task brief, agent instructions, child work, and the parent handoff and verification consume
usage. A smaller context can help, but delegation has no guaranteed saving.

Release publication follows the README's pull request, tested merge, and annotated tag process.
Local installations update through their plugin managers after publication. The pull request and
tag CI runs provide the final commit-bound verification record.

## Decision walkthrough

These are readings of the policy, not automated evidence of model compliance.

| Situation | Expected choice |
| --- | --- |
| Self-contained research needs a stronger model; parent can report findings | Offer one stronger agent and wait for explicit approval |
| Grouped extraction suits a cheaper agent in a long session | Offer one cheaper agent if the work repays handoff and verification |
| Task needs frequent user decisions or conversation-specific judgment | Keep it in the main session; use the session-switch pause if its setting is inadequate |
| User explicitly requested a specific supported agent for this work | Use that delegation authorization without asking again |
| Model exists in another product but subagent access is unknown | Do not offer an unsupported agent; apply the available session route |
| Offered agent is declined and the current session is inadequate | Explain the remaining choice; do not silently proceed at the inadequate setting |
| Agent returns a result that the current main-session setting cannot assess | Run preflight on the remaining assessment |
| Fixed Thinking or unsupported effort controls | Omit fixed controls and offer only settings the runtime supports |
| Ordinary Chat has no exposed delegation tool | Use its native picker route |
| Top-tier move with unknown remaining allowance | Explain the benefit and qualitative pressure; state that remaining allowance is unknown |
| User wants to conserve usage and a bounded expert task meets the need | Offer that one path and state the scope and handoff cost |
| User explicitly chooses the offered conservation path | Honor its stated scope and tradeoff; use a switch handshake only if the chosen path needs a picker change |
| User expresses concern but chooses no path | Keep the choice pending; do not infer approval |
| No viable conservation option or no relevant measurements | State the limit; do not invent a cheaper equivalent, task price, or quota percentage |
| Current setting already meets an escalation trigger's required tier | State the verdict and stay; the hook adds no independent pause |
| Current setting needs to change and delegation does not fit | Follow the selected policy's session-switch pause |
| Documented effort-only change preserves the cache | Assess the effort change without adding an assumed full reread cost |
| Documented effort change invalidates cached prefixes | Include that cost in the downshift decision |
| Cache behavior is unknown for the current client | State the uncertainty; assume neither full rereading nor a free change |

## Verification

- All 31 Python tests passed: 27 metadata/delivery tests and four release-version tests.
- PowerShell/POSIX hook parity passed all eight cases.
- Both manifests parsed and the release-version check matched `v1.1.0`.
- Selected-policy and missing-policy probes emitted 656 and 964 UTF-8 bytes, within the output budget.
- The wrapper regression failed before the fix in inline, reminder, and policy-reference output.
  It checks delivered instructions and does not establish model compliance with the policy.
- Whitespace and character/residue checks passed. Salted failures were detected before trusting
  the character scan. The complete policy was checked for superseded rereading claims.
- All three recorded review findings are resolved in the release candidate.
- Direct PowerShell analysis reported two existing variable-use warnings in transcript-reading
  closures; no error diagnostics. The installed analyzer wrapper lacks its documented
  `TargetVersion` parameter, so the direct analyzer was used without changing the wrapper.

Tests on Windows used a temporary `python3` shim pointing at the installed interpreter because
the Windows Store alias could not execute. The shim is outside the plugin. Native pickers,
live agent execution, hosted clients, and CI at a published commit were not verified.
