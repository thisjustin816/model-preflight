# Codex model and effort presets

Reviewed November 9, 2026, against `e38f18d`, with both plugin manifests at 1.2.1.
The previous model review is [November 2](2026-11-02-current-versions.md).

## Scope and evidence

This is a scoped Codex app control update requested by the maintainer. It does not refresh
model releases or change task tiers, effort targets, Claude controls, delegation permissions,
or switch confirmation. Those retain their previous review baseline.

The [official OpenAI models guide](https://learn.chatgpt.com/docs/models?surface=app), opened
November 9, documents combined Power presets and Advanced controls for selecting model and
reasoning effort. Its example has six presets, while its text says available choices vary by
plan, client, workspace settings, and rollout. The illustration does not enumerate every live
slider. No release or rollout completion date is established by that page.

The maintainer reports a Codex app slider progressing through Luna, Terra, Sol, and Astra,
with preset efforts, and confirms that model and effort can also be set individually. This
establishes the requested control behavior, not universal account access or a fixed preset list.

## Decision

| Previous wording | Revised rule |
| --- | --- |
| Recommend only effort levels exposed by the selected model on the current surface | Count presets and manual controls when determining support |
| Name the GUI model and reasoning controls beneath the composer | Recommend a model and effort pair, then map it to a matching preset or manual selection |
| Unknown access requires a question and pause | Retain that rule, but a missing preset alone does not establish unknown or unavailable access |

Recommend the task's model and effort pair even when the slider has no matching stop. Explain
manual selection before the existing switch template. Do not downgrade or drop effort merely
to fit the presets. Actual unsupported controls and missing model access keep their existing
gates. This is the maintainer's routing decision; no comparative model evaluation or paid API
call is needed for this control change.

## Decision walkthrough

| Situation | Expected decision |
| --- | --- |
| Recommended pair matches a known preset | Name the pair and use that preset |
| Pair has no preset but manual controls support it | Recommend the same pair and direct manual selection |
| Slider positions or labels are unknown | Name the pair without inventing a stop label or position |
| Effort is fixed or unavailable through manual controls too | Do not request an unsupported adjustment |
| Model access is unknown after considering manual controls | Ask once and wait under the existing availability rule |
| Older model is active while a current version is selectable manually | Require the current-version switch or explicit older-version choice |
| Routine work, escalation, or top-tier task | Use the existing task tier and effort targets |
| Delegated task | Check the subagent runtime independently; GUI presets do not establish agent access |
| Ordinary Chat or Claude surface | Apply its existing surface-specific route |

## Verification limits

The policy and README use the canonical plugin source. The hook reads the changed sections
without a generated policy copy. Installed plugin caches and published consumer pins remain
release-managed; they are not edited by this change. The native picker and model compliance
have not been exercised in this review. Local checks do not prove model compliance or CI results.

Local verification passed all 31 Python tests, all eight hook parity cases, and the release-version
check at 1.2.1. The initial
test environment lacked `sh` on PATH and resolved `python3` to a blocked Windows app alias;
the passing run added Git's shell directory and a temporary wrapper for the installed Python
to that process's PATH. No repository runtime code changed for this environment issue.
The direct PowerShell dry run emitted the selected policy reference and active metadata in
658 UTF-8 bytes. The missing-policy dry run emitted its NOTE in 1,381 bytes, below the
2,000-byte delivery limit. Whitespace checks passed.
