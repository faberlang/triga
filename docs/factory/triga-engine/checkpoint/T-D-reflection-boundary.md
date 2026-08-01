# T-D: Triga-vs-Radix Reflection Boundary

**Track**: six-parallel research — Triga-vs-Radix reflection boundary
**Date**: 2026-08-01
**Read-only research**: evidence from the live Radix compiler at `/Users/ianzepp/work/faberlang/radix` (commit-agnostic; code cited by crate/path/struct, docs by path).
**Inputs**: [GOAL.md](../GOAL.md) §§"Engine layers" and "Compiler and package ownership" (the engine vision), `docs/factory/mir-gpu` campaign + ledger + Stage 4/8/9 goals, `docs/design/target-capability-matrix.md`, `crates/radix-mir/src/abi.rs` (the frozen ABI seam), `crates/radix/src/driver/mod.rs`, `crates/radix-mir-wgsl/src/lib.rs`, `crates/radix/src/tool/commands/reflection.rs`, `docs/design/reflection-reciprocity.md`, and the triga corpus `reflection.json` fixtures (JSON only).

**Purpose**: answer the goal's open question — *which render-graph facts belong in Triga versus Radix/MIR reflection* — with evidence from what the compiler emits today.

---

## 1. Current reflection inventory: what Radix/MIR emits today

### 1.1 The frozen ABI seam (`crates/radix-mir/src/abi.rs`)

All GPU reflection is Rust structs in `crates/radix-mir/src/abi.rs` (re-exported through `crates/radix-mir/src/lib.rs` and `crates/radix/src/mir/mod.rs`). The top-level serialized shape is:

```rust
pub struct MirGpuReflection {
    pub kernels: Vec<MirKernelReflection>,
    pub pipeline: Option<MirGraphicsPipelineReflection>,
}
```

**Per-kernel facts** (`MirKernelReflection`, landed):
- `function`, `provenance` (`MirKernelProvenance::MirFunction | SourceFunction`), `entry_name`, `shader_stage` (`MirKernelShaderStage::Compute | Vertex | Fragment`).
- `resources: Vec<MirKernelResourceReflection>` — `group`, `binding`, `kind` (`MirKernelResourceKind`, **only `StorageBuffer`**), `role` (`MirKernelResourceRole::Input | Output`), `access` (`MirKernelResourceAccess::Read | Write | ReadWrite`), `element_ty`, `element_layout` (`MirScalarLayout`), `element_byte_width`, `element_count`, `buffer_byte_len`, `source_local`, `source_name`.
- **Stage IO (graphics, landed)**: `vertex_inputs: Vec<MirVertexInputReflection>` (`source_name`, `location`, `format` (`MirVertexInputFormat::Float32x2/3/4`), `step_mode` (`MirInputStepMode::Vertex | Instance`), `offset_bytes`, `stride_bytes`); `varyings: Vec<MirVaryingReflection>` (`source_name`, `location`, `format`, `interpolation` (`MirVaryingInterpolation::Perspective | Linear | Flat`)); `fragment_outputs: Vec<MirFragmentOutputReflection>` (`location`, `format`).
- **Builtins (landed)**: `builtin_inputs` (15 `MirKernelBuiltin` values, axis, ty, layout), `called_builtins`.
- **Dispatch (landed, compute-shaped)**: `workgroup`, `dispatch_size`, `workgroup_count`.
- **Launch plan (landed)**: `launch_plan()` → `MirKernelLaunchPlan` with `pipeline_layout`, per-bind-group resource/kind/role/access/offset/length/min-binding-size/source-provenance arrays, `layout_entries`, `bindings`, and a typed `webgpu_adapter()` projection (`MirWebGpuLaunchAdapter`): pipeline-layout, bind-group-layout and bind-group descriptor projections, `vertex_buffer_layout_descriptors` (`MirWebGpuVertexBufferLayoutDescriptor` with per-attribute `shader_location`/`format`/`offset`), and `dispatch_workgroups`.

