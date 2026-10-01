# Triga presenter

Thin browser WebGPU presenter for Triga. Admits radix `wgsl-text` reflection
and draws to a visible canvas. It is not the compute-first WebGPU product.

```bash
./scripta/host check    # emit host/fixtures/box.fab, write bins, admit
./scripta/host serve    # http://127.0.0.1:8788/
```

`generate` runs `faber emit -t wgsl-text` and `--reflection` on
`fixtures/box.fab`, writes vertex bins from `src/primitives/basic.fab`
`box(1,1,1)`, and writes a 32-float / 128-byte `TransformPayload` from the
fixture's `PerspectiveCamera` (same `matrix_look_at` / `matrix_perspective`
formulas as `triga:math`). Color is remapped face normals. `faber run`
cannot dump Geometry or matrices yet (MIR vector-method residual).
