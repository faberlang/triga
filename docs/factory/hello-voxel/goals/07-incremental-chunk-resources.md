# Goal 07: Incremental Chunk Resource Lifecycle

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Delivery**: [`../deliveries/07-incremental-chunk-resources-delivery.md`](../deliveries/07-incremental-chunk-resources-delivery.md)
**Target repos**: `triga`, `radix`, `examples`
**Depends on**: Goals 05 and 06
**Lowers to**: `delivery` -> `factory`
**Batching posture**: discovery-first, then batch resource transition cases

## Purpose

Make block edits update derived geometry and GPU resources without rebuilding
the entire renderer or leaking replaced resources.

## Invariant

A world mutation invalidates only the owning chunk and any neighbor whose
visible faces can change. Resource replacement follows explicit ownership and
disposal state.

## Locked Invalidation And Resource Contract

- An interior edit invalidates its owning chunk. An edit on local X or Z edge
  also invalidates the directly adjacent in-world chunk. Y has no chunk layer
  in the bounded proof.
- Dirty chunks remesh once before the next submitted frame. Multiple edits in
  one frame deduplicate the dirty set.
- Each chunk has stable logical identity separate from replaceable mesh and GPU
  resource generations.
- Empty remesh results remove the chunk draw and destroy its previous buffers.
  Non-empty results create replacement buffers before retiring old buffers.
- Retired buffers are destroyed only after the queue has completed submitted
  work that references them. The host uses an explicit completion fence or
  equivalent WebGPU queue completion promise.
- Proof counters expose created, live, retired, and destroyed buffer counts plus
  per-chunk resource generation.

## Ground Truth And Implementation Path

- Implement dirty-set and logical generation behavior in
  `examples/hello-voxel/src/voxel.fab` and `meshing.fab`.
- Extend graphics resource creation/replacement in
  `radix/hosts/webgpu-browser/public/src/webgpu-runtime.js` or its Goal 02
  graphics sibling. Keep queue completion and destruction in the host.
- Carry resource identity and payload changes through the generated artifact or
  application-to-host contract established by Goals 02-04.
- Add pure affected-set tests and a browser resource-cycle proof. Do not claim
  leak freedom without bounded live-resource counters after repeated edits.

## Scope

- Track chunk mesh validity and resource identity.
- Compute the affected chunk set for interior and boundary edits.
- Rebuild affected CPU meshes and replace corresponding GPU buffers.
- Preserve unaffected chunk resources and stable application identities.
- Dispose replaced buffers only after they are no longer submitted.
- Handle empty chunks, growth, shrinkage, and zero-index transitions.
- Expose deterministic counters or identities for resource-lifecycle evidence.

## Non-Goals

- Background workers, asynchronous streaming, or unbounded queues.
- General-purpose GPU memory allocation or defragmentation.
- Persistent caches or network synchronization.
- Rebuilding all chunks as an accepted fallback.

## Gate

- Interior edits replace one chunk's derived resources.
- Boundary edits replace only the owning and affected neighbor chunks.
- Unaffected chunk resource identities remain stable.
- Removed resources are released without use-after-dispose behavior.
- Repeated place/remove cycles do not cause unbounded live-resource growth.

## Validation

Use deterministic affected-set tests, resource identity/counter assertions,
repeated edit cycles, and browser execution evidence across submitted frames.

## Stop Conditions

- Every edit rebuilds the full world or renderer.
- GPU resources become authoritative world storage.
- Disposal timing is guessed without an explicit submission/lifecycle rule.
- Instrumentation claims leak freedom without counting live resources.
