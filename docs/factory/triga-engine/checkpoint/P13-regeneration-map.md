# P13: triga-lit Artifact Regeneration Map (GATED)

**Track**: read-only research for the DS-S2 gated item — regenerating
`hosts/webgpu-browser/public/generated/triga-lit.wgsl` +
`triga-lit-reflection.json` through the radix path (report §4.4, §8 row 3;
DS-S2 invariants 3–4, fixtures §"New fixtures"; open question "Triga-lit
regeneration source").
**Date**: 2026-08-01
**Status**: the gate is EXECUTABLE NOW for the reflection *format*, but a
semantically faithful regeneration (lighting uniform + `view_depth` varying +
full lit body) is BLOCKED on 80 Stage 4 residual items. Everything below is
evidence from the live radix tree; no file was modified, nothing built, no git
run.

---

## 1. The current-emit path (what radix emits today)

**Front end of the chain** — `generate_wgsl_text_output` in
`radix/crates/radix/src/driver/mod.rs` (~line 512):

1. `analysis.graphics_source` (a `GraphicsSourceFacts`, assembled by
   `collect_graphics_source_facts`, driver ~line 2192) is built from five fact
   families extracted from the analyzed HIR before MIR emission:
   | Fact family | Producer | Status |
   | --- | --- | --- |
   | `triga_vertex_layout_facts` | `collect_triga_vertex_layout_facts` — recognizes `geometry.geometry_vertex_layout_matches(...)` `adfirma` calls (7–8 args: source_name, location, format_code, offset_bytes, stride_bytes, [step_mode_code]) | landed, source-extracted |
   | `triga_pipeline_facts` | `collect_triga_pipeline_facts` — recognizes `geometry.geometry_pipeline_descriptor_matches(...)` `adfirma` calls (5 args: color_target_format_code, depth_compare_code, depth_write_enabled_code, primitive_topology_code, vertex_count); **falls back to a hardcoded default** (bgra8unorm=1, depth less+write, triangle-list=1, vertex_count=36) | landed but defaulted when no call |
   | `triga_varying_facts` | `derive_triga_varying_facts` — **derived, not declared**: every non-`position` vertex attribute becomes a varying at consecutive locations; interpolation hardcoded to `Perspective` | derived bridge; explicit Triga varying calls planned, not landed |
   | `triga_fragment_output_facts` | `collect_triga_fragment_output_facts` — **hardcoded** to one `{location: 0, format_code: 4}` (Float32x4) | default only |
   | `triga_resource_binding_facts` | `collect_triga_resource_binding_facts` — **hardcoded** to one transform buffer (group 0, binding 0, 64 elements, read-only storage) | default only |

2. If the source has `@ vertex` and/or `@ fragment` annotated functions
   (`collect_vertex_entries` / `collect_fragment_entries`), the driver runs
   `lower_graphics_mir_with_context_for_target` and dispatches to
   `emit_wgsl_graphics_pipeline_output` (both stages), or the per-stage
   `emit_wgsl_vertex_source_output` / `emit_wgsl_fragment_source_output`
   (driver ~line 573–601). A non-empty source body that fails to lower is a
   **fail-closed diagnostic** (`mir_lower_graphics_body_missing` /
   `mir_wgsl_vertex_source_body`), never a silent fallback.

3. The WGSL emit functions live in `radix/crates/radix-mir-wgsl/src/lib.rs`:
   - `emit_wgsl_vertex_entry_contract` (~line 233) — entry struct from
     `vertex_inputs`, output struct (position + varyings), and a body that is
     either the lowered MIR body (`emit_wgsl_body_from_mir`, when non-empty) or
     the reflection contract: hardcoded locked MVP payload (`view_proj * model
     * pos` from the `transform` storage resource at group 0 binding 0, model
     16 f32 + view-projection 16 f32, column-major) + pass-through varyings.
   - `emit_wgsl_fragment_entry_contract` (~line 386) — varying input struct +
     per-output assignments; MIR body when non-empty, else
     `color`/`color_N` scaffold.
   - `emit_wgsl_fragment_entry_contract_with_targets` (~line 498) — multi-target
     wrapper.
   - `emit_wgsl_vertex_resource_declarations` (~line 1036) — **rejects any
     non-`StorageBuffer` resource** ("wgsl vertex resources must be storage
     buffers") and any non-f32 layout; emits `var<storage, read|read_write>
     transform: array<f32>;`.

4. **Reflection sidecar** — `radix emit --reflection` serializes through
   `crates/radix/src/tool/commands/reflection.rs`
   (`GpuReflectionJson::from_reflection`, `GPU_REFLECTION_SCHEMA_VERSION = 1`):
   root `schema_version: 1`, `target: "wgsl-text"|"metal-text"`, `kernels[]`
   each carrying `provenance`, `entry_name`, `shader_stage`, `resources`,
   `vertex_inputs`, `builtin_inputs`, `called_builtins`, a `launch` envelope
   (pipeline layout, bind groups, **`webgpu_adapter`** descriptor projections,
   workgroup/dispatch counts), and an optional `pipeline` block
   (`color_target_formats`, `primitive_topology`, `vertex_count`,
   `vertex_input_count`, `varying_count`, `vertex_resources`/`fragment_resources`
   + counts, `depth_stencil`).

**Corpus fixture emission precedent** (how kernel.wgsl + reflection.json were
produced on the radix side): `radix/docs/help/faber-after-help.md` and
`radix/README.md` document
`faber emit -t wgsl-text ../examples/corpus/vector/kernel.fab` and
`faber emit --reflection -t wgsl-text ../examples/corpus/vector/kernel.fab`
(the compute-shader reference example). The hosts graphics artifacts in the
*current* format (`schema_version`/`target`/`launch.webgpu_adapter` present)
are already emitted via hosts `./scripta/webgpu-browser-proof generate` from
`triga/exempla/triga-hello-voxel-shaders.fab` using `radix emit --reflection
-t wgsl-text` (DS-S2 §"Hosts current state", verified). The **old corpus
`kernel.wgsl` (127 ln) was hand-authored**, per DS-S2's fork table — not
radix-emitted.

---

## 2. The target invocation

From the hosts `scripta/webgpu-browser-proof generate` path (extended per DS-S2
fixtures: "radix emit from the lit fixture"), the two-file regeneration is:

```bash
# WGSL source (stdout or -o):
radix emit -t wgsl-text -o <hosts>/public/generated/triga-lit.wgsl <lit-fixture>.fab

# Reflection sidecar (schema_version 1, target "wgsl-text", launch.webgpu_adapter):
radix emit --reflection -t wgsl-text -o <hosts>/public/generated/triga-lit-reflection.json <lit-fixture>.fab
```

Equivalent faber alias (same compiler authority):
`faber emit --reflection -t wgsl-text <lit-fixture>.fab` (prints sidecar JSON
to stdout; `-o` writes it). The corpus demos then pick both files up via
`tests/run.sh` (copies hosts `public/generated/triga-lit.*` into each demo's
`public/` and `src/shaders/test-data/` — see
`corpus/webgl-geometries/tests/run.sh`).

**Inputs the emission needs** (the lit fixture `.fab` must declare):
- one `@ vertex` function and one `@ fragment` function — zero source
  parameters, `→ vacuum` return, no payload on the annotation (driver
  `validate_wgsl_vertex_source_entry` / `validate_wgsl_fragment_source_entry`
  fail closed on payload/params/non-vacuum/error-type);
- `geometry.geometry_vertex_layout_matches(...)` `adfirma` calls for the
  interleaved stride-36 layout: position `(0, 3, 0, 36, 1)`, normal
  `(1, 3, 12, 36, 1)`, color `(2, 3, 24, 36, 1)` — per-attribute
  `offset_bytes`/`stride_bytes` are carried verbatim into `vertex_inputs` and
  the `webgpu_adapter.vertex_buffer_layout_descriptors`;
- `geometry.geometry_pipeline_descriptor_matches(...)` `adfirma` for the
  pipeline block (bgra8unorm, depth compare less, depth_write enabled,
  triangle-list, vertex_count) — or accept the hardcoded default
  (bgra8unorm=1, depth less+write, triangle-list=1, vertex_count=36), which
  matches the lit pipeline except vertex_count;
- once 80 Stage 4 closes its residual gaps: the resource-binding /
  varying / fragment-output **source facts** for the lighting uniform and the
  `view_depth` varying (see §3, R2–R5);
- a non-empty vertex/fragment body only if the lit math lowers (see §4,
  R6) — otherwise the fixture uses empty bodies and the emitter prints the
  contract scaffold.

The `triga-hello-voxel-shaders.fab` exempla is the minimal shape precedent;
`exempla/triga-stage4-source-facts.fab` (and the compiler-side copy
`radix/crates/radix/src/fixtures/triga-stage4-source-facts.fab`) pins the
layout-fact recognition pattern (7-arg `geometry_vertex_layout_matches`).

---

## 3. What is BLOCKED today — 80 Stage 4 gate + emitter gaps

### 3.1 80 Stage 4 gate status (as of 2026-08-01)

Stage 4 is **IP** and the gate is **not met** at the last check (2026-07-18;
`goals/04-graphics-mir-shader-stages.md` §"Gate Check"; T-C table row 4).
**Since that check the radix tree advanced** (ledger Phases 9GI 2026-07-19,
9GJ 2026-07-25; driver + `tool_test.rs` tests): the fragment stage + varying
model landed, the `@ fragment` source driver path landed, and **source vertex
and fragment BODIES lower for simple assignments** (`out_position ← position`,
`out_color ← color` — see `wgsl_text_source_vertex_body_emits_position_assign`,
`triga_stage4_source_fragment_body_emits_authored_color_widening`,
`triga_stage4_vertex_body_validates_with_naga`). The **remaining** source-body
work per `goals/08-shader-stage-model.md` §"Remaining" is exactly what the lit
shader needs: **"Source-owned vertex/fragment bodies (matrix transforms,
lighting)"** — plus runtime/host rendering (Stage 5) and Metal/LLVM parity.

| Stage 4 gate item | Status (2026-08-01) | What must still land for the triga-lit gate |
| --- | --- | --- |
| 1. One Faber fixture lowers to typed vertex+fragment MIR + valid WGSL | **OPEN** (partial since 07-18: source entry paths + simple body assigns landed) | Full source body lowering for matrix construction from storage elements, `mat4 * vec4`, `normalize`/`dot`/`max`/`select`, `pow`/`exp2`/`clamp`/`mix`, author-defined helper fns (e.g. `aces_tonemap`) — `goals/08` Remaining |
| 2. Reflection describes stage IO, vertex layouts, resources, pipeline targets, draw prerequisites | **PARTIAL** | Resource bindings beyond the default single transform (G10); explicit varying source facts (`view_depth`); combined pipeline-layout descriptors with stage visibility |
| 3. Mismatched varyings / unsupported types / illegal resources / missing outputs fail before emission | **PARTIAL** | Unsupported *types* and *resources* in graphics context not yet tested (uniform-kind rejection exists in the WGSL emitter, §4 R2/R7) |
| 4. Existing compute kernels and reflection remain valid | **MET** | — |
| 5. MIR GPU Stage 8 artifact + progress ledger reflect state | **MET** | — |

### 3.2 Emitter gaps that would produce a MISMATCHED or REJECTED regeneration

| # | Gap | Evidence | Consequence if regenerated today |
| --- | --- | --- | --- |
| R1 | The stale corpus fixtures lack `schema_version`/`target`; the live emitter always emits them | `reflection.rs` `GPU_REFLECTION_SCHEMA_VERSION=1`, `target` field; corpus fixtures lack both | The OLD fixtures are rejected by admission (this is the point of the gate); a *new* regeneration passes `loadFaberGraphicsPipeline`'s `expectValue(schema_version,1)` / `expectValue(target,"wgsl-text")` |
| R2 | `kind: "UniformBuffer"` / `role: "Uniform"` are un-emittable | `MirKernelResourceKind { StorageBuffer }` only (abi.rs ~1242); `MirKernelResourceRole { Input, Output }` | The lit shader's **lighting uniform (group 0, binding 1)** cannot appear in the regenerated reflection or WGSL; the emitter produces only the default transform storage |
| R3 | Resource-binding source facts (G10) not landed | `collect_triga_resource_binding_facts` hardcodes one transform buffer (driver ~2625); `to_resource_reflection` doc: "best-effort contract for Goal 01 acceptance" | The fixture cannot declare the lighting binding, its 12-f32 layout, or its byte length; host-side binding of the uniform would mismatch the reflection |
| R4 | Varyings derived from vertex attributes, not declared | `derive_triga_varying_facts`; `MirTrigaVaryingFact`/explicit calls "planned, not landed" | `view_depth` (a *computed* f32 varying, not a vertex attribute) cannot be derived; a regeneration emits only normal+color varyings |
| R5 | Fragment-output facts hardcoded | `collect_triga_fragment_output_facts` → one `{location 0, format 4}` | Matches the lit shader's single `float32x4` color target — OK, but no source path if the target set changes |
| R6 | Lit body math unproven in `emit_wgsl_body_from_mir` | `goals/08` Remaining: "matrix transforms, lighting"; proven body tests are simple assignments | A non-empty body using matrices/lighting/tonemapping fails closed (structured diagnostic) or falls back to the contract scaffold — cannot reproduce the hemisphere/Lambert/ACES/fog body |
| R7 | WGSL resource emitter rejects non-storage resources | `emit_wgsl_vertex_resource_declarations`: "wgsl vertex resources must be storage buffers" | Even a hand-fed uniform resource in reflection would fail WGSL emission |
| R8 | Interleaved stride-36 layout must be *declared* (not derived) | `MirTrigaVertexLayoutFact` carries `offset_bytes`/`stride_bytes`; fixtures today pin per-attribute stride 12 | Expressible today IF the fixture declares offset 0/12/24 at stride 36 — the reflection carries it correctly; no emitter gap, but the fixture must say it |

The DS-S2 spec already anticipated R2–R6: "**Triga-lit regeneration source**:
80 Stage 4–5 graphics-MIR must express the lit shader (pos/normal/color
stride-36 + storage transform + uniform lighting + hemisphere/Lambert/ACES/fog)
as radix-lowerable Faber source. If not yet fully expressible at P1.3, the
interim is the nearest radix-lowered equivalent with the pixel references
re-baselined (recorded change), and the full lit shader lands with 80 Stage
4–5."

---

## 4. Hand-authored vs emitted — verdict for triga-lit.wgsl

**Verdict: triga-lit.wgsl must remain hand-authored (checked-in corpus proof
shader) for the full lit semantics.** The current emitter can reproduce:

- the **reflection format** (schema_version 1, target, per-kernel
  `launch.webgpu_adapter`, pipeline block) — proven by the hosts
  `graphics-reflection.json` emitted from `triga-hello-voxel-shaders.fab`;
- the **vertex contract body** (locked MVP from the transform storage + varying
  pass-through) and the **storage resource declaration** — structurally
  identical to the placeholder's vertex half;
- the **layout facts** for the interleaved stride-36 pos/normal/color input
  and the bgra8unorm/triangle-list/depth pipeline facts.

It **cannot** reproduce today:

- the lighting **uniform** resource (R2/R3/R7 — no `UniformBuffer` kind, no
  source path for a second binding);
- the **`view_depth` varying** (R4 — derived varyings only);
- the **body**: hemisphere ambient + Lambert, ACES + sRGB, exp2 fog (R6 —
  matrix transforms and lighting are the named remaining source-body item).

**What the checkpoint report §4.4 and the GOAL allow:**
- report §4.4: the corpus `reflection.json` fixtures are stale and **must be
  regenerated through the radix path** before host admission is built on them;
  `buildDescriptorFromReflection` is **retired** (never moved) — the shared
  `loadFaberGraphicsPipeline` becomes the only admission path.
- `triga-engine/GOAL.md` §"Programmability: shader": "It must not expose raw
  WGSL as the normal public material API. A later bounded
  programmable-material surface may let authors customize vertex and fragment
  behavior, but those programs must still pass through typed Radix lowering,
  reflection, target checks, and engine caching."
- `triga-engine/CAMPAIGN.md` S3: "keeps raw WGSL out of the **normal demo
  path**"; gate "no raw WGSL in the normal **public material** path."
- The corpus proof may therefore carry a checked-in shader until the typed
  path exists — corpus assets are proof fixtures ("Demo assets are proof
  fixtures, not the permanent renderer distribution", GOAL.md current-to-target
  table), and DS-S2 pins the "nearest radix-lowered equivalent, pixel
  references re-baselined (recorded change)" interim with the full lit shader
  landing with 80 Stage 4–5. The typed material/shader surface that retires
  the checked-in shader is S3 / 80 Stage 6 (materials, textures, lighting).

---

## 5. Gated action list (executable the moment 80 Stage 4 closes)

1. **Trigger / coordination point**: 80 Stage 4's gate closes (one Faber
   fixture lowers to typed vertex+fragment MIR and valid WGSL; reflection
   fully describes stage IO, vertex layouts, **resources**, pipeline targets,
   draw prerequisites). The regeneration lands in the **Stage 5→6 gap**
   (report §3: no seam during 80 Stages 4–5 without coordination) and is
   coordinated with the 80 graphics-MIR lane, which **authors the lit
   fixture's `.fab` source** (DS-S2 adds no `.fab`). Stage 5 (direct WebGPU
   first scene) is the DS-S2 Phase 2 dependency; the P1.3 regeneration itself
   depends only on Stage 4.

2. **Fixture**: 80 authors the lit fixture (e.g. `exempla/triga-lit-shaders.fab`
   in triga) declaring: `@ vertex`/`@ fragment` functions; interleaved
   `geometry_vertex_layout_matches` for position/normal/color (offset 0/12/24,
   stride 36); `geometry_pipeline_descriptor_matches` (bgra8unorm, depth less+
   write, triangle-list, vertex_count); and, once landed, the
   resource-binding/varying/fragment-output source facts for the lighting
   uniform + `view_depth` (G10). If the full lit body still does not lower,
   the interim fixture uses the nearest radix-lowerable equivalent (recorded
   pixel-reference re-baseline).

3. **Emit** (via hosts `scripta/webgpu-browser-proof generate`, extended per
   DS-S2; direct forms):
   ```bash
   radix emit -t wgsl-text -o <hosts>/public/generated/triga-lit.wgsl <lit-fixture>.fab
   radix emit --reflection -t wgsl-text -o <hosts>/public/generated/triga-lit-reflection.json <lit-fixture>.fab
   ```
   Do NOT move the stale corpus fixtures into `generated/` (DS-S2 invariant 4).

4. **Acceptance criteria**:
   - Regenerated reflection passes `loadFaberGraphicsPipeline` admission:
     `schema_version == 1`, `target == "wgsl-text"`, `kernels` present with
     per-kernel `launch.webgpu_adapter` descriptor projections; `pipeline`
     block carries color targets / topology / vertex_count / depth-stencil.
   - Emitted WGSL validates through naga when available (precedent:
     `validate_wgsl_with_naga` in `tool_test.rs`).
   - `buildDescriptorFromReflection` is **absent** from the hosts tree
     (grep asserted by `engine-admission-check.mjs`); its negative fixtures
     (reflection missing `schema_version`/`target`) still reject.
   - Both corpus demos render through the shared facade:
     `corpus/{webgl-geometries,webgl-geometry-terrain}/tests/run.sh` green
     (they re-copy `triga-lit.*` into each demo's `public/` and
     `src/shaders/test-data/`); pixel oracle re-baselined with a recorded
     change if the interim shader was used.
   - Triga `./scripta/check-source` and `./scripta/check-compile` unchanged
     (no `.fab` edits by DS-S2; the fixture is the 80 lane's).

5. **Ordering**: hosts side first (scripta extension + admission harnesses),
   then the corpus rewire is one serialized commit (both `run.sh`, both pages,
   `_host` disposition) so the corpus is never half-wired.

---

## 6. Key sources

- `radix/crates/radix/src/driver/mod.rs` — `generate_wgsl_text_output`
  (~512), `emit_wgsl_{vertex,fragment}_source_output` (~623, ~673),
  `emit_wgsl_graphics_pipeline_output` (~729), `collect_graphics_source_facts`
  (~2212), `collect_triga_vertex_layout_facts` (~2329),
  `derive_triga_varying_facts` (~2447), `collect_triga_fragment_output_facts`
  (~2470), `collect_triga_pipeline_facts` (~2485, default at ~2490),
  `collect_triga_resource_binding_facts` (~2625), `GraphicsSourceFacts`
  (~1654).
- `radix/crates/radix-mir-wgsl/src/lib.rs` — `emit_wgsl_vertex_entry_contract`
  (~233), `emit_wgsl_fragment_entry_contract` (~386),
  `emit_wgsl_fragment_entry_contract_with_targets` (~498),
  `emit_wgsl_vertex_resource_declarations` (~1036),
  `emit_wgsl_body_from_mir` (~4002).
- `radix/crates/radix/src/tool/commands/reflection.rs` — `GpuReflectionJson`,
  `GPU_REFLECTION_SCHEMA_VERSION=1`, `launch.webgpu_adapter` projections.
- `radix/crates/radix-mir/src/abi.rs` — `MirKernelResourceKind` (~1242,
  StorageBuffer-only), `MirKernelResourceRole`, `to_resource_reflection`
  (~509, "best-effort contract for Goal 01 acceptance").
- `radix/crates/radix/src/tool_test.rs` — source vertex/fragment driver tests,
  naga validation, `output_reflection_json` assertions.
- `radix/crates/radix/src/fixtures/triga-stage4-source-facts.fab` +
  `triga/exempla/triga-stage4-source-facts.fab` — layout-fact fixture shape.
- `radix/docs/factory/mir-gpu/progress-ledger.md` (9GI/9GJ),
  `goals/08-shader-stage-model.md` §Remaining, `goals/09-reflection-sidecar.md`.
- `radix/README.md` (~396) / `radix/docs/help/faber-after-help.md` (~86) —
  `emit -t wgsl-text` / `emit --reflection -t wgsl-text` invocation.
- `triga/docs/factory/triga-engine/checkpoint/report.md` §4.4, §8 row 3,
  §3 schedule; `T-D-reflection-boundary.md` §1.2/§1.3/§3 (G1–G11);
  `T-C-80-90-reconciliation.md` row 4; `GOAL.md` §"Programmability: shader";
  `CAMPAIGN.md` S3.
- `triga/docs/factory/triga-engine/deliveries/DS-S2-engine-extraction-slice.md`
  — invariants 3–4, fork table, fixtures, gates, open question "Triga-lit
  regeneration source".
- `triga/corpus/_host/README.md`, `corpus/*/tests/run.sh`,
  `corpus/*/public/triga-lit.wgsl` + `triga-lit-reflection.json` (placeholders).
