# GOAL: generic-math-types Stage 1 — Core Triga math surface delivery

**Status**: planned — lowered 2026-09-16 against live baselines (triga `b85ac16`, radix `574526dfb`); 6 units, 4 dispatchable immediately, S1-T1 gated on S1-R1 plus the OQ-1 spelling confirmation
**Created**: 2026-09-16
**Campaign:** `generic-math-types` (Stage 1 of 5)
**Source:** Mind task `3f8823c2`; [`CAMPAIGN.md`](CAMPAIGN.md) Stage 1 block; [`migration-map.md`](migration-map.md) (frozen 2026-08-25; spelling layer re-baselined per OQ-1 below)
**Repos:** `triga` (S1-P0, S1-T1), `radix` (S1-R1…S1-R4)
**Related:** [`delivery-stage0.md`](delivery-stage0.md) · [`representation-decision.md`](representation-decision.md) · [`api-shape-vocabulary/GOAL.md`](../api-shape-vocabulary/GOAL.md)

---

## Invariant

`triga:math` exposes no dimension-suffixed public identifier, carries vector/matrix
shape in the type (`vector<f32, N>` / `matrix<f32, [R, C]>`), and keeps the frozen
32-float / 128-byte model-then-VP column-major `TransformPayload` wire contract
byte-identical. No compatibility alias, adapter, or numbered constructor survives.

## Problem

Stage 1 has been idle since 2026-08-25 with no delivery artifact. Lowering against
the **live** repos (not the freeze pins) surfaced five baseline facts. Every claim
below was executed 2026-09-16 from `/Users/ianzepp/work/faberlang/triga` at `b85ac16`
(radix `574526dfb`, `radix`/`faber` debug binaries built same-tree).

### P-1 — All three named Stage-1 oracle commands are red or broken on current main

The campaign's Stage 1 done oracle names `./scripta/check-source`,
`./scripta/check-compile`, `./scripta/check-transforms` "in the assigned Triga
packet". Observed on main today:

| Command | Exit | Observed output (verbatim) |
| --- | --- | --- |
| `./scripta/check-source` | 1 | 13 findings, e.g. `src/math.fab:901:fn matrix4_identity() → Matrix4 {` … `check-source: genus-prefixed function should be a receiver method (see docs/api-shape-policy.md § 5) in /Users/ianzepp/work/faberlang/triga/src/math.fab`; plus `src/scene.fab:624` (`visible_meshes`) and `src/material/base.fab:93` (`material_from_name`) |
| `./scripta/check-compile` | 1 | `error[SEM002:qualified_type_not_exported]: …/exempla/triga-scene-store.fab:33` (`scene.VisibiliaRetium` — the exemplar is still Latin; `src/` converted to English 2026-08-27) |
| `./scripta/check-transforms` (standalone) | 1 | `check-transforms: missing faber checkout at /Users/ianzepp/work/faberlang/triga/../../../faber` — exits before checking anything; the `-f "$ROOT/../faber/Cargo.toml"` fallback fails because the public `faber/` repo has no root `Cargo.toml`, and the script only works when `check-compile` exports `FABER_ROOT` |
| `FABER_ROOT=…/radix/crates/faber ./scripta/check-transforms` | 1 | `error[SEM004:namespace_missing_export]` / `SEM004:unknown_method` at `exempla/triga-transforms.fab:12–14` (`math.matrix4_translatio`, `.multiplicata` — exemplar still Latin vs English src) |