**Pipeline facts** (`MirGraphicsPipelineReflection`, landed):
- `color_target_formats: Vec<MirColorTargetFormat>` (`Rgba8Unorm | Bgra8Unorm | Bgra8UnormSrgb`), `primitive_topology` (`TriangleList | LineList | PointList`), `vertex_count: u32`, `vertex_input_count`, `varying_count`, `vertex_resources`/`vertex_resource_count`, `fragment_resources`/`fragment_resource_count`, `depth_stencil: Option<MirDepthStencilState>`.
- `MirDepthStencilState` is fully modeled: `depth_write_enabled`, `depth_compare` (`MirDepthCompareFunction`, 8 values), `stencil_read_mask`/`stencil_write_mask`, `stencil_front`/`stencil_back` (`MirStencilFaceState`: compare + fail/depth_fail/pass ops from `MirStencilOp`, 8 values). Builders `with_depth_stencil`, `with_stencil`, `with_topology`.
- Pipeline construction gate (`MirKernelReflection::graphics_pipeline_reflection`): requires vertex + fragment stages, non-empty vertex inputs, non-empty color targets, and `validate_varying_consistency` (fragment varyings must match vertex varyings on location/format/interpolation — fail-closed with `mir_graphics_pipeline_varying_mismatch`).

### 1.2 Where the facts come from: source extraction vs defaults (`crates/radix/src/driver/mod.rs`)

`GraphicsSourceFacts` collects five Triga fact families from the analyzed HIR before MIR emission. Two are **extracted from real Triga API calls**, three are **compiler defaults**:

| Fact family | Producer | Status |
| --- | --- | --- |
| `triga_vertex_layout_facts` | `collect_triga_vertex_layout_facts` recognizes `geometry.geometry_vertex_layout_matches(...)` `adfirma` calls (7–8 args: source_name, location, format_code, offset_bytes, stride_bytes, [step_mode_code]) | Landed (source-extracted) |
| `triga_pipeline_facts` | `collect_triga_pipeline_facts` recognizes `geometry.geometry_pipeline_descriptor_matches(...)` `adfirma` calls (5 args: color_target_format_code, depth_compare_code, depth_write_enabled_code, primitive_topology_code, vertex_count); **falls back to a hardcoded default** (bgra8unorm=1, depth less+write, triangle-list=1, vertex_count=36) | Landed but defaulted when no call |
| `triga_varying_facts` | `derive_triga_varying_facts` — **derived**, not declared: every non-`position` vertex attribute becomes a varying at consecutive locations; interpolation hardcoded to `Perspective` | Derived bridge; explicit Triga varying calls are planned, not landed |
| `triga_fragment_output_facts` | `collect_triga_fragment_output_facts` — **hardcoded** to one `{location: 0, format_code: 4}` (Float32x4) | Default only; explicit Triga fragment-output calls planned |
| `triga_resource_binding_facts` | `collect_triga_resource_binding_facts` — **hardcoded** to one transform buffer (group 0, binding 0, 64 elements, read-only storage) | Default only; explicit Triga resource-binding calls planned |

So today, the graphics pipeline reflection is a mix of genuine source facts (vertex layout, some pipeline config) and compiler defaults (varyings derivation, fragment outputs, resource bindings, fallback pipeline). The compiler defaults are *better than host guessing* but they are still guessed facts — the `MirTrigaResourceBindingFact::to_resource_reflection` doc comment says so explicitly ("Uses f32 scalar defaults … best-effort contract for Goal 01 acceptance").

### 1.3 Emission surfaces

Two JSON shapes exist:

