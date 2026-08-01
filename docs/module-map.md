# Triga module map

**Status:** living map for the public `triga:*` surface  
**Date:** 2026-07-30

Triga is a multi-file Faber source library under `src/`. Each `.fab` file is a
provider module path: `triga:<stem>` resolves to `src/<stem>.fab`.

## Pattern (from Norma)

| Pattern | Norma example | Triga example |
| --- | --- | --- |
| Flat leaf | `norma:csv`, `norma:chorda` | `triga:math`, `triga:resource` |
| Cross-module import | `csv` imports `chorda` | `primitives` imports `geometry` |
| Nested package | `norma:caelum/terminus` | *(none yet — see nesting rule)* |
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
| `triga:graph` | `src/graph.fab` | `Object3D`, `Scene`, cameras, lights |
| `triga:material` | `src/material.fab` | `Material` family, `Mesh`, `MeshGeometry`, material free helpers |
| `triga:face` | `src/face.fab` | `FaceQuad` + unit/colored quad builders (depends on math + geometry) |
| `triga:geometry` | `src/geometry.fab` | `BufferGeometry`, attributes, draw batches, vertex-layout reflection |
| `triga:primitives` | `src/primitives.fab` | Deterministic mesh generators (`plane_geometry`, `box_geometry`, …) |
| `triga:scene` | `src/scene.fab` | `SceneStore`, `SceneHandle`, nodes, traversal, `visibilia` |
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
graph        ──► math
material     ──► math, graph
face         ──► math, geometry
geometry                (leaf)
primitives   ──► geometry
resource                (leaf)
scene        ──► math, resource
triga (facade) ──► math, graph, material, face   (docs only)
```

No cycles.

## Import examples

```fab
importa ex "triga:math" privata math
importa ex "triga:graph" privata graph
importa ex "triga:material" privata material
importa ex "triga:geometry" privata geometry
importa ex "triga:primitives" privata primitives
importa ex "triga:scene" privata scene
importa ex "triga:resource" privata resource
```

```fab
fixum math.Vector3 p ← math.vector3(1.0, 2.0, 3.0)
fixum resource.ResourceHandle h ← resource.ResourceHandle { index = 0, generation = 1 }
varia scene.SceneStore store ← scene.scene_store()
```

## Size (approx after split)

| File | Lines |
| --- | --- |
| `math.fab` | ~850 |
| `geometry.fab` | ~1320 |
| `scene.fab` | ~930 |
| `resource.fab` | ~550 |
| `primitives.fab` | ~470 |
| `material.fab` | ~180 |
| `graph.fab` | ~120 |
| `face.fab` | ~40 |

`geometry.fab` is still large (BufferGeometry methods). Next seam only if a second
importer wants a pure layout-facts module. If `scene` is later split into a
nested package, put **store + resource + visibilia** (or similar) under
`src/scene/` together — not a lone file.

## Target map (frozen at S0, 2026-08-01)

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
until `render/batch` exists at H4; `cista.toml` is future, not current.

## Validation

```bash
./scripta/check-source
./scripta/check-compile
# package tests (requires faber + green generated Rust for lib packages):
# faber test .
```
