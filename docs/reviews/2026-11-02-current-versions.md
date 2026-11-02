# Current model versions within task tiers

Reviewed November 2, 2026, against `c96e23591ef2aa7b2c3a2d12600cdb9f15351508`, the
published 1.1.0 policy. Release target: 1.2.0. Publication and installation are pending.

## Decision and scope

The maintainer approved requiring current stable versions within each task tier, asking once
and pausing when access is unknown, and using an older version only by explicit choice. The
reported failure was an ordinary Sol session continuing on GPT-6 Sol while GPT-6.1 Sol was
selectable. The published rule explicitly allowed the older fallback and a short-task exception.

Freshness is checked at the first preflight in a session using current official provider
guidance or authoritative live release metadata. Evidence is reused until a newer release or
changed account, workspace, provider, or surface invalidates it. A pending source check is
announced in the initial verdict; only that lookup precedes the completed verdict and task work.
If sources are unavailable, the user must explicitly choose whether to continue unverified.

Availability remains a separate check. The rule neither infers account access from public
release information nor changes a picker or configuration. Short tasks, switching overhead,
runtime pins, and delegation cannot silently keep an older version in use. Current-version
checks alone change neither the task tier nor its reasoning effort.

The scope is this freshness and access criterion. Existing task tiers, effort recommendations,
Thinking controls, delegation permissions, and switch handshakes are retained. Other surface
and control recommendations still need their regular maintenance review. No paid model comparison ran, and
the change makes no measured quality, latency, cache, or allowance claim.

## Current and proposed criteria

| Situation | Published 1.1.0 rule | Approved rule |
| --- | --- | --- |
| Current Sol access unknown | Use GPT-6 Sol without repeated questions | Ask once whether the current stable Sol is selectable; wait |
| Current Sol available during a short task on older Sol | Keep older Sol when switching overhead outweighs the task | Require the switch or an explicit choice of the older version |
| Version table may be stale | Use reviewed model mapping | Check current official guidance once per session and reuse evidence |
| Newer stable version identified mid-session | No version-specific reminder | Recheck freshness without automatically raising task tier or effort |
| Runtime pin or proposed agent would retain an older main session | Task-routing exception can skip the session check | Resolve main-session freshness first |

## Sources and limits

All sources below were opened and checked November 2, 2026. Public provider facts establish
release candidates and controls; they do not establish an individual account's access. Requiring
current versions and explicit consent for exceptions is the maintainer's routing decision.

