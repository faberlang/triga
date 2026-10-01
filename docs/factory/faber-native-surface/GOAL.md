# GOAL: Faber-native Triga surface

**Status**: active — Units 0–10 implemented 2026-09-30 on main; residual: `math.proba` MIR blocked on generic-width vector methods (`invalid MIR: vector aggregate type is not vector`); analysis (`faber check`) is the Unit 3 typecheck gate
**Created**: 2026-09-30
**Campaign:** —
**Source:** operator request 2026-09-30 after architectural review: Triga reads as a three.js clone rather than a first-class Faber library; scoping then a goal
**Repos:** `triga` (primary); `radix` if the generic-math compiler gate is still red; `examples` and `hosts` for consumer migration
**Related:** [`../generic-math-types/`](../generic-math-types/) (Stage 0 representation record; Stages 1–5 product application absorbed here — do not dispatch a second Hand on `src/math.fab` from that campaign); [`../api-shape-vocabulary/GOAL.md`](../api-shape-vocabulary/GOAL.md) (receivers landed; three.js-mirror naming already overturned in intent); [`../../api-shape-policy.md`](../../api-shape-policy.md) (stale: still keeps `Vector3`); [`../../continuation-assessment.md`](../../continuation-assessment.md)

---

## Invariant

Triga's public `triga:*` surface is a Faber library. Dimension lives in types (`vector<f32, N>`, `matrix<f32, [R, C]>`, `Box<N>`), not in identifiers. Vendor product names from three.js do not appear as public types or constructors. Domain nouns that are industry-standard stay. No compatibility alias of a retired name survives.

## Problem

The live library at triga `fb31914` (2026-09-30, `main`, clean, two commits ahead of `origin`) is a typed scene/geometry contract written in Faber syntax and still architected as a three.js mirror. That is observable in source, not inferred from campaign prose.

### What is already Faber-native

Leaf imports, composition through a `base` field, `∪ none` at invalid construction, SoA `list<f32>` attributes, `SceneStore` / `ResourceHandle`, and `triga:shader_contract` fact adapters. Package locale is `en` (`faber.toml`). Receivers landed on the genera that still exist.

### What is still a clone

**1. Numbered math carriers.** Live `src/math.fab` still declares `Vector2`, `Vector3`, `Vector4`, `Matrix3`, `Matrix4`, `Box3`. `Vector2` and `Matrix3` are field bags (Matrix3 comment: "no operations in this module yet"). `Vector3` has English receivers (`add`, `dot`, `cross`, …). `Matrix4` is a 16-lane `list<f32>` whose shape is checked by `valid()`. Faber already owns `vector<f32, N>` and `matrix<f32, [R, C]>`. Gradus uses size-generic `tensor<f32, [M, N]>` and does not ship `Vector3`.

Oracle hits on 2026-09-30 (`Vector2|Vector3|Vector4|Matrix3|Matrix4|Box3|vector3\(|vector2\(|matrix4_|box3_`):

| Surface | Hits (order of magnitude) |
| --- | --- |
| `src/math.fab` | 142 |
| `src/math.proba` | 87 |
| other `src/**` (camera, object, scene, face, lighting, bounds, data) | ~40 |
| `exempla/` (transforms, normal-oracle, box3 spike, …) | ~80 |
| `corpus/` animation + camera_controls | ~60 |
| `locale/la/pack.toml` | 49 (maps English canonicals on `Vector3` / `Matrix4` / …) |

**2. three.js product taxonomy.** Live public types still include `Object3D`, `BufferGeometry`, `BufferAttribute`, `MeshBasicMaterial`, `MeshPhongMaterial`, `MeshStandardMaterial`. `src/material/base.fab` still says "deliberately a small value contract (THREE.Material)". `src/renderable/mesh.fab` still says "mirrors THREE.Mesh". Primitive constructors are the three.js helper spellings: `plane_geometry`, `box_geometry`, `sphere_geometry`, `circle_geometry`, `cylinder_geometry`, `cone_geometry`, `torus_geometry`, `box_wire_geometry`.

