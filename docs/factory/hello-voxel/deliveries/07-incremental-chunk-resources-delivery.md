# HV-07 Delivery: Incremental Chunk Resource Lifecycle

**Parent goal**: [`../goals/07-incremental-chunk-resources.md`](../goals/07-incremental-chunk-resources.md)
**Factory admission**: READY (HV-05 + HV-06 accepted on tip)
**Primary repos**: `examples`, `hosts`
**Supporting**: `triga` (consume-only helpers; no product expansion unless proven gap)

## Tip re-ground (2026-07-21 lower)

| Surface | Tip / evidence |
| --- | --- |
| examples Goal 06 theme | `e968cc3` HV-06A · `271d514` HV-06B · `5e51214` HV-06C · `4536ca0` REPAIR (HEAD) |
| examples Goal 05 theme | `59e6326` HV-05A · `810e8d2` HV-05B · `34eec9b` HV-05C |
| hosts graphics | `4f1922f` HEAD — create/submit path exists; **no** queue-completion retire API; single-draw residual |
| triga resource helpers | `scene.fab` `ResourceHandle` / `ResourceTransition` / `ResourceLifecycleTransition` + batch facts (live) |
| Host path correction | Canonical host is sibling **`hosts/webgpu-browser/`**, not `radix/hosts/…` (Goal 02 re-ground) |

**Live grounding**:
- `examples/hello-voxel/src/voxel.fab` — authoritative world; `world_set` exists; **no** dirty-set / generation model yet.
- `meshing.fab` — full remesh of one chunk; no incremental dirty drain.
- `application.fab` — place/remove mutate world; `main.fab` remeshes and re-emits after edits via residual **concatenated single-buffer** path (`data-hv-residual-path="concatenated-single-buffer"`). Draw/resource counts are ownership facts, not host multi-draw.
- `hosts/webgpu-browser/public/src/webgpu-runtime.js` — `createGraphicsResources`, `runGraphicsFrame*`, depth replace destroy; **no** per-chunk buffer map, create-before-retire, or `onSubmittedWorkDone` retirement counters.

**Unit graph unchanged**: HV-07A → (parallel after contract freeze) HV-07B → HV-07C. Delivery text below remains Hand authority, with host path and multi-draw residual clarified in scopes.

**Multi-draw residual (from HV-05C / HV-06C want)**: folds into **HV-07B** host resource path. Goal 07 cannot prove stable per-chunk generation or unaffected-chunk buffer identity while the host still owns one concatenated world buffer. HV-07A may still land pure dirty/generation facts on the residual path; HV-07C gate requires real per-chunk GPU resources.

## Interpreted Unit

Connect authoritative block edits to deduplicated dirty chunks, derived remeshes,
GPU buffer replacement, queue-safe retirement, and bounded lifecycle evidence.

## Normalized Spec

- Compute the locked affected chunk set for interior and X/Z boundary edits.
- Deduplicate all edits before one pre-submit remesh pass.
- Preserve stable logical chunk identity and increment resource generation only
  when its derived resources change.
- Replace or remove GPU resources based on non-empty/empty remesh results.
- Retire old buffers only after queue completion.
- Expose created/live/retired/destroyed counts and generation values.
- Do not rebuild the world or create a general GPU allocator.

## Repo-Aware Baseline

- Voxel model and mesher: `examples/hello-voxel/src/voxel.fab` and
  `meshing.fab` after HV-05.
- Edit behavior: `application.fab` + `main.fab` after HV-06 (edits remesh today
  via full four-chunk rebuild into residual concatenated upload).
- Triga scene identity provides `ResourceHandle`, `resource_handle_equals`, and
  `resource_handle_next` for logical resource identity and generation advance.
  It also provides pure `ResourceTransition` helpers for unchanged and replaced
  logical resources, plus batch validation for unique logical resource
  transitions. Validated changed/unchanged transition counters and changed plus
  unchanged logical-index extraction support exact affected-chunk assertions.
  Current-handle extraction exposes the full post-transition generation set.
  Changed and unchanged handle extraction separates advanced chunks from stable
  chunks. These helpers support generation and stable unaffected-chunk
  assertions without GPU lifetime policy. Triga also provides
  `ResourceLifecycleTransition` constructors for unchanged, replaced, created,
  and removed single-resource states, so empty chunk remeshes can be represented
  as no-current-resource facts before host disposal. Batch lifecycle validation,
  a packaged lifecycle batch fact record, changed/unchanged/removed/live
  logical-index extraction, retired logical-index extraction, unchanged handle
  extraction, retired previous-handle extraction, and current-handle
  extraction provide exact per-chunk generation, affected-set, stable
  unaffected chunk, removed-chunk, old resources that need retirement, and
  live-resource evidence. Queue completion, GPU destruction, and destroyed
  counters remain host-owned. Prefer consume-only of these helpers; do not move
  voxel dirty policy into Triga.
