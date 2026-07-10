# Goal 12: Capstones And 80-Point Audit

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: all participating repositories
**Depends on**: every goal contributing to the claimed score
**Lowers to**: `delivery` → `factory`
**Batching posture**: split-on-boundary for audit fixes; batch homogeneous residuals after findings stabilize

## Purpose

Independently verify that Triga delivers the promised workload capability and
that the campaign hardened Faber/Radix rather than accumulating demos,
host-side substitutions, policy exceptions, or undocumented gaps.

## Invariant

Campaign completion is an evidence-backed capability claim: score, mandatory
floors, capstones, negative behavior, ownership, and broad validation must all
agree with the live repositories.

## Scope

- Run `poker-face` against the campaign, all stage goals, score ledger,
  capstones, delivery records, and live code.
- Recalculate the score from proof evidence; no manual point overrides.
- Execute all five mandatory capstones without three.js runtime dependencies
  and verify their structural/numeric/pixel contracts.
- Audit source-to-host ownership for shadow scene graphs, shader/layout guesses,
  host reimplementations, target-specific compiler shortcuts, stale generated
  artifacts, and weakened negative tests.
- Run broad Triga, Radix, Faber, runtime, examples, target, and browser
  validation appropriate to the final claim.
- Document the remaining 20 percent, deferred three.js/addon families, target
  limitations, environment gaps, performance shape, and next-campaign options.
- Make an explicit release/version decision after evidence is complete.

Out of scope: implementing unrelated late features merely to make the score
look round or claiming production readiness.

## Gate

- Verified score is at least 80/100 and every domain mandatory floor passes.
- All mandatory capstones run from Faber source through canonical paths with no
  three.js runtime dependency.
- Unsupported and malformed cases fail closed under the documented contracts.
- Broad validation passes or every environment-only omission is separately
  identified without upgrading the claim.
- The remaining 20 percent and all known material gaps are documented.
- The campaign artifact, goal statuses, ledgers, and factory index agree.
- Release prep, internal milestone, or continued foundation work is chosen
  explicitly.

## Stop Conditions

- Score depends on declarations, planned work, hand-written generated outputs,
  or host-side feature substitutes.
- A mandatory floor or capstone is waived to reach 80.
- Browser/GPU validation is unavailable and the completion claim is upgraded
  anyway.
- Audit findings are hidden, reclassified, or fixed by weakening the proof.
- “80 percent equivalent” is presented as production or source compatibility
  with three.js.
