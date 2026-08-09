# Triga exempla

Instructional demos for `triga:*` modules. Each file is a small, runnable
Faber program whose imports point directly at the public leaf modules.

These programs belong with the Triga source library, not the keyword language
dictionary under sibling `examples/corpus/`.

## Learning path

Read these in order when learning how a Faber source library grows from plain
data into a graphics contract:

1. [`triga-basics.fab`](triga-basics.fab) constructs vectors, matrices, and
   materials, then shows explicit validation and nullable construction.
2. [`triga-transforms.fab`](triga-transforms.fab) exercises receiver methods
   for transforms, quaternions, camera directions, bounds, and ray hits.
3. [`triga-geometry-attributes.fab`](triga-geometry-attributes.fab) constructs
   typed attributes and indexed/non-indexed geometry with draw ranges and
   groups, accumulates ColoredQuadMesh faces, and uses primitive generators.
4. [`triga-scene-store.fab`](triga-scene-store.fab) moves from values to
   stable handles, parent/child relationships, and visible traversal.
5. [`triga-hello-voxel-pipeline.fab`](triga-hello-voxel-pipeline.fab) connects
   geometry and transforms to explicit vertex, fragment, resource, and
   pipeline facts.

The remaining files are focused fixtures: edge cases, type coverage, shader
contract conformance, and a three.js-shaped browser host demonstration.

## Layout

```text
exempla/
  triga-basics.fab              # Vector3, Matrix4, and material basics
  triga-geometry-attributes.fab # Typed attributes, indexed/non-indexed geometry, ColoredQuadMesh accumulation, primitive generators
  hello-voxel-first-draw-facts.fab # Locked position/color indexed-draw facts
  triga-scene-store.fab         # Stable handles, graph edits, and world transforms
  triga-stage4-source-facts.fab # Stage 4 vertex-layout handoff (primitives.plane)
  triga-transforms.fab          # Vector, quaternion, and matrix operations
  triga-types-untested.fab      # Instantiation of previously untested genus types
  triga-math-edge-cases.fab     # NaN/Infinity, degenerate-input, boundary tests
  triga-scene-store-empty.fab   # Empty SceneStore edge case tests
  triga-graphics-pipeline-facts.fab # Shader stages, pipeline reflection, Goal 01
  triga-vertex-fragment-stub.fab # @vertex / @fragment annotation stubs
  triga-hello-voxel-shaders.fab  # @vertex + @fragment with layout + fragment facts
  triga-hello-voxel-pipeline.fab # Full Goal 01 pipeline facts
  triga-box3-genus-spike.fab    # Box3 genus / method surface spike
  triga-normal-oracle.fab       # Surface-normal winding oracle: cylinder caps + sphere poles
  threejs-host-demo/            # Browser fixture: Triga scene data via three.js
```

Language keyword exempla: sibling `examples/corpus/`.

## Imports

| Module | Typical exempla use |
| --- | --- |
| `triga:triga` | Math, materials, face codes |
| `triga:geometry/data` | BufferGeometry constructors and geometry queries |
| `triga:geometry/attribute` | BufferAttribute construction and payload queries |
| `triga:geometry/layout` | Vertex format and step-mode facts |
| `triga:geometry/batch` | Draw ranges, groups, and batch facts |
| `triga:primitives/basic` | Mesh generators (`plane_geometry`, `box_wire_geometry`, …) |
| `triga:scene` | SceneStore / handles |

Prefer the leaf that owns the type. The `triga:triga`, `triga:geometry`,
`triga:graph`, `triga:material`, and `triga:primitives` modules are maps for
humans; they intentionally do not re-export genera. This keeps an example's
dependency list honest and makes each source file a useful place to learn.

## How to read an example

Most examples use the same three-step rhythm:

```text
import the leaf → construct a typed value → inspect or validate a fact
```

`nihil` results are part of the API rather than hidden exceptions. Constructors
and queries return them when input cannot satisfy the contract; the examples
keep the result visible so failure behavior is easy to study.

## Current state (2026-08-02)

Exempla target `radix check` via `./scripta/check-compile`. WGSL emission works
end-to-end on files with `@ vertex` annotations and vertex layout facts:
`triga-hello-voxel-shaders.fab` emits valid combined vertex+fragment WGSL with
reflection sidecar.

Files without vertex layout facts (e.g. `triga-vertex-fragment-stub.fab`)
correctly fail `radix emit --target wgsl-text` with
`CODEGEN001:mir_wgsl_vertex_source_layout_missing` — expected, not a regression.
