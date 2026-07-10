# Triga Agent Instructions

Triga is the public Faber source library for `triga:*` imports — geometry,
scene graph, material, and GPU-facing type contracts modeled after three.js
shapes. This repo owns `.fab` source under `src/`; Radix and `faber` consume it
through `FABER_LIBRARY_HOME`, usually the parent `faberlang/` directory in local
development.

## Rules

- Keep public modules under `src/**/*.fab`.
- Keep instructional demos under `exempla/**/*.fab` (not in the language keyword
  corpus under sibling `examples/corpus/`).
- Do not add `@ externa` or `@ subsidia`; Triga source should stay native Faber
  or explicit `mori` deferral based.
- Optional genus fields use `sponte`, not retired `T ∪ nihil field = nihil` syntax.
- Triga is an optional domain library for graphics/WebGPU — not universal stdlib.
  Do not move modules into Norma unless explicitly asked.

## Validation

Run from this repo after source changes:

```bash
./scripta/check-source
./scripta/check-compile
```