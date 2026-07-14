# Stage 4 Readiness Map After Stage 2 Acceptance

**Date**: 2026-07-14
**Decision**: Stage 4 - graphics MIR and shader-stage handoff is the selected
next stage.
**Scope**: Triga status and readiness only. This packet does not implement
compiler, provider, host, or proof-ledger changes.

## Current Green Gates

- Stage 1 foundation is cleared: Triga math/transform families, provider path,
  generated Rust, selected MIR CPU/WGSL matrix slices, and fail-closed non-WGSL
  GPU behavior remain green in the campaign record.
- Stage 2 generated-Rust scene identity acceptance is green after Radix/Faber
  producer fixes and the Triga reparent fixture correction. The accepted
  executable gate is `exempla/triga-scene-store.fab` through the Faber
  provider-imported generated-Rust path.
- Stage 3 Triga geometry source is accepted on main at `969b7cb`: the public
  attribute/layout contract exposes explicit shader locations plus ordered
  format, offset, stride, and step-mode facts for CPU comparison.
- Stage 2 status was synced in Triga at `4be7f5b`; no Triga source-owned
  blocker remains for generated-Rust scene identity acceptance.

## Residual Diagnostics

The remaining direct check residual is not a Triga Stage 2 acceptance blocker:

```text
WARN014.file_interface_export_skipped:scene.scene_node
SEM004.unknown_field
SEM010.expression_type_mismatch / initializer_annotation_mismatch
```

Ownership: Radix/Faber provider-interface handling. Keep this routed separately
unless direct source inspection proves a new Triga source defect.

## Selected Next Stage

Proceed with Stage 4 rather than reopening Stage 2. Stage 4 should lower
Triga's completed vertex/layout contract through the existing Radix MIR GPU
shader-stage track, not create a parallel graphics design.

The nearest honest decision is therefore:

- Start a Stage 4 delivery/factory packet against Radix graphics MIR and
  reflection, with Triga supplying the forcing workload and CPU layout facts.
- Keep the direct Radix provider-interface residual as an upstream issue in
  parallel; it should not block the Stage 4 readiness decision.
- Do not promote any capstone or scorecard state until a real graphics proof
  runs at the required level.

## Stage 4 Preconditions

Ready:

- Triga has native source for math, scenes, and geometry/layout facts.
- `attribute_vertex_layout` and `geometry_vertex_layouts` provide the comparison
  seam for reflection without requiring a host to inspect attribute names.
- `geometry_vertex_layout_*` scalar accessors and
  `exempla/triga-stage4-source-facts.fab` now pin the source-owned
  position/normal/uv layout rows that the first Radix reflection fixture must
  match.
- The campaign already names the overlap rule: update the existing MIR GPU
  shader-stage goal instead of designing a second shader-stage path.

Needed from the Stage 4 delivery:

- Select the smallest source-level vertex/fragment entrypoint surface using
  existing annotations and types unless a separate language decision proves new
  syntax is required.
- Lower one matching vertex input through graphics MIR and prove Radix
  reflection agrees with Triga's declared location, format, offset, stride, and
  step-mode facts.
- Define fail-closed diagnostics for mismatched varyings, unsupported types,
  missing outputs, illegal resources, and target-incompatible graphics
  capabilities.
- Preserve existing compute kernels and reflection, or migrate them through an
  explicit shared contract change.

## Ownership Map

| Item | Owner | Stage 4 posture |
| --- | --- | --- |
| Triga vertex/layout contract v1 | `triga` | Ready input; keep source checks green |
| Stage 2 generated-Rust scene identity gate | `triga` + `faber` path | Green; monitor only |
| Direct provider-interface residual | `radix` / `faber` | Upstream parallel residual, not a Triga blocker |
| Shader-stage MIR, legality, diagnostics, WGSL emission | `radix` | Primary next implementation area |
| Graphics reflection agreement | `radix`, forced by `triga` workload | Stage 4 acceptance seam |
| Direct browser/WebGPU lifecycle | `radix/hosts/webgpu-browser` or successor | Stage 5, after Stage 4 reflection exists |
| Public graphics capstones | `examples` | Stay unsupported until host graphics proofs exist |

## Proof And Capstone State

No source-owned proof JSON changes are warranted by this readiness map. The
current `proof/capabilities.json` and `proof/capstones/*.json` ledgers remain
honest baselines: mandatory capstones still require `host_graphics` evidence and
remain `unsupported`.

Stage 4 can produce MIR/WGSL/reflection evidence, but it should not claim the
hierarchical-scene, PBR, animated-gltf, picking-culling, or
multipass-instancing capstones. Those require later direct host graphics or
end-to-end workload proofs.

## Recommendation

Stage 4 graphics MIR and shader-stage handoff is ready to lower next. The first
unit should be a narrow Radix-owned graphics MIR/reflection proof driven by
Triga's existing vertex-layout facts. Stage 5 direct WebGPU rendering should
wait until that reflection agreement exists.