- [OpenAI models](https://learn.chatgpt.com/docs/models) lists GPT-6.1 Sol, GPT-6.1 Terra,
  GPT-6 Luna, and GPT-6 Astra for Work and Codex. Ordinary Chat has its own model guidance.
- [OpenAI changelog](https://learn.chatgpt.com/docs/changelog) records GPT-6.1 Terra's Work
  and Codex release on October 26, 2026, after the October 19 baseline review. Its availability
  depends on the product, plan, region, and workspace. No Terra task-tier change is proposed.
- [Workspace model availability](https://learn.chatgpt.com/docs/enterprise/workspace-model-availability)
  documents administrator gates for newer models. Configuring a model does not grant access.
- [OpenAI model selection](https://developers.openai.com/api/docs/guides/model-selection)
  distinguishes model capability, effort, cost, and latency. A newer version within a family
  does not justify moving every task to the highest tier.
- [Claude model configuration](https://code.claude.com/docs/en/model-config) documents
  aliases and provider-specific resolutions. An unversioned alias can resolve to an earlier
  release on another provider or client; the actual resolution needs checking.
- [Claude release notes](https://support.claude.com/en/articles/12138966-release-notes)
  were checked through the October 21, 2026 entry. The later entry concerns a product preview;
  no Claude task-tier change is proposed.

The live session reported GPT-6 Sol at medium before the user's switch and GPT-6.1 Sol at high
afterward. That verifies parent-session Sol access here. It does not verify every picker,
subagent runtime, provider, hosted carrier, or future session. Existing installed plugin
caches are release-managed consumers and update after publication.

## Decision walkthrough

These are readings of the written policy, not measurements of model compliance.

| Situation | Expected decision |
| --- | --- |
| Routine task on current Sol with source evidence from this session | Stay at the default effort |
| Escalation on current Sol | Use high or extra high under the existing trigger |
| Hard decision whose expensive failure meets the top-tier exception | Use current Astra with high reasoning |
| Old Sol, current Sol selectable, one small command remaining | Require the version switch; no short-task exemption |
| Old Sol, current Sol access unknown | Ask once and wait; do not infer unavailability |
| Current version unavailable | Explain and ask whether to use the named older version or stop |
| User explicitly chooses the older version for this task | Proceed within that scope; reassess later work |
| Official version guidance cannot be checked | Report the gap and wait for an explicit choice to proceed unverified |
| Repeated task in the same release and access context | Reuse release evidence and answered availability information |
| Account, workspace, provider, or surface changes | Revalidate release and access evidence |
| Known current version but effort or Thinking control unsupported | Omit the unsupported control |
| Pinned mechanical skill uses an older version | Resolve version freshness before the routed workflow |
| Proposed agent is current but parent version is old | Resolve the parent's version; delegation cannot waive it |
| Child receives fresh public release evidence in its brief | Reuse that evidence and check child-runtime access separately |
| Late downshift between current tiers | Keep the existing switching-overhead test |
| Claude alias resolves to an older provider-specific version | Apply the current-version availability check and explicit-choice path |
| Background execution support unknown | Retain existing execution-mode checks; a current model grants no permission |

## Verification and remaining work

- All 31 Python tests passed: 27 metadata/delivery tests and four release-version tests.
- PowerShell/POSIX hook parity passed all eight cases. The skill validator passed, and both
  plugin manifests passed the release-version check for candidate 1.2.0.
- Direct selected-policy and missing-policy dry runs emitted 656 and 1,426 UTF-8 bytes,
  respectively, within the 2,000-byte budget. The selected path resolves to the candidate
  source; the missing-policy probe emits its NOTE. These checks verify delivery, not compliance.
- Tests used Git for Windows' POSIX tools on the process PATH and a temporary `python3`
  shim pointing to the installed Python interpreter. The initial metadata run could not find
  `sh`; no plugin-source change was needed to fix the test environment.
- Shared instructions defer model versions and access to the plugin. Claude imports that
  source. The duplicated fallback and stale version list were removed without copying trigger
  markers into the shared instructions. A soft reload used the current shared source and its
  scoped instruction file; earlier conversation context remains.
- Backups and local verification logs are outside the repositories in a timestamped temporary
  directory. The privacy review found only generic model-policy content in added lines.
- The pull request and CI provide the candidate's commit-bound verification record.
  Release publication, consumer pins, and plugin-manager installation follow a tested merge.
- Live behavioral checks on newly installed hooks, native pickers, hosted clients, and
  subagent execution: not run.

## Pull request review

Scope: seven plugin files, including this evidence record. Correctness review traced the
changed rules through the hook's selected-policy delivery and the decision walkthrough above.
The policy, manifests, and documentation were reviewed with coding-standards, writing-style,
and remove-ai-tells. No language-specific source file changed.

| Check | Ran | Found | Fixed | Left, and why |
| --- | --- | --- | --- | --- |
| Correctness and policy delivery | Yes | No further defect | None | Live model compliance needs installation |
| Standards and consistency | Yes | No further defect | None | No source-code change |
| Behavior descriptions | Yes | Pending-authorization wording after shipping approval | Updated verification record | Publication remains pending |
| Writing and character scan | Yes | No character or citation residue in added lines | None | Model names and control labels retained |
| Detector validation | Yes | Salted em dash and citation residue detected | None | None |
| Tests and release metadata | Yes | 31 Python tests, eight parity cases, and validation passed | None | Commit-bound CI runs on the PR |
