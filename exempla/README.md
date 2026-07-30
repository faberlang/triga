# Triga exempla

Instructional demos for `triga:*` modules.

These programs belong with the Triga source library, not the keyword language
dictionary under sibling `examples/corpus/`.

## Layout

```text
exempla/
  triga-basics.fab              # Vector3, Matrix4, and material basics
  triga-geometry-attributes.fab # Buffer layout + primitives.box_wire_geometry
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
  threejs-host-demo/            # Browser fixture: Triga scene data via three.js
```

Language keyword exempla: sibling `examples/corpus/`.

## Imports

| Module | Typical exempla use |
| --- | --- |
| `triga:triga` | Math, materials, face codes |
| `triga:geometry` | BufferGeometry constructors, attributes, layout |
| `triga:primitives` | Mesh generators (`plane_geometry`, `box_wire_geometry`, …) |
| `triga:scene` | SceneStore / handles |

## Current state (2026-07-30)

Exempla target `radix check` via `./scripta/check-compile`. WGSL emission works
end-to-end on files with `@ vertex` annotations and vertex layout facts:
`triga-hello-voxel-shaders.fab` emits valid combined vertex+fragment WGSL with
reflection sidecar.

Files without vertex layout facts (e.g. `triga-vertex-fragment-stub.fab`)
correctly fail `radix emit --target wgsl-text` with
`CODEGEN001:mir_wgsl_vertex_source_layout_missing` — expected, not a regression.
