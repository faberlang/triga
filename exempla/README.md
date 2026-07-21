# Triga exempla

Instructional demos for `triga:*` modules.

These programs belong with the Triga source library, not the keyword language
dictionary under sibling `examples/corpus/`.

## Layout

```text
exempla/
  triga-basics.fab              # Vector3, Matrix4, and material basics
  triga-geometry-attributes.fab # Geometry generation and vertex-layout reflection
  hello-voxel-first-draw-facts.fab # Locked position/color indexed-draw facts
  triga-scene-store.fab         # Stable handles, graph edits, and world transforms
  triga-stage4-source-facts.fab # Stage 4 vertex-layout handoff facts
  triga-transforms.fab          # Vector, quaternion, and matrix operations
  triga-types-untested.fab      # Instantiation of previously untested genus types
  triga-math-edge-cases.fab     # NaN/Infinity, degenerate-input, boundary tests
  triga-scene-store-empty.fab   # Empty SceneStore edge case tests
  triga-graphics-pipeline-facts.fab # Shader stages, pipeline reflection, and Goal 01 contract facts
  triga-vertex-fragment-stub.fab # @vertex / @fragment annotation stubs for Goal 01
  triga-hello-voxel-shaders.fab  # @vertex + @fragment exemplar with vertex layout + fragment facts
  triga-hello-voxel-pipeline.fab # Full Goal 01 pipeline: varyings, fragment outputs, resources
  threejs-host-demo/            # Browser fixture: Triga scene data rendered by three.js
```

Language keyword exempla: sibling `examples/corpus/`.

## Current state (2026-07-21)

All exempla pass `radix check`. WGSL emission works end-to-end on
files with `@ vertex` annotations and vertex layout facts:
`triga-hello-voxel-shaders.fab` emits valid combined vertex+fragment
WGSL with reflection sidecar.

Files without vertex layout facts (e.g. `triga-vertex-fragment-stub.fab`)
correctly fail `radix emit --target wgsl-text` with
`CODEGEN001:mir_wgsl_vertex_source_layout_missing` — this is expected,
not a regression.
