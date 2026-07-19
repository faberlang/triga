# Goal 07: Incremental Chunk Resource Lifecycle

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
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
