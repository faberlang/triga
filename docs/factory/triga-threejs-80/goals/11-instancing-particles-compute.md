# Goal 11: Instancing, Particles, And Compute Integration

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `radix`, browser host, `examples`
**Depends on**: Goals 03–05; consumes the existing MIR GPU compute foundation
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first for shared compute/render resources; batch-by-default afterward

## Purpose

Prove that Triga can express GPU-scale workloads rather than only CPU-built
small scenes, reusing MIR GPU compute facts in graphics pipelines and stressing
resource sharing, instance data, synchronization, indirect data, and
high-cardinality rendering.

## Invariant

Compute and render stages share compiler-described resources directly; host
readback or CPU rebuilding cannot erase the claimed GPU execution path.

## Scope

- Define instanced object data and per-instance transforms/colors with stable
  scene/resource identity and bounds policy.
- Render one high-count instanced mesh workload through admitted instance
  attributes or storage-buffer access.
- Define points/particle geometry and use a Faber-emitted compute kernel to
  update render-consumed state.
- Extend reflection/host contracts for compute-to-render resource sharing,
  ordering, visibility, and barriers required by the selected proof.
- Consider indirect draw data only if it follows from the same bounded resource
  path; otherwise record it as a scored deferral.
- Include performance-shape evidence such as object/particle count and absence
  of per-frame host round trips, without turning the campaign into a benchmark
  competition.

Out of scope: general ECS, physics, distributed simulation, exhaustive GPU
sorting, and target-specific hand-written kernels.

## Gate

- The GPU-scale capstone renders a high-count instanced or particle scene.
- At least one Faber compute kernel updates state consumed by a subsequent
  render pass without readback/re-upload.
- Reflection and host scheduling describe shared resource access and ordering.
- Unsupported hazards, layouts, or device limits fail before submission.

## Stop Conditions

- Host JavaScript updates each instance/particle as the primary path.
- Compute results are read back only to rebuild render buffers on the CPU.
- Resource synchronization is implicit or target-specific inside an emitter.
- Performance claims lack workload-shape and transfer evidence.
