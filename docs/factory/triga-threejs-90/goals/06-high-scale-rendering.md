# Goal 06: High-Scale Rendering

**Status**: parked surface brief
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Reserved increment**: 1.0 point
**Likely owners**: `triga`, `radix`, graphics host/runtime, `examples`
**Depends on**: successor Stage 0, verified instancing/compute integration, and stable render/resource contracts
**Lowers to**: `delivery` → `factory` only after campaign activation

## Purpose

Move beyond a first high-count proof into sustained large-scene behavior that
pressures ownership, memory residency, visibility, update granularity, GPU
scheduling, and performance observability.

## Surface Area

- Batching and merged/instanced draw organization beyond one demonstration.
- LOD policy, deeper visibility/occlusion work, bounds maintenance, and scene
  traversal behavior at high cardinality.
- Indirect or GPU-driven draw preparation where selected targets support it.
- Streamed resource residency, eviction/disposal, dirty-range updates, and
  avoidance of per-object host work or whole-buffer rebuilding.
- Measured workload shape covering counts, transfers, memory, submissions, and
  frame behavior rather than an unqualified performance claim.
- Degradation and device-limit behavior that remains explicit and fail-closed.

## Boundary

The later delivery spec must freeze representative workloads and thresholds
from measured baselines. General ECS design, physics, distributed simulation,
and benchmark competition are outside this brief.