- Host buffer creation/submission: sibling monorepo
  `hosts/webgpu-browser/public/src/webgpu-runtime.js` after HV-02/HV-04
  (not `radix/hosts/…`). Existing compute path owns buffer usage and queue
  submission as evidence only — do not duplicate graphics lifecycle under a
  second module name.

## Stage Graph

### HV-07A - Dirty Chunk And Generation Model

**Output**: affected-set calculation, deduplication, dirty drain, logical ids,
and resource-generation transitions in Faber.
**Write scope** (primary `examples`):
- `examples/hello-voxel/src/voxel.fab` and/or `meshing.fab` / `application.fab`
  (dirty set, logical chunk id, generation advance on derived change)
- focused fixtures under `examples/hello-voxel/tests/` (interior, four X/Z
  edges, corners, repeated same-frame edits, no-op `world_set`, empty remesh)
- optional consume-only of Triga `ResourceHandle` / lifecycle helpers
**Gate**: interior, four X/Z edges, corners, repeated edits, and no-op mutations
produce exact affected sets and generations. No GPU effects in Faber.

### HV-07B - Queue-Safe Resource Replacement

**Depends on**: replacement payload contract with HV-07A (logical id + generation
+ mesh payload / empty); may start in parallel once that contract is frozen.
**Output**: host API for **per-chunk** create-before-retire replacement, empty
removal, queue completion, destruction, and counters. Closes the HV-05C
multi-draw residual: one resource pair (position/color + index) and one draw
per non-empty chunk identity, replaceable independently.
**Write scope** (primary `hosts`):
- `hosts/webgpu-browser/public/src/webgpu-runtime.js` (+ Node/fake-device tests
  beside host fixtures)
- narrow adapter touch in `examples/hello-voxel` only if the app→host payload
  shape must name per-chunk slots (no host world mutation)
**Gate**: resources are not destroyed while referenced; `queue.onSubmittedWorkDone`
(or equivalent completion promise) retires them; invalid transitions reject;
created/live/retired/destroyed counters are honest; multi-draw residual path
is gone from the admitted Hello Voxel graphics route.

### HV-07C - Repeated Edit Browser Proof

**Depends on**: HV-07A and HV-07B
**Output**: scripted interior/boundary place-remove cycles with stable unaffected
ids and bounded counters across submitted frames.
**Write scope**:
- `examples/hello-voxel/src/main.fab` + application wiring (dirty drain → remesh
  → host replace only affected chunks)
- proof script under `examples/hello-voxel/tests/` / `scripta/` (extend HV-06C)
**Gate**: only exact affected chunks advance generation; unaffected chunk
resource identities stay stable; live counts return to the expected bound after
queue completion; repeated place/remove does not unbounded-grow live buffers.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-07A | Dirty sets and generations are deterministic | No GPU effects in Faber |
| HV-07B | Replacement and retirement obey queue completion | No general allocator |
| HV-07C | Repeated browser edits keep bounded live resources | No streaming/workers |

HV-07A and HV-07B have disjoint repos and can run in parallel after their
replacement payload contract is frozen. HV-07C integrates both.

## Checkpoints And Gates

- **Checkpoint**: dynamic voxel edits are resource-safe; HV-08 is unblocked.
- **Batching / Split Decision**: split application invalidation, host effects,
  and integrated proof at repo and lifecycle boundaries.
- **Release decision**: defer until final clean-break proof.
- Rebuilding all chunks or relying on garbage collection for disposal fails.

## Validation

- Focused Faber tests for affected sets, deduplication, no-op edits, empty chunks,
  and logical/resource generations.
- Node tests with a fake device/queue for transition order and completion.
- Actual WebGPU repeated edit cycles with counters sampled after queue completion.
- Re-run HV-05 face/boundary and HV-06 edit regressions.

## Companion Skill Plan

- `red-green`: affected-set and lifecycle transition tables.
- `correctness`: queue completion, double destroy, use after retire, empty/non-empty
  transitions, and counter honesty.
- `optimization`: read-only confirmation that update scope is chunk-bounded.
- `polish`: modified Faber, JavaScript, and proof sources.

## Open Questions

None blocking. If queue completion is unavailable in the current browser surface,
stop and extend the platform host contract; do not substitute a frame-count guess.