**3. Three naming laws at once.** `docs/api-shape-policy.md` §1b keeps `Vector2/3/4` and Latinizes stems (`productum`, `transversum`). Live `src/` is English-first (`93d03e7`, 2026-08-27). `exempla/conformance/generic-math-types/selected/operations.fab` uses Latin free functions over native `vector<f32, N>`. `locale/la/pack.toml` (109 `library_members` rows) is the Latin *reader* projection of the English canonicals — that pack is correct locale machinery, not a third public API.

**4. Generic-math already decided the math destination and did not apply it.** [`../generic-math-types/representation-decision.md`](../generic-math-types/representation-decision.md) selected direct native types (2026-08-25). [`../generic-math-types/migration-map.md`](../generic-math-types/migration-map.md) is frozen: retire numbered genera, no aliases. [`../generic-math-types/delivery-stage1.md`](../generic-math-types/delivery-stage1.md) is still `planned` (2026-09-16) and recorded a radix `SEM010` regression on the Stage-0 fixture plus an English-vs-Latin spelling fork (OQ-1). Filling `Vector2` / `Matrix3` on the current names would cement the clone.

**5. Consumers are already on the old surface, and some are already broken.**

| Consumer | Live import / name posture (2026-09-30) |
| --- | --- |
| `triga/exempla/*.fab` | English `import from "triga:…"`; several still call Latin constructors (`matrix4_translatio` in `triga-transforms.fab`) |
| `triga/corpus/` | leaf imports of `triga:math` / geometry / primitives / camera |
| `hosts/webgpu-browser/fixtures/graphics.fab` | `triga:geometry/data`, `triga:primitives/basic` |
| `examples/hello-voxel`, `examples/triga-drift-city`, `examples/triga-budapest` | Latin `importa ex`; facade imports (`triga:geometry`, `triga:primitives`, `triga:graph`) that hold no genera after S1 |

`tela/` and `gradus/` have no `triga:` imports.

### What this goal is not solving

The library still does not render. That is a host/radix job (`triga-engine` S2). This goal is the public *language* of the contract, not a renderer, not three.js-80, and not a 2D scene-graph twin.

## Proposal

One clean-break identity repair in three layers, applied in order. Representation of math carriers is **not** re-adjudicated: direct native types per the generic-math selection. Vendor-noun destinations are law (OQ-1 settled 2026-09-30: defaults as written, types only, import paths unchanged).

### Layer A — Math carriers (apply the frozen map)

| Live | Action | Destination |
| --- | --- | --- |
| `class Vector2/3/4` | retire | `vector<f32, 2\|3\|4>`; construct `[x, y, z] ↦ vector<f32, 3>` |
| `class Matrix3/4` | retire | `matrix<f32, [3, 3]>` / `matrix<f32, [4, 4]>` |
| `class Box3` | reshape | `class Box<size N>` over `vector<f32, N>` min/max |
| `Box3OverlapFacts`, `RayBox3Hit` | rename | `BoxOverlapFacts`, `RayBoxHit` (no `3` token) |
| `vector3(…)`, `matrix4_*`, `box3_from_*` | retire numbered helpers | language construction; `matrix_identity` / `matrix_translation` / `matrix_perspective` / `matrix_look_at` / `box_from_*` (English, no dimension token) |
| `Vector3` receivers | move off the retired genus | glyphs and compiler intrinsics where they exist (`·`, `×`, `.dot`, `.cross`, `.added`); Triga free functions for the rest (`length`, `normalized`, `lerp`, `apply_point`, `affine_inverse`, …) — English stems, `en` locale |
| `Matrix4.valid()` | retire | type invariant of `matrix<f32, [4, 4]>` |
| `TransformPayload` | keep genus + 32-float / 128-byte wire | constructor inputs become `matrix<f32, [4, 4]>` |
| `Quaternion`, `Euler`, `Color`, `Sphere`, `Plane`, `Ray`, `RayInterval`, `FaceCodeFacts`, `CameraYawPitchFacts` | keep | retype fields/signatures off retired carriers |

