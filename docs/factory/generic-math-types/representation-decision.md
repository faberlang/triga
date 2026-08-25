# Generic Math Types — Representation Decision (S0-T1)

**Status**: active — S0-T1 probe EXECUTED 2026-08-25 at radix `9a78fb080` (pin verified ancestor of radix main); **NO CANDIDATE SELECTABLE at this base** — all three candidates fail mandatory matrix rows; the delivery's all-fail stop condition fired and the observed compiler boundaries are routed to Mind as narrow Radix units. Re-run `./scripta/check-generic-math-representation --matrix` after each lands.

**Campaign**: [`CAMPAIGN.md`](CAMPAIGN.md) · **Delivery**: [`delivery-stage0.md`](delivery-stage0.md) §4 S0-T1

## 0. Probe identity

| Fact | Value |
| --- | --- |
| Radix pin | `9a78fb080047395bec3124fe53eebcd660f6de1d` (S0-R1), built as a detached clean worktree — radix main carried foreign WIP in `crates/faber/**` at probe time |
| Radix CLI packages | `cargo build -p radix-cli --bin radix` + `cargo build -p faber --bin faber` (the delivery's `-p radix --bin radix` spelling predates the bin-package split; the repo wins) |
| Triga base | `8d53b9b` + this commit; fixtures under `exempla/conformance/generic-math-types/` |
| Tools | `faber 1.8.0` / `radix` from the pin; `rustc 1.97.1`; `tsc 6.0.3` |
| Import route | real product package route: temporary library home assembled by the runner (`probevectors` package, module `vectors`), resolved through `FABER_LIBRARY_HOME` |
| Runner | `scripta/check-generic-math-representation` (`--candidate alias\|direct\|wrapper`, `--matrix`/`--all`); exits non-zero while any delivery-ideal row fails — failures are recorded evidence, not runner defects |

Every row below cites the exact command and the structured diagnostic identity
observed at the pin. Full per-row output is reproducible via the runner.

## 1. Verdict

The candidate preference order (alias → direct → wrapper) cannot be applied:
no candidate passes every mandatory row, so per §4 S0-T1's approval
requirement and §10's stop condition ("all three candidates fail a mandatory
matrix row"), **no representation is selected, Stage 0 is blocked at S0-T1,
and the smallest observed boundaries route back through Mind** as narrow
Radix units. No least-broken candidate is picked.

| Candidate | Mandatory-row failures observed (root identities) | Verdict |
| --- | --- | --- |
| Transparent alias | Construction + Operations + Rust + TypeScript: `SEM004:unknown_method` (`.added/.dot/.cross/.swizzle` on alias receivers), `SEM011:glyph_operands_unsupported` (`·`/`⊗` on alias operands), `SEM014:cannot_infer_tensor_shape` (`[..] ↦ Vector<N>` conversions), `SEM010:initializer_annotation_mismatch` (builtin→alias assignment) | **Rejected on observed evidence** — the alias is not value-transparent at this base |
| Direct native | Rust + TypeScript: `CODEGEN001` "vector intrinsic requires concrete vector width" (rust and ts) on size-parametric intrinsics; imported generic calls: `faber check` green but `radix emit` route fails `SEM010:expression_type_mismatch`/`initializer_annotation_mismatch` | **Not selectable** — source-clean, emitter-blocked |
| Generic wrapper | Construction (applied record form does not parse), Rust (emits structs without type parameters; `rustc` `E0425`), TypeScript (`CODEGEN001:size_generic_argument_unsupported` fail-close) | **Not selectable** — no construction surface, invalid/inadmissible emission |

Shared blocker (all three): `Box<N>` is a nominal genus in every candidate
per the fixed contract, and **no source construction form exists for applied
generic nominals** at this base.

## 2. Candidate matrix (observed at the pin)

| Probe row | alias | direct | wrapper |
| --- | --- | --- | --- |
| Declaration and use (sizes 2/3/4, `Matrix<R,C>`, `Box<N>`) | PASS — `type Vector<size N>` / two-param `Matrix<R,C>` / `class Box<size N>` declare and apply; two-arg applications analyze in signature/return positions | PASS — builtin carriers; `Box<size N>` nominal + field access typechecks | PASS — `Vector/Matrix/Box` generic nominals declare; accessors typecheck |
| Same-file substitution | FAIL — calls/conversions red at typecheck (`SEM004/SEM010/SEM011/SEM014` on op bodies and `↦ Vector<N>` conversions) | PASS — `add/dot` over `vector<f32,N>`, inference at 2/3/4 calls, `⊗`/`·` with concrete shapes; only the generic `·` body fails (`SEM011:glyph_static_shape_required`) | PARTIAL — accessors only; construction unexpressible, so no same-file value behavior exists |
| Imported substitution (package route) | FAIL — import resolves; provider redness propagates (`SEM004` reported at provider source) | PASS at `faber check` (consumer `ok`); FAIL on the emit route (`SEM010` on imported generic-call results) | PASS at `faber check` (applied `gmt.Vector<4>`/`gmt.Matrix<4,4>`/`gmt.Box<3>` signatures analyze); emit blocked (below) |
| Static rejection (negatives) | PASS — `negative/vector-width`, `matrix-shape`, `box-width`: `SEM010:argument_type_mismatch` (+`SEM014` cascade) in Faber analysis; `negative/generic-kind`: `SEM008:generic_argument_kind_mismatch` both directions. Mismatch never reaches `rustc`/`tsc` — emission is refused for red sources | same (shared fixtures) | same (shared fixtures) |
| Construction (one posture, widths 2/3/4) | FAIL — `[..] ↦ Vector<2/3/4>`: `SEM014:cannot_infer_tensor_shape`; `Box<3> { … }` does not parse | PASS for vectors/matrices (`[..] ↦ vector<f32, N>`, `⊗`); FAIL for `Box` (no applied record form) | FAIL — `Vector<N> { lanes = … }`/`Gen<3> { … }` do not parse; bare `Gen { … }` fails instantiation (`SEM010:field_initializer_type_mismatch`) |
| Component access | FAIL with alias-typed receivers (`SEM004` on `.dot/.swizzle`) | PASS — `.dot`, `.swizzle("zyx")`, `Box` field access on builtin-typed values | PASS — field/alias accessors typecheck; no values to exercise them on |
| Operations | FAIL (`SEM004`/`SEM011`) | PASS at source; concrete-only at emission | unexpressible (construction gap) |
| Rust (emit + `rustc --edition 2021 --crate-type lib`) | FAIL — no emission (source red) | FAIL — provider: `CODEGEN001` concrete-width requirement; consumer: emit-route `SEM010` | FAIL — provider/consumer EMIT but do not compile: generic structs emit without type parameters (`pub struct Vector { pub lanes: Vec<f32> }`) while signatures reference `Vector<N>` → `rustc E0425` "cannot find type `N`" |
| TypeScript (emit + `tsc --noEmit --strict`) | FAIL — no emission (source red) | FAIL — `CODEGEN001` concrete-width requirement (ts side) | FAIL — `CODEGEN001:size_generic_argument_unsupported` (fail-close posture confirmed live) |
| Host boundary | not probed — S0-T2 row; no selection to carry it | not probed | not probed |
| Device posture | not probed — S0-T2 row | not probed | not probed |
| Clean break | PASS — no numbered spelling in any fixture; widths live in types | PASS | PASS |

Positive emitter evidence worth keeping (it is what the narrow units build
toward): concrete-width intrinsic Rust emission is shaped and self-contained
— `fn cross(a: [f32; 3], b: [f32; 3]) -> [f32; 3]` with inline math; the
wrapper consumer's applied size arguments are visible in generated Rust type
identities (`crate::gmt::Vector<4>`, `crate::gmt::Matrix<4, 4>`,
`crate::gmt::Box<3>`), and imported providers emit inline as `pub mod gmt { … }`.

## 3. Observed compiler boundaries (routed to Mind)

Each boundary below is a candidate for a narrow Radix unit. Ordered by
preference-rule impact, not size.

1. **Applied-generic nominal record construction** — `Gen<3> { lanes = … }`
   does not parse (`PARSE001:json_quoted_key` — `Ident<` routes to the
   comparison path, never the typed-constructor branch;
   `radix-parser/src/expr.rs:1695–1720`); bare `Gen { … }` parses but fails
   param instantiation (`SEM010:field_initializer_type_mismatch` family).
   Blocks `Box<N>` in all three candidates and every wrapper carrier.
   Runner probe: `gap/box-applied-construction`, `gap/box-bare-construction`.
2. **Alias value transparency** — `type X<size N> = vector<f32, N>` does not
   unify with its builtin carrier at the value level: methods
   (`SEM004:unknown_method`), glyph operators
   (`SEM011:glyph_operands_unsupported`), literal conversions
   (`SEM014:cannot_infer_tensor_shape`), builtin→alias assignment
   (`SEM010:initializer_annotation_mismatch`; runner probe
   `gap/alias-assignment-transparency` against a minimal green alias
   provider). This is the alias candidate's rejection evidence; a Radix unit
   here would re-open alias adjudication.
3. **Size-parametric intrinsic emission** — `CODEGEN001` "vector intrinsic
   requires concrete vector width" on both `hir-rust` and `hir-ts` for
   `vector<f32, N>` receivers (`fn add<size N>` bodies). Blocks the direct
   candidate's Rust/TS rows; a clean-break direct provider cannot avoid
   size-parametric intrinsics without numbered per-width spellings (banned).
4. **Generic-nominal Rust declaration emission drops type parameters** —
   structs emit unparametrized with `Vec<f32>`/`Vec<Vec<f32>>` fallback
   fields (the §3.4 parametric fallback, observed live) while emitted
   signatures still reference `Vector<N>`/`Matrix<R, C>` → invalid Rust
   (`rustc E0425`). Blocks the wrapper Rust row and `Box<N>` emission in
   every candidate.
5. **hir-ts applied-size fail-close** — `CODEGEN001:size_generic_argument_unsupported`
   (`radix-hir-ts/src/types.rs:113–124`), the known S0-R0 posture, confirmed
   live on applied size arguments in TS-bound identities. The TS row needs a
   checked TS carrier form (tuple identities or equivalent) before any
   candidate can pass TypeScript.
6. **Emit-route imported generic-call size inference** — `faber check`
   accepts `const vector<f32, 3> s ← gmt.add(a, b)` (green consumer) while
   the `radix emit` route rejects it (`SEM010:expression_type_mismatch`,
   `initializer_annotation_mismatch`, `SEM011:numeric_operands_required`
   cascade). Plausibly connected to the recorded S0-R1 residual
   ("artifact-restore path leaves `decl_param_kinds` empty"); causation is
   for the Radix unit to confirm.
7. **Generic glyph matmul** — `SEM011:glyph_static_shape_required` on
   `fn multiply<size R, size K, size C>` bodies (`a · b`); concrete shapes
   work. Matters to the §2.4 operation map regardless of representation.

## 4. Green surface at the pin (reuse inventory)

- Generic declaration kinds and ordered application, local and imported:
  `type Vector<size N>`, two-parameter `Matrix<R, C>` applications, generic
  nominal `class Box<size N>` with typed field access — all analyze through
  the real package import route (`FABER_LIBRARY_HOME` library home,
  `probevectors:vectors`).
- Kind-directed fail-close: `SEM008:generic_argument_kind_mismatch` in both
  directions (committed fixture `negative/generic-kind.fab`).
- Width/shape static rejection in Faber analysis, including through the
  import route (`SEM010:argument_type_mismatch` /
  `incompatible_tensor_index` on wrong-shape imported calls).
- Source-level dimension-neutral operations over builtin carriers with
  param widths (`vector<f32, N>` + `.added/.dot` — the norma-proven
  posture; `norma/src/vector.fab` checks green at the same pin).
- Concrete-width Rust emission: `[f32; 3]`-shaped carriers, inline
  intrinsic math, applied sizes visible in generated type identities.

## 5. Posture rows

- **Constructor posture** — vectors/matrices: the one conversion posture
  (`[…] ↦ carrier`) works on builtins only; alias targets fail
  (`SEM014`); applied generic nominals have no construction form (§3.1).
  No numbered spelling exists or is needed.
- **Component access** — `.dot`, `.swizzle`, field access on builtins and
  generic nominals typecheck; alias-typed receivers lose methods (§3.2).
- **Operation placement** — at this base, dimension-neutral free functions
  over builtin carriers are the only place source-level operations check;
  alias receivers and generic glyph matmul are blocked; wrapper receiver
  operations are unexpressible. Final placement defers to the re-run.
- **Rust/TS results** — §2 matrix; emitted-source excerpts preserved in the
  runner output and quoted in §2.
- **Host boundary / device posture** — S0-T2 rows, intentionally unprobed:
  with no selectable representation there is no selected value to convert;
  probing them now would prejudice no candidate and prove nothing the §2.2
  rows do not already bound.

## 6. Residuals and routing

- S0-T1 remains the adjudicator: after any routed Radix unit lands, re-run
  `RADIX_ROOT=… RADIX_BIN=… FABER_BIN=… ./scripta/check-generic-math-representation --matrix`
  and update this record; the selection rule then applies unchanged
  (first fully passing candidate in alias → direct → wrapper order).
- The runner's gap probes flip green exactly when their boundaries close,
  so the matrix is the re-adjudication instrument.
- `representation-decision.md` selection row: resolved as **no selection at
  radix `9a78fb080`** (stop condition), not as a deferred `TBD`.
- S0-T2 remains blocked on a committed selection; no Stage 1+ surface is
  touched by this unit.
