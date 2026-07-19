# HV-07 Delivery: Incremental Chunk Resource Lifecycle

**Parent goal**: [`../goals/07-incremental-chunk-resources.md`](../goals/07-incremental-chunk-resources.md)
**Factory admission**: READY after HV-05 and HV-06
**Primary repos**: `examples`, `radix`

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
- Edit behavior: `application.fab` after HV-06.
- Triga scene identity provides `ResourceHandle`, `resource_handle_equals`, and
  `resource_handle_next` for logical resource identity and generation advance.
  It also provides pure `ResourceTransition` helpers for unchanged and replaced
  logical resources, plus batch validation for unique logical resource
  transitions. Validated changed/unchanged transition counters and changed plus
  unchanged logical-index extraction support exact affected-chunk and stable
  unaffected-chunk assertions without GPU lifetime policy. GPU lifetime and
  queue completion remain host-owned.
- Host buffer creation/submission: Radix browser WebGPU runtime after HV-02.
- Existing compute runtime already owns buffer usage and queue submission; its
  semantics are evidence, not permission to duplicate graphics lifecycle code.

## Stage Graph

### HV-07A - Dirty Chunk And Generation Model

**Output**: affected-set calculation, deduplication, dirty drain, logical ids,
and resource-generation transitions in Faber.
**Write scope**: Hello Voxel voxel/meshing/application modules and tests.
**Gate**: interior, four X/Z edges, corners, repeated edits, and no-op mutations
produce exact affected sets and generations.

### HV-07B - Queue-Safe Resource Replacement

**Depends on**: HV-07A
**Output**: host API for create-before-retire replacement, empty removal, queue
completion, destruction, and counters.
**Write scope**: Radix browser graphics runtime and focused Node tests.
**Gate**: resources are not destroyed while referenced; completion retires them;
invalid transitions reject.

### HV-07C - Repeated Edit Browser Proof

**Depends on**: HV-07A and HV-07B
**Output**: scripted interior/boundary place-remove cycles with stable unaffected
ids and bounded counters across submitted frames.
**Write scope**: application-host integration and proof script.
**Gate**: only exact affected chunks advance generation; live counts return to
the expected bound after queue completion.

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
