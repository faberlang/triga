# Triga Hardening — Stage 2 Delivery Spec
## Failure model, valid-state construction, and API boundary

**Status**: delivery — lowered 2026-08-19 for Mind admission; no unit dispatched
by planner
**Date**: 2026-08-19
**Planner**: `planner` handle `3f4ef64b`
**Campaign**: [`CAMPAIGN.md`](./CAMPAIGN.md) Stage 2
**Landed prior**: Stage 0 (`delivery.md`); Stage 0.5 sources c01–c09
(`stage-0-5-delivery.md`, gate `tgh-s05-gate` still 22/26 blocked); Stage 1
spine (`stage-1-delivery.md`, hands 10/13/15)
**Depends on**: Stages 0–1 (landed). `tgh-s05-gate` green is **not** a start
dependency for any unit in this spec.
**Repository**: `/Users/ianzepp/work/faberlang/triga`
**Scope**: `src/**/*.fab` + `src/**/*.proba` failure-model/API migration,
`exempla/*.fab` consumer migrations, `docs/api-shape-policy.md` §5, the
inventory deriver/checker, and one `scripta/check` rung. No Radix/Hosts/Cista
writes. No version bump (Stage 6 owns version alignment).

## 0. Goal-check (Stage 2)

| Field | Value |
| --- | --- |
| Artifact | `docs/factory/triga-hardening/CAMPAIGN.md` §Stage 2 + Development Posture + open questions Q2/Q3 |
| Evaluator mode | cold self-pass against live `src/`, `scripta/`, `proof/inventory/`, live EBNF, live gradus |
| Intended consumer | delivery (this spec) |
| Verdict | **READY** for Stage 2 lowering |

**Reasoning.** Every Stage 2 gate sentence resolves to a named live surface
with no missing architecture decision:

- *Typed module errors and stable causa rendering.* The live language has the
  full error channel (`faber/docs/EBNF.md`: `⇥ E` after `→ T`, bare-`⇥`
  effect-only failables, `throw`/`iace`, `do { } catch err { }`, closure
  channel rules). Live gradus is the executed reference pattern:
  `gradus/src/tensor.fab` defines `union TensorError { Variant { string
  message } … }`, raises `throw variant IndexOutOfBounds {message = "…"}`, and
  renders through a module-level `fn message(TensorError e) → string`.
  Verified 2026-08-19: freshly built `radix/target/debug/radix check --locale
  en` passes `gradus/src/tensor.fab` and `gradus/src/math.fab` (cross-module
  error values caught and rendered via `dtype.message(err)` in
  `gradus/src/math.fab:628-647`). Both packages are `locale = "en"`, matching
  `triga/faber.toml`. No compiler-expressiveness gap.
- *`null` only for genuine absence.* The live census is
  `proof/inventory/triga-inventory.json` `error_null_contract`:
  `typed_error_channel: none`, `failable_return_arrow_occurrences: 0`,
  `iace_call_sites: 0`, `null_returning_functions: 147`. Per-leaf `∪ null`
  counts: geometry/data 67, math 53, scene 52, resource 35, geometry/batch 21,
  primitives/basic 10, graph/camera 8, material/basic 7, face 4,
  geometry/attribute 3, material/base 2.
- *Centralized boundary checks.* Live defects confirmed: `scene.fab:108`
  `continet` checks only the upper bound (`manubrium.index ≥
  self.slots.length()`), not negative index; `math.fab:759`
  `_angulus_reductus` while-loops hang on `inf` and pass NaN through;
  `_radix_f32` (`math.fab:732`) clamps `≤ 0.0` but propagates NaN
  (campaign open-questions Q2 records the same for
  `geometry/data.fab`/`primitives/basic.fab` helpers; Q2's `math.fab:705`
  citation is stale against the live tree); `Matrix3`/`Matrix4`
  carry public `list<f32> elements` and `determinans_affinis`/`transposita`
  (`math.fab:119-134`) index fixed positions with no length entry guard.
- *Receiver-method policy agrees with exports.* Live `./scripta/check-source`
  exits 1 with 14 genus-prefixed red rows across `face.fab`,
  `geometry/{batch,data,layout}.fab`, `math.fab`, `resource.fab`,
  `shader_contract.fab`, `material/{base,basic}.fab` and five `.proba` files
  (full census in §3.2).
- *Generated API/diagnostic inventory fails on drift.* `proof/inventory/`
  already carries `derive-inventory.sh` + `check-inventory` +
  schema-versioned `triga-inventory.json` with an `error_null_contract`
  section; Stage 2 extends it to per-module diagnostics and wires it into the
  spine.
- Open questions Q2 (non-finite policy, named degenerates retained:
  `Vector3.normata()` → zero vector, `Quaternion.normata()` → identity) and
  Q3 (`matrix<T, [R, C]>` register type exists; grammar `faber/docs/EBNF.md`
  type table, compiler `radix-module` types/codegen tests, live exempla
  `examples/conversio-matrix/`) are answered and routed to Stages 2/3; this
  spec takes the Stage 2 half and names the Stage 3 half (§5).

**Key points**

- Stage 2 is a clean-break API migration stage. Pre-1.0 posture (campaign
  Invariant): each family migrates in one unit including every in-repo
  consumer; no alias layer, no half-migrated leaf.
- The 4 executed-proba runner failures (`material/base`, `material/lit`,
  `material/standard` assertion reds; `scene` MIR red) are owned by
  `tgh-s05-gate` residuals and later correctness stages. Stage 2 units touch
  those files and must preserve the red assertions' content verbatim —
  migration is call-shape only there.
- The committed inventory is stale on `co_located_tests` (10 vs the live 26
  probas) and pins `source_revision` 6137a81; the final unit regenerates it.
  `check-inventory` is currently green only because src facts have not moved
  since its last derivation; every Stage 2 migration unit turns it red until
  `tgh-s2-9` regenerates. It is not in the `./scripta/check` spine today, so
  no intermediate spine red is introduced.