1. **CLI sidecar** — `radix emit --reflection -t wgsl-text|metal-text` → `GpuReflectionJson` (`crates/radix/src/tool/commands/reflection.rs`): adds `schema_version: 1`, `target`, per-kernel `launch` envelope + `webgpu_adapter` projections. This is the shape the reciprocity law (below) freezes.
2. **Raw serde of `MirGpuReflection`** — direct `serde_json::to_string_pretty(&output.reflection)`, used by `emit_wgsl_text_probe_with_reflection_json` (`crates/radix-mir-wgsl/src/lib.rs`). This is the shape of the corpus fixtures.

**Honesty caveat (corpus fixture drift):** the three corpus fixtures (`corpus/_host/shaders/reflection.json`, `corpus/webgl-geometries/src/shaders/test-data/reflection.json`, `corpus/webgl-geometry-terrain/src/shaders/test-data/reflection.json` — all byte-identical) contain `"kind": "UniformBuffer"`, `"role": "Uniform"`, and omit `element_type`/`element_layout`/`source_local`. **No radix crate can emit `UniformBuffer` today** (only `StorageBuffer`) and `MirKernelResourceRole` has only `Input | Output`; a uniform buffer role does not exist in the enum. The fixtures therefore do **not** match the live emitter's serialization of `MirKernelResourceReflection`. They appear to be a hand-maintained or stale fixture. Anyone using them as the "current emitted shape" is looking at an older/intended shape. This is exactly the class of drift the engine checkpoint should catch before building host admission on the fixtures.

### 1.4 What is planned but not landed (Stage 4/8/9 track)

Per `docs/factory/mir-gpu/goals/08-shader-stage-model.md` (stage model "substantively complete" via Phases 9GI/9GJ) and `09-reflection-sidecar.md` (Stage 9 in progress), plus `progress-ledger.md`:
- **Planned (compiler)**: source-owned vertex/fragment bodies (the current WGSL emitters generate contract stub bodies); explicit Triga varying-definition calls; Triga fragment-output calls; Triga resource-binding calls; Metal/LLVM shader-stage parity (Metal paused, LLVM parked).
- **Deferred (compiler)**: runtime/host rendering (Stage 5); product/native host adapters; render passes/render targets/hazards (nothing on any radix queue — confirmed by search: no `RenderPass`, `render_pass`, `RenderTarget`, `attachment`, `hazard`, `index_format`, or `index_count` modeling anywhere in `crates/`).
- **Landed (compiler)**: `webgpu_adapter` descriptor projections for bind-group layouts/groups/pipeline layout/dispatch, typed `MirKernelLaunchPlan` (Phases 9EF–9EH), vertex buffer layout descriptor projections, vertex+fragment entry emission with Naga validation, cross-stage varying consistency.

### 1.5 The reflection contract law (already frozen)

`docs/design/reflection-reciprocity.md` (G-SPINE-03, accepted 2026-07-26) is the spine law for the schema: one shared root (`schema_version`, `target`, `kernels`, `launch.webgpu_adapter` structure) is **spine-frozen** (Mind approval); stage-specific fields are leaf-owned by the `radix` tool serializer. Host admission is sequential root → kernel → stage, and every admission failure is a rejection. Critically for the boundary:

- **`draw.*` facts (index_format, instance_count, base_vertex, first_index, index_count) are NOT in the reflection JSON.** They travel in a separate host-side **draw manifest** handed to `loadFaberGraphicsPipeline`; `parseDrawManifest` validates them host-side.
- **Host-invention blacklist**: `cullMode: "none"` and `DEPTH_FORMAT: "depth24plus"` are classified **host-owned policy defaults** (with a one-way ratchet: once the emitter provides the field, the host must prefer it). Stencil fields and graphics-stage `dispatch_workgroups` are host-owned silent-drops.

These two items are the *current* admission that the host owns facts the engine goal's invariant says the host must never guess.

---

## 2. The boundary recommendation

