# Triga Agent Instructions

**Workspace work mode.** Ordinary development is **direct** in this
checkout on `main`. Worktree packets under `../worktrees/<lane>/` are
optional Tugboat isolation. Do not stand up lanes unless the operator
asked. Container law: [`../AGENTS.md`](../AGENTS.md).

Triga is the public Faber source library for `triga:*` imports — geometry,
scene graph, material, and GPU-facing type contracts modeled after three.js
shapes. This repo owns `.fab` source under `src/`; Radix and `faber` consume it
through `FABER_LIBRARY_HOME`, usually the parent `faberlang/` directory in local
development.

Browser WebGPU runtime product code lives in sibling `hosts/webgpu-browser`,
not here. Triga owns typed contracts and generators that feed that path.

## Module layout (Norma style)

One `.fab` file → one import path. Nested dirs for packages.

| Import | Role |
| --- | --- |
| `triga:math` | Vectors, matrices, volumes, rays, face-code tables |
| `triga:graph` | Object3D, cameras, lights |
| `triga:material` | Material family facade and material leaves |
| `triga:renderable/mesh` | Mesh composition (graph + geometry + material) |
| `triga:face` | FaceQuad builders |
| `triga:geometry` | BufferGeometry / vertex layout |
| `triga:primitives` | Mesh generators |
| `triga:scene` | SceneStore / identity |
| `triga:resource` | ResourceHandle lifecycle |
| `triga:triga` | Facade map only (no genera) |

Nested package dirs only with **≥2 modules** (prefer ≥3). A single nested file
is flattened to a top-level leaf (`triga:resource`, not `triga:scene/resource`).

Full map: [`docs/module-map.md`](docs/module-map.md). API shape:
[`docs/api-shape-policy.md`](docs/api-shape-policy.md).

## Corpus

`corpus/` holds browser-rendered demo scenes recreating three.js examples
(`webgl-geometries/`, `webgl-geometry-terrain/`), one self-contained
browser-app package per demo, with shared WebGPU host assets under
`corpus/_host/`. Details and per-demo commands: [`corpus/README.md`](corpus/README.md).
Demos should exercise the public `triga:*` surface and feed gaps back into the
library (example: `BufferAttribute.float32_values()`), not grow workarounds.

## Rules

- Keep public modules under `src/**/*.fab`.
- Keep package tests as co-located `src/**/*.proba` (`name.fab` + `name.proba`).
- Keep instructional demos under `exempla/**/*.fab`.
- Keep three.js-reference browser demos under `corpus/<slug>/`; shared host
  assets only under `corpus/_host/` (demo `public/` is generated, gitignored).
- Do not add `@ externa` or `@ subsidia`.
- Optional genus fields use `sponte`.
- Prefer leaf imports; do not grow genera on the `triga:triga` facade.
- Prefer receiver methods on genera; free functions for constructors / scalars /
  generators only.
- Nested package directories need at least two leaves (prefer three+).
- Do not move modules into Norma unless explicitly asked.
- Never `importa` a `.proba` file; shared helpers stay in `.fab` modules.

## Validation

```bash
./scripta/check-source
./scripta/check-compile
```
