# Triga module map

**Status:** living map for the public `triga:*` surface  
**Date:** 2026-07-30

Triga is a multi-file Faber source library under `src/`. Each `.fab` file is a
provider module path: `triga:<stem>` resolves to `src/<stem>.fab`. Nested paths
use directories, Norma-style: `triga:scene/resource` → `src/scene/resource.fab`.

## Pattern (from Norma)

| Pattern | Norma example | Triga example |
| --- | --- | --- |
| Flat leaf | `norma:csv`, `norma:chorda` | `triga:math`, `triga:geometry` |
| Cross-module import | `csv` imports `chorda` | `primitives` imports `geometry` |
| Nested package | `norma:caelum/terminus` | `triga:scene/resource` |
| Facade | `norma:caelum` composes submodules | `triga:triga` documents leaves (no genera) |

There is **no type re-export**. Consumers import the leaf that owns the genus.

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
| `triga:scene/resource` | `src/scene/resource.fab` | `ResourceHandle` + lifecycle free functions |
| `triga:triga` | `src/triga.fab` | Facade / map only (no genera) |
| `triga:triga_proba` | `src/triga_proba.fab` | Proba helpers |

## Dependency direction

```text
math                    (leaf)
graph        ──► math
material     ──► math, graph
face         ──► math, geometry
geometry                (leaf)
primitives   ──► geometry
scene/resource          (leaf)
scene        ──► math, scene/resource
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
importa ex "triga:scene/resource" privata resource
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
| `scene/resource.fab` | ~550 |
| `primitives.fab` | ~470 |
| `material.fab` | ~180 |
| `graph.fab` | ~120 |
| `face.fab` | ~40 |

`geometry.fab` is still large (BufferGeometry methods). Next seam only if a second
importer wants a pure layout-facts module.

## Validation

```bash
./scripta/check-source
./scripta/check-compile
```