Do not implement `Vector2` / `Matrix3` arithmetic on the retired names. 2D support is the same generic surface at `N = 2` / `[3, 3]`.

This goal absorbs generic-math Stages 1–5 product application (OQ-2, operator 2026-09-30). Stage 0 (`representation-decision.md`, `migration-map.md`) stays the selection record. `delivery-stage1.md` is the Unit 2–3 worksheet, not a second dispatch surface. Do not run a Hand on `src/math.fab` from that campaign. A live re-probe of the 2026-09-16 radix `SEM010` gate is the first Layer A action; if still red, radix units stay in front of `src/math.fab`.

### Layer B — Vendor nouns (three.js product names)

Industry-standard domain nouns stay. three.js *product* names go. Spellings below are law (OQ-1, operator 2026-09-30). Import paths stay (`triga:material/basic`, `triga:geometry/data`, `triga:primitives/basic`).

| Live | Disposition | Destination |
| --- | --- | --- |
| `Object3D` | rename | `Object` (module is already `triga:graph/object`; drop the `3D` token) |
| `Scene` (graph value) | keep | `Scene` |
| `BufferGeometry` | rename | `Geometry` |
| `BufferAttribute` | rename | `Attribute` |
| `MeshBasicMaterial` | rename | `UnlitMaterial` |
| `MeshPhongMaterial` | rename | `PhongMaterial` (keep the lighting-model word; drop `Mesh`) |
| `MeshStandardMaterial` | rename | `StandardMaterial` (drop `Mesh`; do not rename to `PbrMaterial` while nothing evaluates lighting) |
| `Mesh`, `Material`, `Light`, `AmbientLight`, `DirectionalLight`, `PointLight` | keep | industry domain |
| `PerspectiveCamera`, `OrthographicCamera` | keep | industry domain |
| `plane_geometry` … `box_wire_geometry` | rename | `plane`, `circle`, `sphere`, `cylinder`, `cone`, `torus`, `box`, `box_wire` — constructors returning `Geometry`. Distinct from math `Plane` / `Box<N>` by case and arity. |
| `TextureDescriptor` | keep | comment cleanup only (still a seed) |
| `VertexFormat` (`Float32x3`, …) | keep this goal | already recorded as temporary host vocabulary until radix bounded-buffers; integer `*_code` fields stay frozen ABI |
| `ColoredQuadMesh`, `FaceQuad`, `BoundingBox`, `BoundingSphere`, draw-batch / scene-store / resource genera | keep | Triga-native or industry |

`Material.side` numeric codes (`0/1/2`) and every `*_code` field consumed by `radix-mir` shader_contract stay frozen. Renaming those is a paired radix change and is out of this goal.

### Layer C — Policy, locale, consumers, living docs

- Rewrite `docs/api-shape-policy.md` so §1b matches Layer A (native vectors/matrices; `Box<N>` is the only remaining Triga math nominal in that family). Strike Latin-stem-as-canonical-for-`en`. Keep the Latin *pack* as the `la` reader surface.
- Regenerate `locale/la/pack.toml` against the new English canonicals after Layers A and B land in `src/`.
- Update `scripta/check-source` exemptions to the surviving free-function names.
- Migrate `exempla/` and `corpus/` onto leaves + new names in the same goal (otherwise the library has no honest compile oracle).
- Migrate `examples/hello-voxel`, `examples/triga-drift-city`, `examples/triga-budapest`, and `hosts/webgpu-browser/fixtures/graphics.fab` last. Those apps also still import hollow facades and (hello-voxel / drift-city / budapest) use the `la` surface — that migration is name + import + locale, not a rewrite of their game logic.
- Living docs: `README.md`, `docs/module-map.md`, `AGENTS.md` module table. Historical factory docs (`triga-threejs-80`, engine checkpoint inventories) stay as history; do not rewrite them to pretend the old names never existed.

### Non-goals

