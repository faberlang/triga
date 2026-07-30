# Triga module map

**Status:** living map for the public `triga:*` surface  
**Date:** 2026-07-30

Triga is a multi-file Faber source library under `src/`. Each `.fab` file is a
provider module path: `triga:<stem>` resolves to `src/<stem>.fab`.

## Public modules

| Import | File | Owns |
| --- | --- | --- |
| `triga:triga` | `src/triga.fab` | Three.js-shaped math carriers (`Vector*`, `Matrix*`, `Quaternion`, …), scene-graph genera (`Object3D`, cameras, lights), materials, mesh, face-code helpers, transform payload |
| `triga:geometry` | `src/geometry.fab` | GPU-facing buffer layout: `BufferAttribute`, `BufferGeometry`, draw batches, vertex-layout reflection, free constructors, visible-face payload facts |
| `triga:primitives` | `src/primitives.fab` | Deterministic mesh generators (`plane_geometry`, `box_geometry`, …) and wire/draw helpers that build `BufferGeometry` |
| `triga:scene` | `src/scene.fab` | Stable scene identity: handles, `SceneStore`, traversal, `visibilia`, resource lifecycle free functions |
| `triga:triga_proba` | `src/triga_proba.fab` | Proba / property-test helpers (not a product API) |

## Dependency direction

```text
primitives ──imports──► geometry
triga      ──imports──► geometry   (colored-quad mesh append only)
scene      ──imports──► triga      (Matrix4, TransformPayload)
```

No cycles. Hosts and apps import the modules they need; there is no umbrella
re-export file.

## Boundary rules

1. **`geometry`** is the render-pipeline buffer contract consumed by Radix MIR
   and the WebGPU host path. Keep attribute / draw / layout types here.
2. **`primitives`** is CPU-side mesh construction. It may call geometry
   constructors; it must not grow GPU reflection enums.
3. **`triga`** is the three.js-familiar shape contract (math + scene graph
   types + materials). Spatial `Box3` / `Sphere` live here; geometry's
   `BoundingBox` / `BoundingSphere` are mesh-payload bounds.
4. **`scene`** is backend-agnostic identity storage and draw-packet projection.
   Resource lifecycle free functions stay on this module until a second caller
   forces a split.

## Size targets (hygiene)

Prefer production modules under ~1000 lines when a natural seam exists.
After the 2026-07-30 split (approximate):

| File | Lines | Note |
| --- | --- | --- |
| `geometry.fab` | ~1300 | Buffer core still large; method body is the next seam |
| `primitives.fab` | ~470 | Shape generators only |
| `triga.fab` | ~1200 | Math + materials; next optional seam |
| `scene.fab` | ~1470 | Store + resource lifecycle free functions |

Further splits (math vs materials inside `triga`, resource lifecycle inside
`scene`) wait until import churn is intentional.

## Validation

From the Triga repo root:

```bash
./scripta/check-source
./scripta/check-compile
```

See `README.md` for the full capability / hello-voxel gate list.
