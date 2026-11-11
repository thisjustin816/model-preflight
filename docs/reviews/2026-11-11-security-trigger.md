# Security escalation boundary

Reviewed November 11, 2026, against baseline `f22ef44` (version 1.4.0).

## Decision

The security trigger treated any code change involving authentication, secrets, permissions,
or untrusted input as an escalation. A routine review combining additional error details with
an API scope correction exposed the problem: the subject matter triggered a stronger-model
offer without identifying a reasoning problem that needed one.

Require substantive security judgment about exploitability, trust boundaries, privilege
escalation, or competing security designs. Routine logging, documented API scope corrections,
and established security patterns remain ordinary work unless they introduce that problem.
A small diff can still need escalation when its security behavior is ambiguous.

This routing decision follows observed over-escalation and the maintainer's requested boundary.
Model versions, tiers, controls, availability checks, delegation approval, and switch handshakes
retain their existing rules. No model comparison ran; the previous model-release review remains
the version baseline.

## Representative policy decisions

These are manual checks of the written rule, not live model evaluations or automated proof
that an agent will follow it. OpenAI examples assume a current Sol session at medium reasoning.
Other surfaces apply the same trigger through their existing tier mappings.

| Task | Expected route | Reason |
| --- | --- | --- |
| Add an API response's error details to an existing deployment warning, preserving existing credential handling | Ordinary tier | Routine diagnostic change with no unresolved security decision |
| Add the scope documented as required for an existing API operation | Ordinary tier | Established access requirement; no competing access design to resolve |
| Review an obvious scanner finding and apply the project's established parameterized-query pattern | Ordinary tier | The finding's label alone does not establish a hard reasoning problem |
| Decide whether a script-execution permission is necessary when documentation and observed access disagree | Escalated tier | Requires substantive judgment about access boundaries and privilege |
| Trace attacker-controlled input through several decoding steps to decide whether an authorization bypass is exploitable | Top-tier hard-question exception | Adjudicates an exploit path whose failure may be slow to surface |
| Choose between access designs that expose different tenants' data | Escalated tier; top tier if the existing hard-question exception applies | Competing trust boundaries and access contracts |
| Fix a bug still unexplained after reading its implementation | Escalated tier | The separate unexplained-bug trigger still applies |
| Execute a settled release sequence across repositories | Ordinary tier | Repository breadth alone does not trigger escalation |
| Verify a current model, encounter unknown access, or consider a delegated task | Existing availability and approval rules | This correction changes only the security task trigger |

## Verification and publication

Local verification on macOS:

- Python suite: 30 passed, one host-specific path-length case skipped.
- PowerShell/POSIX hook parity: all eight cases passed, including partial and missing policies.
- Hook dry runs selected the source policy and emitted the missing-policy diagnostic; opening
  contexts were 663 and 1,355 UTF-8 bytes, within the 2,000-byte budget.
- Release-version consistency and whitespace checks passed. Both manifests remain at 1.4.0;
  this source correction has not been packaged as a release.
- Hook marker structure, basic frontmatter, documentation links, and privacy checks passed.
  Skill validation also passed using an isolated temporary environment with PyYAML.
- Reviewed the nine representative decisions above against the full policy. These are manual
  policy checks; hook transport tests do not prove live routing compliance.

No CI or live-agent evaluation ran for this correction. The installed plugin cache remains on
its published version; publication, consumer pins, and plugin-manager updates are still required
before the revised source becomes the installed policy.
