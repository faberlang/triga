# Triga exempla

Instructional demos for `triga:*` modules. Each file is a small, runnable
Faber program whose imports point directly at the public leaf modules.

## Learning path

Read these in order when learning how a Faber source library grows from plain
data into a graphics contract:

1. [`triga-basics.fab`](triga-basics.fab) constructs vectors, matrices, and
   materials, then shows explicit validation and nullable construction.
2. [`triga-transforms.fab`](triga-transforms.fab) exercises native-vector
   construction, matrix helpers, quaternions, camera directions, boxes, and ray hits.
3. [`triga-geometry-attributes.fab`](triga-geometry-attributes.fab) constructs
   typed attributes and indexed/non-indexed geometry with draw ranges and
   groups, accumulates ColoredQuadMesh faces, and uses primitive generators.
4. [`triga-scene-store.fab`](triga-scene-store.fab) moves from values to
   stable handles, parent/child relationships, and visible traversal.
5. [`triga-presenter-scene-values.fab`](triga-presenter-scene-values.fab)
   mirrors the thin presenter fixture: two SceneStore meshes, AmbientLight,
   DirectionalLight, PhongMaterial, and a PerspectiveCamera (values only).
6. [`shaders/unlit.fab`](shaders/unlit.fab) writes a vertex and fragment
   stage as typed functions marked `@ Vertex` and `@ Fragment`;
   [`shaders/lambert.fab`](shaders/lambert.fab) adds diffuse lighting.
7. [`triga-hello-voxel-pipeline.fab`](triga-hello-voxel-pipeline.fab) connects
   geometry and transforms to real stages and explicit resource and pipeline
   facts.

The remaining files are focused fixtures: edge cases, type coverage, and a
three.js-shaped browser host demonstration.

## Layout

```text
exempla/
  triga-basics.fab              # Native vectors, matrices, and material basics
  triga-geometry-attributes.fab # Typed attributes, indexed/non-indexed geometry, ColoredQuadMesh accumulation, primitive generators
  hello-voxel-first-draw-facts.fab # Locked position/color indexed-draw facts
  triga-scene-store.fab         # Stable handles, graph edits, and world transforms
  triga-presenter-scene-values.fab # Presenter-shaped SceneStore + lights + Phong values
  triga-stage4-source-facts.fab # Vertex-layout facts for primitives.plane
  triga-transforms.fab          # Vector, quaternion, and matrix operations
  triga-types-untested.fab      # Instantiation of previously untested genus types
  triga-math-edge-cases.fab     # NaN/Infinity, degenerate-input, boundary tests
  triga-scene-store-empty.fab   # Empty SceneStore edge case tests
  triga-graphics-pipeline-facts.fab # Shader stages, pipeline reflection, Goal 01
  triga-hello-voxel-pipeline.fab # Cube geometry, real stages, and pipeline facts
  triga-box3-genus-spike.fab    # Box free-function overlap oracle
  triga-normal-oracle.fab       # Surface-normal winding oracle: cylinder caps + sphere poles
  shaders/                      # Vertex/fragment stage pairs; each emits WGSL
  threejs-host-demo/            # Browser fixture: Triga scene data via three.js
```

## Imports

| Module | Typical exempla use |
| --- | --- |
| `triga:triga` | Math, materials, face codes |
| `triga:geometry/data` | Geometry constructors and geometry queries |
| `triga:geometry/attribute` | Attribute construction and payload queries |
| `triga:geometry/layout` | Vertex format and step-mode facts |
| `triga:geometry/batch` | Draw ranges, groups, and batch facts |
| `triga:primitives/basic` | Mesh generators (`plane`, `box_wire`, …) |
| `triga:scene` | SceneStore / handles |
| `triga:shader` | `@ Vertex`, `@ Fragment`, `@ Position` stage contracts |

Prefer the leaf that owns the type. The `triga:triga`, `triga:geometry`,
`triga:graph`, `triga:material`, and `triga:primitives` modules are maps for
humans; they intentionally do not re-export genera. This keeps an example's
dependency list honest and makes each source file a useful place to learn.

## How to read an example

Most examples use the same three-step rhythm:

```text
import the leaf → construct a typed value → inspect or validate a fact
```

`null` results are part of the API rather than hidden exceptions. Constructors
and queries return them when input cannot satisfy the contract; the examples
keep the result visible so failure behavior is easy to study.

## Checking

`./scripta/check` runs `faber check` on every exemplum, verifies the
`+++ text stdout` sections with `faber corpus`, and emits WGSL for the
exempla that declare stages.
