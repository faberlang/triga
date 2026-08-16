# Core Graphics Profile v0 — Stage 0 decision (frozen)

**Status**: frozen — decision on record (Stage 0 of the triga-hardening campaign)
**Date**: 2026-08-16
**Campaign**: [`CAMPAIGN.md`](./CAMPAIGN.md) Stage 0 (discovery-first)
**Delivery**: [`delivery.md`](./delivery.md) unit `tgh-s0-2`
**Source revision**: `d6f8e99c41a50a93af7c1108eff678908f3e32c7` (`triga` main)
**Machine-readable mirror**: [`proof/profile-v0.json`](../../../proof/profile-v0.json)
  (`profile_schema_version: 1`, consumed by Stages 7–8)

This document is the authoritative Core Graphics Profile v0 decision. Every
row below is grounded in the live `triga/src` tree (26 modules) and the live
hosts admission/engine surfaces, as captured by delivery §3.5. Discovery only:
no `src/` change, no capability-ledger change.

---

## 1. Decision: retain (with two evidence-forced refinements)

**The default profile shape is retained.** Every default-profile row has a
live source fact in the 26-module tree (`find src -name '*.fab'`), so the row
set does not force inventing modules. The execution gaps the live tree shows —
carrier-only composition, no draw, transform ABI drift — are owned by later
stages (5/7) as proof requirements, not by a profile reduction.

Two refinements are forced by the live evidence (§3.5 rows 6–7: the lit
material and lighting rows are carrier-only shapes with no constructor or
validation):

1. **One lit material row = `MeshPhongMaterial` only.** The Phong-shaped
   carrier exists (`src/material/lit.fab`); the PBR-shaped
   `MeshStandardMaterial` (`src/material/standard.fab`) is a separate carrier
   with no render path and stays on the unsupported broad horizon.
2. **Ambient + directional lighting only.** `AmbientLight` and
   `DirectionalLight` (`src/lighting/light.fab`) are the retained rows;
   `PointLight` stays on the unsupported broad horizon.

These refinements narrow the *supported* row set to exactly what the live
tree can ground; they are not a reduction of the default profile's shape.

## 2. Evidence table (delivery §3.5, verified live 2026-08-16)

| Default profile row | Live source fact | State today |
| --- | --- | --- |
| Perspective camera | `PerspectiveCamera` + `projectio()` / `visus_projectio()` + facts genera (`PerspectiveCameraProjectionFacts`, `ViewProjectionFacts`), `src/graph/camera.fab` | constructible, no proba |
| Indexed triangle geometry | `indexed_triangle_geometry` (`src/geometry/data.fab:722`), `index_format_code()` (`:210`), `topology_code()` (`:613`) | constructible, proba absent |
| Position/normal/UV attributes | `BufferAttribute` + `float32_attribute` (`src/geometry/attribute.fab`); `vertex_normals()` (`src/geometry/data.fab:491`) / `planar_uvs()` (`:569`) | constructible, proba absent |
| Model/view-projection transforms | `TransformPayload`, `matrix4_identitas|translatio|scala|composita|perspectiva|conspectus` (`src/math.fab`) | 32 f32/128 bytes vs hosts reflection 64 f32/256 bytes — drift |
| Depth/culling policy | `pipeline_matches(depth_compare_code, depth_write_enabled_code, …)` + goal constants (`goal_depth_compare_code ← 1` less, `goal_depth_write_enabled_code ← 1`, `goal_primitive_topology_code ← 1`, `goal_color_target_format_code ← 1`) `src/shader_contract.fab`; `MaterialPipelineFacts.side_code` / `material_side_code()` `src/material/base.fab` | adapter facts only |
| One lit material path | `MeshPhongMaterial` (`src/material/lit.fab`) — carrier only, no constructor/validation | shape only |
| Ambient/directional lighting | `AmbientLight` / `DirectionalLight` (`src/lighting/light.fab`) — carriers only | shape only |
| Resize/device-loss | no Triga surface; hosts execution (no-draw placeholder state) | hosts-owned, unproven |

### Live hosts corroboration (read-only evidence)

- `hosts/webgpu-browser/public/generated/graphics-reflection.json` —
  transform binding `element_count: 64`, `buffer_byte_len: 256`
  (drift vs `TransformPayload` 32 f32 / 128 bytes); pipeline
  `depth_write_enabled: true`, `depth_compare: "less"`,
  `color_target_formats: ["bgra8unorm"]`, `primitive_topology:
  "triangle-list"`, `vertex_count: 36`; vertex inputs float32x3
  `position` (location 0) and `color` (location 1), stride 12 — consistent
  with the Triga goal constants except the transform element count.
- `hosts/webgpu-browser/public/src/engine/engine.js` (lines 94–100) — the
  `triga-lit.*` artifacts are byte-identical pre-radix placeholders; the
  placeholder reflection is rejected by `loadFaberGraphicsPipeline` with a
  typed `FaberKernelContractError` and **no draw happens**. Documented gated
  state, not a defect. `TRANSFORM_BYTE_LEN = 128` (32 f32) is the engine's
  current local constant, `MAX_TRANSFORM_SEQUENCE = 600`.