- Live baseline health: `./scripta/check-compile` passes all 26 leaves and
  the checked exempla on 2026-08-19 after rebuilding the stale sibling
  binaries (the WGSL-suite stale-binary failure mode, cf. triga commit
  `093d0b8`). The one exempla red is `PARSE050.import_privata_removed` on
  `exempla/triga-geometry-attributes.fab` (4 import lines) — a retired-syntax
  fixup that `tgh-s2-5` may retire to restore its oracle (§10 Q4).

**Recommended next step:** file `tgh-s2-1` first (pattern unit, alone), then
the wave-2+ units per §4 ordering.

## 1. Interpreted theme

Stage 2 gives Triga one consistent rule for malformed input, genuine absence,
finite numbers, and construction invariants, and makes the public export
surface agree with the receiver-method policy.

Today:

- Zero typed errors exist. 147 public functions return `∪ null` or `bool` for
  rejection, indistinguishable from genuine absence
  (`resource_transition_changed_count` returns `int ∪ null` for an invalid
  batch; `SceneStore.cape` returns null for a stale handle; `adiunge` returns
  false for invalid-handle vs cycle vs valid-rejection).
- Non-finite inputs hang or silently propagate
  (`_angulus_reductus`/`_radix_f32` family).
- `Matrix3`/`Matrix4` public `list<f32>` carriers are constructible at any
  length; ops index fixed positions unguarded.
- `SceneStore.continet` misses the negative index.
- The complete-exported-surface lint is intentionally red on 14 files
  (Stage 1 `tgh-s1-1` receipt) pending this migration.
- The inventory has no per-module diagnostic facts, and `check-inventory` is
  not a spine rung.

## 2. Normalized spec

One delivery-sized outcome:

> Every public Triga rejection path raises a typed module error with a stable
> causa string renderable through a module-level `message` function; `∪ null`
> survives only for genuine absence; finite-input, non-negative
> index/generation, ceiling, and carrier-length checks are centralized at
> creation/mutation boundaries; the receiver-method lint is green with
> constructor/adapter exemptions recorded in policy; and the regenerated
> inventory records per-module error unions, variants, causa renderers, and
> rejection paths, with `check-inventory` failing on undocumented drift as a
> spine rung.

### Locked architecture directions

| Lock | Decision |
| --- | --- |
| Error union shape | One `union <Leaf>Error` per owning leaf, every variant carrying `string message` (gradus `TensorError`/`MathError` shape). Variants are declared and raised in the owning leaf only — cross-module *variant naming* is a known compiler gap (gradus tensor.fab header note); cross-module error *values* flow via `do/catch` and render through the owning module's `message`. |
| Causa contract | Causa strings are ASCII English, stable public contract, one per variant+site, recorded in the inventory; changing one is a documented API change. |
| Surface spelling | `locale = "en"`: `⇥ E`, `throw variant X {message = "…"}`, `do { … } catch err { … }`, `match e { case V const m { … } }`. (Campaign prose says `iace`/`fac…cape`; that is the Latin surface of the same channel. `requirit` is proposed-only in the EBNF — do not use.) |
| Genuine absence | `∪ null` remains only where no value exists: `SceneStore.inveni` name-miss, ray/intersection miss, optional parent (`SceneNode.parent`, lifecycle `previous`/`current` one-sided states), and the like. Stale handle, invalid batch, wrong length, non-finite input, negative index, cycle, bad topology ⇒ typed error. |
| Named degenerates (Q2) | `Vector3.normata()` keeps returning the zero vector and `Quaternion.normata()` the identity `(0,0,0,1)` — documented degenerates, not errors. Everything else non-finite at a public boundary rejects. |
| Finite predicate | Public pure-scalar helper `fn finita(f32 valor) → bool` in `math.fab` (policy §1 scalar-helper class). Implementation is Hand's choice between NaN self-inequality plus `v - v ≠ 0.0` algebra and an `abs` bound against f32 max; proba must prove classification for NaN, ±inf, ±max, 0, and normals. |
| Matrix carriers (Q3) | Stage 2 keeps `list<f32>` storage but centralizes validation: constructors gain `⇥ MathError` on wrong length / non-finite / degenerate input, and every public matrix/transform operation begins with a length guard raising `MathError` (public fields stay constructible — `@ protecta` is rejected by the grammar, so op-entry guards are the honest Stage 2 enforcement). The `matrix<f32, [R, C]>` register-type storage migration is Stage 3 (§5) where exactness and indexing semantics are proven; it then removes the redundant guards. |
| Per-operation table | §2.1 below is the default table; Mind may amend rows, units implement the table, and `tgh-s2-9` records the final table in the inventory. |
| Receiver-method migration | Real migrations: `material_*` → `Material` methods, `mesh_basic_material_*` → `MeshBasicMaterial` methods, `color_valida`/`color_interpolata` → `Color` methods, `face_code_*` projections → `FaceCodeFacts` query accessors (§4 policy), `visible_face_*` → `VisibleFaceMeshFacts` query accessors, `resource_transition_*`/`resource_lifecycle_*` batch projections → query genera on the transition families. Constructor and compiler-contract-adapter families get §5 policy exemptions instead (§3.2 classification). |
| Proba evidence tier | New rejection/negative proba cases are authored red-first where executable, parse/check-green on landing; executed proof rides the `tgh-s05-gate` refresh cycle (Hands do not remeasure the scorecard — Stage 1 law). The 4 known-red runner rows keep their assertion content verbatim. |
| No version bump, no corpus | Root manifests stay `0.2.0`; corpus packages and their `dist/` artifacts stay untouched (Stage 6 consumers). |

### 2.1 Default per-operation acceptance/rejection table

