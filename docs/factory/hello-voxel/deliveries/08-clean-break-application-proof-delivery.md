# HV-08 Delivery: Clean Break And Application Proof

**Parent goal**: [`../goals/08-clean-break-application-proof.md`](../goals/08-clean-break-application-proof.md)
**Factory admission**: READY after HV-00 through HV-07
**Primary repos**: `examples`, `radix`, `triga`
**Supporting repo**: `faber`

## Interpreted Unit

Assemble one reproducible Hello Voxel product proof, remove obsolete three.js
runtime paths, update only earned evidence, and run an independent closeout audit.

## Normalized Spec

- Build and serve `examples/hello-voxel/` through canonical Faber packaging.
- Execute the locked multi-frame movement/select/remove/place/resize flow.
- Tie structural, interaction, resource, and pixel evidence to one artifact id.
- Remove executable three.js imports, import maps, objects, and fallback routes
  from the Triga and Radix browser fixtures.
- Preserve compute proof honesty and concise historical documentation.
- Upgrade capability/campaign state only at the evidence level actually run.
- Defer publishing until a separate release decision.

## Repo-Aware Baseline

- Product package and proof scripts from HV-03 through HV-07.
- Radix host and proof driver under `radix/hosts/webgpu-browser/` and
  `radix/scripta/webgpu-browser-proof`.
- Triga three.js fixture under `triga/exempla/threejs-host-demo/`.
- Triga capability ledger and checker under `triga/proof/` and
  `triga/scripta/check-capabilities`.
- Triga Hello Voxel runtime dependency checker under
  `triga/scripta/check-hello-voxel-runtime-deps`.
- Campaign state under `triga/docs/factory/hello-voxel/` and the older Three.js
  80 breadth reference.
- Triga runtime dependency inventory:
  [`../runtime-dependency-inventory.md`](../runtime-dependency-inventory.md).

## Stage Graph

### HV-08A - Unified Proof Harness

**Output**: one build/serve/check flow and proof state containing artifact,
pipeline, frame, interaction, dirty-chunk, visible-resource, and lifecycle facts.
**Write scope**: Hello Voxel package/proof and narrowly required producer scripts.
**Gate**: static checks and actual browser checks are separately labeled and
consume the same artifact identity.

### HV-08B - Runtime Dependency Removal

**Depends on**: HV-08A passing direct graphics
**Output**: deletion or conversion of executable three.js fixture code/imports
with no fallback alias or hidden CDN import.
**Write scope**: named Radix/Triga browser fixtures and their docs/checks.
**Gate**: bounded runtime scan is empty; compute and Hello Voxel proofs remain
honest; historical prose does not execute.

### HV-08C - Evidence, Audit, And Closeout

**Depends on**: HV-08B
**Output**: scripted success/failure receipts, pixel evidence, capability updates,
independent review, campaign status, and release decision.
**Write scope**: proof outputs allowed by repo convention and planning/ledger docs.
**Gate**: independent audit finds no proxy success, hidden shim, stale artifact,
or unsupported capability claim.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-08A | One artifact passes structural and browser application flow | No release |
| HV-08B | Runtime third-party renderer scan is empty | No compatibility fallback |
| HV-08C | Evidence is honest and independent audit passes | No successor features |

Proof harness must pass before removal. Evidence updates and audit follow the
clean break; they must not be written speculatively in parallel.

## Checkpoints And Gates

- **Checkpoint**: Hello Voxel campaign completion candidate.
- **Batching / Split Decision**: split proof admission, clean removal, and
  evidence/audit at destructive-clean-break and claim boundaries.
- **Release decision**: explicit `release-prep`, `release-now`, or
  `defer-release` decision after audit; default is `defer-release`.
- Do not remove historical material needed to explain the migration, but ensure
  it cannot execute as an alternate renderer.

## Validation

- All named Triga source, compile, transform, inventory, and capability checks.
- `./scripta/check-hello-voxel-contract` for the Triga-owned pre-browser
  contract gate.
- Radix focused compiler tests and `./scripta/webgpu-browser-proof check`.
- Faber browser package tests and deterministic rebuild comparison.
- Hello Voxel actual browser flow with structural and pixel evidence.
- Repeated edit/resource lifecycle proof after queue completion.
- Bounded `rg` runtime scan across `triga`, `radix`, `faber`, and `examples` for
  imports/CDN scripts/runtime references to third-party renderers.
- Triga-owned scan expectations and historical-reference boundaries from
  [`../runtime-dependency-inventory.md`](../runtime-dependency-inventory.md).
- `./scripta/check-hello-voxel-runtime-deps` before cleanup and
  `./scripta/check-hello-voxel-runtime-deps --post-clean-break` after cleanup.
- Independent `poker-face` and correctness review against Goal 08.

## Companion Skill Plan

- `poker-face`: promise-versus-proof closeout.
- `correctness`: failure outcomes, artifact coupling, lifecycle counters.
- `clean-break`: remove executable old routes without shims.
- `housekeeping` and `polish`: after implementation and before audit.

## Open Questions

No planning blockers. Browser GPU or pointer-lock evidence that cannot run must
remain unavailable; it blocks campaign completion unless the user explicitly
changes the acceptance boundary.
