# Delivery: Faber-native Triga surface

**Status**: active — Units 0–10 implemented 2026-09-30; residual named on math.proba MIR
**Goal:** `faber-native-surface`
**Repos:** `triga` (primary); `radix` only if Unit 1 is red; `examples`, `hosts` in Unit 9
**Release:** not-applicable (source library identity break; no product tag)

---

## 1. Interpreted Unit

Make the public `triga:*` surface a first-class Faber library: native math carriers, no three.js product type names, English `en` operations, consumers and living docs on the new surface. One clean break. No aliases.

## 2. Normalized Spec

Done when closeout `rg` in GOAL.md Validation is empty on `src/`, `exempla/`, `corpus/`; `./scripta/check-source` and `./scripta/check-compile` pass; proba still sit on every leaf; `TransformPayload` remains 32 f32 / 128 bytes; no `*_code` renames.

## 3. Repo-Aware Baseline

Triga `main` at `fb31914`, clean, ahead of origin by 2. Locale `en`. Live `src/math.fab` still has numbered genera. Layer B names still three.js. Generic-math Stage 0 selected direct native types; Stage 1 delivery is the worksheet for Units 2–3, not a second dispatch surface.

Sept 16 claim: `exempla/conformance/generic-math-types/selected/operations.fab` was `SEM010` on radix `574526dfb`. Unit 1 re-probes live HEAD. If red, Unit 2 is radix typecheck; if green, skip Unit 2.

## 4. Stage Graph

```text
0 (policy docs) ∥ 1 (compiler probe)
2 (radix) only if 1 red
3 (math.fab Layer A) after 1 green, or after 2
4 (retype src) after 3
5 (Layer B types) after 4
6 (primitive ctors) after 5
7 (locale + check-source) after 5+6
8 (exempla + corpus) after 7
9 (examples + hosts fixture) after 8
10 (leftover living docs) after 5+6; may overlap 8
```

## 5. Implementation Work

| Unit | write_scope | edit | done_when | sanity |
| --- | --- | --- | --- | --- |
| 0 | `triga/docs/api-shape-policy.md`, `triga/README.md`, `triga/AGENTS.md` | Close §1b and identity prose to GOAL law | Policy no longer keeps `Vector3` / Latin stems as `en` canon; Layer B names listed as law | read-only review |
| 1 | none (probe) | `faber check` on `exempla/conformance/generic-math-types/selected/operations.fab` from radix binary | Receipt: green or named SEM identities | — |
| 2 | `radix/crates/radix-semantic/src/passes/typecheck/**` plus focused tests | Only if Unit 1 red; S1-R1 worksheet | operations fixture checks green | minimal P-2 probes |
| 3 | `triga/src/math.fab`, `triga/src/math.proba`, generic-math selected fixtures as needed | Apply Layer A English surface | No `Vector2/3/4`, `Matrix3/4`, `Box3`, `vector3(`, `matrix4_`, `box3_` in those files | `faber check` math + `faber test` math.proba |
| 4 | remaining `triga/src/**/*.fab` + sibling `.proba` | Retype off retired carriers; no Layer B rename | `src/` typechecks against Unit 3 math | `faber check` on edited leaves |
| 5 | graph/object, geometry/data, geometry/attribute, material/{basic,lit,standard}, renderable/mesh, facades, proba | Type renames per settled table | No `Object3D`, `BufferGeometry`, `BufferAttribute`, `Mesh*Material` in `src/` | `faber check` those leaves |
| 6 | `triga/src/primitives/basic.fab` + proba + call sites in `src/` | `*_geometry` → short names | No `plane_geometry` / `box_geometry` / … in `src/` | `faber check` primitives |
| 7 | `triga/locale/la/pack.toml`, `triga/scripta/check-source` | Regenerated members; EXEMPT for surviving `box_*` / `camera_*` / `matrix_*` / `scene_*` / geometry ctors | `./scripta/check-source` exit 0 | — |
| 8 | `triga/exempla/**/*.fab`, `triga/corpus/**/*.fab` | New names + leaves | `./scripta/check-compile` exit 0 | — |
| 9 | `examples/hello-voxel`, `examples/triga-drift-city`, `examples/triga-budapest`, `hosts/webgpu-browser/fixtures/graphics.fab` | Leaf imports + new names | Those packages/`graphics.fab` check | `faber check` each |
| 10 | `triga/docs/module-map.md`, exempla README, `src/**/*.fab` THREE comments | Living-doc / header cleanup | No live `THREE.*` identity claims in `src/` headers | — |

## 6. Checkpoints And Gates

- After 3: math leaf green; do not start 5 until 4 typechecks.
- After 7: source lint green before exempla migration claims done.
- After 8: `check-compile` is the integration gate for triga-owned consumers.
- After 9: external consumers compile. Foreign dirt in examples serializes 9.

## 7. Validation

GOAL.md Validation block. Plus Unit 1 receipt filed in the goal ledger.

## 8. Companion Skill Plan

`$faber` for all `.fab` edits (locale `en` in triga src; `la` in examples until Unit 9). `$faberlang` if Unit 2 touches radix. `$factory` owns phase closeout.

## 9. Open Questions

None. Goal settled 2026-09-30.