| Operation family | Non-finite input | Structural invalidity | Result channel |
| --- | --- | --- | --- |
| `Vector3/4.normata` | named degenerate (zero vector) | — | value (unchanged) |
| `Quaternion.normata` | named degenerate (identity) | — | value (unchanged) |
| `matrix3_*`/`matrix4_*` constructors | `⇥ MathError.NonFinita` | wrong length / degenerate basis (`conspectus` up) `⇥ MathError` | value or error |
| matrix ops (`multiplicata`, `transposita`, `inversa_affinis`, …) | entry guard `⇥ MathError.NonFinita` | carrier length `⇥ MathError.Longitudo` | value or error |
| `inversa_affinis` (determinant ≈ 0) | — | non-invertible `⇥ MathError.Degenerata` | error (was `∪ null`) |
| angle/camera scalar helpers (`camera_pitch_coercita`, `radians_ex_gradibus`, …) | `⇥` at public boundary (`NonFinita`) | — | value or error |
| `transform_payload` | `⇥ MathError.NonFinita` | carrier length `⇥ MathError.Longitudo` | value or error (was `∪ null`) |
| geometry constructors (`indexed_triangle_geometry`, `line_geometry`, `colored_indexed_geometry`, attribute/layout builders) | `⇥ GeometryError.NonFinita` | negative counts, index ≥ vertex count, stride/offset misalignment `⇥ GeometryError` | value or error |
| `visible_face_*` / bounds | `⇥ GeometryError.NonFinita` | negative face count / empty bounds misuse `⇥ GeometryError` | value or error |
| primitive generators (`plane_geometry`, `sphere_geometry`) | `⇥ PrimitiveError.NonFinita` | non-positive segments/size `⇥ PrimitiveError` | value or error |
| camera `projectio`/`visus_projectio` | `⇥ CameraError.NonFinita` | non-positive fov/aspect `⇥ CameraError` | value or error (was `∪ null`) |
| resource transitions/lifecycles | — | invalid transition, duplicate logical index, generation mismatch `⇥ ResourceError` | value or error (batch accessors stop returning `∪ null`) |
| scene store (`cape`, `adiunge`, `seiunge`, `detrahe`, `pone_*`, traversals) | — | stale/negative handle, cycle, unknown root `⇥ SceneError` | value or error; `inveni` miss stays `∪ null` |
| `face_code_*` / `face_code_unit_quad` | — | unknown code `⇥ FaceError` (via `MathError` in math's facts) | value or error |

Non-goals (whole stage):

- no numeric exactness, error envelopes, or storage-type migration (Stage 3)
- no scene traversal/resource lifecycle semantics rewrite (Stage 4)
- no camera/material/light profile composition semantics (Stage 5)
- no version/license/docs-package work (Stage 6)
- no ABI/schema change: `_code` fields and frozen names untouched; the 32/128
  vs 64/256 transform disagreement stays a Stage 7 fact
- no corpus package or `dist/` regeneration
- no scorecard remeasure, no `tgh-s05-gate` closure attempt, no Radix edits
- no weakening of any existing proba assertion or lint rule

## 3. Repo-aware baseline (live, 2026-08-19)

### 3.1 Toolchain and spine

- `./scripta/check` rungs: `check-source` (structural), `check-compile`
  (structural), `check-proba-coverage` (executed-proba, honest-red 22/26),
  `check-wgsl-shader-contract-conformance` (wgsl), `check-capabilities`
  (public-execution). `check-inventory` exists at `proof/inventory/` but is
  **not** a rung.
- Per-leaf structural check route (the one `check-compile` uses; verified
  green for all 26 leaves today):
  `cd triga && ../radix/target/debug/radix check --locale en src/<leaf>.fab`
  — the sibling debug binaries were stale against the radix locale-pack move
  and were rebuilt 2026-08-19; if a Hand sees the reader-locale error, rebuild
  `radix-module --bin radix` and `faber` first (known stale-binary mode).
- `./scripta/check-source` exit 1: 14 files with genus-prefixed red rows.
- `./scripta/check-compile`: 26/26 leaves `ok`; exempla red only
  `exempla/triga-geometry-attributes.fab` `PARSE050.import_privata_removed` ×4.
- Inventory: revision 1, `source_revision` 6137a81,
  `co_located_tests: 10` (stale; 26 live), `error_null_contract` zeros as in
  §0.

### 3.2 Lint-red census and disposition

| File | Red functions | Disposition |
| --- | --- | --- |
| `src/material/base.fab` | `material_valida`, `material_double_sided`, `material_est_double_sided`, `material_side_code`, `material_depth_enabled`, `material_depth_test_enabled`, `material_depth_write_enabled`, `material_pipeline_facts` (8) | migrate to `Material` receiver methods |
| `src/material/basic.fab` | `mesh_basic_material` (ctor), `mesh_basic_material_valida`, `_color_{r,g,b}`, `_alpha`, `_pipeline_facts` (7) | ctor stays free + gains `⇥`; rest migrate to `MeshBasicMaterial` methods |
| `src/math.fab` | `color_valida`, `color_interpolata`, `face_code_valida`, `face_code_axis_code`, `face_code_opposite`, `face_code_{x,y,z}_offset`, `face_code_normal`, `face_code_color`, `face_code_facts`, `transform_payload` (11) | `Color` receiver methods; `face_code_*` collapse into `FaceCodeFacts` query genus + accessors; `transform_payload` → §5 constructor exemption + `⇥` |
| `src/face.fab` | `face_code_unit_quad` (1) | scalar-domain generator → §5 exemption + `⇥ FaceError` |
| `src/geometry/batch.fab` | `visible_face_{vertex,index,triangle}_count`, `visible_face_{position,color,index,payload}_byte_count`, `visible_face_mesh_facts` (8) | collapse into `VisibleFaceMeshFacts` query genus + accessors |
| `src/geometry/data.fab` | `indexed_triangle_geometry`, `line_geometry`, `colored_indexed_geometry` (3) | BufferGeometry constructors → §5 exemption + `⇥ GeometryError` |
| `src/geometry/layout.fab` | `vertex_format_from_component_width`, `vertex_step_mode_vertex_step` (2) | scalar→genus constructors → §5 exemption |
| `src/shader_contract.fab` | `vertex_layout_matches`, `resource_binding_matches` (2) | compiler-contract adapters → §5 exemption (precedent `geometry_vertex_layout_matches`) |
| `src/resource.fab` | 39 `resource_*` functions | §4 query-genus collapse + typed errors (see `tgh-s2-3`) |
| `src/graph/camera.proba` | `camera_base` | test-local helper rename off the genus stem |
| `src/lighting/light.proba` | `light_node`, `light_node_at` | test-local helper rename |
| `src/geometry/data.proba`, `src/geometry/bounds.proba` | `indexed_positions`, `indexed_colors`, `indexed_geometry`, `line_positions` | test-local helper rename |
| `src/shader_contract.proba` | `vertex_format_code_published`, `color_target_format_code_published`, `resource_kind_code_published`, `resource_role_code_published`, `resource_access_code_published` | test-local predicate rename or §5 adapter exemption |

### 3.3 Caller map (drives unit ordering)

- material family `.proba` callers: `material/{base,basic,lit,standard}.proba`,
  `renderable/mesh.proba`. Exempla: `triga-basics.fab` (base+basic),
  `triga-graphics-pipeline-facts.fab` (basic).
- resource family callers: `src/resource.proba`,
  `exempla/triga-scene-store.fab` (also calls matrix constructors — hence
  serial math→resource ordering). No `.fab` leaf calls `resource_*`.
- math family `.fab` callers: matrix constructors → `graph/camera.fab`,
  `scene.fab`, exempla `triga-math-edge-cases.fab`, `triga-scene-store.fab`,
  `triga-transforms.fab`, `triga-types-untested.fab`; `transform_payload` →
  `scene.fab`, exempla `triga-hello-voxel-pipeline.fab`, `triga-transforms.fab`;
  `face_code_*`/`color_*` → `face.fab`, `material/basic.fab`,
  `exempla/triga-transforms.fab`.
- geometry constructor `.fab` callers: `primitives/basic.fab` (plus the
  defining `geometry/data.fab`); probas `geometry/{attribute,batch,bounds,
  data,layout}.proba`, `renderable/mesh.proba`; exempla
  `hello-voxel-first-draw-facts.fab`, `triga-geometry-attributes.fab`,
  `triga-hello-voxel-pipeline.fab`, `triga-hello-voxel-shaders.fab`.
- `visible_face_*` callers: `geometry/batch.fab` (defines),
  `geometry/data.fab`.
- layout scalar constructors: `geometry/attribute.fab`, `geometry/layout.fab`.
- shader_contract adapters: `geometry/data.fab`, `geometry/layout.fab`, the
  seven `exempla/conformance/shader-contract/*.fab` programs and
  `exempla/triga-stage4-source-facts.fab` (WGSL-gate corpus — untouched
  because the adapter exemption keeps the signatures).

### 3.4 Executed-proba tier per touched module

22/22 executed-green modules include `material/basic`, `math`, `resource`,
`graph/camera`, `geometry/{attribute,batch,bounds,data,layout}`,
`primitives/basic`, `face`, `renderable/mesh`. The four runner-failure rows on
this stage's write surfaces: `material/base` (assertion: texture descriptor
placeholder shape), `material/lit` (assertion: Phong defaults),
`material/standard` (assertion: standard defaults), `scene`
(`invalid MIR: option unwrap operand is not nullable`). Units preserve those
assertions' content; the MIR defect is a Radix residual on `tgh-s05-gate`.

