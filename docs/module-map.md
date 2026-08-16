# Triga module map

**Status:** living map for the public `triga:*` surface  
**Date:** 2026-08-02 (S1 splits landed: graph, lighting, geometry, material,
primitives, and renderable; scene remains parked)

Triga is a multi-file Faber source library under `src/`. Each `.fab` file is a
provider module path: `triga:<stem>` resolves to `src/<stem>.fab`.

## Pattern (from Norma)

| Pattern | Norma example | Triga example |
| --- | --- | --- |
| Flat leaf | `norma:csv`, `norma:chorda` | `triga:math`, `triga:resource` |
| Cross-module import | `csv` imports `chorda` | `primitives` imports `geometry` |
| Nested package | `norma:caelum/terminus` | `triga:graph/object`, `triga:geometry/data` |
| Facade | `norma:caelum` composes submodules | `triga:triga` documents leaves (no genera) |

There is **no type re-export**. Consumers import the leaf that owns the genus.

### Nesting rule

Nested dirs (`src/<pkg>/<leaf>.fab` → `triga:<pkg>/<leaf>`) only when the
directory has **at least two** modules, preferably **three or more**. A single
nested file is flattened to a top-level leaf instead (e.g. `triga:resource`,
not `triga:scene/resource`).

## Public modules

| Import | File | Owns |
| --- | --- | --- |
| `triga:math` | `src/math.fab` | `Vector*`, `Matrix*`, `Quaternion`, `Euler`, `Color`, `Box3`, `Sphere`, `Plane`, `Ray`, transform payload, face-code tables, free math constructors |
| `triga:graph` | `src/graph.fab` | Facade / map only (no genera) |
| `triga:graph/object` | `src/graph/object.fab` | `Object3D`, `Scene` |
| `triga:graph/camera` | `src/graph/camera.fab` | `PerspectiveCamera`, `OrthographicCamera`, `PerspectiveCameraProjectionFacts`, `ViewProjectionFacts` |
| `triga:lighting` | `src/lighting.fab` | Facade / map only (planned leaves: model H3, shadow H4, environment H5) |
| `triga:lighting/light` | `src/lighting/light.fab` | `Light`, `AmbientLight`, `DirectionalLight`, `PointLight` |
| `triga:material` | `src/material.fab` | Facade for the material leaves; `Material` and material families live under `material/{base,basic,lit,standard}` |
| `triga:face` | `src/face.fab` | `FaceQuad` + unit/colored quad builders (depends on math + geometry/data) |
| `triga:geometry` | `src/geometry.fab` | Facade / map only (no genera) |
| `triga:geometry/data` | `src/geometry/data.fab` | `BufferGeometry` (+ methods incl. `index_format_code`), `PrimitiveTopology`, `ColoredQuadMesh`, free constructors |
| `triga:geometry/attribute` | `src/geometry/attribute.fab` | `BufferAttribute`, `AttributeData`, `AttributeUsage`, `float32_attribute` |
| `triga:geometry/layout` | `src/geometry/layout.fab` | `VertexAttributeLayout`, `VertexFormat`, `VertexStepMode`, layout code helpers |
| `triga:geometry/bounds` | `src/geometry/bounds.fab` | `BoundingBox`, `BoundingSphere` (math `Box3`/`Sphere` stay in math) |
| `triga:geometry/batch` | `src/geometry/batch.fab` | `DrawRange`, `GeometryDrawCommand`, `GeometryGroup`, draw-batch facts |
| `triga:primitives` | `src/primitives.fab` | Facade for deterministic generators in `primitives/basic`; procedural/terrain/voxel remain deferred |
| `triga:scene` | `src/scene.fab` | `SceneStore`, `SceneHandle`, nodes, traversal, `visibilia` — **DS-D parked** on language gaps G2/G3 |
| `triga:resource` | `src/resource.fab` | `ResourceHandle` + lifecycle free functions |
| `triga:triga` | `src/triga.fab` | Facade / map only (no genera) |

## Proba (test sources)

Co-located `name.proba` next to `name.fab`. Discovered only by `faber test`
(`include_proba`); never imported as a product module.

| File | Covers |
| --- | --- |
| `src/math.proba` | Vector3 method suite (`addita`, `normata`) |

## Dependency direction

```text
math                    (leaf)
graph/object ──► math
graph/camera ──► math, graph/object
graph (facade) ──► object, camera
lighting/light ──► math, graph/object
material     ──► math (Mesh → renderable/mesh; graph dep deleted)
face         ──► math, geometry/data
geometry/attribute ──► geometry/layout
geometry/data ──► attribute, layout, bounds, batch
geometry (facade) ──► data, attribute, layout, bounds, batch
primitives   ──► geometry/data, attribute, batch
resource                (leaf)
scene        ──► math, resource
triga (facade) ──► math, graph/object, graph/camera, material, face   (docs only)
```