The engine vision (GOAL.md §"Render planning: render") names the render-plan facts; this is the Triga / Radix-MIR / host split, grounded in what exists today. Ownership rule used throughout: **Triga declares backend-neutral intent; Radix lowers/validates/reflects it (or rejects fail-closed); the host executes reflected + declared facts and invents nothing.**

| Render-plan fact (GOAL) | Owner | Current state in Radix | Reasoning (evidence-grounded) |
| --- | --- | --- | --- |
| **Stage IO, varyings, resources, bindings** | Radix/MIR-owned reflection; Triga declares the underlying facts | Landed: `MirVertexInputReflection`, `MirVaryingReflection`, `MirFragmentOutputReflection`, `MirKernelResourceReflection`; `validate_varying_consistency` fail-closes mismatches | Already the working split: the compiler owns the reflection shape and the cross-stage consistency rule (`shader-stage-architecture-recheck` F3). Triga only needs to *declare* varyings/outputs/bindings explicitly (currently derived/defaulted) so the defaults stop masking facts. |
| **Render items and draw ranges** | **Triga-owned** (`render/item.fab`), then Radix-reflected as `draw.*` facts | Radix has only `pipeline.vertex_count`; draw facts live in a host-side draw manifest (`reflection-reciprocity.md` §1.6) | The host-side draw manifest is today's "host guesses draw topology" violation. Triga declares render items (geometry reference, draw range, instance count, index format/count, base vertex); Radix lowers them into the reflection so the host stops carrying a manifest. |
| **Pipeline topology and state** | Split: **Triga declares** backend-neutral topology + pipeline state; **Radix encodes/validates/reflects**; host executes | Topology (`MirPrimitiveTopology`), color target format, depth compare/write, and vertex count are already Triga facts → `MirTrigaPipelineFact` → `MirGraphicsPipelineReflection` (landed); `MirDepthStencilState`/`MirStencilOp` structs are fully modeled (landed) but have **no Triga source feed** for stencil | The working pattern already exists for topology/depth; extend it to full pipeline state (cull mode, blend, MSAA, stencil) via Triga pipeline-state facts decoded by the same `_code` seam. Host-side `cullMode`/`DEPTH_FORMAT` defaults are explicit blacklist admissions that stop being acceptable once Triga declares the state. |
| **Color/depth attachments and render targets** | **Triga-owned** (`render/target.fab`) declarations; Radix reflects per-target facts | Single color target format from the Triga pipeline fact; `MirColorTargetFormat` only has 3 values; no depth *format*, no MSAA/sample count, no attachment set; multi-target is structurally possible (`Vec<MirColorTargetFormat>`, `fragment_outputs` Vec, `emit_wgsl_fragment_entry_contract_with_targets`) but has no Triga source path | The compiler seam can carry multiple targets (the WGSL fragment emitter already does), so the missing piece is Triga declaring the target/attachment set — including depth *format*, which today is a host constant. |
| **Compute and render passes** | **Triga-owned** pass declarations (`render/pass.fab`); Radix reflects per-stage facts; host runs passes | No pass concept in radix; `shader_stage` is the only pass-ownership signal, and pass/resource ownership boundaries are documented host-side in `docs/design/unified-webgpu-host-resource-model.md` (§"Compute-pass vs render-pass ownership boundaries") | The compiler models kernels/stages, not passes. A pass is a semantic grouping (stage pair + target set + resource scope) that belongs in Triga; Radix keeps reflecting the stages; the host must not invent pass membership. |
| **Pass dependencies and resource hazards** | **Triga-owned** (`render/graph.fab`) — a semantic DAG validated before submission; host executes it | Nothing anywhere: no hazard/ordering facts in radix; G-SPINE-01 documents host-side ordering conventions (submission order defines execution order) | The goal requires cycle/format/size/MSAA/read-write-hazard validation before submission. That validation is a Faber-side semantic check over Triga's plan (Triga can do it), not a compiler emission. Radix only needs the *single-queue-submission* facts (which passes are in one submission) if it is to validate artifacts — otherwise the DAG never crosses the compiler seam. |
| **Batching, instancing, submission groups** | **Triga-owned** (`render/batch.fab`); Radix reflects per-draw instance facts | Nothing in radix; `instanceCount` exists only in the host draw manifest | Same class as render items: group membership and instance counts are render-plan facts. Triga declares them; the host consumes them. |
| **Required vs optional target capabilities** | **Three-way**: Triga declares the required/optional capability set (`render/capability.fab`); **Radix owns compile-time target capability** (lowerability verbs + fail-closed diagnostics); **host owns runtime device capability admission** | `docs/design/target-capability-matrix.md` is compile-time target lowerability (Support/Erase/Warn/Reject/Defer/Probe/Proof per feature × target) — no runtime device facts (adapter limits, feature flags, format support) exist in any layer; the host performs its own capability admission today | These are two different capability axes and must not be conflated. Triga's "required vs optional" set is render intent (a fact). Radix's `target-capability-matrix` answers "can this Triga feature compile for target X" — already executable and fail-closed. Runtime adapter negotiation is a device fact that only the host can know; it must stay host-owned but *admit against* the Triga-declared requirements. |