## 4. Hand unit graph

Nine units in five waves. Wave N starts after wave N−1 lands (write-surface
conflicts in §3.3 all cross wave boundaries). Within a wave, write scopes are
disjoint.

```
w1: tgh-s2-1
w2: tgh-s2-2
w3: tgh-s2-3 ∥ tgh-s2-4 ∥ tgh-s2-5
w4: tgh-s2-6 ∥ tgh-s2-7 ∥ tgh-s2-8
w5: tgh-s2-9
```

### `tgh-s2-1` — pattern: material family failure model + receiver methods

- **outcome**: `Material` and `MeshBasicMaterial` operations become receiver
  methods with typed errors; construction validates fail-closed
  (`⇥ MaterialError`); total accessors replace nullable re-validation;
  `mesh_basic_material_pipeline_facts` becomes a projection that errors, not
  nulls. This unit establishes the leaf-family pattern (error union + causa +
  `message` renderer + construction invariants + receiver shape) that waves
  2–4 replicate.
- **write_scope**: `triga/src/material/base.fab`, `triga/src/material/base.proba`,
  `triga/src/material/basic.fab`, `triga/src/material/basic.proba`,
  `triga/src/material/lit.proba`, `triga/src/material/standard.proba`
  (call-site updates only), `triga/src/renderable/mesh.proba` (call-site
  updates only), `triga/exempla/triga-basics.fab`,
  `triga/exempla/triga-graphics-pipeline-facts.fab`
- **done_when**:
  1. `material/base.fab` defines `union MaterialError` (variants per §2.1,
     each `{string message}`) and a public `message(MaterialError) → string`;
     `material/basic.fab` defines its own `MaterialError` or reuses base's
     type with base-owned variants raised only in base (cross-module variant
     naming is unsupported — follow gradus dtype precedent);
  2. `grep -rn "material_valida(\|material_pipeline_facts(\|material_double_sided(\|material_side_code(\|material_depth_\|material_est_\|mesh_basic_material_"
     src/ exempla/ --include="*.fab" --include="*.proba"` returns no
     free-function call sites (the exempted `mesh_basic_material(` constructor
     form may remain only if it keeps its constructor exemption spelling);
  3. invalid Material/MeshBasicMaterial input raises typed errors; valid
     construction makes accessors total (no `f32 ∪ null` color/alpha
     accessors remain);
  4. `radix check --locale en` passes `src/material/base.fab`,
     `src/material/basic.fab`, and the two exempla;
  5. `lit.proba`/`standard.proba`/`mesh.proba` call sites updated; the known
     assertion-red content in `base.proba`/`lit.proba`/`standard.proba` is
     byte-preserved in meaning (call shape may change, assertion operands and
     expected values may not);
  6. new rejection proba cases exist in `base.proba`/`basic.proba` for each
     new error variant (parse/check-green; executed tier rides the gate).
