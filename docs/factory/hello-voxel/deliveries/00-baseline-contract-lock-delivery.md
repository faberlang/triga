# HV-00 Delivery: Baseline And Contract Lock

**Parent goal**: [`../goals/00-baseline-contract-lock.md`](../goals/00-baseline-contract-lock.md)
**Factory admission**: ACTIVE; Triga inventory complete, Radix red fixtures pending
**Primary repo**: `triga` for the current pass; `radix` for deferred red fixtures
**Supporting repos**: `triga`, `faber`

## Interpreted Unit

Produce the executable-truth contract and red evidence that all later Hello
Voxel work inherits. This unit records current support and adds focused failing
fixtures only where a missing capability needs an implementation entry point.

## Normalized Spec

- Inventory producer, artifact, host, package, and Triga source facts.
- Record one owner and representation for every first indexed-draw fact.
- Pin the locked position/color/index/transform/pipeline contract from Goal 01.
- Distinguish implemented, scaffolded, absent, and stale-document claims.
- Add focused red tests for fragment admission and compute-only graphics host
  rejection. A red test must reach the intended assertion.
- Do not implement graphics lowering or WebGPU draw behavior.

## Repo-Aware Baseline

- Radix source vertex scaffold: `crates/radix/src/driver/mod.rs`.
- Device roles: `crates/radix/src/mir/device.rs` and `mir/lower.rs`.
- ABI/reflection: `mir/abi.rs`, `tool/commands/reflection.rs`, and adjacent tests.
- Browser consumer: `hosts/webgpu-browser/public/src/faber-kernel.js`.
- Host effects: `hosts/webgpu-browser/public/src/webgpu-runtime.js`.
- Proof driver: `scripta/webgpu-browser-proof`.
- Faber packaging: `faber/src/package/product.rs` and `manifest.rs`.
- Triga layout source: `triga/src/geometry.fab` and
  `triga/exempla/triga-stage4-source-facts.fab`.

## Stage Graph

### HV-00A - Executable Truth Inventory

**Status**: complete for Triga-owned evidence
**Output**: a fact/owner/state table saved beside this delivery spec.
**Write scope**: `triga/docs/factory/hello-voxel/` only.
**Gate**: every Goal 01 locked fact maps to a live type, generated field, missing
field, or platform-owned value.
**Evidence**: [`../goal-00-contract-map.md`](../goal-00-contract-map.md)

### HV-00B - Red Admission Fixtures

**Status**: pending Radix ownership
**Depends on**: HV-00A
**Output**: focused Radix and browser-consumer tests that expose the first
missing fragment and graphics-adapter boundaries.
**Write scope**: adjacent test modules under `radix/crates/radix/src/` and
`radix/hosts/webgpu-browser/public/src/`.
**Gate**: tests fail for named unsupported behavior and preserve compute checks.
**Current constraint**: Radix has active foreign implementation work. Do not
write these fixtures from a Triga-only pass.

### HV-00C - Contract Freeze

**Status**: pending HV-00B
**Depends on**: HV-00B
**Output**: final contract matrix, fixture handles, exact validation commands,
and any revisions propagated to Goal 01/02 delivery specs.
**Write scope**: Hello Voxel planning docs only.
**Gate**: no downstream unit must select between incompatible representations.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-00A | Live code and test evidence supports every state claim | No implementation |
| HV-00B | Red tests reach fragment/graphics admission boundaries | No broad test refactor |
| HV-00C | Contract matrix is internally linked and dependency-ready | No new campaign |

Safe parallelism is limited to read-only inventory across repos. Red fixture
writes and contract freeze are serialized.

## Checkpoints And Gates

- **Checkpoint**: Goal 00 gate passes and HV-01/HV-03 can start.
- **Batching / Split Decision**: discovery followed by one red-fixture batch.
- **Release decision**: not applicable; this is internal planning and red proof.
- Do not commit unrelated existing dirt from Radix or Faber.

## Validation

- `git diff --check` in every modified repo.
- One filtered `cargo test -p radix <new_fragment_filter>` with an explicit
  120-second runner timeout.
- `node hosts/webgpu-browser/public/src/product-boundary-check.mjs` for existing
  compute admission, plus the new focused graphics rejection check.
- `./scripta/check-source` from `triga` if Triga source facts change.
- Confirm the intended new tests are red before HV-01/HV-02 implementation.

## Companion Skill Plan

- `correctness`: confirm red fixtures fail at the intended boundary.
- `consequences`: check reflection schema and browser-consumer blast radius.
- `polish`: planning files and modified focused test files before commit.

## Open Questions

None blocking. Inventory findings may revise delivery details but may not change
the accepted application boundary without returning to the campaign.
