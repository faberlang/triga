# GOAL: PhongMaterial on the presenter

**Status**: done — 2026-10-01 operator visual: cyan/green–black checkerboard; top faces very light; inward faces dark
**Created**: 2026-10-01
**Campaign:** —
**Source:** operator pick after library-draw: Phong from library records
**Repos:** `triga`
**Related:** [`../../archived/library-draw/GOAL.md`](../../archived/library-draw/GOAL.md)

---

## Invariant

`PhongMaterial` and `DirectionalLight` field values that the fixture constructs are the values the fragment uses (shared module consts).

## Proposal

Extend `host/fixtures/scene.fab`: module consts build `PhongMaterial` + `DirectionalLight` and drive tint / intensity / specular in `@fragment`. Residual: `.power(shininess)` is not WGSL-emittable yet — specular uses diffuse⁴.

## Requirements register

| ID | Requirement | Status |
| --- | --- | --- |
| P1 | Phong color + light color/intensity tint the albedo | done |
| P2 | Specular term from Phong specular fields | done |

## Validation

`./scripta/host check` green; hard-reload `:8788` — warmer checkerboard, brighter specular on lit faces.
