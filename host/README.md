# Triga presenter

Thin browser WebGPU presenter for Triga. Admits radix `wgsl-text` reflection
and draws to a visible canvas. It is not the compute-first WebGPU product.

```bash
./scripta/host check    # emit host/fixtures/scene.fab, write bins, admit
./scripta/host serve    # http://127.0.0.1:8788/
```

`generate` runs `faber emit -t wgsl-text` and `--reflection` on
`fixtures/scene.fab`, writes shared `box(1,1,1)` vertex bins (position,
normal, uv), and writes two 32-float `TransformPayload`s for the SceneStore
left/right mesh nodes (same camera / translation formulas as the fixture).
`albedo.png` is an 8×8 checkerboard; the fragment lamberts it with a
direction matching the fixture’s `DirectionalLight`. `faber run` cannot dump
Geometry or matrices yet (MIR vector-method residual).

The older single-mesh `fixtures/box.fab` remains as a smaller emit smoke.