No cycles (scene's planned nested split is parked on language gaps G2/G3 —
see the [engine checkpoint](factory/triga-engine/checkpoint/report.md) §8).

## Import examples

```fab
importa ex "triga:math" privata math
importa ex "triga:graph/object" privata object
importa ex "triga:graph/camera" privata camera
importa ex "triga:material" privata material
importa ex "triga:geometry/data" privata data
importa ex "triga:primitives/basic" privata basic
importa ex "triga:scene" privata scene
importa ex "triga:resource" privata resource
```

```fab
fixum math.Vector3 p ← math.vector3(1.0, 2.0, 3.0)
fixum resource.ResourceHandle h ← resource.ResourceHandle { index = 0, generation = 1 }
varia scene.SceneStore store ← scene.scene_store()
```

## Size (after S1 splits)

> **Archive notice (2026-08-16):** live coverage data superseded by `proof/coverage-scorecard.json` (2026-08-16); this section is archival

| File | Lines |
| --- | --- |
| `math.fab` | ~850 |
| `geometry/data.fab` | ~500 |
| `geometry/attribute.fab` | ~180 |
| `geometry/layout.fab` | ~220 |
| `geometry/bounds.fab` | ~60 |
| `geometry/batch.fab` | ~300 |
| `scene.fab` | ~930 (split parked) |
| `resource.fab` | ~550 |
| `primitives.fab` | ~16 (facade) + `primitives/basic.fab` |
| `material.fab` | ~21 (facade) + `material/{base,basic,lit,standard}.fab` |
| `graph.fab` | ~25 (facade) + object ~20 / camera ~110 |
| `lighting/light.fab` | ~28 |
| `face.fab` | ~40 |

`scene.fab` remains a monolith until the language gains cross-module enum
variants (G2) and cycle tolerance (G3). If it is later split, put **store +
resource + visibilia** (or similar) under `src/scene/` together — not a lone
file.

## Target map (frozen at S0, 2026-08-01)

> **Archive notice (2026-08-16):** live coverage data superseded by `proof/coverage-scorecard.json` (2026-08-16); this section is archival

The engine campaign's S0 architecture checkpoint
([report](factory/triga-engine/checkpoint/report.md)) freezes the target ownership
map. This living map documents what exists; the target map records what S1+ will
build. Three states:

**Freeze as-is** (no split): `math`, `resource`, `face`, `triga` (facade, map-only).

**Split now (S1 / Horizon 1)** — leaves with live content, each split documented
below as it lands:

| Family | Leaves | Notes |
| --- | --- | --- |
| `scene` | `node`, `store`, `query` | pure relocation, unchanged interface names; nested-package tooling check (DEFER-121) is a precondition |
| `geometry` | `data`, `attribute`, `layout`, `bounds`, `batch` | preserves frozen ABI `_code` names verbatim; fixes the pre-existing `geometry_vertex_layout_matches` naming-lint failure |
| `material` | `base`, `basic`, `lit`, `standard` | `Mesh` → `renderable/mesh`; `MeshGeometry` retired into `BufferGeometry` |
| `renderable` | `mesh` | `Mesh` = graph + geometry + material |
| `lighting` | `light` | light families move from `graph.fab`; `graph/light` dropped |
| `primitives` | `basic` | `procedural`/`terrain`/`voxel` deferred |
| `graph` | `object`, `camera` | corpus demos migrate to leaf imports in the same change |

**Planned** (record as future home; do NOT create empty leaves): `engine/*` (H2),
`shader/*` (H3, program at H7), `render/*` (H4), `material/{texture,sampler}` (H3),
`lighting/{model,environment,shadow}` (H3/H5/H4), `renderable/{skin,morph,instance}`
(H5/H6), `primitives/{procedural,terrain,voxel}` (H2/H5), `asset/*`, `animation/*`,
`world/*` (H5, `query` at H6).

Inventory corrections frozen at S0: leaf count is 61 non-facade leaves / 75 import
paths (not "~50"); `Box3`/`Sphere` stay in `math` while `geometry/bounds` owns
`BoundingBox`/`BoundingSphere`; geometry draw-batch facts live in `geometry/batch`
until `render/batch` exists at H4; `cista.toml` is the current source-package
manifest and is independent of the `faber.toml` provider metadata.

## Validation

```bash
./scripta/check-source
./scripta/check-compile
# package tests (requires faber + green generated Rust for lib packages):
# faber test .
```
