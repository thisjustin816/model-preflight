# Preset-aware routing and switch justification

Reviewed November 9, 2026, against `4b059dc8de7971e01bb4bff33dc0bc1c702aa3a1`.
This corrects the routing omitted by the [picker control update](2026-11-09-codex-presets.md).
The maintainer selected 1.3.0 for the expanded policy and requested that it replace 1.2.2
before withdrawing the 1.2.2 tag. Published tags are not moved or reused.

## Problem and approved direction

The prior change added manual model and effort selection but retained a fixed Sol medium to
Sol high escalation. The maintainer's slider moves from Sol medium to Astra light. The policy
also treated another repository or another review round as sufficient to escalate. The session
used that rule to request Sol high for a routine release without identifying a reasoning need
that medium could not meet.

The correction belongs in the existing Pause, Escalate, Re-check, and OpenAI tier rules. No
classifier, additional hook, or model call is introduced. Both plugin manifests use 1.3.0.

## Sources and limits

The following official pages were opened November 9, 2026:

- [Models](https://learn.chatgpt.com/docs/models?surface=app) illustrates Sol medium followed by
  Astra light, recommends starting Astra at light and Luna at high, and provides manual controls.
  Presets depend on the client, plan, workspace, and rollout. The example uses an older Sol
  generation; it does not replace the existing current-version check or prove account access.
- [Pricing](https://learn.chatgpt.com/docs/pricing) lists higher credit token rates for Astra
  than Sol. It warns that token prices alone do not determine included subscription usage.
  These rates do not establish total task usage for Sol high versus Astra light.
- [Deployment checklist](https://developers.openai.com/api/docs/guides/deployment-checklist)
  describes effort as a workload tradeoff and recommends measuring representative task success,
  latency, token use, and cost. API effort support does not establish product picker access.

The thresholds below are the maintainer's routing judgment. No comparative model evaluation
ran, and no measured quality, latency, cache, or total-cost advantage is claimed. Model version
examples and Claude tier pairs retain the November 2 review baseline; this is not a model-release
refresh. The shared trigger correction applies on all surfaces.
The Claude effort explanation is narrowed to match that shared rule: routine verification
alone does not raise effort, while concrete unresolved behavior can justify it.

## Current and revised criteria

| Situation | Prior policy | Revised policy |
| --- | --- | --- |
| Work reaches another repository | Normally escalate | Reassess; known release or repeated configuration work stays ordinary |
| User questions wording or a result | Normally escalate | Reassess the remaining work; feedback alone does not establish difficulty |
| Refactor spans several files | Escalate | Escalate when interacting behavior or contracts need substantive decisions |
| Stronger setting recommended | Name the closest trigger | Identify the reasoning problem, why the lower pair is insufficient, and what the proposed pair adds |
| OpenAI substantive escalation | Sol high or extra high | Astra light as the stronger-model starting pair |
| OpenAI expensive-failure exception | Astra high | Astra medium as the starting pair; justify effort above light separately |
| Sol high selected manually | Automatic escalation path | Explain a concrete task or budget tradeoff against Sol medium and Astra light |
| Mechanical OpenAI task | Luna low | Luna high as the reviewed starting pair |
| Manual pair has no preset | Permit manual selection | Retain manual selection and actual availability checks |

All moves to Astra include the existing benefit and allowance context. A family change and
an effort increase are separate decisions. Hypothetical risks must not be described as observed
model failures, and missing presets do not prove that a setting is unavailable.

## Decision walkthrough

These are applications of the written policy, not live model-compliance measurements.

| Input | Expected decision and reason |
| --- | --- |
| Reviewed merge, release tag, and two local plugin updates | Sol medium: known operations; repository count supplies no extra reasoning need |
| Another review requests a spelling correction | Keep the ordinary pair; the remaining correction is routine |
| Check a completed change against a clear acceptance criterion | Ordinary review; verification alone does not establish escalation |
| Apply a settled refactor across six files | Ordinary tier while contracts and behavior are settled |
| Conflicting service traces leave competing explanations after investigation | Astra light: stronger judgment is justified by the unresolved ambiguity |
| Decide an irreversible API contract or a migration whose rollback is costlier | Astra medium under the hard-question exception; explain the consequence and effort need |
| User prioritizes allowance and evidence supports a manual Sol high tradeoff | Explain its benefit over medium and its uncertainty against Astra light; do not promise savings |
| Generic claim that high is better because verification matters | Keep Sol medium; no task-specific justification supports the increase |
| Justified pair has no slider stop | Recommend the pair and explain manual selection |
| Current model access unknown, including manual controls | Ask once and wait; a preset alone does not establish entitlement |
| Older Sol active on a short task while current Sol is available | Require the version switch or the user's explicit older-version choice |
| User explicitly chooses the older model for a bounded scope | Continue within that scope; reassess changed work |
| Surface changes | Recheck available controls and current-version access |
| Effort fixed or unsupported | Omit an unavailable effort adjustment |
| Thinking fixed on | Omit the Thinking control from the pause |
| Background work has unknown execution-mode support | Keep the existing runtime-support and authorization gates |
| Claude routine correction after user feedback | Retain the ordinary Claude tier; shared Re-check no longer forces escalation |

## Verification and release sequence

The existing Python suite tests settings transport, release versions, and delivery behavior.
All 31 Python tests and all eight hook parity cases passed locally at version 1.3.0.
Hook parity and direct dry runs check both policy-reference delivery and the missing-policy
NOTE within the output budget. Those checks cannot prove the quality of a routing judgment;
the decision walkthrough covers the policy interpretation separately.

The release uses a reviewed pull request and the tested merged tree, then an annotated 1.3.0
tag. Local Claude and Codex installations must report 1.3.0, match the release files, and retain
an enabled, trusted Codex hook. Local cloud and marketplace pins advance to the actual tagged
commit. Only after those checks does the maintainer-authorized withdrawal delete the 1.2.2
tag. Release receipts and CI results belong in the pull request and tag runs.