- `hosts/webgpu-browser/public/src/contract/artifact-admission.js` —
  `loadFaberGraphicsPipeline` requires `schema_version: 1`, target,
  `launch.webgpu_adapter`, two kernels (vertex + fragment), and a
  draw-manifest `index_format` of `uint16`/`uint32`; the no-draw state is
  enforced at admission.
- `faber/docs/EBNF.md` — the language has a fixed-size register matrix type
  `matrix<T, [R, C]>` (type table), so the fixed-size carrier migration
  question (campaign Q3) has an available language path; the live carriers
  stay `list<f32>` today and the migration is a Stage 2/3 decision, not a
  v0 decision.

## 3. Supported rows (frozen)

Each supported row carries its proof requirement, owning stage, and evidence
level. Evidence levels follow the campaign ladder
(`executed-proba` → `target` (target-equivalence) → `browser-numeric-pixel`);
a lower tier never implies a higher one.

| # | Row | Live source (module/symbol) | Proof requirement | Owning stage | Evidence level |
| --- | --- | --- | --- | --- | --- |
| S1 | Perspective camera | `src/graph/camera.fab`: `PerspectiveCamera`, `projectio`, `visus_projectio`, `projectio_facta`, `visus_projectio_facta`, `PerspectiveCameraProjectionFacts`, `ViewProjectionFacts` | Camera projection probas: non-null projection/view for valid fov/aspect/near/far and eye/target/up; degenerate negatives (fov or near/far invalid); facts `float_count`/scale terms match `Matrix4` elements; Rust/TypeScript (declared-target) equivalence at the highest executed tier | 3 | executed-proba → target |
| — | — | — | Camera facts consumed by the admitted render descriptor: projection terms feed the host transform/view binding; view-projection numeric sample in the headless-browser draw matches the Triga-computed matrix | 7 | browser-numeric-pixel |
| S2 | Indexed triangle geometry (position/normal/UV) | `src/geometry/data.fab`: `indexed_triangle_geometry`, `index_format_code`, `topology_code`, `vertex_normals`, `planar_uvs`; `src/geometry/attribute.fab`: `BufferAttribute`, `float32_attribute`; `src/geometry/batch.fab`: `DrawRange`, `GeometryGroup` | Exact-value probas for positions/normals/UVs/winding/indices; negative validation (wrong attribute counts, malformed ranges, unknown topology); target-equivalence for the generated attributes | 3 | executed-proba → target |
| — | — | — | Indexed geometry consumed by the admitted descriptor: one `drawIndexed` per mesh with the position/normal/UV vertex-input layout; pixel/numeric sample verifies the drawn triangles | 7 | browser-numeric-pixel |
| S3 | Model/view-projection transforms | `src/math.fab`: `TransformPayload`, `Matrix4`, `matrix4_identitas`, `matrix4_translatio`, `matrix4_scala`, `matrix4_composita`, `matrix4_perspectiva`, `matrix4_conspectus` | Value probas for matrix4_* composition and `TransformPayload` (`float_count`/`byte_count`/`model_value`/`view_projection_value`); non-finite input cannot hang (campaign Stage 2 policy); target-equivalence at the highest executed tier | 3 | executed-proba → target |
| — | — | — | One versioned schema resolves the 32/128 vs 64/256 transform disagreement and generates/validates every Triga/Radix/Hosts reader; per-frame transform buffer numeric sample in the admitted draw | 7 | browser-numeric-pixel |
| S4 | Depth/culling policy | `src/shader_contract.fab`: `pipeline_matches`, `goal_depth_compare_code`, `goal_depth_write_enabled_code`, `goal_primitive_topology_code`, `goal_color_target_format_code`; `src/material/base.fab`: `MaterialPipelineFacts`, `material_pipeline_facts`, `material_side_code`, `material_depth_write_enabled` | Typed validation of the pipeline/material facts and profile semantics stating which facts affect culling, depth, and opacity/alpha; composition tests against the profile material/light rows | 5 | executed-proba → target |
| — | — | — | The admitted pipeline's `depth_stencil` (depth compare + write) matches the Triga facts — no host default silently substitutes; pixel sample verifies depth occlusion/culling in the drawn scene | 7 | browser-numeric-pixel |
| S5 | One lit material (`MeshPhongMaterial`, not PBR) | `src/material/lit.fab`: `MeshPhongMaterial`; `src/material/base.fab`: `Material` | Typed construction + validation negatives for `MeshPhongMaterial` (color/specular/shininess); composition with the `Mesh` renderable's material union (`src/renderable/mesh.fab`); probe that PBR `MeshStandardMaterial` stays outside the profile | 5 | executed-proba → target |
| — | — | — | Lit row rendered through the admitted pipeline; deterministic pixel sample proves Phong shading occurs (not flat/no-lighting) | 7 | browser-numeric-pixel |
| S6 | Ambient/directional lighting | `src/lighting/light.fab`: `AmbientLight`, `DirectionalLight`, `Light`; `src/graph/object.fab`: `Object3D` | Typed construction + validation of the two light contracts (color/intensity; `DirectionalLight.target_position`); composition tests in a profile scene; probe that entities not in the profile (`PointLight`) reject or are excluded at composition | 5 | executed-proba → target |
| — | — | — | Ambient + directional light facts consumed by the admitted descriptor/bindings; pixel/numeric sample verifies the lighting law (ambient term + directional contribution) | 7 | browser-numeric-pixel |

