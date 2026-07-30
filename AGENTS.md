# Triga Agent Instructions

Triga is the public Faber source library for `triga:*` imports — geometry,
scene graph, material, and GPU-facing type contracts modeled after three.js
shapes. This repo owns `.fab` source under `src/`; Radix and `faber` consume it
through `FABER_LIBRARY_HOME`, usually the parent `faberlang/` directory in local
development.

Browser WebGPU runtime product code lives in sibling `hosts/webgpu-browser`,
not here. Triga owns typed contracts and generators that feed that path.

## Rules

- Keep public modules under `src/**/*.fab` (one file → one `triga:<stem>` path).
- Keep instructional demos under `exempla/**/*.fab` (not in the language keyword
  corpus under sibling `examples/corpus/`).
- Do not add `@ externa` or `@ subsidia`; Triga source should stay native Faber
  or explicit `mori` deferral based.
- Optional genus fields use `sponte`, not retired `T ∪ nihil field = nihil` syntax.
- Triga is an optional domain library for graphics/WebGPU — not universal stdlib.
  Do not move modules into Norma unless explicitly asked.
- Honor module seams in [`docs/module-map.md`](docs/module-map.md) and
  [`docs/api-shape-policy.md`](docs/api-shape-policy.md):
  - `geometry` — buffer / draw / vertex-layout contract
  - `primitives` — mesh generators built on geometry constructors
  - `triga` — math + scene-graph shapes + materials
  - `scene` — stable identity store + resource lifecycle free functions
- Prefer receiver methods on genera for operations; free functions only for
  constructors, pure scalars, and generators (policy §1).

## Validation

Run from this repo after source changes:

```bash
./scripta/check-source
./scripta/check-compile
```

After import-path or public-API moves, also run the hello-voxel / capability
checks listed in `README.md` when those surfaces were touched.
