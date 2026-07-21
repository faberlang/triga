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
  threejs-host-demo/            # Browser fixture: Triga scene data rendered by three.js
```

Language keyword exempla: sibling `examples/corpus/`.