- **depends_on**: none
- **sanity**: `../radix/target/debug/radix check --locale en src/material/base.fab
  src/material/basic.fab` from `triga/`; the §done_when grep
- **read_scope**: `docs/api-shape-policy.md`, `gradus/src/tensor.fab`
  (pattern reference), `docs/factory/triga-hardening/stage-2-delivery.md` §2
- **non_goals**: `material/lit.fab`/`material/standard.fab` source changes
  (they are receiver-clean and null-free; their red assertions are not
  Stage 2's); Phong/standard semantics; texture pipeline design
- **risk**: medium — first use of the error channel in triga; if the compiler
  rejects a pattern gradus does not exercise, stop and report to Mind as a
  Radix residual rather than inventing a workaround
- **integrable**: yes

### `tgh-s2-2` — math + face failure model, finite policy, carrier validation

- **outcome**: `math.fab` gains `MathError` + `message`, public `finita(f32)`
  predicate, `⇥` on all rejecting matrix/transform/angle/color/face-code
  paths, entry length guards on matrix ops, the `Color` receiver-method
  migration, and the `FaceCodeFacts` query-genus collapse of `face_code_*`;
  `_angulus_reductus`/`_radix_f32` become finite-guarded; `face.fab`'s
  `face_code_unit_quad` gains `⇥ FaceError`. All in-repo callers migrate.
- **write_scope**: `triga/src/math.fab`, `triga/src/math.proba`,
  `triga/src/face.fab`, `triga/src/face.proba`, call-site updates in
  `triga/src/graph/camera.fab`, `triga/src/scene.fab`,
  `triga/src/material/basic.fab`, `triga/exempla/triga-transforms.fab`,
  `triga/exempla/triga-hello-voxel-pipeline.fab`,
  `triga/exempla/triga-math-edge-cases.fab`,
  `triga/exempla/triga-types-untested.fab`,
  `triga/exempla/triga-scene-store.fab`
- **done_when**:
  1. `finita(f32)` is public in `math.fab` and `math.proba` proves
     classification for NaN, +inf, −inf, ±f32-max, 0, and ordinary values
     (or reports honestly if non-finite values cannot be constructed at the
     executed tier — see §10 Q2);
  2. `grep -n "∪ null" src/math.fab` returns only genuine-absence sites (ray
     miss class); every rejection path raises `MathError`;
  3. `matrix3_*`/`matrix4_*` constructors and `transform_payload` are `⇥`;
     `multiplicata`/`transposita`/`inversa_affinis`/elementwise matrix ops
     begin with a length guard;
  4. `_angulus_reductus` and `_radix_f32` reject non-finite input instead of
     looping/clamping it (private guards; public boundary raises);
  5. `color_valida`/`color_interpolata` are `Color` receiver methods;
     `face_code_*` free functions are gone, replaced by
     `face_code_facts`-shaped query accessors on `FaceCodeFacts` with unknown
     codes raising the math-side error;
  6. `radix check --locale en` passes `math.fab`, `face.fab`, `camera.fab`,
     `scene.fab`, `material/basic.fab` and every listed exemplum;
  7. call-site edits in `scene.fab` are mechanical only (null-checks →
     `do/catch`); scene's own error model stays in `tgh-s2-8`.
- **depends_on**: `tgh-s2-1` (shared `material/basic.fab` surface)
- **sanity**: per-leaf `radix check --locale en` over the write scope; the
  §done_when greps
- **read_scope**: `gradus/src/math.fab` (MathError reference),
  `faber/docs/EBNF.md` §conversio/throw
- **non_goals**: `matrix<T, [R, C]>` storage migration (Stage 3); numeric
  envelope pinning; camera's own method errors (`tgh-s2-4`); scene error
  model (`tgh-s2-8`); frozen `_code` fields
- **risk**: high — widest caller fan-in (7 exempla + 3 leaves); the
  `∪ null` → `⇥` cascade can surface semantic-check surprises in exempla that
  must be fixed at the call site, never by reverting the migration
- **integrable**: yes

### `tgh-s2-3` — resource query genera + typed errors

- **outcome**: the 39 `resource_*` free functions collapse per
  `api-shape-policy` §4 into receiver methods on `ResourceHandle`/
  `ResourceTransition`/`ResourceLifecycleTransition` plus query genera
  (`ResourceTransitionCounts`-class projections with total accessors),
  and invalid batches raise `ResourceError` instead of returning `∪ null`.
- **write_scope**: `triga/src/resource.fab`, `triga/src/resource.proba`,
  `triga/exempla/triga-scene-store.fab` (resource call sites; matrix sites
  already migrated by `tgh-s2-2`)
- **done_when**:
  1. `grep -c "∪ null" src/resource.fab` counts only the lifecycle one-sided
     absence sites (`previous`/`current` optional fields and their honest
     readers); no `int ∪ null` / `list<…> ∪ null` batch accessor remains;
  2. `grep -rn "resource_handle_\|resource_transition_\|resource_lifecycle_"
     src/ exempla/ --include="*.fab" --include="*.proba"` returns no
     genus-prefixed free functions beyond constructor-shaped exemptions the
     unit records in its commit message;
  3. `ResourceError` + `message` exist; duplicate logical index, generation
     mismatch, and invalid one-sided transitions raise it;
  4. `ResourceHandleTraversal.remaining` ceiling semantics are documented at
     the boundary and preserved (Stage 4 owns deeper lifecycle proofs);
  5. `radix check --locale en` passes `resource.fab` and
     `triga-scene-store.fab` (the check-compile Faber-provider path for that
     exemplum must still pass);
  6. rejection proba cases cover each error variant (parse/check-green).
- **depends_on**: `tgh-s2-2` (shared `triga-scene-store.fab` exemplar)
- **sanity**: `radix check --locale en src/resource.fab
  exempla/triga-scene-store.fab`; the §done_when greps
- **read_scope**: `api-shape-policy.md` §4
- **non_goals**: scene-store integration (Stage 4 semantics); host disposal
  authority (Stage 4/7); `ResourceHandle` field changes
- **risk**: medium — largest single-leaf rewrite; the query-genus shape is a
  public API redesign, so the commit message must enumerate the new genera
- **integrable**: yes

### `tgh-s2-4` — graph/camera errors + lighting proba helpers

- **outcome**: camera methods (`projectio`, `projectio_facta`,
  `visus_projectio`, `visus_projectio_facta`, ray/planar helpers as
  applicable) replace `∪ null` rejections with `⇥ CameraError`; genuine
  absence (no intersection) stays nullable; `camera.proba` and
  `lighting/light.proba` helpers renamed off genus stems.
- **write_scope**: `triga/src/graph/camera.fab`, `triga/src/graph/camera.proba`,
  `triga/src/lighting/light.proba`; any in-repo caller of changed camera
  methods discovered by grep (expected: exempla only)
- **done_when**:
  1. `grep -n "∪ null" src/graph/camera.fab` shows only genuine-absence
     returns (ray-miss class), each with a comment naming the absence;
  2. `CameraError` + `message` exist; non-finite and non-positive
     fov/aspect/near/far raise it;
  3. `./scripta/check-source` no longer reports `camera.proba` or
     `lighting/light.proba`;
  4. `radix check --locale en` passes `camera.fab` and touched exempla.
- **depends_on**: `tgh-s2-2` (camera.fab call sites from the math migration)
- **sanity**: `radix check --locale en src/graph/camera.fab`; `grep -c
  genus-prefixed <(./scripta/check-source 2>&1)` decreased by the two proba
  rows
- **read_scope**: none restricted
- **non_goals**: camera composition semantics (Stage 5); `graph/object.fab`
  (already clean: zero nulls, zero lint rows)
- **risk**: low
- **integrable**: yes

### `tgh-s2-5` — geometry carriers: attribute + data validation

- **outcome**: `BufferAttribute`/`BufferGeometry` construction validates
  fail-closed (`⇥ GeometryError`: negative counts, index ≥ vertex count,
  stride/offset misalignment, non-finite values); `_geometry_radix_f32` gets
  the finite guard; the three red constructors keep constructor shape (policy
  exemption lands in `tgh-s2-9`) but become failable; callers migrate.
- **write_scope**: `triga/src/geometry/attribute.fab`,
  `triga/src/geometry/attribute.proba`, `triga/src/geometry/data.fab`,
  `triga/src/geometry/data.proba`, call-site updates in
  `triga/src/primitives/basic.fab`, `triga/src/renderable/mesh.proba`,
  `triga/exempla/hello-voxel-first-draw-facts.fab`,
  `triga/exempla/triga-geometry-attributes.fab`,
  `triga/exempla/triga-hello-voxel-pipeline.fab`,
  `triga/exempla/triga-hello-voxel-shaders.fab`
- **done_when**:
  1. `GeometryError` + `message` exist in the owning leaf, with variants for
     the §2.1 geometry rows;
  2. rejection proba cases exist for each variant (parse/check-green);
  3. `radix check --locale en` passes `attribute.fab`, `data.fab`,
     `primitives/basic.fab`, and the four exempla — where
     `triga-geometry-attributes.fab` still fails PARSE050, the unit may apply
     the mechanical retired-import fixup (§10 Q4) and must then note the
     known-red retirement in its commit message;
  4. `visible_face_*` call sites in `data.fab` are untouched (batch family is
     `tgh-s2-6`); `shader_contract` adapter call sites are untouched
     (exemption route);
  5. frozen ABI fields (`format_code`, `step_mode_code`, `offset_bytes`,
     `stride_bytes`, `source_name`, …) are byte-unchanged.
- **depends_on**: `tgh-s2-2` (shared `triga-hello-voxel-pipeline.fab`
  exemplar)
- **sanity**: `radix check --locale en src/geometry/attribute.fab
  src/geometry/data.fab src/primitives/basic.fab`
- **read_scope**: `api-shape-policy.md` §3 (frozen seam)
- **non_goals**: exact geometry values/target equivalence (Stage 3);
  layout/bounds/batch families (`tgh-s2-6`)
- **risk**: medium — `geometry/data.fab` is the densest leaf (67 nulls);
  classification of genuine absence (empty-geometry bounds) must be explicit
  per site
- **integrable**: yes

### `tgh-s2-6` — geometry projections: layout + bounds + batch

- **outcome**: `visible_face_*` collapses into the `VisibleFaceMeshFacts`
  query genus with total accessors and `⇥ GeometryError` on negative counts;
  layout scalar constructors become failable where they can reject; bounds
  misuse rejects; the three geometry probas' test-local helpers rename off
  genus stems.
- **write_scope**: `triga/src/geometry/layout.fab`,
  `triga/src/geometry/layout.proba`, `triga/src/geometry/bounds.proba`,
  `triga/src/geometry/batch.fab`, `triga/src/geometry/batch.proba`,
  call-site updates in `triga/src/geometry/data.fab`
  (`visible_face_*` readers)
- **done_when**:
  1. `grep -rn "visible_face_" src/` returns only the query genus and its
     accessors;
  2. `./scripta/check-source` no longer reports `geometry/layout.fab`,
     `geometry/batch.fab`, `geometry/bounds.proba`, `geometry/data.proba`;
  3. `radix check --locale en` passes the touched leaves;
  4. rejection proba cases exist for the new error variants.
- **depends_on**: `tgh-s2-5` (data.fab constructor surface)
- **sanity**: `radix check --locale en src/geometry/batch.fab
  src/geometry/layout.fab`; the §done_when greps
- **read_scope**: none restricted
- **non_goals**: bounds math exactness (Stage 3)
- **risk**: low–medium
- **integrable**: yes

### `tgh-s2-7` — scene failure model

- **outcome**: `SceneStore` rejections raise `SceneError`
  (stale/generation-mismatched handle, unknown root, cycle, non-node-kind
  misuse); `continet` gains the negative-index check; `cape`/`adiunge`/
  `seiunge`/`detrahe`/`pone_*` stop returning bool/null for rejection;
  `inveni` keeps `∪ null` for name-miss; traversal ceilings stay explicit.
- **write_scope**: `triga/src/scene.fab`, `triga/src/scene.proba`
- **done_when**:
  1. `continet` rejects negative `manubrium.index` (unit proba proves a
     negative handle is not contained, structurally — the module's executed
     tier is MIR-blocked and stays honestly open);
  2. `SceneError` + `message` exist with variants for stale handle, negative
     index, cycle, and unknown root; rejection paths raise;
  3. `grep -n "∪ null" src/scene.fab` shows only genuine-absence sites
     (`inveni` miss, optional parent), each commented;
  4. the `!` unwrap-after-null-check pattern is reduced to sites where a
     total accessor or `do/catch` cannot replace it (count them in the commit
     message if nonzero);
  5. `radix check --locale en` passes `scene.fab` and
     `exempla/triga-scene-store.fab`;
  6. scene.proba stays parse/check-green with preserved assertion content
     (MIR red is a Radix residual, not a Stage 2 target).
- **depends_on**: `tgh-s2-2` (math call sites), `tgh-s2-3` (resource genera)
- **sanity**: `radix check --locale en src/scene.fab`; the §done_when greps
- **read_scope**: `resource.fab` post-`tgh-s2-3` shape
- **non_goals**: traversal unification/collapse of the five copied bodies
  (Stage 4, gated on Radix G2/G3); world-transform propagation semantics;
  store/query split
- **risk**: medium — the MIR defect limits executed proof; structural-only
  evidence must be stated, not implied
- **integrable**: yes

### `tgh-s2-8` — primitives finite + constructor validation

- **outcome**: `plane_geometry`/`sphere_geometry` and the mesh-append helpers
  reject non-finite and non-positive structural inputs with
  `⇥ PrimitiveError`; `_primitives_radix_f32` gets the finite guard.
- **write_scope**: `triga/src/primitives/basic.fab`,
  `triga/src/primitives/basic.proba`
- **done_when**:
  1. `PrimitiveError` + `message` exist; non-positive segments/size and
     non-finite inputs raise;
  2. rejection proba cases exist per variant (parse/check-green);
  3. `radix check --locale en` passes `primitives/basic.fab`;
  4. generator output values are byte-unchanged for valid inputs (Stage 3
     owns exactness; this unit must not perturb positions/normals/UVs).
- **depends_on**: `tgh-s2-5` (geometry constructor call sites)
- **sanity**: `radix check --locale en src/primitives/basic.fab`
- **read_scope**: none restricted
- **non_goals**: exact-output proofs, winding/index pinning (Stage 3)
- **risk**: low
- **integrable**: yes

### `tgh-s2-9` — inventory drift gate + API-policy closeout

- **outcome**: the inventory records per-module error unions, variants, causa
  renderers, and rejection-path classification; `check-inventory` fails on
  undocumented drift and runs as a `structural` rung in `./scripta/check`;
  `api-shape-policy.md` §5 gains the constructor/adapter exemptions; the
  inventory is regenerated; `./scripta/check-source` exits 0 (the Stage 1
  intentional red retires).
- **write_scope**: `triga/proof/inventory/derive-inventory.sh`,
  `triga/proof/inventory/check-inventory`,
  `triga/proof/inventory/triga-inventory.json` (regenerated),
  `triga/proof/inventory/README.md` (schema note), `triga/scripta/check`
  (one rung), `triga/docs/api-shape-policy.md` (§5 only),
  `triga/src/shader_contract.proba` (helper renames)
- **done_when**:
  1. `derive-inventory.sh` derives, per module: error union names + variants,
     causa `message` renderer presence, `null_returning_functions` with a
     genuine-absence classification field, and receiver-method conformance;
  2. `check-inventory` fails when a live error union/variant/causa is absent
     from the committed inventory (drift oracle: edit a variant name in src,
     checker exits non-zero; revert);
  3. `./scripta/check` lists `check-inventory` as a `structural` rung and the
     rung passes against the regenerated inventory;
  4. regenerated inventory shows `typed_error_channel` present,
     `failable_return_arrow_occurrences > 0`, `iace_call_sites > 0` (or the
     en-surface equivalents recorded), and `co_located_tests: 26`;
  5. `./scripta/check-source` exits 0 with §5 exemptions recorded for:
     BufferGeometry constructors (`indexed_triangle_geometry`,
     `line_geometry`, `colored_indexed_geometry`), scalar→genus constructors
     (`vertex_format_from_component_width`,
     `vertex_step_mode_vertex_step`), `transform_payload`,
     `face_code_unit_quad`, and the shader-contract adapters
     (`vertex_layout_matches`, `resource_binding_matches`) — no exemption
     added that hides a genus-instance operation;
  6. `shader_contract.proba` lint rows are gone (rename or adapter
     exemption);
  7. `git diff --check` clean; no `src/**/*.fab` edits in this unit.
- **depends_on**: `tgh-s2-1` … `tgh-s2-8` (all migrations landed)
- **sanity**: `./scripta/check-source` (expected exit 0);
  `./proof/inventory/test-check-inventory`
- **read_scope**: all migrated leaves
- **non_goals**: capability-ledger changes; scorecard remeasure; public-CI
  workflow changes
- **risk**: medium — the deriver extension is real parsing work; keep the
  schema addition backward-compatible (`inventory_schema_version` bump)
- **integrable**: yes

## 5. Named, not lowered (routed elsewhere)

| Item | Owner | Why not Stage 2 |
| --- | --- | --- |
| `matrix<f32, [R, C]>` storage migration for `Matrix3`/`Matrix4`/`TransformPayload` | Stage 3 | Q3 routes it to Stages 2/3 jointly; Stage 2 takes validated construction + entry guards, Stage 3 takes storage + exactness together (removing then-redundant guards) |
| `material/base`/`lit`/`standard` assertion reds; `scene` MIR red | `tgh-s05-gate` / Radix residuals / Stages 3–5 | runner failures on the executed-proba gate, not API-shape defects |
| `tgh-s1-proba-rung` (hard-green executed-proba rung) | blocked on `tgh-s05-gate` 26/26 | unchanged Stage 1 routing; Stage 2 does not gate on it |
| Scene traversal-body unification, store/query split | Stage 4 (G2/G3 Radix decision) | language-gap-gated |
| Transform ABI 32/128 vs 64/256 resolution | Stage 7 | versioned cross-repo schema migration |
| Corpus package version alignment and `dist/` regeneration | Stage 6 | corpus consumers pin `triga = "0.1.0"` |

## 6. Integration / merge gate

Every unit compiles alone (each carries its full in-repo caller migration), so
no aggregate merge gate is required beyond the standard lane/merge flow. The
wave ordering in §4 is mandatory where units share files (material/basic.fab:
1→2; triga-scene-store.fab: 2→3; camera.fab: 2→4; scene.fab: 2→7;
primitives/basic.fab: 5→8; data.fab: 5→6; mesh.proba: 1→5). `tgh-s2-9` lands
last and turns `check-source` green — until then the Stage 1 intentional red
narrows file by file, which each unit's commit message must state.

## 7. Checkpoints and gates

**Hand sanity** is the per-unit command above. Do not put
`./scripta/check-compile`, `check-proba-coverage`, `--stage`, `--full`, or
package `faber check` on a child Hand; do not remeasure
`proof/coverage-scorecard.json`.

**Lane-owned validation** (named once, after the stage's waves land):

```bash
cd /Users/ianzepp/work/faberlang/triga
./scripta/check-source            # exit 0 after tgh-s2-9
./scripta/check-compile           # 26/26 leaves + checked exempla
./proof/inventory/test-check-inventory
./scripta/check                   # tier-labeled; executed-proba stays honest-red until tgh-s05-gate
./scripta/check-proba-coverage    # receipt writer; 22/26+ expected, no remeasure by Hands
git diff --check
```

Known-reds that remain after Stage 2 (documented, not papered over):
executed-proba gate rows on `material/base|lit|standard` (assertions
preserved), `scene` (MIR), and the WGSL PARSE family. The exempla PARSE050
row may retire inside `tgh-s2-5` (§10 Q4).

Release posture: `not-applicable` (source-library stage; no standalone
release).

## 8. Validation vs this spec

This spec is done when Mind can file nine Hand pointers (`tgh-s2-1` …
`tgh-s2-9`) with the §4 ordering and no unit requires a Hand to invent an
error-model decision, remeasure a gate, or touch a sibling repo.

It is not done by implementing any unit.

## 9. Companion skill plan

- Hands implement from this spec (`$factory` / direct on triga main),
  `tgh-s2-1` first and alone.
- An auditor, if dispatched, checks: preserved known-red assertion content,
  no `∪ null` introduced for rejection, no exemption hiding a genus-instance
  operation, frozen `_code` fields byte-unchanged, and no scorecard remeasure.
- No Head fork is required; §10 routes the two judgment defaults to Mind.

## 10. Open questions for Mind

1. **Determinant-zero inverse** (§2.1): default routes
   `inversa_affinis` to `⇥ MathError.Degenerata` rather than `∪ null`
   (absence reserved for query-shaped APIs). Confirm or override before
   `tgh-s2-2`.
2. **Non-finite construction at the executed tier**: if probas cannot
   construct NaN/inf values (division/overflow semantics unknown at MIR
   level), `finita` proof stays structural for now and the executed proof
   becomes a Stage 3 residual with a named Radix question. Hands must report,
   not fake, classification proof.
3. **Matrix storage timing** (Q3): confirm the Stage 2/3 split — validated
   `list<f32>` carriers + entry guards now, `matrix<T, [R, C]>` storage in
   Stage 3 — or amend to pull storage into `tgh-s2-2` (larger blast radius:
   every `elements` indexing site).
4. **Exempla PARSE050 fixup**: `tgh-s2-5` may apply the 4-line
   retired-import fixup in `triga-geometry-attributes.fab` to restore its
   compile oracle, retiring one known-red row. Default: allow, flagged in the
   commit message. If Mind prefers keeping the known-red list stable, the
   unit's oracle for that file drops to grep-only.
5. **Campaign bookkeeping**: on admission, CAMPAIGN.md §Stage 2 status moves
   planned → active and the Current State "Diagnostics" row cites this spec;
   on completion the status line and inventory receipts update. Mind owns
   those edits, not the Hands.
6. **Error-union naming**: `MathError`/`GeometryError`/… keep the English
   carrier noun `Error` (gradus precedent; vocabulary policy keeps standard
   technical nouns English). Confirm, or direct Latin carrier naming before
   `tgh-s2-1` lands.

## 11. Delivery readiness

READY for factory dispatch of `tgh-s2-1` … `tgh-s2-9` in §4 wave order.
READY is a planner verdict, not a GO stamp.
