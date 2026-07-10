# Goal 00: Capability Baseline And Proof Harness

**Status**: selected — ready for delivery
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `examples`; `radix` and `faber` only for harness seams
**Depends on**: none
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first

## Purpose

Turn “80 percent equivalent to three.js” into a durable, machine-checkable
capability ledger and workload suite before implementation begins.

## Invariant

A Triga capability is counted only when a Faber-authored workload exercises it
through its canonical execution path with durable positive and negative
evidence.

## Scope

- Inventory the official three.js core/manual families relevant to the campaign
  and map them to the weighted scorecard.
- Define sub-capabilities, points, mandatory floors, exclusions, and evidence
  requirements without changing the campaign's weights or 80-point threshold.
- Establish public workload locations, fixture/asset policy, expected-output or
  image-comparison policy, browser result protocol, and generated-artifact
  freshness checks.
- Create baseline manifests for all mandatory capstones and record unsupported
  states without leaving ordinary CI permanently failing.
- Record which validations run in Triga, Radix, Faber, runtime, examples, and a
  WebGPU-capable browser.

Out of scope: implementing math, scene, renderer, shader, material, asset, or
host features merely to turn the baseline green.

## Gate

- The scorecard is represented in a versioned ledger whose points sum to 100.
- Every point maps to a named proof, owner repo, and current evidence state.
- All five mandatory capstones have fixtures or fixture manifests and honest
  unsupported baselines.
- The harness distinguishes parse/typecheck, generated Rust, MIR/WGSL,
  host-executed compute, and host-rendered graphics claims.
- A documented command reports score, mandatory-floor state, stale artifacts,
  and unavailable browser validation separately.

## Validation Direction

Delivery must select exact commands. Prefer one repo-owned orchestrator that
invokes narrow existing checks rather than duplicating compiler logic or
requiring global Node/Bun tooling.

## Stop Conditions

- Scoring is based on class or method counts.
- A visual claim lacks a deterministic numeric, structural, pixel, or approved
  screenshot contract.
- Unsupported capabilities are hidden to keep the ledger green.
- Stage 0 starts implementing campaign features instead of establishing proof
  and routing infrastructure.