- No `triga:engine` / `triga:render` / `triga:world` / `triga:asset` / `triga:animation` leaves.
- No lighting evaluation, textures, shadows, glTF, instancing, or picking.
- No `Object2D` / parallel 2D graph. 2D is `vector<f32, 2>` and `matrix<f32, [3, 3]>` plus orthographic projection when a caller needs it.
- No generic-math representation re-vote. No numbered compatibility aliases.
- No `VertexFormat` generic conversion (radix bounded-buffers).
- No tela/canvas2d merge. Canvas2D stays tela.
- No Metal / second backend.
- No weakening `check-source` to go green.
- Does not close `triga-engine` S2 (admitted host draw) and does not resume three.js-80/90.

## Units (lowering sketch — refine via `$delivery`)

| Unit | Scope | Depends on | Hand evidence |
| --- | --- | --- | --- |
| 0 | Close the policy fork in living docs: `docs/api-shape-policy.md` §1b, identity paragraphs in `README.md` / `AGENTS.md`. Record Layer B spellings as law. | — | none |
| 1 | Live re-probe of generic-math Stage-0/1 compiler gate (`faber check` on `exempla/conformance/generic-math-types/selected/operations.fab` against current radix). Receipt: still-red identities or green. | — | none |
| 2 | Radix residuals named by Unit 1 / `delivery-stage1.md` S1-R\* (only if Unit 1 is red). Write scope is radix, not triga src. | 1 | none |
| 3 | `src/math.fab` + `src/math.proba` + generic-math selected fixtures: apply Layer A. No remaining `Vector2/3/4`, `Matrix3/4`, `Box3`, `vector3(`, `matrix4_`, `box3_` in those files. | 1 (and 2 if red) | none |
| 4 | Retype remaining `src/**` off retired math carriers (graph, camera, scene, face, lighting, geometry/bounds, renderable, primitives). No vendor-noun rename yet. | 3 | none |
| 5 | Layer B type renames: `Object3D` → `Object`, `BufferGeometry` → `Geometry`, `BufferAttribute` → `Attribute`, `MeshBasicMaterial` → `UnlitMaterial`, `MeshPhongMaterial` → `PhongMaterial`, `MeshStandardMaterial` → `StandardMaterial`. Update same-module proba and facades. Paths unchanged. | 4 | none |
| 6 | Layer B constructor renames: `*_geometry` primitive family. | 5 | none |
| 7 | `locale/la/pack.toml` + `scripta/check-source` exemptions against the new English canonicals. | 5, 6 | none |
| 8 | `exempla/` (except historical comments) + `corpus/**/*.fab` compile on the new surface. | 7 | none |
| 9 | `examples/hello-voxel`, `triga-drift-city`, `triga-budapest`: leaf imports + new names (and current `en`/`la` locale of each package). `hosts/webgpu-browser/fixtures/graphics.fab`. | 8 | none |
| 10 | Living docs left after Unit 0: `docs/module-map.md`, exempla README, any remaining identity claims in `src/*.fab` headers (`THREE.*` comments). | 5, 6 | none |

Units 5 and 6 may merge if the rename set stays as small as the default table. Do not merge Layer A with Layer B: math must typecheck before the scene nouns move, or every file is edited twice.

## Validation

Goal-closeout (all must hold on the trees this goal writes):

```bash
# from triga/
rg -nE 'class Vector[234]|class Matrix[34]|class Box3|class Object3D|class BufferGeometry|class BufferAttribute|class Mesh(Basic|Phong|Standard)Material' src
# expect: no matches

rg -nE '\bvector3\(|\bmatrix4_|\bbox3_|\bplane_geometry\(|\bbox_geometry\(' src exempla corpus
# expect: no matches in live source (comments in archived factory docs are allowed)

./scripta/check-source
./scripta/check-compile
# plus the math-transform oracle once Unit 8 has migrated exempla/triga-transforms.fab
```

- `src/**/*.proba` still sit beside every live leaf and pass `faber test` for the package (or the current `./scripta/check` proba rung).
- `hosts/webgpu-browser/fixtures/graphics.fab` checks against the new geometry/primitives names.
- Frozen ABI: no rename of `format_code`, `step_mode_code`, `offset_bytes`, `stride_bytes`, `source_name`, `side_code`, or other `*_code` fields; `TransformPayload` remains 32 f32 / 128 bytes, model then view-projection, column-major.
- Historical `docs/factory/triga-threejs-*` and engine checkpoint files may still mention old names as history.

