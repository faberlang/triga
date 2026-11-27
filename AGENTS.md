# Triga Agent Instructions

Triga is the public Faber source library for `triga:*` imports: geometry,
scene graph, materials and GPU-facing type contracts. Container rules:
[`../AGENTS.md`](../AGENTS.md).

## Work mode

- Develop directly in this checkout. There is no issue queue and no CI for
  this repo; checks run locally.
- Branch each piece of work as `peer/<topic>` off `origin/main`, push it,
  and open a pull request into `main`. Never use the `agent/` prefix.
- Path-limited commits only (`git add -- <paths>`, then
  `git commit -- <same paths>`).
- Planning documents, proofs, scorecards and other generated or runtime data
  stay out of this repo.

## Library shape

Dimension lives in types (`vector<f32, size N>`, `matrix<f32, [R, C]>`,
`Box<N>`), not in identifiers. three.js product names are not the public
surface. The module list is in [`README.md`](README.md).

- One `.fab` file is one import path. Public modules live under `src/`.
- A nested package directory needs at least two modules; a lone nested file
  is flattened to a top-level leaf.
- Package facades (`triga:triga`, `triga:geometry`, …) are maps only. Do not
  add types to them; prefer leaf imports.
- Prefer receiver methods on types. Free functions are for constructors,
  scalars and generators.
- No `@ externa` or `@ subsidia`. Optional fields use `sponte`.
- Do not move modules into Norma unless asked.
- Triga owns its graphics stage contracts and their WGSL bindings
  (`bindings/wgsl.toml`, read through `[target.wgsl-text]` in `faber.toml`).

## Tests and exempla

- Every `.fab` file uses `+++` sections, in this order: `+++ toml` (with
  `locale = "en"`), `+++ faber` (the module), then `+++ faber test` (the
  module's tests), then any `+++ text stdout` (expected output). There are no
  separate `.proba` or `.expected` files.
- A test section sees only the module's `@ public` names, either bare or
  through an import of the module's own path.
- Instructional programs live under `exempla/`. An exemplum with a
  `+++ text stdout` section is verified with `faber corpus`.
- Browser demo scenes live under `corpus/<slug>/`, with shared host assets in
  `corpus/_host/`. Demos use the public `triga:*` surface; a gap they find is
  fixed in the library, not worked around in the demo.
- The thin WebGPU presenter lives in `host/` and is Triga-owned.

## Validation

```bash
./scripta/check
```

It runs `faber check` on the library and on each exemplum, `faber corpus` on
the exempla that carry expected output, then `faber test` on the package. It
takes about 15 seconds: about 9 checking exempla one at a time, about 5 in
`faber test`. The presenter has its own driver: `./scripta/host check` and
`./scripta/host serve`.

## Releases

Triga is a source library. There is no artifact publish and no GitHub release
workflow. A version is a manifest pair plus an annotated tag:

1. Bump `version` in `cista.toml` and `faber.toml` together.
2. Commit, merged to `main`.
3. `git tag -a vX.Y.Z` on that commit, and push the tag.