Root cause (all three): the 2026-08-27 polish campaign (`93d03e7` "convert triga/src
to English-first identifiers", operator ruling thread `8acd975f`) converted `src/**`
only — its own commit says "this commit is source-only". The exempla, the
`check-source` EXEMPT regex (still `box3_ex_`, `matrix[34]_(identitas|translatio|…`,
`camera_(pitch_coercita|…)`), and the `check-transforms` fallback were left behind.
No open goal owns the exempla follow-up (`api-shape-vocabulary/GOAL.md`: "compiler/
exempla follow-up remains outside this hygiene repair").

### P-2 — New radix regression breaks the frozen Stage-0 proof (RB-A)

At the freeze pin `fbec200be`, `--selected --operations` was source-PASS. At radix
`574526dfb`, the **unchanged** fixture (last touched `f1ccbac`, 2026-08-25) fails:

```text
$ …/radix/target/debug/faber check exempla/conformance/generic-math-types/selected/operations.fab
error[SEM010:incompatible_tensor_index]: …/operations.fab:502   ← const vector<f32, 3> mensura ← capsam.mensura()
error[SEM010:initializer_annotation_mismatch]: …/operations.fab:502
error[SEM010:expression_type_mismatch]: …/operations.fab:614    ← const f32 xe ← x_entry coalesce 0.0
error[SEM010:initializer_annotation_mismatch]: …/operations.fab:614   (also :615, :616)
```

Minimal repros executed at `574526dfb` (2026-09-16):

- Receiver seam — `SEM010:incompatible_tensor_index` ×2 + `initializer_annotation_mismatch`:

  ```faber
  class Box<size N> {
      vector<f32, N> min
      vector<f32, N> max
      fn size() → vector<f32, N> { return self.max.subtract(self.min) }
  }
  fn probe(Box<3> b) → f32 {
      const vector<f32, 3> s ← b.size()
      return s.dot([1.0, 1.0, 1.0] ↦ vector<f32, 3>)
  }
  ```

- Coalesce seam — a plain `f32 ∪ null` parameter `coalesce 0.0` is **green**; the
  failure requires `const f32 ∪ null e ← f()` then `if e is null then return null`
  then `const f32 x ← e coalesce 0.0` (guard-narrowed local), producing
  `SEM010:expression_type_mismatch` + `SEM010:initializer_annotation_mismatch`.

Both identities are the **exact posture Stage 1 must write** (free predicate
functions over `Box<3>` calling the parametric receiver; nullable slab intervals).
This regression is not in the freeze residual record — it is new since `fbec200be`.

### P-3 — Freeze-era routed residuals, live status at `574526dfb`

| Freeze residual | Live status 2026-09-16 |
| --- | --- |
| R4: rust emission of size-parametric glyph-matmul body (`CODEGEN001`) | still blocks `operations/rust-emit`; **masked** by P-2 (analysis fails before emit) |
| hir-ts `TS2339` Box-receiver method calls + `TS7006` untyped `reduce` accumulator | blocks `operations/ts-compile`; **masked** by P-2 |
| hir-ts payload flatten `TS2364`/`TS2304` | **reproduced live**: `[FAIL] selected payload/ts-compile … payload.ts(342,18): error TS2304: Cannot find name 'c'. payload.ts(342,27): error TS2304: Cannot find name 'r'.` |
| Box mutable inflate (field stores on applied generic nominals, unproven at freeze) | **no longer a blocker**: `fn inflate_min() → void { self.min ← self.max }` on `class Box<size N>` checks green at `574526dfb` (declaration-body store proven) |
| T1R R1: hir-ts library-mode module exports (`TS2306`) | **reproduced live** in the `--all` matrix rows: `[FAIL] direct ts/consumer-compile … consumer.ts(302,22): error TS2306: File '…/probevectors-vectors.ts' is not a module.` (identical `wrapper ts/consumer-compile`) — the "need filed" from T1R was never filed; see OQ-5 |

Two **new** regressions vs the freeze posture, both observed only via `--all`
(candidate-matrix rows; green at freeze per `representation-decision.md` §1):

```text
[FAIL] direct rust/provider-compile   command: rustc --edition 2021 --crate-type lib provider.rs
                                      exit: 1  first: error: expected expression, found `+`  error[E0308]: mismatched types
[FAIL] direct rust/consumer-compile   command: rustc --edition 2021 --crate-type lib consumer.rs
                                      exit: 1  first: error: expected expression, found `+`
```

The hir-rust emitter now produces syntactically invalid Rust for the direct
candidate fixtures (emission "succeeds", `rustc` then fails to parse) — an
emitted-syntax regression in the same `radix-hir-rust` parametric-body emission
family S1-R3 touches; fold-or-split decision routed as OQ-6.

Five-invocation posture at `574526dfb`: `--selected --payload` PASS, `--selected
--device-posture` PASS, `--selected --operations` FAIL (P-2), `--selected --targets
rust,ts` FAIL ×3 (`operations/rust-emit`, `operations/ts-emit` both cascade from P-2;
`payload/ts-compile` = TS2304 family), `--all` FAIL ×12 (4 permanent alias-candidate
recorded reds; the 2 `direct rust/*-compile` emitted-syntax regressions above;
`direct`/`wrapper ts/consumer-compile` TS2306; the 4 selected-mode reds already
named). The closeout ratchet for `--all` is parity with this 12-row baseline; the
freeze posture did not include the two `direct rust/*-compile` emitted-syntax reds.

### P-4 — Frozen-map defects surfaced by command-derived census (routed, not re-adjudicated)

1. **The map's §10 grep oracle is case-blind to lowercase helper consumers.** Run
   2026-09-16:

   ```sh
   rg -l 'Vector2|Vector3|Vector4|Matrix3|Matrix4|Box3' src exempla corpus | sort   # 28 files
   rg -l '\bvector3\(|\bmatrix4_[a-z]+|\bbox3_from_[a-z_]+|\bbox3_hit\b' src exempla corpus | sort  # 23 files
   comm -13 <(rg -l 'Vector2|Vector3|Vector4|Matrix3|Matrix4|Box3' src exempla corpus | sort) \
            <(rg -l '\bvector3\(|\bmatrix4_[a-z]+|\bbox3_from_[a-z_]+|\bbox3_hit\b' src exempla corpus | sort)
   ```

   Five real consumers have **zero** oracle hits: `exempla/triga-geometry-attributes.fab`,
   `exempla/triga-scene-store.fab`, `src/geometry/data.proba`, `src/graph/object.proba`,
   `src/renderable/mesh.proba`. Two of them are pinned exempla of `check-compile`.
   They have no map rows; a Stage-2 Hand would hit unlisted compile errors.
2. **The campaign's Stage-1 done oracle over-claims.** Stage 1 removes `Vector3`/
   `Matrix4` from `math.fab` while `check-compile` parses **every** `src/**/*.fab`
   leaf and `check-transforms` checks `exempla/triga-transforms.fab` — all Stage-2
   consumers. No Stage-1-scoped change can make the trio green; the trio is a
   Stage-1→2 integration property (see Validation).
3. **Spelling fork (OQ-1).** The frozen map's destination spellings are the Latin
   `operations.fab` names (`addita`, `matricis_identitas`, `capsa_*`); the live
   `src/` vocabulary is English-first by operator ruling (`8acd975f`, 2026-08-27,
   landed `93d03e7`), which post-dates the freeze. This delivery defaults to the
   operator ruling (§ Proposal) and routes the confirmation to Mind.
4. `src/math.fab` drifted 112 → **113** oracle hits (Sept-13 `b9a602f` extrema
   polish); every other file count matches the frozen map exactly.

## Proposal

Lower Stage 1 into six units: one triga baseline-repair precondition (S1-P0), four
narrow radix units (S1-R1…R4), one triga surface unit (S1-T1). The representation is
**not** re-adjudicated: direct native types per `representation-decision.md` §1.

### Destination surface (spelling default: operator-ruled English-first, OQ-1)

| Retired today (live English surface) | Stage 1 destination |
| --- | --- |
| `class Vector2/Vector3/Vector4` | removed; carriers `vector<f32, 2\|3\|4>`; construction `[x, y, z] ↦ vector<f32, 3>` |
| `class Matrix3/Matrix4` | removed; carriers `matrix<f32, [3, 3]>` / `matrix<f32, [4, 4]>` |
| `class Box3` | `class Box<size N>` over `vector<f32, N> min` / `max` |
| `Vector3.add/subtract/scale/dot/cross/length/normalized/distance/lerp/project` (receivers) | free `add<N>/subtract<N>/scale<N>/dot<N>/length<N>/normalized<N>/distance<N>/lerp<N>/project<N>`; width-3 `cross` — map §2 rows, English stems per the live surface (`addita→add`, `scala→scale`, `productum→dot`, `transversum→cross`, `longitudo→length`, `normata→normalized`, `distantia→distance`, `interpolata→lerp`, `projecta→project`) |
| `Matrix4.multiply` | glyph `·` (parametric; S1-R3 owns its rust emission) |
| `Matrix4.transpose/apply_point/affine_determinant/affine_inverse` | free `transpose<R,C>`, `apply_point` at `[4,4]`, `affine_determinant`, `affine_inverse → matrix<f32, [4, 4]> ∪ null` |
| `Matrix4.valid()` | **removed — type invariant** (`matrix<f32, [4, 4]>` cannot carry ≠16 lanes); the two guards in `transform_payload` are deleted; perspective/look-at/affine-inverse domain nullables unchanged |
| `Box3` receivers | `Box<N>` receivers `size()` / `translated(vector<f32, N>)` / `inflate(f32)` (mutable — field-store seam green, P-3 row 4); immutable + predicate family as free functions over `Box<3>`: `box_inflated`, `box_valid`, `box_contains`, `box_contains_box`, `box_intersects`, `box_center`, `box_overlap`, `box_overlap_facts`, `box_union` (map §2 "predicates as free functions per operations.fab") |
| `vector3(x, y, z)` | removed |
| `matrix4_{identity,translation,scale,compose,perspective,look_at}` | `matrix_{identity,translation,scale,compose,perspective,look_at}` → `matrix<f32, [4, 4]>` (`4` token dropped; nullable returns unchanged) |
| `box3_from_{min_max,min_and_size,center_and_size}` | `box_from_*` free over `Box<3>` (Stage 2 may inline; keeping them minimizes consumer churn) |
| `Ray.box3_hit`, `RayBox3Hit`, `hit_face_*` | `Ray.box_hit`, `RayBoxHit`, `hit_face_*` (no `3` token survives in `math.fab`) |
| `Box3OverlapFacts` | `BoxOverlapFacts` |
| `TransformPayload` | genus unchanged; constructor inputs `matrix<f32, [4, 4]>`; guards deleted (see `validum` row); wire contract byte-identical |
| `camera_*`, `face_code_*`, `axis_interval`, `hit_normal`, `sqrt_f32`, `sin_f32`, `cos_f32`, `reduced_angle`, `radians_from_degrees`, `quaternion`, `euler`, `CameraYawPitchFacts`, `FaceCodeFacts`, `RayInterval`, `Sphere`, `Plane`, `Quaternion`, `Color`, `Euler` | keep; signatures/fields retyped off the retired carriers (they cannot outlive Stage 1 inside `math.fab` — the file must typecheck with the declarations removed) |

All surviving free `box_*`/`camera_*` helpers get explicit `check-source` EXEMPT
entries (the sanctioned mechanism); `matrix_*`/`vector*` prefixes die with their
genera (the lint derives prefixes from live `class` declarations).

### Non-goals

- No Stage-2 work: scene/graph/face/geometry/lighting consumers, exempla/corpus
  parametric migration, `Ray`/facts renames **outside** `math.fab`.
- No representation change, no aliases/shims/numbered compatibility spellings.
- No generated outputs, Examples, site, locale-pack, or `docs/` API-guide edits.
- No device enablement (posture stays fail-closed, runner-verified).
- S1-R units fix only the named defects; no broad emitter rework.

## Units

Ordered graph (parallel waves where write surfaces are disjoint):

```text
wave 1 (parallel; disjoint):
  S1-P0 (triga scripta + 2 exempla) ∥ S1-R1 (radix-semantic) ∥ S1-R2 (radix-hir-ts payload) ∥ S1-R3 (radix-hir-rust)
wave 2 (serial on the shared radix-hir-ts seam):
  S1-R4 after S1-R2
wave 3:
  S1-T1 after S1-R1 (+OQ-1 confirmed)
```

### S1-P0 — Oracle baseline repair (triga; polish-campaign fallout)

| Field | Value |
| --- | --- |
| Seam | The 2026-08-27 English-first conversion left `exempla/triga-scene-store.fab` and `exempla/triga-transforms.fab` Latin (P-1), and `scripta/check-transforms` unrunnable standalone (broken `FABER` fallback). **Mechanical English re-spell to the current retired surface only** — no parametric migration (Stage 2 owns that; S1-T1 will re-break these exempla until Stage 2 migrates them, by design). Also fixes the fallback to prefer `$RADIX/crates/faber` as `check-compile` already does. |
| write_scope | `scripta/check-transforms`; `exempla/triga-scene-store.fab`; `exempla/triga-transforms.fab` |
| done_when | `./scripta/check-compile` exits 0 (parses all `src` leaves + all pinned exempla + FHIR envelope + child `check-transforms`/`check-exempla-inventory`). Current baseline: exit 1, single error `SEM002:qualified_type_not_exported … triga-scene-store.fab:33`. |
| sanity | `./scripta/check-transforms` exits 0 standalone with no `FABER_ROOT` in the environment (currently exits 1 printing `missing faber checkout`). |
| depends_on | none |
| non_goals | `check-source` findings outside `src/math.fab` (`scene.fab`, `material/base.fab` — routed OQ-4); any parametric-surface edit |
| risk | low — mechanical renames verified by compile; the transforms exemplar gets re-migrated in Stage 2 |
| integrable | yes |

### S1-R1 — Radix regression: applied-nominal receiver substitution + guarded-nullable coalesce (radix; RB-A)

| Field | Value |
| --- | --- |
| Seam | Two `radix-semantic` typecheck regressions since `fbec200be`, both reproduced on the unchanged freeze-green fixture and minimized (P-2): (a) calling a parametric receiver `fn size() → vector<f32, N>` on a `Box<3>`-typed parameter yields `SEM010:incompatible_tensor_index` ×2 + `SEM010:initializer_annotation_mismatch` (no substitution of `N=3` at the call site); (b) `coalesce` over an `is null`-guard-narrowed `f32 ∪ null` local yields `SEM010:expression_type_mismatch` + `SEM010:initializer_annotation_mismatch` (plain-parameter `coalesce` is green). Owning surface: `crates/radix-semantic/src/passes/typecheck/**` (the Hand refreshes the consumer census before edits, delivery-stage0 §4.1 convention). |
| write_scope | Repo `radix`: the typecheck-pass files the fix requires under `crates/radix-semantic/src/passes/typecheck/` plus focused co-located tests; a regression fixture reproducing both probes (runner gap-probe row or crate test) |
| done_when | From a triga checkout with the packet tools exported: `./scripta/check-generic-math-representation --selected --operations` exits 0 (flips `selected operations/source` FAIL→PASS; currently exit 1). |
| sanity | `"$FABER_BIN" check` green on both minimal probes of P-2 (currently red on the receiver seam). |
| depends_on | none |
| non_goals | Emitter changes (R2/R3/R4); fixture re-spelling; alias-candidate repair |
| risk | medium — receiver substitution touches the applied-generic nominal seam; the negatives posture (`SEM010` on genuine mismatches, `SEM008:generic_argument_kind_mismatch`) must stay red |
| integrable | yes |

### S1-R2 — hir-ts payload-flatten coordinate emission (radix; freeze TS2364/TS2304)

| Field | Value |
| --- | --- |
| Seam | `payload/ts-compile` red at `574526dfb`: emitted `payload.ts(342): TS2304: Cannot find name 'c'` / `'r'` — iteration-coordinate variables out of scope at the index-assignment store in the payload flatten (`hir-ts` emission of `for from m at [r, c]` bodies). Owning surface: `crates/radix-hir-ts/src/**` where coordinate/index-assignment emission lives. |
| write_scope | Repo `radix`: the `radix-hir-ts` emission files the fix requires plus focused co-located tests |
| done_when | `./scripta/check-generic-math-representation --selected --targets rust,ts` reports `payload/ts-compile` PASS (row is currently FAIL with the quoted TS2304s; `payload/rust-compile` already PASS and must stay green). |
| sanity | `cargo test -p radix-hir-ts --lib` non-empty focused filter covering the coordinate-emission change. |
| depends_on | none (payload path is analysis-green today; independent of S1-R1) |
| non_goals | Box-receiver emission / reduce accumulator (S1-R4 — same crate, serialized after this) |
| risk | medium — strict `tsc --strict` gates the row; width-preserving Rust side must not drift |
| integrable | yes |

### S1-R3 — hir-rust size-parametric glyph-matmul emission (radix; freeze R4)

| Field | Value |
| --- | --- |
| Seam | `CODEGEN001` "glyph product operator `·` requires a concrete static shape at codegen" for size-parametric bodies (`crates/radix-hir-rust/src/expr/ops.rs` arm; anchor from delivery-stage0 §4.1), **plus** the P-3 emitted-syntax regression in the same crate's parametric-body emission (`direct rust/provider-compile` + `direct rust/consumer-compile`: emitted Rust fails to parse, `expected expression, found '+'`). Stage-1 content depends on the glyph half: the map's `multiply` destination **is** the parametric glyph. Code-dispatchable now (disjoint from R1/R2); its oracle rows are masked behind S1-R1. |
| write_scope | Repo `radix`: `crates/radix-hir-rust/src/expr/ops.rs` + the sibling emission files the emitted-syntax fix requires + focused co-located tests |
| done_when | `./scripta/check-generic-math-representation --selected --targets rust,ts` reports `operations/rust-emit` PASS (reachable only after S1-R1 un-masks the row). |
| sanity | `cargo test -p radix-hir-rust --lib` non-empty focused filter over the glyph emission arm; concrete-width `·` emission byte-unchanged; matrix rows `direct rust/provider-compile` + `direct rust/consumer-compile` re-checked via `--all` (fold-or-split per OQ-6). |
| depends_on | S1-R1 (proof; code parallel-safe) |
| non_goals | TS emission; semantic glyph admission (S0-G7 landed) |
| risk | medium — const-generic width preservation; concrete-shape regression guard is the byte-identity clause |
| integrable | yes |

### S1-R4 — hir-ts Box-receiver method calls + reduce accumulator (radix; freeze TS2339/TS7006)

| Field | Value |
| --- | --- |
| Seam | Freeze §8 routed defects: Box-receiver method calls over tuple-carrier parameters (`TS2339`) and untyped `reduce` accumulator parameters (`TS7006`) under `tsc --strict`. Blocks `operations/ts-compile` (currently unreachable behind P-2). Serialized after S1-R2 — same crate, overlapping emission files. |
| write_scope | Repo `radix`: the `radix-hir-ts` files the fix requires (shared seam with S1-R2) plus focused co-located tests |
| done_when | `./scripta/check-generic-math-representation --selected --targets rust,ts` reports `operations/ts-compile` PASS (row reachable after S1-R1; single remaining red in that invocation). |
| sanity | `cargo test -p radix-hir-ts --lib` non-empty focused filter covering receiver-call and reduce emission. |
| depends_on | S1-R2 (shared `radix-hir-ts` seam); S1-R1 (row visibility) |
| non_goals | Library-mode module exports (T1R R1 / TS2306 — reproduced live, routed OQ-5); TS emission |
| risk | medium — carrier coupling with the tuple-identity decision (S0-G5); strict-gate only |
| integrable | yes |

### S1-T1 — Triga math surface rewrite (triga; the Stage-1 product unit)

| Field | Value |
| --- | --- |
| Seam | Whole `src/math.fab` per the destination table: the six retired declarations removed, `Box<size N>` + receivers, free vector/matrix/box operations, `matrix_*` constructors (token dropped), `validum`/`valid` retirement with `transform_payload` guard deletion, dependent genera retyped and `3`-token names renamed (`RayBox3Hit→RayBoxHit`, `Box3OverlapFacts→BoxOverlapFacts`, `Ray.box3_hit→box_hit`), helpers retyped; `src/math.proba` rewritten against the new surface (78 oracle hits → 0) including the 32-float payload-layout asserts; `scripta/check-source` EXEMPT refreshed for the surviving free helpers (`camera_*` English spellings, `box_*` family; `matrix_*`/`vector*` entries die with their genera). Header comments rewritten (they name the retired types). |
| write_scope | `src/math.fab`; `src/math.proba`; `scripta/check-source` |
| done_when | `"$FABER_BIN" test src/math.proba` exits 0 from the triga packet root (single-file proba run; transitively requires `math.fab` check-green since the proba imports `./math`). |
| sanity | `rg -n 'Vector2|Vector3|Vector4|Matrix3|Matrix4|Box3|\bvector3\(|\bmatrix4_[a-z]|\bbox3_' src/math.fab src/math.proba` exits 1 (zero retired tokens, type-spelled **and** helper-spelled). |
| depends_on | S1-R1 (the Box-receiver + guarded-coalesce seams are this unit's content); OQ-1 confirmation at dispatch |
| non_goals | Consumers outside `math.fab` (Stage 2); exempla/corpus; generated output; locale packs; API-guide docs; `docs/factory` status (Mind's) |
| risk | high — the public surface swaps in one change set; behavior preservation is carried by the proba asserts (arithmetic, transforms, payload layout, box predicates); landing intentionally re-breaks Stage-2 consumers until Stage 2 lands (integration marked below) |
| integrable | **no — packet-branch only.** Cannot reach main alone (six `src` consumer files + pinned exempla reference the retired surface; see P-4 item 2). Merge owns the atomic Stage-1+2 landing. |

## Validation

Stage-1 unit closeout (per-unit oracles above; no lane gates on children). Stage-1
**theme** closeout, once S1-T1 + all S1-R units are committed:

```sh
export RADIX_ROOT=<assigned radix packet>   # radix + faber built same-tree
export RADIX_BIN="$RADIX_ROOT/target/debug/radix" FABER_BIN="$RADIX_ROOT/target/debug/faber"
./scripta/check-generic-math-representation --selected --operations   # exit 0
./scripta/check-generic-math-representation --selected --targets rust,ts  # exit 0
./scripta/check-generic-math-representation --selected --payload      # exit 0 (already green)
./scripta/check-generic-math-representation --selected --device-posture # exit 0 (already green)
./scripta/check-generic-math-representation --all                    # parity with the recorded 12-row baseline (P-3), not the freeze posture
"$FABER_BIN" test src/math.proba
```

**Integration boundary (honest scope):** the campaign's scripta trio
(`check-source`/`check-compile`/`check-transforms` green) is a Stage-1→2
integration property, not a Stage-1 unit property — Stage 1 removes declarations
that six `src` consumer files and the pinned exempla still reference (P-4 item 2;
OQ-2). The Stage-2 delivery owns the trio-green claim on the integrated tree;
`S1-P0` restores the pre-Stage-1 baseline so the Stage-2 diff is attributable.
Lane-owned after integration: lint lane stages 1–2; test lane stages 3+ and
`scripta/e2e` per campaign; never a child-Unit gate.

## Delivery checklist

| Check | Enforced by |
| --- | --- |
| Every unit's `done_when` is one named command with a pasted baseline | this artifact (verification discipline: each command above executed 2026-09-16, output quoted) |
| Write scopes are command-derived | oracle-hit census + helper-spelling census (P-4 item 1) run and pasted |
| Retired-token zero on the Stage-1 surface | S1-T1 sanity `rg` (type- and helper-spelled) |
| Wire contract unchanged | `--selected --payload` + proba layout asserts |
| No compatibility destination | destination table has none; S1-T1 sanity greps them |

## Ledger

| Unit | Status | Seat | Receipt | Notes |
| --- | --- | --- | --- | --- |
| S1-P0 | pending | — | — | dispatchable now |
| S1-R1 | pending | — | — | dispatchable now; gates S1-T1 |
| S1-R2 | pending | — | — | dispatchable now |
| S1-R3 | pending | — | — | code now; proof after S1-R1 |
| S1-R4 | pending | — | — | after S1-R2 |
| S1-T1 | pending | — | — | after S1-R1 + OQ-1; non-integrable alone |

## Open questions (Mind)

1. **OQ-1 — spelling default confirmation.** Map-as-frozen says Latin destinations
   (`matricis_identitas`, `capsa_*`); live src is English-first by operator ruling
   `8acd975f` (2026-08-27), which post-dates the freeze. This delivery defaults to
   **English-first** (repo wins; newer operator authority; the conformance fixtures
   are self-contained Stage-0 probes, unaffected). Confirm, or direct the Latin
   spelling (then S1-T1's destination table re-bases and the map stands verbatim).
   This is the only decision that changes S1-T1's content.
2. **OQ-2 — Stage-1 oracle amendment vs scope pull.** The campaign's Stage-1 row
   ("scripta trio pass in the assigned packet") is unachievable within Stage-1
   scope (P-4 item 2). Default recorded here: unit-oracles as in §Units, trio-green
   moves to Stage-2 integration. Alternative: Mind pulls the six src consumers
   into Stage 1 (an explicit campaign amendment; not assumed here).
3. **OQ-3 — map addendum for oracle-blind consumers.** Five files call retired
   helpers with zero §10-oracle hits (P-4 item 1), including both `check-compile`-
   pinned exempla. They need Stage-2 rows (and the §10 oracle needs the lowercase
   helper alternation appended at closeout). Mind amends the map or instructs the
   Stage-2 lowering to absorb them.
4. **OQ-4 — unowned check-source findings.** `src/scene.fab:624` (`visible_meshes`)
   and `src/material/base.fab:93` (`material_from_name`) keep `check-source` red
   after S1-P0 + S1-T1 (polish-introduced genus-prefixed names; no goal owns them;
   CI already labels the lint "expected until Stage 2"). Route: exempt, convert to
   receivers, or accept-red with a CI note — Mind's call; not Stage-1 scope.
5. **OQ-5 — library-mode TS exports (T1R R1, TS2306).** **Reproduced live** in the
   `--all` matrix rows (`direct`/`wrapper ts/consumer-compile`,
   `probevectors-vectors.ts is not a module`) — the T1R "need filed" was never
   filed. For Stage 1 it is a recorded residual inside the `--all` parity baseline;
   it gates library-mode TS emission for Stage 3/4. Named follow-up: file it as a
   narrow hir-ts unit when Stage 3 lowers (`TsCodegen::new_module`/`write_module_exports`
   wiring per decision §6 R1); no Stage-1 unit carries it.
6. **OQ-6 — new hir-rust emitted-syntax regression.** `direct rust/provider-compile`
   and `direct rust/consumer-compile` fail `rustc` parsing on emitted output
   (`expected expression, found '+'`; green at freeze). Provisionally folded into
   S1-R3's packet (same crate, same parametric-body emission family); if the
   characterizing Hand shows a different seam, split it as its own unit — Mind's
   routing call at dispatch.