**Retained profile shape, hosts-owned (no Triga source row): resize and
device-loss** — no Triga surface exists today; hosts owns the execution
surface and currently sits in the documented no-draw placeholder state
(`engine.js`). Proof requirement: headless-browser draw survives resize
(depth/texture resize path) and device-loss rejection/recovery uses published
facts or rejects explicitly. Owning stage: **7**; evidence level:
**browser-numeric-pixel**. This row is part of the retained default profile
(§2) but is not a Triga supported row and carries no Triga source citation.

## 4. Unsupported rows (broad horizon, frozen)

These rows stay on the broad horizon and remain explicitly out of the
admitted profile at campaign closeout (capabilities §Dependency Rules). They
are listed only to make the split explicit.

| Row | Live evidence today | Why unsupported |
| --- | --- | --- |
| PBR `MeshStandardMaterial` | `src/material/standard.fab` (carrier only; roughness/metalness/emissive fields) | No render path; broad horizon; refinement S5 narrows the lit row to `MeshPhongMaterial` |
| `PointLight` | `src/lighting/light.fab` (carrier only; distance/decay) | Not consumed by the retained lighting row; refinement confines lighting to ambient + directional |
| Textures | `src/material/base.fab`: `TextureDescriptor` placeholder seed only | No sampler/mipmap/render-target pipeline; camera H3 relocation |
| Animation/skinning | No live module (planned `renderable/skin`, `renderable/morph`) | No source surface; separate feature campaign |
| Shadows | No live module (planned `lighting/shadow`) | No source surface; separate feature campaign |
| Post-processing | No live module | No source surface; separate feature campaign |
| Instancing | No instanced-draw surface (batch facts carry an `instance_count` field only, `src/geometry/batch.fab`); planned `renderable/instance` | No source surface; separate feature campaign |
| Terrain/voxel | No terrain/voxel module (planned `primitives/terrain`, `primitives/voxel`); `src/face.fab` voxel face-code helpers are shape-only | Not part of the admitted draw proof; separate feature campaign |
| Asset ingestion | No ingestion module (`ResourceHandle` is pure generation identity, `src/resource.fab`) | No source surface; separate feature campaign |

Unsupported rows must never appear operational by name alone (campaign Stage 5
overlap rule). Stage 7 rejects or excludes them at composition; the
capability ledger keeps them `unsupported` (see §6).

## 5. Profile-size assumptions (for a bounded draw proof — not a stress budget)

These are **assumptions for the bounded draw proof** that Stage 7 executes,
not the Stage 8 reproducibility/stress contract. Stage 8 freezes its own
budget values separately before measuring (campaign Q8; `delivery.md`§4
`tgh-s0-4` routes Q8 to Stage 8).

- **Single small scene** — one scene store with a small node set.
- **One camera** — the single `PerspectiveCamera` admitted per frame.
- **One directional light** — plus the ambient light row; no other light
  family is admitted.
- **≤ one lit mesh** — at most one mesh carrying a `MeshPhongMaterial`; any
  additional meshes are unlit profile geometry.
- **No textures** — no sampler/mipmap/render-target surface in the draw
  proof; the `TextureDescriptor` placeholder is not exercised.
- Size facts that bound the proof today (recorded, not budgets):
  `engine.js` `TRANSFORM_BYTE_LEN = 128` / `MAX_TRANSFORM_SEQUENCE = 600`,
  hosts `graphics-reflection.json` `vertex_count: 36`, Triga
  `goal_transform_element_count ← 32`.

## 6. Capability ledger

`proof/capabilities.json` (ledger revision 1, all 32 broad proofs
`unsupported`, 0/11 floors, 5/5 capstones unmanifested/unsupported) is
**unchanged by this decision**. The supported rows above are a profile
claim, not a ledger update: only Core Graphics Profile v0 is eligible for
upgrade, and that upgrade happens at **Stage 8** after the campaign gates
produce the required evidence. Every broader capability remains explicitly
`unsupported` (campaign §Stage 8 gate).

## 7. JSON mirror and verification

`proof/profile-v0.json` mirrors the tables above (`profile_schema_version:
1`) for machine consumption by Stages 7–8. All modules/functions cited in
this document were cross-checked against the live tree (the same
`find src -name '*.fab'` source the `tgh-s0-1` inventory derives from); no
pre-split symbol or non-existent module is cited. `profile-v0.json` keys
modules by the inventory's module-path convention.