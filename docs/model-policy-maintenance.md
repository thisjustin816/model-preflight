# Refreshing the model policy

Use this procedure when asked to refresh Model Preflight, when a model release, retirement, or
control change could affect its recommendations, and before publishing the resulting policy.
Research happens during maintenance. Per-task preflight uses the reviewed policy.

Start with: "Refresh Model Preflight using docs/model-policy-maintenance.md, comparing current
official guidance with the last reviewed policy."

## 1. Establish the baseline

Read the current policy, README, manifests, and the previous model-update review or release PR.
Record the starting commit, review date, and the last covered release date for each vendor. If
there is no earlier evidence record, review all model families the policy currently recommends.
Keep unfinished findings visible; an unmerged proposal is not the published baseline.

Use a dated review document or the PR body for this run. Record public product facts there;
keep account identifiers, credentials, and private workspace details out of published evidence.

## 2. Fetch current primary sources in the same order

Open the pages themselves. Search snippets, model training knowledge, and a previous review do
not establish current behavior. Scan both vendors' releases since the baseline, then recheck
the live control and availability documentation for every family the policy recommends and
each surface it covers. Control documentation can change without a model launch.

| Check | OpenAI starting points | Claude starting points |
| --- | --- | --- |
| Releases, retirements, rollout changes | [ChatGPT and Codex changelog](https://learn.chatgpt.com/docs/changelog); follow relevant launch and retirement links | [Claude release notes](https://support.claude.com/en/articles/12138966-release-notes), [Claude Code changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md) |
| Task strengths and effort tradeoffs | [Model selection](https://developers.openai.com/api/docs/guides/model-selection), plus the affected model's official launch guidance and evaluations | Follow the model launch links from release notes; compare with [Claude Code model guidance](https://code.claude.com/docs/en/model-config) |
| Actual product controls and access | [Models](https://learn.chatgpt.com/docs/models?surface=web), [workspace availability](https://learn.chatgpt.com/docs/enterprise/workspace-model-availability) | [Code model and effort controls](https://code.claude.com/docs/en/model-config), [chat controls](https://support.claude.com/en/articles/8664678-change-the-model-effort-and-thinking-settings), [execution-mode support](https://code.claude.com/docs/en/permission-modes) |
| Cost, latency, and allowance impact | [Product pricing and usage](https://learn.chatgpt.com/docs/pricing); follow current API pricing only for API comparisons | Follow current plan, usage, and API pricing links from the affected model's official documentation |

These are entrypoints, not a frozen list of models. Follow provider links to newer replacements.
If a page moves, find and open its official replacement. If fetching fails, record the gap; do not
claim a complete refresh. Third-party discussion can identify a question to investigate, but a
rule about supported controls or access needs the provider's documentation.

For every material fact, record the source URL, date checked, release or effective date if given,
model version, surface, and relevant client/provider/plan limits. Distinguish an announcement
date from a rollout completion date or a future retirement. When official pages disagree, check
their scope and dates, record the conflict, and keep the disputed change pending.

## 3. Separate capability from availability

Check Claude Code, Claude chat, and Cowork separately. For OpenAI, check Codex CLI, desktop,
IDE, hosted execution, ChatGPT Work, and ordinary ChatGPT Chat as applicable. Record whether
each affected surface exposes the model, effort levels, Thinking control, delegation, execution
mode, and plugin hook or skill needed by the proposed rule. Mark unknowns explicitly.

An API capability does not prove the same control exists in a product picker. A release,
subscription entitlement, local default, or cached catalog does not prove a particular account
can select a model. Preserve runtime availability gates and the established fallback. Confirm
access through the current host's active-model metadata or the user's current native picker
confirmation where the policy permits it; check subagent access in that runtime separately.

## 4. Derive the switching criteria

For each relevant update, write the current rule, the evidence, and the proposed rule or the
reason to keep it. Label provider facts separately from the maintainer's routing judgment.
Use this sequence:

1. Name the task shape: mechanical work, routine implementation or writing, verification-heavy
   work, synthesis, or a hard decision with expensive failure. Include required tools and outputs.
2. Compare the existing tier with the candidate on that task shape. Use official task guidance,
   evaluation conditions, and limitations. A headline benchmark or a newer name alone does not
   justify promoting a model, changing all tiers, or extrapolating across unrelated tasks.
3. Choose the lowest model and exposed effort that meet the task's quality needs. Weigh latency,
   allowance or cost, and expected work remaining. Distinguish model changes from effort-only
   changes and check the current model, provider, and client's cache and conversation-processing
   behavior. Use documented or observed switching costs and state uncertainty where they are
   unknown. Keep product usage limits separate from API token prices. State any unmeasured tradeoff.
4. Decide whether this changes a task trigger, the model within an existing tier, an effort or
   Thinking recommendation, or only availability wording. Keep the existing tiers unless the
   evidence and requested scope justify changing them. Preserve user permissions and the pause.
5. Write an observable condition, one recommendation when it holds, and the fallback or unknown
   behavior. Recommend only selectable settings. Do not ask users to change fixed controls or
   infer availability from another account, workspace, surface, or runtime.

Where a quality or efficiency claim would materially change routing, compare representative
tasks on both settings with the same inputs, tools, and success criteria when access and
authorization permit. Record correctness, rework, latency, and usage or cost where measurable.
If no comparison ran, label the proposal as based on documentation and keep the uncertainty
visible. Do not claim measured superiority or spend on API evaluations without authorization.

## 5. Review the concrete change and all consumers

Show current and proposed wording with sources, impact, and remaining uncertainty. Obtain any
approval required by the maintainer's instructions before behavioral edits. Retire contradicted
claims throughout the policy rather than adding another exception beside them.

Update the canonical skill and affected README or manifest descriptions together. Check shared
instruction pointers, generated cloud instructions, runtime mirrors, model-routed skills, and
published pins that consume the policy. Apply the existing sync workflow where shared content
changes. Keep research and source notes outside the hook's injected sections.

## 6. Verify and publish through the existing release process

Run the existing hook parity and session-settings/delivery tests, release-version checks, and
whitespace checks described in the repository and CI. Run the documented hook dry run and
missing-policy case. Inspect the selected policy reference and the opening/reminder output
budget. Read the complete changed policy for contradictions.

Review representative decisions: routine work, an escalation, a downshift late in a session,
known and unknown model access, a changed surface, unsupported effort, fixed Thinking, and
background work with supported or unknown execution-mode support. Record the expected decision
and why the written rule gives it. These are policy reviews; string matching and transport
tests do not establish that a model follows the policy.

Where live verification is available, check the affected native picker and carrier: hook,
explicitly loaded skill, and hosted execution as applicable. Report separately what passed
locally, what ran in CI at which commit, what was checked live, and what remains unverified.

Use the README's existing release process. Update both manifests together, tag only the tested
merged commit, and move consumer pins to that actual release. Refresh installed plugins through
their managers and renew hook trust where required. Keep each action within the user's shipping
authorization.

## Completion record

Finish the dated review or PR with the baseline and review date; source links and effective
dates; changed and retained criteria with reasons; surface and access limits; verification
results and gaps; unresolved findings; and the published commit/tag or pending publication step.
That record is the starting point for the next refresh.
