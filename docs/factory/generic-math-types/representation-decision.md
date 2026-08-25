# Generic Math Types — Representation Decision (S0-T1 / S0-T1R)

**Status**: selected — S0-T1R closing re-adjudication EXECUTED 2026-08-25 at radix `24ec99d7e` (detached clean worktree; all eight routed gap units S0-G1…S0-G7 verified ancestors of the pin). **SELECTED: direct native types** — `vector<f32, N>` / `matrix<f32, [R, C]>` carriers with dimension-neutral Triga free operations; `Box<N>` stays a generic Triga nominal over the selected vector values. Preference rule applied: alias rejected on observed evidence; direct is the first candidate whose only red is the shared, routed, candidate-independent `ts/consumer-compile` residual (below). `S0-T2` is unblocked. Residual re-run instrument unchanged: `./scripta/check-generic-math-representation --matrix`.

**Campaign**: [`CAMPAIGN.md`](CAMPAIGN.md) · **Delivery**: [`delivery-stage0.md`](delivery-stage0.md) §4 S0-T1

## 0. Probe identity

| Fact | Value |
| --- | --- |
| Radix pin (S0-T1R, 2026-08-25) | `24ec99d7e1fe6b179cbc75bbc194bc9162e5fa4a` (radix main HEAD at re-adjudication), built as a detached clean worktree — radix main again carried foreign WIP (`crates/radix-hir-faber/**`, Faber-source emitter only; off every probe path) at probe time. Prior pin: `9a78fb080` (S0-T1, all-fail) |
| Landed gap units in the pin | S0-G1 `ea8728ffb` · S0-G2 `59e81cbc5` · S0-G3R `e736f24b2` · S0-G3T `e0687bd32` · S0-G5 `bd71dfeb6` · S0-G4 `1459eec1a` · S0-G7 `7ec4c20a9` · S0-G6 `86d00e94c` — each `git merge-base --is-ancestor`-verified against the pin |
| Radix CLI packages | `cargo build -p radix-cli --bin radix` + `cargo build -p faber --bin faber` (the delivery's `-p radix --bin radix` spelling predates the bin-package split; the repo wins) |
| Triga base | `f0b485a` + this commit; fixtures under `exempla/conformance/generic-math-types/` |
| Tools | `faber 1.8.0` / `radix` from the pin; `rustc 1.97.1`; `tsc 6.0.3` |
| Import route | real product package route: temporary library home assembled by the runner (`probevectors` package, module `vectors`), resolved through `FABER_LIBRARY_HOME` |
| Runner | `scripta/check-generic-math-representation` (`--candidate alias\|direct\|wrapper`, `--matrix`/`--all`); exits non-zero while any delivery-ideal row fails — failures are recorded evidence, not runner defects |

Every row below cites the exact command and the structured diagnostic identity
observed at the pin. Full per-row output is reproducible via the runner.

## 1. Verdict (S0-T1R closing adjudication, radix `24ec99d7e`)

**SELECTED: direct native types.** Consumers use `vector<f32, N>` and
`matrix<f32, [R, C]>` directly; Triga supplies dimension-neutral free
operations; `Box<N>` remains a generic Triga nominal genus over two selected
vector values. The preference rule (alias → direct → wrapper) applies on the
re-run matrix: alias is rejected on observed evidence, and direct is the first
candidate whose only failing row is the shared, candidate-independent,
routed `ts/consumer-compile` residual (§6 R1) — identical for wrapper, so
wrapper gains nothing and loses nothing; direct wins by order. Per the
dispatch-stop rule and S0-T1R's done_when branch (2), the selection is
recorded with the remaining red named as a routed residual carrying the next
gap's boundary.

| Candidate | Rows at `24ec99d7e` | Verdict |
| --- | --- | --- |
| Transparent alias | 5 red: `source/consumer(imported)` (`SEM001:unknown_identifier` + `SEM008:undefined_name` on uses of applied-alias-typed locals, §6 R3); `rust/provider-emit` (`CODEGEN001` glyph product `·` unsupported on the Rust target in size-parametric bodies); `ts/provider-emit` (`CODEGEN001:size_generic_argument_unsupported` on the alias *declaration* itself); both consumer emits red with propagated `SEM001`/`SEM008` | **Rejected on observed evidence** — same-file transparency landed (G2/G7: provider, all four gap probes green), but the imported applied-alias surface and alias-declaration emitters remain red |
| Direct native | 13/14 green: source provider+consumer, rust provider+consumer emit+compile, ts provider emit+compile, ts consumer emit; `ts/consumer-compile` red **TS2306 only** (§6 R1, routed; identical for wrapper) | **SELECTED** — first candidate in preference order whose sole red is the shared routed residual |
| Generic wrapper | Same 13/14 as direct (identical single red, §6 R1) | **Not needed** — direct passes first; no demonstrated receiver/domain behavior requires nominal ownership of vectors/matrices |

Selected-representation evidence worth naming (why direct is honest, not
least-broken): emitted Rust is width-preserving end to end —
`fn add<const N: usize>(a: [f32; N], b: [f32; N]) -> [f32; N]`,
`pub struct Box<const N: usize> { pub minima: [f32; N], … }`, concrete
`cross` at `[f32; 3]`, `multiply` monomorphized at the call shape
`[[f32; 2]; 3] · [[f32; 3]; 2] -> [[f32; 3]; 3]` — no `Vec<f32>` erasure
anywhere in the emitted provider. Imported substitution is green on both the
`faber check` and `radix emit` routes (S0-G6). Static rejection stays in
Faber analysis (all four negatives). Construction at 2/3/4, swizzle, dot,
cross, outer product, and same-file generic calls all check and emit.

### Prior verdict (S0-T1, radix `9a78fb080`) — superseded, kept as history

At the pre-gap base no candidate passed a mandatory row and the all-fail stop
condition fired; the seven observed boundaries routed as S0-G1…S0-G7. The
original failure identities (`SEM004`/`SEM011`/`SEM014`/`SEM010` alias
transparency; `CODEGEN001` concrete-width intrinsics; parse-gap applied
construction; `E0425` unparametrized structs; ts fail-close; emit-route
inference; `glyph_static_shape_required`) are all closed or superseded by the
landed gap units except where §6 records their surviving descendants. The
S0-T1 shared blocker — no source construction form for applied generic
nominals, blocking `Box<N>` in all three candidates — is closed by S0-G1
(`gap/box-applied-construction` and `gap/box-bare-construction` both PASS).

## 2. Candidate matrix (observed at the S0-T1R pin `24ec99d7e`)

| Probe row | alias | direct | wrapper |
| --- | --- | --- | --- |
| Declaration and use (sizes 2/3/4, `Matrix<R,C>`, `Box<N>`) | PASS — provider checks green post-G2/G7 | PASS — builtin carriers; `Box<size N>` nominal + field access typechecks | PASS — generic nominals declare; accessors typecheck |
| Same-file substitution | PASS — G2+G7 closed the op-body/conversion reds; `same_file()` checks green | PASS — `add/dot` over `vector<f32,N>` at 2/3/4, `⊗`, concrete `·`; generic `·` body green via `gap/generic-glyph-matmul` (G7) | PASS — `Gen<3> { … }`/bare `Gen { … }` construct post-G1; same-file value behavior exists |
| Imported substitution (package route) | FAIL — consumer red: uses of applied-alias-typed locals report `SEM001:unknown_identifier`/`SEM008:undefined_name` (§6 R3; distinct from the pre-G2 propagated-`SEM004` posture) | PASS — `faber check` green AND `radix emit` route green (S0-G6 closed the `SEM010` cascade) | PASS — applied `gmt.Vector<4>`/`gmt.Matrix<4,4>`/`gmt.Box<3>` signatures analyze and emit |
| Static rejection (negatives) | PASS — `SEM010:argument_type_mismatch`/`incompatible_tensor_index` (width/shape/box), `SEM008:generic_argument_kind_mismatch` (kind), all in Faber analysis; never reaches `rustc`/`tsc` | same (shared fixtures) | same (shared fixtures) |
| Construction (one posture, widths 2/3/4) | PASS at source — `[..] ↦ Vector<2/3/4>` and `Box<3> { … }` check green post-G1/G2 | PASS — `[..] ↦ vector<f32, N>`, `⊗`, `Box` applied/bare record construction | PASS — applied and bare record construction post-G1 |
| Component access | PASS — `.dot`, `.swizzle("zyx")`, field access on alias-typed receivers green post-G2 | PASS — same on builtin-typed values | PASS — accessors on constructed values |
| Operations | PASS at source (G2+G7) | PASS at source; rust emission width-preserving (`const N: usize` generics); concrete `·` emits, generic `·` body emission remains rust-red (§6 R4) | PASS at source; wrapper fixture carries accessors only |
| Rust (emit + `rustc --edition 2021 --crate-type lib`) | FAIL — provider: `CODEGEN001` "glyph product operator `·` is not supported on the Rust target" (size-parametric glyph body); consumer emit red with propagated alias diagnostics | PASS — provider emits `fn add<const N: usize>(a: [f32; N], …) -> [f32; N]`, `pub struct Box<const N: usize>`; both artifacts compile | PASS — provider/consumer emit and compile; consumer inlines `pub mod gmt { pub struct Vector<const N: usize> { pub lanes: [f32; N] } … }` |
| TypeScript (emit + `tsc --noEmit --strict`) | FAIL — provider: `CODEGEN001:size_generic_argument_unsupported` on the alias declaration itself; consumer emit red (propagated) | PASS provider (compiles standalone); consumer emits with the correct module import; **consumer compile FAIL TS2306** — routed §6 R1 | PASS provider; same single **TS2306** consumer-compile red — routed §6 R1 |
| Host boundary | not probed — S0-T2 row against the selected representation | not probed — S0-T2 | not probed — S0-T2 |
| Device posture | not probed — S0-T2 row | not probed — S0-T2 | not probed — S0-T2 |
| Clean break | PASS — no numbered spelling in any fixture; widths live in types | PASS | PASS |

TS carrier posture (recorded, from the S0-G5 landing): concrete sizes on
locally-declared nominals render tuple identities; parametric positions and
imported shapes render the bare nominal reference with type arguments
preserved (`gmt.Vector`) — the size stays a compile-time fact at the semantic
boundary, matching the width-erased `Array<T>` builtin posture. The direct
candidate's TS identities render as the builtin carriers
(`Array<number>`/`FaberMatrix<number>`); this is the recorded checked form
for the selected representation, and sharpening it (width-carrying TS
identities) is not required by §2.2's "or another recorded checked form"
clause.

Positive emitter evidence carried forward: concrete-width intrinsic Rust
emission is shaped and self-contained — `fn cross(a: [f32; 3], b: [f32; 3])
-> [f32; 3]` with inline math; applied size arguments are visible in
generated Rust type identities (`Vector<const N: usize>`,
`Matrix<const R: usize, const C: usize>`, `Box<const N: usize>`, and
`crate::gmt::Vector<4>`-style consumer references); imported providers emit
inline as `pub mod gmt { … }`.

## 3. Observed compiler boundaries — closing dispositions (S0-T1R)

> **Lowered 2026-08-25 (planner task 1c5088cd):** the seven boundaries below
> were dispatched as units `S0-G1…S0-G7` (+ closing `S0-T1R`) in
> [`delivery-stage0.md`](delivery-stage0.md) §4.1. **All seven landed before
> the closing re-adjudication; dispositions below are the S0-T1R record.**
> The pre-landing evidence text is retained per boundary as history.

1. **Applied-generic nominal record construction** — **CLOSED by S0-G1
   (`ea8728ffb`)**: `gap/box-applied-construction` and
   `gap/box-bare-construction` both PASS; applied and bare record
   construction typecheck with substituted field types. *(History:
   `Gen<3> { … }` did not parse — `Ident<` routed to the comparison path.)*
2. **Alias value transparency** — **CLOSED for same-file by S0-G2
   (`59e81cbc5`)**: `gap/alias-assignment-transparency` PASS; the alias
   provider's operation bodies, conversions, and builtin→alias assignment
   check green. The *imported* applied-alias surface remains red with a new
   identity (§6 R3) — the alias candidate's rejection now rests on that plus
   the alias-declaration emitter residuals (§6 R4/R5).
3. **Size-parametric intrinsic emission** — **CLOSED by S0-G3R
   (`e736f24b2`, rust: const generics) and S0-G3T (`e0687bd32`, ts:
   width-generic bodies over the builtin carrier)**: direct rust/ts
   provider rows emit and compile.
4. **Generic-nominal Rust declaration emission drops type parameters** —
   **CLOSED by S0-G4 (`1459eec1a`)**: emitted structs carry
   `<const N: usize>`/`<const R: usize, const C: usize>` with width-preserving
   fields; wrapper rust rows compile (no `E0425`, no `Vec<f32>` fallback).
5. **hir-ts applied-size fail-close** — **CLOSED by S0-G5 (`bd71dfeb6`)**:
   tuple identities for concrete local sizes; bare nominal reference for
   parametric/imported shapes (recorded carrier decision); the fail-close
   now fires only for genuinely unsupported forms.
6. **Emit-route imported generic-call size inference** — **CLOSED by S0-G6
   (`86d00e94c`)**: `faber check` and `radix emit` agree on imported generic
   calls; the direct rust/ts consumer-emit rows are green. G6 refuted
   `decl_param_kinds` as the cause and routed the real imported-alias
   restore defect as the queued need (§6 R2/R3).
7. **Generic glyph matmul** — **CLOSED at source by S0-G7 (`7ec4c20a9`)**:
   `gap/generic-glyph-matmul` PASS; concrete-shape behavior unchanged. The
   *rust emission* of a size-parametric glyph body remains unsupported
   (`CODEGEN001`, §6 R4) — source-green, emit-red.

## 4. Green surface at the pin (reuse inventory)

- Generic declaration kinds and ordered application, local and imported:
  `type Vector<size N>`, two-parameter `Matrix<R, C>` applications, generic
  nominal `class Box<size N>` with typed field access — all analyze through
  the real package import route (`FABER_LIBRARY_HOME` library home,
  `probevectors:vectors`).
- Applied and bare generic-nominal record construction with substituted
  field types (S0-G1).
- Same-file alias transparency: methods, glyph operators, conversions, and
  builtin→alias assignment over `type X<size N> = vector<f32, N>` (S0-G2).
- Size-parametric intrinsic/conversion bodies on rust (const generics) and
  ts (width-generic loops) (S0-G3R/G3T); applied-size TS carriers (S0-G5).
- Kind-directed fail-close: `SEM008:generic_argument_kind_mismatch` in both
  directions (committed fixture `negative/generic-kind.fab`).
- Width/shape static rejection in Faber analysis, including through the
  import route (`SEM010:argument_type_mismatch` /
  `incompatible_tensor_index` on wrong-shape imported calls).
- Source-level dimension-neutral operations over builtin carriers with
  param widths (`vector<f32, N>` + `.added/.dot` — the norma-proven
  posture; `norma/src/vector.fab` checks green at the same pin), plus
  generic glyph matmul at source (S0-G7).
- Concrete-width Rust emission: `[f32; 3]`-shaped carriers, inline
  intrinsic math, applied sizes visible in generated type identities; and
  now parametric-width Rust emission (`[f32; N]` under
  `fn add<const N: usize>`).

## 5. Posture rows (selected representation)

- **Constructor posture** — the one conversion posture (`[…] ↦ carrier`)
  works at widths 2/3/4 on the selected builtin carriers; applied and bare
  generic-nominal record construction (`Box<3> { … }`) is green. No numbered
  spelling exists or is needed.
- **Component access** — `.dot`, `.swizzle("zyx")`, indexing on builtin
  values; field access on `Box<N>`. Accessors do not require nominal
  wrappers for vectors/matrices.
- **Operation placement** — dimension-neutral free functions over
  `vector<f32, N>` / `matrix<f32, [R, C]>` (compiler intrinsics where they
  exist, Triga free functions for the domain remainder); generic glyph
  matmul checks at source. `Box<N>` keeps receiver operations as the Triga
  spatial genus. Final §2.4 table is S0-T2's deliverable.
- **Rust/TS results** — §2 matrix; emitted-source excerpts preserved in the
  runner output and quoted in §2. The one red (`ts/consumer-compile`
  TS2306) is routed (§6 R1).
- **Host boundary / device posture** — S0-T2 rows, now unblocked: they probe
  the selected `Matrix<4,4>` (= `matrix<f32, [4, 4]>`) → `TransformPayload`
  conversion and the device posture of the selected representation.

## 6. Residuals and routing (S0-T1R closing table)

| # | Residual (row / identity) | Disposition |
| --- | --- | --- |
| R1 | `direct ts/consumer-compile` and `wrapper ts/consumer-compile`: `tsc` **TS2306** "File 'probevectors-vectors.ts' is not a module" — the emitted consumer imports the library module name, but the provider's single-file TS emit produces no `export` statements. Runner staging was fixed this unit (provider now staged under `probevectors-vectors.ts`, killing the prior **TS2307** harness artifact); the remaining red is compiler-side: `TsCodegen::new_module`/`write_module_exports` (`radix-hir-ts/src/module.rs:876`, `:2199`) is unreachable from the CLI, and `OutputMode::Library` is consumed only by the Swift backend (`radix-module/src/codegen/mod.rs:419–431` — ts takes `_output_mode`). | **Routed (need filed)** — narrow Radix unit: wire module-mode export emission into the `radix emit -t ts` library route. **Non-blocking for selection**: identical for direct and wrapper, provider and consumer emit green, provider compiles standalone under `--strict`. |
| R2 | G2 imported-alias permuted-body mis-binding (filed need, queued): `ImportedFileType.decl_param_kinds` carries kinds only; `rebuild_carrier_with_size_args` fills shape slots in order, so a permuted alias body mis-binds. | **Non-blocking for S0** — no fixture exercises permutations; the alias candidate is rejected regardless. Need stays queued; owning surfaces `radix-semantic/src/scope.rs` + `passes/typecheck/infer.rs`. |
| R3 | Alias `source/consumer(imported)`: uses of applied-alias-typed locals report `SEM001:unknown_identifier` + `SEM008:undefined_name` (minimized: one `const gmt.Vector<3> a ← …` then `return a` fails on the use). New identity at this pin — not the pre-G2 propagated-`SEM004` posture, and distinct from R2's mis-binding symptom, though it lives in the same imported-alias restore family (R2's owning surfaces). | **Routed (joins R2's queued need; reported to Mind)** — moot for Stage 0 under the direct selection; no direct/wrapper row depends on imported applied aliases. |
| R4 | Alias `rust/provider-emit`: `CODEGEN001` "glyph product operator `·` is not supported on the Rust target" — rust emission of a *size-parametric* glyph body (G7 closed source only). The direct fixture's concrete `·` emits and compiles. | **Routed** — matters to S0-T2/Stage 1 only if Triga's real `Matrix<R,C>` multiply is written as a generic glyph body; the narrow surface is the rust glyph emission arm. Does not block the selected representation's current proof. |
| R5 | Alias `ts/provider-emit`: `CODEGEN001:size_generic_argument_unsupported` fires on the alias *declaration* (`type Vector<size N>`) in TS-bound identities. | **Moot under selection** — the rejected candidate's declaration form; no unit needed unless alias adjudication re-opens. |

Withdrawals per the dispatch-stop rule: all eight dispatched gap units
(S0-G1, G2, G3R, G3T, G5, G4, G7, G6) landed before the stop condition could
fire, so **no dispatched unit is withdrawn**. The one queued-but-undispatched
item — the G2-successor need for imported-alias param names (R2) — is
**withdrawn from the Stage 0 queue** by this adjudication (non-blocking;
Stage 0 no longer needs it). R1 is the single new routed need.

S0-T2 is unblocked by this selection: its dependency ("one selected
representation and complete candidate matrix") is discharged. No Stage 1+
surface is touched by this unit.

## 7. S0-T2 selected-representation proof (2026-08-25, task 96894b30)

Executed at the same selection pin `24ec99d7e1fe6b179cbc75bbc194bc9162e5fa4a`
(detached clean worktree; radix main again carried live foreign WIP in
`crates/radix-mir-metal/**` at run time — classified Class B with a live
owner, off every probe path, untouched). Fixtures:
`exempla/conformance/generic-math-types/selected/{operations,payload,device}.fab`;
runner: `./scripta/check-generic-math-representation --selected …` (five
invocations per the delivery §4 validation recipe).

**VERDICT: S0-T2 STOPPED on a proven new compiler prerequisite** per the
delivery's retry/resume clause — "if a new compiler prerequisite is proven,
stop and ask Mind to revise this delivery with a narrow Radix unit; S0-T2
has no Radix write authority." The selection itself is NOT reopened: every
gap below is carrier-independent (alias and wrapper compose over the same
intrinsics and would hit the identical walls), so the §2 retry rule
("return to S0-T1") does not apply. The migration map is NOT frozen and
Stage 0 is NOT complete; both wait for Mind's narrow Radix units and the
resumed S0-T2.

### S0-T2 operations (done_when 1-2)

`selected/operations.fab` checks green and proves every §2.4 row at its
natural width, each classified [I] intrinsic / [F] dimension-neutral free
function / [R] surviving receiver / [T] type-invariant retirement:

| §2.4 row | Placement | Proof |
| --- | --- | --- |
| Vector<N> construction 2/3/4 | [F] one conversion posture `[…] ↦ vector<f32, N>` | `lanes_2/3/4` + every construction below |
| lane access | [I]+[F] basis-dot `v.dot(e_i)` and width-preserving swizzle (repeats broadcast a lane) | `lanes_2/3/4`, `uniform_3/4` |
| add / subtract / elementwise / dot | [I] `.added/.subtract/.multiply/.dot`, parametric | `addita/subtracta/multiplicata/productum` |
| length | [F] Babylonian root on the dot product (`radix_f32`, same shape as current Triga) | `longitudo` — `.power(0.5)` is source-green but its emitted TS prelude member is not strict-green (N4) |
| guarded normalization | [I] `.normalize()` concrete; [F] guarded form at width 4 | `normata` — **parametric intrinsic is red** (N1) |
| distance | [F] `distantia` parametric over subtract+length | green |
| scalar scale / interpolation / projection | [F] elementwise multiply against a swizzle-broadcast uniform, proven at width 4 | `scala/interpolata/projecta` — **parametric forms red** (N1) |
| Vector<3> cross | [I] `.cross`, width-3-constrained in types | `transversum` |
| 3D camera/face/ray uses | [F] over concrete width-3 lane reads | `camera_directio`, `face_normal`, `axis_interval`, `capsa_intersecat_radium` |
| Matrix<R,C> two-axis access | [I] `for from m at [r, c]` cell iteration, parametric at source | `cells_summa` — emitters red (N4/N5) |
| Matrix<R,C> compile-time shape | [T] the type; negatives stay red | `negative/matrix-shape` |
| Matrix<R,C> multiplication | [I] glyph `·` parametric at source (S0-G7); method `.matmul` is NOT parametric | `multiplicata_matrix` — rust emission of the generic body is the known R4 |
| Matrix<R,C> transpose | [F] construction from read columns at [4,4] | `transposita` — no glyph/method exists (N3) |
| Matrix<4,4> domain rows | [F] basis outer-product construction `ex_columnis` + readable elements | `identitas/translatio/scala_diagonals/composita/perspectiva/conspectus/determinans_affinis/applica_punctum/inversa_affinis` |
| Retired `Matrix4.validum()` | [T] NO runtime replacement — `matrix<f32, [4, 4]>` makes 16 lanes a type invariant; caller-guard removal is a migration-map action, domain failures (perspectiva/conspectus/inversa_affinis) stay nullable and separate | fixture comment + `negative/matrix-shape` |
| Box<N> construction | [R] applied/bare generic-nominal construction (S0-G1) | `Box<3> {…}` in `capsa_*` |
| Box<N> size / translation | [R] parametric receivers | `Box.mensura/translata` |
| Box<3> validity/containment/intersection/inflate/center/overlap/union | [F] width-in-type free functions over lane reads + uniforms | `capsa_validum/continet/intersecat/inflata/centrum/superpositio/unio` — **parametric Box<N> receivers red** (N1/N2) |
| Box<3> mutable inflate | ROUTED — field stores on applied generic nominals reject, and the generic mutator needs the parametric uniform | gap-probe evidence; not proven |
| Host payload | see below | `selected/payload.fab` |

### S0-T2 rust/typescript (done_when 2)

Observed rows (verbatim in the runner output): Rust — `operations.fab`
EMIT is red on the generic glyph-matmul body (`CODEGEN001` "glyph
product operator `·` requires a concrete static shape at codegen" — the
known routed R4), so its rust compile leg is not reached; `payload.fab`
emits and its rust compile is red on the matrix cell iteration — the
emitted coordinates are out of scope (`E0425: cannot find value 'c'/'r'
in this scope`, N5; an isolated probe additionally shows the row-array
binding `E0277: cannot add '[f32; 2]' to 'f32'`). TypeScript — both
fixtures emit green; `tsc --noEmit --strict` is red on the
matrix/vector-intrinsic surface: emitted members `normalizata`
(vectors), `subtrahe` (matrices), `applica` (matrices), `potentia`
(scalars) and the `FaberMatrix[Symbol.iterator]` protocol are absent
from the emitted prelude (`TS2339`/`TS2488`, N4), and the emitted
payload artifact references an unstaged `@faber/runtime` module
(`TS2307`, a library-mode packaging boundary in R1's family). The
mismatch negatives stay red in Faber analysis while the positives emit;
these reds are recorded evidence, not fixture defects.

### S0-T2 host payload (done_when 3)

`selected/payload.fab` proves the frozen wire contract on the selected
representation under `faber run` (all asserts pass): model then
view-projection, each column-major via explicit `c * 4 + r` placement of
cells read through the typed iteration surface, 32 `f32`, 128 bytes,
accessor halves enforced. **Native memory layout is not assumed** — no
reinterpretation of the register carrier occurs; the retired lane-count
guard has no successor. The runner's `--selected --payload` row is the
executable oracle.

### S0-T2 device posture (done_when 4)

`selected/device.fab` (vector/matrix/Box subset) FAILS CLOSED on both
device targets before artifact use, with stable structured identities:
`CODEGEN001:unsupported_mir_lowering_vector_method_with_non_literal_width_before_mir_lowering`
(the Box generic in the fixture rejects first), and
`CODEGEN001:mir_wgsl_text_unsupported` / `CODEGEN001:mir_metal_text_unsupported`
for non-Box vector/matrix functions, exit ≠ 0, zero artifact bytes.
The device-supported subset at the pin is buffer-backed `@ kernel`
tensor programs (verified: a tensor kernel emits real WGSL/MSL); the
selected CPU representation does not silently substitute a list-backed or
host fallback. Posture recorded: unsupported, fail-closed, structured.

### Proven compiler prerequisite (the stop) — proposed S0-G8..G10

Observed identities, each reproduced by a committed runner gap probe
(`--selected --operations` tail) at the pin:

| # | Boundary | Observed identity | Blocks (§2.4) |
| --- | --- | --- | --- |
| N1 | parametric vector scalar algebra: no splat/broadcast, no scalar-operand elementwise multiply, `⊗` demands static shapes, `.normalize` red under `size N` | `SEM011:glyph_static_shape_required`; `SEM014:cannot_infer_tensor_shape`; `SEM010` on `.multiply(scalar)` at every width | scalar scale, interpolation, projection, guarded normalization (family-wide forms) |
| N2 | parametric vector lane access and applied-generic field substitution: no `v[i]`, iteration does not yield scalars, applied `Box<3>` field binds/stores reject | `SEM011:indexing_requires_array_or_map`; `SEM010:incompatible_tensor_index` | Box<N> predicate receivers (validity/containment/intersection/overlap/union), mutable inflate |
| N3 | matrix materialization and transpose: no `list ↦ matrix`, no `ᵀ`, no `.transpose`, `.apply` demands literal shapes | `SEM016:matrix_materialize_unsupported`; `SEM011:glyph_transpose_operands_unsupported`; `SEM011:matrix_applica_requires_literal_shape` | dimension-neutral matrix construction, transpose, parametric matvec |
| N4 | TS emitted prelude member coverage: `normalizata`, `subtrahe`, `applica`, `potentia`, `FaberMatrix[Symbol.iterator]` missing; emitted payload imports unstaged `@faber/runtime` | `TS2339`, `TS2488`, `TS2307` under `tsc --strict` | normalization, matrix subtract/apply, two-axis access, power-based length, payload artifact on TypeScript |
| N5 | Rust emission of `for from m at [r, c]`: coordinates out of scope at the placement store; isolated probe binds the row array instead of the cell scalar | `E0425` (`c`/`r`), `E0277` under `rustc` | two-axis access / payload flatten on Rust |
| N6 | MIR runner: `vector ↦ list<f32>` fails at execution ("valor to lista conversion failed") despite check-green | runner error | list-flatten routes in interpreted proofs |

Suggested narrow Radix units for Mind (delivery revision): **S0-G8**
parametric vector splat-or-scalar-multiply + parametric normalize +
parametric lane access (N1/N2); **S0-G9** matrix materialization +
transpose + literal-shape relaxation for `.apply` (N3); **S0-G10**
emitter/runner repair — TS prelude members, rust apud-matrix cell
binding, runner vector→list (N4/N5/N6). After they land, S0-T2 resumes:
re-run the five `--selected` invocations, freeze `migration-map.md`, and
advance the campaign.

### What is NOT stopped

The selection, the payload contract proof, the device posture, the
negatives posture, and the §2.4 classifications above all stand as
recorded. Only the migration freeze and the Stage 0 completion claim
wait on the routed units.

### §7 bounded clean-break scans (pre-freeze inventory, 2026-08-25)

Executed per delivery §7 at the pin (counts are per-file hit counts;
classification is the resumed unit's migration-map input):

- **triga** `src exempla corpus`: 28 files — `src/math.fab` 112,
  `src/math.proba` 78, scene/graph/face/lighting/geometry consumers,
  corpus webgl programs, `exempla/triga-*` probes. The two
  `selected/*.fab` hits are comment rows documenting the
  `Matrix4.validum()` retirement (classification: retirement record, not
  usage).
- **examples** (hello-voxel, triga-budapest, triga-drift-city,
  browser-app): 19 files across source and tests; browser-app clean.
- **radix** bounded (`stdlib/locale/en/pack.toml`,
  `crates/faber/src/package_test.rs`, `crates/faber/src/package/**`):
  `pack.toml` clean; 6 test/emitter files carry sample-type uses
  (`ts_emit.rs`/`ts_rewrite.rs` naming + 4 test fixtures) — the direct
  Triga-metadata-vs-unrelated-sample split the campaign requires.
- **faberlang.dev** (`src/en-US`, `dist/en-US`): authored
  `libraries/triga.md` 8 + generated `examples/triga-budapest.md` 1 +
  rendered HTML 9 — the Stage 4 Examples-source-before-generator,
  source-before-`dist` ordering applies.

Stage 0 classifies and maps these; it does not require them to be zero.
The frozen map with per-row destinations is the resumed S0-T2's
deliverable after the narrow Radix units land.
