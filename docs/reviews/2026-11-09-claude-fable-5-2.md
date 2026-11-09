# Claude Fable 5.2 and task guidance

Reviewed November 9, 2026, against `8f4ec71` (1.3.0), following the
[preset routing review](2026-11-09-preset-routing.md). The prior model-release review was
[November 2](2026-11-02-current-versions.md). This update covers the November 9 Claude release
and task guidance. OpenAI routing retains the 1.3.0 decisions.

## Evidence

All sources below were checked November 9, 2026. Public documentation establishes product
capability, not access for a particular account or subagent runtime.

| Source | Fact and scope |
| --- | --- |
| [Model selection playbook](https://claude.dev/blog/which-claude-model-should-you-build-with/) (published November 9) | Recommends Opus medium for general coding and knowledge work, Sonnet medium for scoped tasks, and Fable medium then high for the hardest work in Code. Haiku medium suits high-volume extraction. Everyday artifacts use Sonnet high, with medium in Code. |
| [Fable 5.2 launch](https://www.anthropic.com/claude-fable-and-mythos-5-2) (November 9) | Fable 5.2 is generally available; Mythos remains verification-gated. Launch evaluations support considering Fable on difficult technical work, without proving savings on this maintainer's tasks. |
| [Code model configuration](https://code.claude.com/docs/en/model-config) and [Code changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md) | Version 2.1.321 adds Fable 5.2. Its Code default is medium. The apps gateway can still resolve `fable` to 5; third-party `haiku` aliases can resolve to 4.5. Current Code models keep adaptive Thinking on. |
| [Chat controls](https://support.claude.com/en/articles/8664678-change-the-model-effort-and-thinking-settings) | Fable 5.2 exposes effort. Current Haiku, Sonnet, Opus, and Fable models have fixed-on Thinking in chat; API disable options differ. |
| [Fable plan access](https://support.claude.com/en/articles/15424964-claude-fable-models-on-your-plan) | Code needs 2.1.321; Cowork needs current Desktop. Organization controls and seat billing affect access. Included limits and usage credits differ; API prices cannot predict remaining subscription allowance. |
| [Cowork guidance](https://claude.com/resources/articles/working-with-claude-fable-5-in-claude-cowork) (July 16) | Discusses Fable 5 and complex autonomous work; it does not establish Fable 5.2's Cowork default effort. |
| [Claude release notes](https://support.claude.com/en/articles/12138966-release-notes) | The fetched page ends at November 6. The November 9 launch and Code documentation supply the newer release evidence. |
| [Permission modes](https://code.claude.com/docs/en/permission-modes) | Execution-mode support remains separate from model selection and user authorization. |
| [OpenAI models](https://learn.chatgpt.com/docs/models) and [changelog](https://learn.chatgpt.com/docs/changelog) | Rechecked the provider entrypoints. Sol 6.1 remains the documented ordinary-work family version. No OpenAI criteria changes are part of this Claude update. |

The web reader could not retrieve the playbook or launch article; both full pages were fetched
directly from their official hosts. The Code changelog was fetched from the official repository's
raw file because the GitHub HTML view omitted its contents. Search snippets alone were not used
to establish these changes.

## Routing decisions

These are documentation-based maintenance judgments. No paid API evaluation or comparative
task run was performed.

| Prior rule | Revised rule and reason |
| --- | --- |
| Sonnet medium for all ordinary work | Opus medium for general coding and knowledge work; Sonnet medium for clearly scoped tasks and interactive chat. This adopts the playbook's distinction without promoting a bounded spec-driven edit. |
| Haiku low for all mechanical tasks | Keep low for trivial work; use medium for high-volume extraction and bounded reading. The latter matches the current default and task guidance. |
| Sonnet medium for all drafting | Everyday artifact creation starts high outside Code; Code starts medium. Ordinary explanations and summaries retain medium. |
| Opus high for substantive escalation | Retain it with a concrete reasoning justification. General Opus work at medium is distinct from an Escalate task. |
| Fable high everywhere | Fable 5.2 medium in Code; retain high in chat and Cowork. Code and API defaults differ, and neither proves a product picker default elsewhere. |
| Generic switching-cost uncertainty | Record model-specific Claude caches and API reasoning loss on a downward Fable switch; keep effort-only behavior qualified by model and client. |
| Thinking qualified only generically | Explicitly omit the toggle for current Code and chat models. Check Cowork controls separately. |

Downshift explicitly includes the surface's scoped-work pair, so its general default rule does
not override Sonnet for a bounded task. OpenAI and ordinary Chat retain their existing pairs.

The existing hard-question exception continues to select Fable directly; a failed lower-tier
attempt is not required. Major migrations, difficult architecture, and deep technical research
fit it when the actual reasoning and failure consequences warrant it. Duration and file count
alone still do not establish difficulty. A serious failed Opus-high attempt also qualifies.
Routine verification does not raise effort. Consider self-checking and one effort step for
ordinary tasks, and Fable before pushing Opus above high. None of these rules permits a silent
picker change, new background work, an unapproved agent, or a mandatory API benchmark.

## Decision walkthrough

| Situation | Expected decision |
| --- | --- |
| Implement a clear spec with checkable output | Sonnet medium; a bounded task fits the scoped pair |
| Investigate ordinary feature behavior with an open implementation path | Opus medium; ongoing judgment fits general coding |
| Unexplained bug after reading the involved code | Opus high with a task-specific explanation |
| Decide a major migration whose rollback is more expensive | Fable 5.2 medium in Code; high in chat/Cowork; explain benefit and allowance impact |
| Opus high made a serious attempt but failed | Fable starting pair; explain the observed failure |
| Long predetermined run | Mechanical pair; duration alone does not warrant Fable |
| High-volume extraction | Haiku 5.5 medium; verify runtime access separately |
| Single quick fact during a longer session | Keep the session pair if a handoff costs more than the work |
| Routine document summary / everyday slide creation | Sonnet medium / Sonnet high outside Code |
| Older Fable active, newer access known | Version switch or explicit permission for the older release, even on a short task |
| Access unknown / latest source unavailable | Ask once and wait for the required explicit choice |
| User accepted an older version for a bounded scope | Continue within that scope; do not repeat the answered access question |
| Surface or provider changes | Recheck controls, freshness, and access; an alias is not proof |
| Fixed Thinking / unsupported effort | Omit the fixed control / never request an unsupported adjustment |
| Downshift late in a Claude session | Weigh the model-specific cache cost and prefer a natural boundary |
| Background runtime support unknown | Preserve the existing execution-mode gate |
| Delegated work | Preserve explicit approval and independent runtime availability checks |

## Verification and remaining limits

The canonical plugin skill remains the only policy source; hook scripts contain no model table.
Both manifests prepare 1.4.0. Installed caches and consumer pins remain release-managed.
Native Claude pickers, Cowork's current controls, account entitlements, model compliance, and
cross-platform CI have not been exercised in this review. Chat and Cowork Fable high is retained
policy, not a verified 5.2 default. This is a scoped Claude update, not a complete audit of every
OpenAI surface or unrelated product change.

Local verification ran 31 Python tests: 30 passed and one host-path-length case skipped on macOS.
All eight PowerShell/POSIX parity cases passed. Both direct hooks delivered the current-policy
reference in 663 UTF-8 bytes and the missing-policy NOTE in 1,347 bytes, within the 2,000-byte
limit. Skill validation, local documentation links, the hook marker contract, the release-version
check at 1.4.0, and whitespace checks passed. Publication requires the existing reviewed PR,
merged commit, tested tag, and manager-driven installation workflow.