## Delivery checklist

| Check | Enforced by |
| --- | --- |
| No numbered math genera or helpers in `src/` / `exempla/` / `corpus/` | closeout `rg` above |
| No three.js product type names from the Layer B retire/rename set in `src/` | closeout `rg` above |
| Policy §1b matches live `src/math.fab` | review of Unit 0 + Unit 3 |
| `la` pack rows track English canonicals | Unit 7 + `faber convert` / locale tests as used by the current check spine |
| TransformPayload wire bytes unchanged | existing payload proba / generic-math `selected/payload.fab` |
| No new empty leaves | review |
| No `*_code` / shader-contract field renames | review + radix ingest unchanged |

## Ledger

| Unit | Status | Hand | Receipt | Notes |
| --- | --- | --- | --- | --- |
| 0 | done | — | policy + README + AGENTS | Layer B names recorded as law |
| 1 | done | — | operations.fab re-probe | chained `.added` can SEM004; not a reason to drop generics |
| 2 | dropped | — | Unit 1 not a radix typecheck gate | skip |
| 3 | done | — | math.fab analysis-green | generics kept; `faber test` math.proba MIR residual named |
| 4 | done | — | object/camera/scene/face/light/data | native carriers |
| 5 | done | — | src Layer B type names | Object, Geometry, Attribute, Unlit/Phong/StandardMaterial |
| 6 | done | — | primitives short ctors | plane/circle/sphere/cylinder/cone/torus/box/box_wire |
| 7 | done | — | pack.toml + check-source | EXEMPT for surviving box_*/camera_* free fns |
| 8 | done | — | exempla + corpus | English names; transform oracle on native carriers |
| 9 | done | — | hello-voxel, drift-city, budapest, hosts fixture | leaf imports + native types |
| 10 | done | — | module-map, exempla README, src headers | no live THREE.* identity claims in src/ |

## Settled questions (operator 2026-09-30)

No open questions remain. Defaults on 3–6 are law.

1. **Layer B destination spellings.** Default column as written; types only; import paths unchanged. Law for Units 0, 5, and 6. No compatibility alias.

   | Live type / ctor | Settled destination |
   | --- | --- |
   | `Object3D` | `Object` |
   | `BufferGeometry` | `Geometry` |
   | `BufferAttribute` | `Attribute` |
   | `MeshBasicMaterial` | `UnlitMaterial` |
   | `MeshPhongMaterial` | `PhongMaterial` |
   | `MeshStandardMaterial` | `StandardMaterial` |
   | `plane_geometry` … `box_wire_geometry` | `plane`, `circle`, `sphere`, `cylinder`, `cone`, `torus`, `box`, `box_wire` |
   | `Mesh`, `Material`, lights, cameras, `Scene` | keep |
   | import paths (`triga:material/basic`, …) | unchanged this goal |

2. **Absorb generic-math Stages 1–5.** This goal owns the product application. The generic-math campaign stays the Stage 0 representation/research record. `delivery-stage1.md` is the Unit 2–3 worksheet. Do not dispatch a second Hand on `src/math.fab` from that campaign.

3. **Math operation shape.** Language glyphs/intrinsics for ops the compiler owns (`·`, `×`, `.dot`, `.cross`, `.added`). English free functions on `triga:math` for graphics-domain work (perspective, look-at, affine inverse, ray–box, face codes, payload). Do not Latinize the `en` surface.

4. **Orthographic / 2D helpers.** Out of this goal unless Unit 8/9 hits a missing `matrix_orthographic` / `Box<2>` constructor. Then add that helper in the same unit (second-caller), still on the generic types.

5. **Examples.** Unit 9 in this goal, not a follow-up. Serialize behind foreign dirt if an examples package is mid-rewrite.

6. **`VertexFormat` (`Float32x3`, …).** Remain temporary; not this goal. Already recorded in `src/geometry/layout.fab` and policy §3.

## Open questions

None.