### The two-line summary

- **Triga owns**: render items/draw ranges, render passes, targets/attachments, pass DAG + hazards, batching/submission groups, required/optional capabilities, and full pipeline-state intent — all backend-neutral Faber facts, declared as `adfirma`/API calls the compiler already knows how to recognize.
- **Radix/MIR owns**: stage legality, stage IO/varying/resource reflection, pipeline reflection (topology, color targets, depth/stencil, vertex count), draw reflection once Triga declares draw facts, compile-time target capability checks, WGSL emission, and fail-closed diagnostics. **Host owns**: device creation, residency, pipeline caching, and runtime capability admission — consuming reflection + declared facts, never inventing them.

---

## 3. Gap list: render facts no layer produces today (host would guess = violation)

Current state: the host already guesses several of these (documented as "host-owned policy" in the reciprocity blacklist). Each is a named missing piece and the layer that must produce it.

| # | Missing fact | Who would guess today | Where it must be produced |
| --- | --- | --- | --- |
| G1 | **Draw facts**: index format, index count, first index, base vertex, instance count, draw ranges — no `index_format`/`index_count` anywhere in radix; draw lives in a host draw manifest | Host (draw manifest / geometry parsing) | Triga `render/item.fab` declares render items → Radix reflects `draw.*` into the graphics reflection (MINOR schema bump, leaf-owned per reciprocity §4) |
| G2 | **Depth-stencil format** (`depth24plus` hardcoded host constant); reflection has depth compare/write/stencil ops but no format | Host (`DEPTH_FORMAT`) | Triga `render/target.fab` declares depth format → Radix reflects `depth_format` in the pipeline block |
| G3 | **Cull mode** (`cullMode: "none"` hardcoded at two host sites) | Host | Triga `render/pipeline.fab` pipeline-state fact (cull_mode code) → Radix decodes + reflects |
| G4 | **Blend state / alpha policy** — no blend facts in radix; transparency is required by the goal's material vision | Host (would need to invent) | Triga pipeline-state facts (blend factors/ops per color target) → Radix `MirGraphicsPipelineReflection` extension |
| G5 | **MSAA / sample count** — absent; the goal demands unsupported-multisampling validation | Host | Triga `render/target.fab` attachment facts (sample count) → Radix reflect + validate against target matrix |
| G6 | **Multi-color-target declarations** — structurally possible (`Vec`, `_with_targets` emitter) but no Triga source path; Triga pipeline fact carries a *single* format code | Compiler (unreachable) / host | Triga target-set facts feeding a per-target `color_target_format_code` list |
| G7 | **Stencil source facts** — structs fully modeled (`MirStencilOp`, `MirStencilFaceState`) but nothing feeds them from Triga; host silently drops stencil today | Host (silent-drop) | Triga pipeline-state fact (stencil compare/ops/masks) → existing decode seam |
| G8 | **Pass membership + pass DAG + hazards + submission groups** — no pass/render-target/hazard/order modeling in radix; host owns pass/resource boundaries by convention (G-SPINE-01) | Host (imperative render-graph code — the goal's named stop condition) | Triga `render/pass.fab`, `render/graph.fab`, `render/batch.fab` semantic plan; validation (cycles, formats, sizes, hazards) in Triga before submission |
| G9 | **Runtime device capability facts** (adapter limits, feature flags, format support) — the target-capability matrix is compile-time only | Host (own admission, un-negotiated against Triga requirements) | Split: Triga declares required/optional capability set; host admits runtime device against it |
| G10 | **Explicit varying/fragment-output/resource-binding source facts** — currently derived or defaulted by the driver (`derive_triga_varying_facts`, hardcoded fragment output, default transform binding); the compiler guesses them today | Compiler (defaults mask missing source facts) | Triga API calls (explicit varying definitions, fragment-output declarations, resource-binding declarations) — planned per driver comments/Goal 08 "Remaining", not landed |
| G11 | **Shader-resource payload semantics** — the WGSL vertex emitter hardcodes a locked MVP transform layout ("model (16 f32) then view-projection (16 f32), column-major") and treats a `transform` storage resource specially; the "lighting" binding has no emitted semantics | Compiler (hardcoded convention in `emit_wgsl_vertex_entry_contract`) / host | Triga `shader/resource.fab` declares resource payload layout; the emitter must stop owning shader semantics it cannot know |

**Biggest gap: G1/G8 (draw facts + the pass/render-graph layer).** Draw facts are the smallest missing piece that violates the invariant today (the host already carries a draw manifest), and the pass DAG/hazard layer is the largest absent family — the goal's Horizon 4. Neither exists in any layer.

---

## 4. Frozen-ABI implication: which proposed Triga fact fields must stay `_code`-named

The frozen seam (`crates/radix-mir/src/abi.rs`) decodes Triga fact structs through enum code decoders. Any Triga-declared fact that must cross this seam keeps enumerated/backend-mapped values as **`u32` `_code` fields**, and the decode functions are the contract:

| Triga fact field (today) | Decoder | Decode behavior | Fail-closed? |
| --- | --- | --- | --- |
| `MirTrigaVertexLayoutFact.format_code` | `MirVertexInputFormat::from_triga_format_code` | 2/3/4 → Float32x2/3/4 | **Yes** (else `mir_vertex_input_unsupported_format_code`) |
| `MirTrigaVertexLayoutFact.step_mode_code` | inline in `source_vertex_entry_from_triga_layout_facts` | `== 2 → Instance`, else `Vertex` | **No** — silent default |
| `MirTrigaPipelineFact.color_target_format_code` | `MirColorTargetFormat::from_triga_code` | 1 → Bgra8Unorm, 2 → Bgra8UnormSrgb | **Yes** (note: `Rgba8Unorm` exists but **no code maps to it**) |
| `MirTrigaPipelineFact.depth_compare_code` | `MirDepthCompareFunction::from_triga_code` | 1–7 → Less…Always | **No** — unknown code silently → `Never` |
| `MirTrigaPipelineFact.primitive_topology_code` | `MirPrimitiveTopology::from_triga_code` | 1/2/3 → Triangle/Line/PointList | **Yes** |
| `MirTrigaResourceBindingFact.kind_code` | `to_resource_reflection` | `1 → StorageBuffer`, `_ → StorageBuffer` | **No** — silent |
| `MirTrigaResourceBindingFact.role_code` | `to_resource_reflection` | `1 → Input`, `2 → Output`, `_ → Input` | **No** — silent |
| `MirTrigaResourceBindingFact.access_code` | `to_resource_reflection` | `1/2/3 → Read/Write/ReadWrite`, `_ → Read` | **No** — silent |
| `MirTrigaVaryingFact.format_code` / `MirTrigaFragmentOutputFact.format_code` | `MirVertexInputFormat::from_triga_format_code` | as above | **Yes** |

**Rule for new Triga fact genera** (derived from the goal's inventory and the seam's existing shape):

1. **Enumerated / backend-mapped values stay `_code: u32`** and get a decoder in `radix-mir` — e.g. new `index_format_code`, `cull_mode_code`, `blend_factor_code`, `blend_op_code`, `stencil_op_code` (the `MirStencilOp` enum already exists for the decode target). Radix is the authority that owns the code tables; Triga only ever emits codes via its declared facts, exactly as `geometry_vertex_layout_matches`/`geometry_pipeline_descriptor_matches` do today.
2. **Quantities stay raw numerics**: `offset_bytes`, `stride_bytes` (`u64`), `vertex_count` (`u32`), `element_count` (`u64`), sample counts, draw range numbers — never codes.
3. **Booleans stay booleans**: `depth_write_enabled` is `bool` today; new `depth_write_enabled`, `depth_test_enabled`-class fields follow the same pattern.
4. **The two existing silent-default decoders are a debt the checkpoint should flag**: `step_mode_code`, `depth_compare_code`, `kind_code`, `role_code`, `access_code` all silently default on unknown codes, which contradicts the goal's "fail closed" posture. New fact fields must be fail-closed decoders (like the format/topology ones), and the existing ones should be tightened when the seam is next touched.
5. **Adding a new field to the graphics reflection is a leaf-owned MINOR schema bump** (per `reflection-reciprocity.md` §4), as long as it is stage-specific and no host currently validates it; spine-frozen fields (`schema_version`, `target`, `kernels`, `webgpu_adapter` existence) cannot be touched without Mind approval.

---

## 5. Key sources (exact paths)

- `crates/radix-mir/src/abi.rs` — all reflection + Triga fact structs and `*_code` decoders (the frozen seam).
- `crates/radix/src/driver/mod.rs` — `GraphicsSourceFacts` (lines ~1655), `collect_triga_vertex_layout_facts` / `collect_triga_pipeline_facts` / `derive_triga_varying_facts` / `collect_triga_fragment_output_facts` / `collect_triga_resource_binding_facts` (~2320–2640), `emit_wgsl_vertex_source_output` / `emit_wgsl_fragment_source_output` / `emit_wgsl_graphics_pipeline_output` (~620–770).
- `crates/radix/src/tool/commands/reflection.rs` — CLI `--reflection` `GpuReflectionJson` schema (schema_version 1, kernel/pipeline/launch/webgpu_adapter).
- `crates/radix-mir-wgsl/src/lib.rs` — `emit_wgsl_vertex_entry_contract`, `emit_wgsl_fragment_entry_contract`, `emit_wgsl_fragment_entry_contract_with_targets` (incl. hardcoded MVP transform payload).
- `docs/factory/mir-gpu/goals/08-shader-stage-model.md`, `09-reflection-sidecar.md`, `CAMPAIGN.md`, `progress-ledger.md`, `execution-queue.md` — landed vs planned Stage 4/8/9.
- `docs/design/reflection-reciprocity.md` — frozen shared-root/spine split, draw manifest, host-invention blacklist.
- `docs/design/target-capability-matrix.md` — compile-time target capability (not runtime device capability).
- `docs/design/unified-webgpu-host-resource-model.md` — host-side compute-vs-render-pass ownership boundaries.
- Triga corpus fixtures: `corpus/_host/shaders/reflection.json`, `corpus/webgl-geometries/src/shaders/test-data/reflection.json`, `corpus/webgl-geometry-terrain/src/shaders/test-data/reflection.json` (identical; drift from live emitter noted in §1.3).
