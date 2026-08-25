# Generic Math Types — Stage 0 Delivery Spec

**Status**: active — S0-R0 LANDED 2026-08-24 (radix ae7c5e292) and S0-R1 LANDED 2026-08-25 (radix 9a78fb080): both serial Radix prerequisites complete (see §0.1 re-baseline); **S0-T1 is next and dispatchable NOW**; S0-T2 waits on S0-T1

**Campaign**: [`CAMPAIGN.md`](CAMPAIGN.md)

**Campaign stage**: Stage 0 — parametric representation and backend probe

**Mode**: discovery-first, then one serial proof batch

**Planner**: initial lowering `planner-1`, task `6349e78e`; audit correction `planner-2`, task `b4c25788`, 2026-08-13; live-main revision `planner`, task `ad5b495f`, 2026-08-24

**Owner repo**: `triga`; one proven prerequisite unit writes `radix`

**Planning correction packet**: historical `planner-2` evidence only; dispatch uses the committed live-main bases in §3.1

**Implementation readiness**: `READY` — this is a delivery verdict, not a GO or ship approval

## 0. Language-base re-baseline (2026-08-24)

This revision re-derives the Radix-facing half against committed live main,
not against the old monolithic-crate layout. The current planning pins are
Triga `01d26888a618c4054bcdd0507d34ec78475849fb` and Radix
`6feab5a79ac047a09f443fe1ccd026c22d3ae6af`. The Triga checkout has unrelated
working-tree dirt in `proof/coverage-scorecard.json`; it is foreign evidence,
not part of this docs-only revision or the pinned baseline.

The readiness read measured 172 commits from the original Triga baseline
`05c6ccff5c0d48a0cfd02b740f8caff83578e3e4` to the then-current checkout. Live
main advanced two commits before this revision, so the current count is 174;
the document now pins `01d26888` rather than carrying the stale 172-count
snapshot. The root Triga exempla count is 15, not 13.

### Landed versus to-build

The names below are status claims about the pinned Radix main. They are not
interchangeable, and a later Hand must not treat a landed type-only or hole
path as proof of kinded size application.

| Item | Status (re-baselined 2026-08-25 at Radix `9a78fb080`; original column read the `6feab5a79` pin) | Evidence and Stage 0 consequence |
| --- | --- | --- |
| Declaration `GenericParamKind::{Typus, Magnitudo}` and `TypeParam.kind` | **LANDED** | `crates/radix-syntax/src/ast.rs:253`; parsing in `crates/radix-parser/src/decl.rs`; resolver/lowering kind handling in `crates/radix-semantic/src/{passes/resolve.rs,lower/mod.rs,lower/types.rs}`. S0-R0 consumes this metadata; it does not re-land generic declaration syntax. |
| Type-alias parameters bind their own type parameters | **LANDED** | The D0 alias-parameter fix is covered by `radix-hir-rust` alias tests. This closes the old type-parameter binding defect only. |
| Type-argument alias declaration/use emission | **LANDED for type arguments** | Radix commit `94c6b71d4`; `radix-hir-rust` and `radix-hir-ts` emit and test alias type parameters plus applied type uses. |
| Alias-declared `magnitudo` with `figura` application | **LANDED (S0-R1)** | `radix-program/src/file_interface_s0r1_test.rs` proves `typus Vector<magnitudo N> = vector<fractus<f32>, N>` snapshots params `[(N, Magnitudo)]` and applied `Vector<3>` carries `Size(Literal 3)`. |
| `GenericArgExpr` source cases | **LANDED (S0-R0)** | `crates/radix-syntax/src/ast.rs:1507` defines `GenericArgExpr`; `TypeExprKind::{Named,Qualified}` now carry `Vec<GenericArgExpr>` (ast.rs:1582–1584). |
| `AppliedArg::{Type,Size}` and size-bearing `Type::Applied` | **LANDED (S0-R0)** | `crates/radix-types/src/types.rs:1365` defines `AppliedArg`; `Type::Applied` carries `Vec<AppliedArg>`; hir-rust renders `Size` via `format_figura` (types.rs, ae7c5e292). |
| Interface declaration parameter kind/order and applied size serialization | **LANDED (S0-R1)** | `radix-semantic/src/file_interface.rs`: `InterfaceGenericParam {name, kind}`, `InterfaceAppliedArg::{Type,Size}`, `InterfaceAliasExport {name, params, body}`, ordered params on struct/nominal exports; `radix-program` extraction and the `radix-module` re-export/consumer route populate and consume them. |
| PH-0..4 applied-parameter holes | **LANDED, separate surface** | PH-0..4 landed 2026-08-19. Explicit type `_` and marker holes are already represented and handled through `Type::Infer` / `Type::MarkerHole`; they are not `AppliedArg::Size`. S0-R0 preserved this surface (marker_hole filters green at both landings). |

### What the old delivery text got wrong

- The old S0-R0 AST model was written as if `GenericArgExpr`, `AppliedArg`, and
  size-bearing `Type::Applied` already shipped. They do not.
- The live AST uses `TypeExprKind::Named(Ident, Vec<TypeExpr>)` and
  `Qualified`; built-in `Tensor`, `Sparsa`, `Vector`, and `Matrix` nodes carry
  `FiguraExpr` directly. The target model in §2.3 is therefore a bounded S0-R0
  implementation target, not a description of current code.
- The old write scopes named a removed monolithic semantic/HIR/Forma/tool
  layout. Current ownership is split across `radix-syntax`, `radix-parser`,
  `radix-semantic`, `radix-types`, `radix-program`, `radix-module`, the HIR
  backend crates, and the Faber package integration tests. The exact live
  scopes are in §4 and Appendix A.
- The old package producer path was not merely stale in content; it is absent.
  S0-R1 must repair the current `radix-program` extraction and the actual Faber
  package route rather than restore a deleted file.

### Current boundary

Landed declaration kinds and type-argument alias emission reduce the
prerequisite surface. They do not close the first unit. S0-R0 still builds
kinded named applications and their exhaustive consumers. S0-R1 then carries
those arguments through loose-file extraction, the product Faber package route,
and Rust/TypeScript emission. S0-R0 remains the first unit, and the settled
public contract remains exactly `Vector<3>`, `Matrix<4,4>`, `Box<3>`, one clean
break, and no aliases or compatibility names.

## 0.1 Post-prerequisite re-baseline (2026-08-25, planner task a8cfb7f6)

Both serial Radix prerequisites are committed on radix `main`. The planning
pin for all remaining Stage 0 work is **Radix `9a78fb080047395bec3124fe53eebcd660f6de1d`**
(S0-R1 = radix HEAD at re-baseline; S0-R0 `ae7c5e292` is an ancestor of it).
This section supersedes every pre-landing "TO BUILD"/"next" claim above and in
§3.4 items 3–6 for the landed surfaces.

**S0-R0 — landed `ae7c5e292` (2026-08-24, task c114ab4d).** Source
`GenericArgExpr::{Type,Size,Name}` in `radix-syntax/src/ast.rs:1507` with
`Named`/`Qualified` carrying `Vec<GenericArgExpr>`; checked
`AppliedArg::{Type,Size}` in `radix-types/src/types.rs:1365` with
`Type::Applied(base, Vec<AppliedArg>)`; kind-directed resolution in
`radix-semantic` (resolve.rs, lower/types.rs); exhaustive consumer adaptations
across HIR faber/fhir/go/rust/ts/swift/haskell/lean, MIR llvm/wasm/sexp,
module, program, and parser per the Appendix A census (23/85/17/33 at landing).
Emitter side, split behavior: hir-rust applied uses render `AppliedArg::Size`
through `format_figura` (`radix-hir-rust/src/types.rs`), while hir-ts
**fail-closes** on any size argument with structured diagnostic
`size_generic_argument_unsupported` (`radix-hir-ts/src/types.rs:113–124`) —
the S0-T1 TypeScript row observes this live posture per candidate rather than
assuming parity with Rust.

**S0-R1 — landed `9a78fb080` (2026-08-25, task c6190e05, the interface-schema
row narrowed per the Mind assignment).** `InterfaceGenericParam {name, kind}`
(reusing `radix_syntax::GenericParamKind`), `InterfaceAppliedArg::{Type,Size}`,
`InterfaceTypeSnapshot::Applied(Vec<InterfaceAppliedArg>)`, and
`InterfaceAliasExport {name, params, body}` behind `FileExportKind::TypeAlias`,
plus ordered params on struct/nominal exports — all in
`radix-semantic/src/file_interface.rs`, populated by
`radix-program/src/file_interface.rs` from `HirTypeParam` and re-exported
through `radix-module`. Imported declarations register decl kinds
(`radix-semantic/src/scope.rs` `register_generic_param_kinds` /
`namespace_file_decl_param_kinds`); `lower_qualified_type` kind-directs
namespace applications, and kind-mismatched applications fail closed with
`generic_argument_kind_mismatch`. Round-trip proofs:
`file_interface_preserves_generic_size` filters green and non-zero in
radix-semantic (2), radix-program (4, including `consumer_round_trip` on
`importa ex "math:vectors" math + math.Vector<3>` and
`kind_mismatch_fails_closed`), and radix-module (2). The interface-consumer
census (`FileExportKind::TypeAlias | InterfaceStructExport{ |
InterfaceNominalExport{ | InterfaceTypeSnapshot::Applied`) refreshed at
landing: **18 files, all classified, no unadmitted consumer**.

**Honest scope narrowing recorded at the S0-R1 landing (from the Hand report,
mail d19b006d).** The S0-R1 row as originally written also named two proofs
that the narrowed landing did not execute as focused tests:

1. `cargo test -p faber --lib package_interface_preserves_generic_size` —
   **no such test exists**; the landed evidence is `cargo check -p radix -p
   faber` clean plus the Hand's observation that the faber package consumer's
   interface payload matches (Struct/Function/Tuple) are unaffected by the new
   alias/size snapshot shapes.
2. Rust/TypeScript **alias size-parameter declaration emission** (e.g. Rust
   `const N: usize` on an emitted alias) beyond S0-R0's applied-use rendering —
   not separately proven by a focused `generic_size_alias` filter (none
   exists). Compounding this, hir-ts rejects applied size arguments outright
   (`size_generic_argument_unsupported`, see the S0-R0 paragraph above):
   whether a transparent alias reaches TS emission as its substituted
   built-in carrier (green) or as a size-carrying `Applied` node (fail-closed)
   is live behavior the probe must record, not prior art.

Recorded S0-R1 residuals (outside its narrowed scope):
`InterfaceCallable.type_params` carries names only (functions were not in the
{name,kind} requirement; the four type exports are); the artifact-restore path
leaves `decl_param_kinds` empty (analysis-time fact); the
`radix-module/src/program/compile.rs` AST route cannot produce `Applied`
snapshots (pre-existing shape, unchanged).

**Ruling for the remaining lowering — neither narrowing gates S0-T1.** The
S0-T1 probe is exactly the instrument that observes imported provider→consumer
substitution and emitted/compiled Rust+TypeScript output for all three
candidates equally. If alias size-parameter declaration emission or the
package-route reconstruction fails a mandatory matrix row, that is an observed
row failure recorded with command, fixture, diagnostic, and snapshot — the
delivery's existing stop/retry rules then route a narrow Radix unit back
through Mind (S0-T2 has no Radix write authority). Per the standing no-holds
ruling, no unit is gated on this fork in advance. No head-cto fork is open:
the representation preference order, the fixed contract, and the probe-as-
adjudicator are all settled.

**Refreshed live census at Radix `9a78fb080` (2026-08-25):** 25 syntax
`Named`/`Qualified` consumer files, 87 `Type::Applied` consumer files, 17
resolver-symbol files, 33 `Type::MarkerHole` consumer files. The drift from
23/85 is the landings' own new test files (e.g.
`file_interface_s0r1_test.rs`) plus concurrent foreign WIP in the radix tree;
counts remain stale-base alarms, not oracles. Appendix A stays the
classification method, not a frozen file list.

**Triga side is untouched and ready:** no `exempla/conformance/generic-math-types/`
directory and no `scripta/check-generic-math-representation` runner exist yet;
`src/math.fab` still carries the six numbered declarations. English locale
(`class`, `f32`, `@ public`) matches the fixture spellings in §1/§2.1.

## 1. Interpreted Unit

Select the smallest honest representation for Triga's suffix-free parametric
math contract before the campaign migrates public source or consumers:

```faber
Vector<3>
Matrix<4, 4>
Box<3>
```

The representation decision is ordered, not open-ended:

1. transparent aliases over compiler-owned register values;
2. direct compiler-owned register values with dimension-neutral Triga
   operations; then
3. generic nominal wrappers, only if observed behavior rules out both earlier
   candidates.

Stage 0 owns a source/import/emitter probe, the representation decision record,
the complete operation and migration maps, and the host/device boundary record.
It does not migrate `src/math.fab`, public consumers, examples, generated
outputs, or current API documentation. Those remain campaign Stages 1–4.

Two serial compiler prerequisites are grounded in committed code. Faber can
declare `type Vector<magnitudo N> = vector<f32, N>` (spelling corrected
2026-08-22; capability itself to re-verify per §0 — alias-declared `magnitudo`
parameters have no corpus coverage on live main), but named applications currently
store only type expressions/IDs, and the live interface extraction plus product
package route do not preserve declaration parameter kind/order for imported aliases
and nominals. Stage 0 therefore splits the bounded kinded applied-argument
foundation (`S0-R0`) from the package/import and Rust/TypeScript emitter behavior
that consumes it (`S0-R1`). No later Triga probe may invent either model.

## 2. Normalized Spec

### 2.1 Fixed contract

These decisions come from the campaign and are not reopened here:

- Owned public declarations named `Vector2`, `Vector3`, `Vector4`, `Matrix3`,
  `Matrix4`, and `Box3` are removed by the later migration.
- There are no aliases, adapters, deprecated exports, duplicate constructors,
  or facades preserving those six declarations.
- Shape remains compile-time information. Runtime list-length checks are not
  the primary vector or matrix representation.
- Vectors carry one size parameter. Matrices carry row and column size
  parameters. Boxes carry one vector-space size parameter.
- Generated files follow source and are never patched as an independent API.
- The selected application-lane contract must emit compilable Rust and
  TypeScript.
- Device behavior may be supported or unsupported. An unsupported route must
  reject with a structured diagnostic and must never silently substitute a
  list-backed or host-only representation.

### 2.2 Candidate selection rule

All three candidates are run through the same matrix. The decision record must
select the first candidate in preference order that passes every mandatory
row. A later candidate may not win on aesthetics or field familiarity.

| Probe row | Mandatory evidence |
| --- | --- |
| Declaration and use | The candidate expresses vectors of sizes 2, 3, and 4, matrices with two size arguments, and `Box<N>`. |
| Same-file substitution | Size parameters substitute through parameters, returns, constructors/conversions, and calls. |
| Imported substitution | A provider export and a consumer import preserve the generic parameter kinds, applied sizes, and call signature. |
| Static rejection | Vector-width, matrix-row/column, and box/vector-width mismatches are rejected before code generation with structured diagnostics. |
| Construction | Sizes 2, 3, and 4 have one dimension-neutral construction posture; no `vector2`, `vector3`, `vector4`, `matrix3_*`, or `matrix4_*` compatibility spelling is introduced. |
| Component access | Indexing, swizzle, accessors, or destructuring provides the required lanes without preserving nominal wrappers merely for `.x/.y/.z/.w`. Bounds and width behavior are explicit. |
| Operations | The required vector, matrix, and box operation map can be implemented without losing compile-time shape. |
| Rust | Provider plus consumer emit; emitted source compiles; concrete dimensions remain represented rather than collapsing to an unshaped fallback. |
| TypeScript | Provider plus consumer emit; emitted source passes strict `tsc`; applied size arguments remain visible in generated type identities or another recorded checked form. |
| Host boundary | The 32-float transform payload has an explicit selected-value-to-wire conversion and does not assume an undocumented native register layout. |
| Device posture | The selected source either emits a validated device subset or fails closed with a stable structured diagnostic. |
| Clean break | The candidate creates none of the retired declarations or numbered constructor/helper shims. |

Candidate-specific adjudication:

| Candidate | Pass rule | Rejection rule |
| --- | --- | --- |
| Transparent alias | Select when the complete matrix passes and required Triga behavior can live on compiler intrinsics or dimension-neutral free functions. | Reject only with an observed matrix failure recorded by command, fixture, diagnostic, and committed snapshot. |
| Direct native | Consider only after an observed alias failure. Select when native types pass the matrix and a Triga alias would add spelling only. | Reject when required domain behavior, import identity, emission, or host conversion cannot be expressed honestly. |
| Generic wrapper | Consider only after observed alias and direct failures. Select only when receiver/domain behavior requires nominal ownership and the wrapper stores native register values rather than list-backed shape. | Reject if its only benefit is old field/method ergonomics, numbered-name familiarity, or hiding an emitter/device gap. |

`Box<N>` is a generic Triga spatial carrier over two selected vector values. It
does not require vectors and matrices to become wrappers. Three-dimensional ray
and face behavior may constrain itself to `Box<3>`.


### 2.3 S0-R0 target model — bounded design to build, not current live representation

The following is the bounded internal target selected by this delivery. It is
not a claim that the types already exist on Radix main. S0-R0 must implement
it against the live crate owners in §4, preserving the landed declaration-kind,
type-alias-emission, and PH-0..4 behavior listed in §0.

- The source representation for named and qualified applications becomes
  ordered `GenericArgExpr` values. `GenericArgExpr` has three source-preserving
  cases: `Type(TypeExpr)`, `Size(FiguraExpr)`, and `Name(Ident)`. Natural
  literals, shape tuples, declared `magnitudo` variables, and explicit `_` in a
  size position are `Size`. A bare identifier remains `Name` until the callee's
  declaration metadata is known; it is then resolved as a type name/parameter
  or a size/index parameter. It is never encoded as a fake user type.
- The live resolver/HIR declaration identity, not the lexer `Symbol` tuple,
  exposes the ordered `GenericParamKind` list for a local declaration. Imported
  declarations receive the same metadata from the interface snapshot in S0-R1.
  Kind-directed lowering must not guess from identifier spelling.
- The checked target representation is `AppliedArg::{Type(TypeId),
  Size(IndexId)}` and `Type::Applied(TypeId, Vec<AppliedArg>)`. `AppliedArg`
  is owned by `radix-types` alongside `Type` and uses the existing syntax
  `GenericParamKind` identity. Order is preserved. Type substitution consumes
  only `Type`; index substitution consumes only `Size`. Kind/arity disagreement
  emits a structured diagnostic before HIR target emission.
- The portable interface target uses the same distinction:
  `InterfaceAppliedArg::{Type(InterfaceTypeSnapshot),
  Size(InterfaceIndexSnapshot)}`. Alias, struct, enum, and interface export
  snapshots carry an ordered list of `{name, kind}` declaration parameters.
  Alias exports carry that list and the body. The live `radix-program`
  extractor and the product Faber package route must populate and consume this
  schema; no package-local deleted producer is restored.
- HIR declaration parameters already retain `GenericParamKind`. Faber, Rust,
  TypeScript, and FHIR consumers must preserve or validate `AppliedArg` by kind.
  Other compile-relevant targets may keep their existing type-only behavior, but
  a surviving size argument must be represented or rejected explicitly; it may
  not be dropped or converted to `TypeId`.

#### Existing PH-0..4 serialization surface (landed; preserve, do not conflate)

Applied-parameter holes are a separate, already-shipped surface that the old
§0 omitted. PH-0..4 landed on 2026-08-19 with the following receipts:

| Unit | Landed behavior | Receipt |
| --- | --- | --- |
| PH-0 | EBNF/design notes define explicit type `_` and marker holes as a third hole species; no locale keyword | faber `a40a1e1`; radix `6e1b522d8` |
| PH-1 | Explicit type `_`, mixed lists such as `both<_, textus>`, exact arity, and named reject `explicit_union_type_arg_unsupported` | radix `0ba9ad19a` |
| PH-2 | `numerus<_>`, `fractus<_>`, `modulus<_>`, and `instans<_>` lower to family-preserving `Type::MarkerHole` | radix `0ba9ad19a` |
| PH-3 | Marker holes unify to an exact same-family marker; unsolved holes and family mismatches reject; no numeric widening | radix `0ba9ad19a` |
| PH-4 | Ship-marker/design closeout and type-inspection coverage; no new locale keyword or broad corpus claim | radix `6e1b522d8`; coverage `8194313b4` |

The PH invariant is explicit: call-site `_` is a type hole, marker `_` is a
family-preserving `Type::MarkerHole`, and a future `GenericArgExpr::Size` is a
compile-time index argument. These three cases must not be collapsed. The
current marker-hole serialization surface is owned by
`radix-semantic/src/passes/typecheck`, `radix-types/src/{types.rs,numeric_width.rs,instans_precision.rs}`,
`radix-program/src/mir/cli_plan.rs`, and the backend/MIR consumers listed in
Appendix A.4. S0-R0 adds the kinded application surface without weakening the
shipped PH diagnostics or turning a marker hole into an index argument.

The target model is intentionally limited to existing `FiguraExpr`/`IndexExpr`
forms: natural literals, declared size variables, tuples where the receiving
parameter admits them, and `_`. It does not add arithmetic on sizes, general
dependent values, a new keyword, or a compatibility spelling.

The committed-base census is executable and mandatory before edits:

```sh
cd "$RADIX_ROOT"
rg -l 'TypeExprKind::(Named|Qualified)' crates \
  | sort > /tmp/generic-math-syntax-consumers.txt
rg -l 'Type::Applied' crates \
  | sort > /tmp/generic-math-applied-consumers.txt
rg -l 'Symbol[[:space:]]*\{' \
  crates/radix-semantic crates/radix-program crates/radix-module \
  crates/radix-syntax crates/radix-types \
  | sort > /tmp/generic-math-symbol-constructors.txt
rg -l 'Type::MarkerHole' crates \
  | sort > /tmp/generic-math-marker-hole-consumers.txt
test "$(wc -l < /tmp/generic-math-syntax-consumers.txt)" -ge 23
test "$(wc -l < /tmp/generic-math-applied-consumers.txt)" -ge 85
test "$(wc -l < /tmp/generic-math-symbol-constructors.txt)" -ge 17
test "$(wc -l < /tmp/generic-math-marker-hole-consumers.txt)" -ge 33
```

At the revision pin the census is 23 syntax consumers, 85 `Type::Applied`
consumers, 17 live resolver-symbol files, and 33 `Type::MarkerHole` consumers.
The counts are stale-base alarms, not permission to ignore new matches. S0-R0
classifies every current match as behavior-bearing, type-only pass-through,
explicit unsupported-size rejection, PH marker-hole handling, or test fixture;
Appendix A is the allowed exhaustive scope on the inspected base.

### 2.4 Required operation map

The selected representation proof and frozen migration map must cover at least
these current behaviors. The exact new spelling is chosen by the probe, but no
row may remain `TBD` when Stage 0 closes.

| Family | Required behavior |
| --- | --- |
| `Vector<N>` | dimension-neutral construction for 2/3/4; lane access; add; subtract; scalar scale; dot; length; guarded normalization; distance; interpolation; projection |
| `Vector<3>` | cross product and every current 3D camera/face/ray use |
| `Matrix<R,C>` | dimension-neutral construction; two-axis access; compile-time shape; matrix multiplication; transpose |
| `Matrix<4,4>` | affine determinant; homogeneous point application; affine inverse; identity; translation; scale; quaternion composition; perspective; look-at/view construction |
| Retired `Matrix4.validum()` | No runtime replacement. `Matrix<4,4>` makes the 16-lane length condition a type invariant. The migration map removes each caller guard and separately preserves nullable/domain validation for operations such as perspective, look-at, and affine inverse. |
| `Box<N>` | minimum/maximum construction; validity; point containment; box containment; intersection; immutable and mutable inflate; size; center; overlap; union; translation |
| `Box<3>` | ray interval/hit and face-normal behavior currently tied to three axes |
| Host payload | model followed by view-projection, each 16 column-major `f32`; 32 floats; 128 bytes; explicit flatten/copy boundary |

The operation map must state for every row whether behavior is:

- an existing compiler intrinsic;
- a dimension-neutral Triga free function;
- a receiver operation on `Box<N>` or another surviving Triga genus; or
- a narrowly proven compiler prerequisite.

A missing operation is not permission to choose a wrapper automatically.
First prove that a free operation over the alias/native value cannot satisfy the
contract.

### 2.5 Stage 0 artifacts

Implementation produces these durable artifacts:

| Artifact | Destination | Required content |
| --- | --- | --- |
| Probe sources | `exempla/conformance/generic-math-types/**` | Equal alias/direct/wrapper provider-consumer fixtures; positive sizes; mismatch negatives; selected operations, payload, and device posture fixtures. |
| Probe runner | `scripta/check-generic-math-representation` | Deterministic candidate and selected-target checks; emitted Rust and TypeScript compilation; structured negative and device result handling. |
| Representation decision | `docs/factory/generic-math-types/representation-decision.md` | Candidate matrix, selected/rejected rationale, commands and snapshots, constructor/access posture, operation placement, Rust/TS results, host conversion, device status, and residuals. |
| Frozen migration map | `docs/factory/generic-math-types/migration-map.md` | Every retired declaration/helper/reference family mapped to its exact new spelling and owner; classified path inventory; downstream Stage 1–5 graph. |
| Campaign routing | `docs/factory/generic-math-types/CAMPAIGN.md` | Stage 0 completion evidence only after all gates pass; next stage and any proven prerequisite/residual. |

The decision and migration documents are implementation evidence. They are not
pre-filled with a preferred answer before probes run.

## 3. Repo-Aware Baseline

### 3.1 Snapshots inspected

The original lowering used stale Triga `05c6ccf` and Radix `f4e6bec7d` pins.
The readiness read measured a 172-commit Triga drift from that baseline. This
revision re-pinned the two active prerequisite bases to live main; Triga had
advanced two more commits, so the measured drift is now 174.

| Repo | Committed snapshot observed during this revision | Evidence |
| --- | --- | --- |
| `triga` planning repo | `01d26888a618c4054bcdd0507d34ec78475849fb` | `src/math.fab`, `src/math.proba`, live exempla/corpus consumers, scripts, API/module policy |
| `radix` live main | `6feab5a79ac047a09f443fe1ccd026c22d3ae6af` | split syntax/parser/semantic/types/program/module crates, interface extraction, HIR emitters, PH-0..4 consumers |
| `norma` | `df3f16f0284279796142ca3d0c96eeea027863fa` | generic vector intrinsic operations |
| `examples` | `4dedf671c85a5281ade1f13a77bfc7a3cceed96f` | hello-voxel, Budapest, Drift City, browser bridge, generated source consumers |
| `hosts` | `e76cceb6fe49c07d4e418621cc90804f0b17bd1d` | browser WebGPU payload writers/readers |
| `faberlang.dev` | `c924ae0d2c49d593ec13d7713ce93a6976934b45` | current Triga documentation consumer |

### 3.2 Triga baseline

`src/math.fab` contains six declarations in the clean-break set:

- `Vector2`, `Vector3`, and `Vector4` are nominal field carriers;
- `Matrix3` and `Matrix4` are flat `list<f32>` carriers;
- `Box3` stores two `Vector3` values.

`Vector3` owns add, subtract, scalar multiply, dot, cross, length,
normalization, distance, interpolation, and projection. `Matrix4` owns runtime
length validity, affine determinant, transpose, multiplication, point
application, and affine inverse. Free helpers construct the vector, boxes, and
4×4 transform families. `TransformPayload` already freezes the browser wire
contract as model-first then view-projection, 32 column-major floats, 128
bytes.

The owned Triga blast radius is concentrated in `src/math.fab` but includes
`src/{face,scene}.fab`, graph/camera/object, geometry bounds, lighting,
`src/math.proba`, 15 root exempla, and five corpus camera/animation files. The
migration map must classify every owned hit, including compound/helper names
such as `Box3OverlapFacts`, `RayBox3Hit`, `box3_hit`, and
`_ray_box3_hit_normal`. A raw substring count is not the closeout oracle.

Stage 0 does not edit those public paths. The candidate fixtures live below
`exempla/conformance/`, which the root exemplar inventory intentionally does
not treat as public root exempla.

### 3.3 Existing native math behavior

Norma already proves the generic operation posture:

```faber
functio addita<elem, magnitudo N>(vector<elem, N> a, vector<elem, N> b) → vector<elem, N>
functio productum<elem, magnitudo N>(vector<elem, N> a, vector<elem, N> b) → elem
functio transversum<elem>(vector<elem, 3> a, vector<elem, 3> b) → vector<elem, 3>
```

Radix's compiler-owned intrinsic catalog already includes vector add,
subtract, elementwise multiply/divide, dot, width-3 cross, length,
normalization, swizzle, and zero construction. Rust and TypeScript have vector
intrinsic lowering. Matrix semantic/Rust lowering includes elementwise
operations, matmul, matrix-vector application, and inverse support with
concrete-shape restrictions. TypeScript currently emits vectors as arrays and
matrices as `FaberMatrix<T>`; its matrix intrinsic coverage is not equivalent
to Rust. The candidate matrix must observe these differences rather than infer
parity from catalog rows.

Triga still needs dimension-neutral domain operations for scalar vector scale,
distance, interpolation, projection, homogeneous point application,
affine-specific matrix behavior, graphics constructors, and boxes. Existing
native intrinsics are reuse evidence, not a requirement to move all behavior
into the compiler.

### 3.4 Proven Radix prerequisites and missing boundary

> **Superseded 2026-08-25** for items 3–6 by §0.1: the named-application,
> `AppliedArg`, and interface-schema surfaces described below as missing are
> landed at Radix `9a78fb080`. The list is retained as the pre-landing
> grounding record; read it against §0.1, not as current fact.

At the pinned Radix main, these facts are separated explicitly:

1. `GenericParamKind::{Typus, Magnitudo}` is landed in the syntax AST, parser,
   resolver, and HIR declaration metadata. The parser accepts ordered type
   parameters followed by `magnitudo` parameters.
2. Built-in `vector<T, N>` and `matrix<T, [R,C]>` parse shape arguments through
   `FiguraExpr`; this is not evidence that a user named application such as
   `Vector<3>` carries a checked size argument.
3. Named generic applications still store only `Vec<TypeExpr>`. The parser's
   natural applied argument remains a named identifier, and a bare name is not
   kind-resolved from declaration metadata.
4. Semantic `Type::Applied` still stores `Vec<TypeId>`. The requested
   `AppliedArg::{Type,Size}` and index-bearing application are absent. A size
   must not be encoded as a fake `TypeId`.
5. `radix-semantic/src/file_interface.rs` snapshots type aliases and nominal
   exports without ordered declaration kind/order metadata, and applied
   snapshots contain type-only arguments. `radix-program/src/file_interface.rs`
   is the live extraction producer; `radix-module/src/file_interface.rs`
   re-exports the portable schema and owns module-side consumers.
6. The product Faber package route now reaches the program extractor through
   `radix::program::file_interface`, with integration fixtures in
   `crates/faber/src/package_test.rs` and package helpers under
   `crates/faber/src/package/`. The former package-local interface producer is
   absent. Repairing only semantic extraction or only loose-file tests would
   leave the product route unproved.
7. Alias type-argument emission is landed for Rust and TypeScript (commit
   `94c6b71d4`), including the applied type-argument tests. Size-parameter
   declaration/application emission and dimension-preserving size arguments
   remain to build.
8. Rust still has parametric native-shape fallback behavior, and TypeScript's
   current native carriers do not establish a checked source-static dimension.
   The candidate matrix must test these rather than infer parity from the
   landed type-alias emission.
9. PH-0..4 is landed separately: explicit type holes use the existing type-hole
   path, marker holes use `Type::MarkerHole`, and all backend/MIR consumers must
   keep their explicit handling or rejection. PH does not provide a size-arg
   representation.
10. The live census at this pin is 23 syntax `Named`/`Qualified` consumer files,
    85 `Type::Applied` consumer files, 17 resolver-symbol files, and 33
    `Type::MarkerHole` consumer files. Appendix A records the exact lists.

Therefore Stage 0 still requires S0-R0 followed by S0-R1 before the public
`Vector<3>` / `Matrix<4,4>` / `Box<3>` comparison can run honestly.

### 3.5 Landed shape-generics and PH serialization

Shape Generics Phase 4 is closed and archived at Radix commit `1eaf4ec68`.
The landed `GenericParamKind`/`HirTypeParam` machinery is a prerequisite for
S0-R0, not a replacement for it. Applied-parameter holes PH-0..4 are also
closed, with the receipts in §2.3. Neither landing carries a named size
argument through `TypeExprKind::{Named,Qualified}`, interfaces, package import,
or Rust/TypeScript applied-alias emission.

`S0-R0` starts from the committed live base in §3.1. The Hand must inspect the
assigned base and any active writer before edits, reuse landed declaration-kind
and PH behavior, and avoid treating unmerged work as baseline. The serial
boundary remains: S0-R0 owns the new application identity and exhaustive
consumers; S0-R1 owns interface/package reconstruction and target emission.

### 3.6 Consumers and host boundary

Examples has live source consumers in hello-voxel, triga-budapest,
triga-drift-city, and the browser bridge, plus generated ESM/TypeScript copies.
Those are read-only evidence in Stage 0. They migrate only after the map is
frozen.

Radix inventory is bounded to `stdlib/locale/en/pack.toml`,
`crates/faber/src/package_test.rs`, and `crates/faber/src/package/**`. The map
must distinguish direct Triga locale/package fixtures such as
`package/fhir_test.rs` from unrelated sample user types. Faberlang site
inventory is bounded to `src/en-US/**` and `dist/en-US/**`; it currently
includes authored `src/en-US/libraries/triga.md`, generated
`src/en-US/examples/triga-budapest.md`, and their rendered HTML. Examples source
migrates before `generate-examples.py` rewrites generated Markdown; all source
Markdown is final before `build-site.sh` rewrites `dist/`.

The browser path consumes a flat `Float32Array`/buffer write. Stage 0 must not
pass a compiler register matrix across that boundary based on assumed Rust,
JavaScript, WebGPU, or WGSL layout. The default proof posture is explicit
flattening into the existing `TransformPayload` wire contract. A different
wire contract is allowed only if the decision record names a version boundary
and the campaign stop condition is handled.

## 4. Ordered Unit Graph

```text
S0-R0  kinded type/size applied-argument foundation + exhaustive consumers (radix)
  LANDED ae7c5e292 (2026-08-24)
  -> S0-R1  loose-file/Faber-package import + Rust/TypeScript emitter prerequisite (radix)
     LANDED 9a78fb080 (2026-08-25, interface-schema row; see §0.1 for the honest
     narrowing on the faber package-route test and alias size-param emission)
    -> S0-T1  equal candidate probes + representation decision (triga)
       READY — DISPATCHABLE NOW (Gate 0 base check against radix 9a78fb080)
      -> S0-T2  selected operation/payload/device proof + frozen migration map (triga)
         READY — blocked only on S0-T1's committed selection
        -> campaign Stage 1 delivery lowering
```

The graph is deliberately serial. `S0-R0` fixes the shared identity model before
`S0-R1` persists or emits it. The Triga units share one representation choice,
and `S0-T2` cannot honestly map migration destinations before `S0-T1` selects
them.

### S0-R0 — kinded applied-argument foundation and exhaustive consumers

> **LANDED 2026-08-24 — radix `ae7c5e292` (task c114ab4d).** Row retained as
> the executed contract; see §0.1 for the landed-surface receipts.

| Field | Value |
| --- | --- |
| `id` | `S0-R0` |
| `outcome` | Radix adds the ordered §2.3 `GenericArgExpr` → `AppliedArg::{Type, Size}` foundation to the live split crates. Literal and declared size arguments are never fake user types. Existing type-only applications, explicit type holes, and PH marker-hole behavior remain green; every compile-relevant consumer on the assigned base either handles a size argument or rejects it explicitly. |
| `write_scope` | Repo `radix`, on the packet Mind assigns after the Gate 0 base check. Core syntax/parser/type owners: `crates/radix-syntax/src/{ast.rs,visit.rs}`; `crates/radix-parser/src/{decl.rs,types.rs,types_test.rs,mod_test.rs,generic_call_test.rs}`; `crates/radix-types/src/{index.rs,types.rs,types_test.rs,numeric_width.rs,instans_precision.rs}`. Semantic lowering/resolution/typecheck: `crates/radix-semantic/src/{scope.rs,scope_test.rs,format_type.rs,resolved_use.rs,lower/{mod.rs,decl.rs,expr.rs,types.rs},passes/{collect.rs,collect_test.rs,resolve.rs,resolve_test.rs,typecheck/{generic.rs,generic_call_test.rs,marker_hole_test.rs,infer.rs,finalize.rs,convert.rs,call.rs,aggregate.rs,ops.rs,access.rs,lookup.rs,mod.rs}}}`. Live HIR/module/program consumers: `crates/radix-hir/src/{nodes.rs,visit.rs}` only where declaration metadata requires it; `crates/radix-module/src/{file_interface.rs,forma_render.rs,hir/{visit.rs,nodes.rs},program/compile.rs}` and the exact Appendix A.2/A.4 consumer files; `crates/radix-program/src/{file_interface.rs,analyze.rs,library.rs,mir/{cli_plan.rs,link.rs}}`. Compile-preserving backend adaptations are limited to the exact current Appendix A lists. No Faber package integration, Triga, or sibling-repo edits in S0-R0. |
| `read_scope` | `radix/AGENTS.md`; live `faber/docs/EBNF.md`; all write-scope and Appendix A files; `docs/archived/shape-generics/**`; PH-0..4 receipts and tests; Triga `docs/factory/generic-math-types/{CAMPAIGN.md,delivery-stage0.md}`. Unmerged worktrees are evidence only. |
| `done_when` | (1) Named and qualified applications carry ordered source `GenericArgExpr` values; literals, tuples, declared size variables, and size holes are not fake type names, while bare names resolve from the callee's ordered declaration kinds. (2) The live resolver/HIR declaration identity exposes ordered `GenericParamKind` metadata; no spelling heuristic chooses a kind. (3) Checked applications use `Type::Applied(base, Vec<AppliedArg>)`; each `Size` carries an existing `IndexId`, and type/index substitution stay separate. (4) Local aliases and nominals accept literal sizes 2/3/4 and declared size parameters, while type/size arity or kind swaps reject with structured diagnostics. (5) The refreshed 23/85/17 census plus the 33-file PH census is classified against the assigned base; every affected crate compiles, and existing type-only/PH behavior remains green. (6) Syntax visiting/printing, semantic formatting, HIR Faber/FHIR validation, Rust/TS/backend consumers, and MIR serialization either preserve the new argument kind or reject unsupported size arguments explicitly. (7) No new keyword, locale alias, arithmetic-on-size syntax, numbered Triga name, or change to the PH hole rules is added. |
| `validation` | Re-run the §2.3 census commands and compare counts/lists with Appendix A. Focused tests: `cargo test -p radix-parser --lib generic_applied_arg`; `cargo test -p radix-types --lib generic_applied_arg`; `cargo test -p radix-semantic --lib generic_applied_arg`; `cargo test -p radix-module --lib generic_applied_arg`; `cargo test -p radix-program --lib generic_applied_arg`; `cargo test -p radix-hir-faber --lib generic_applied_arg`; `cargo test -p radix-hir-fhir --lib generic_applied_arg`; `cargo test -p radix-module --lib marker_hole`; `cargo test -p radix-semantic --lib marker_hole`. Compile census: `cargo check -p radix-syntax -p radix-parser -p radix-types -p radix-semantic -p radix-program -p radix-module -p radix-hir-faber -p radix-hir-fhir -p radix-hir-rust -p radix-hir-ts -p radix-mir`. Every filtered command must list at least one test; zero-test success is not evidence. |
| `depends_on` | none in this delivery; Gate 0 requires one committed Radix base after live Shape P4/PH overlap inspection |
| `non_goals` | File/package interface persistence; provider-package import proof; final Rust/TypeScript dimension carrier; Triga representation selection; general dependent values; size arithmetic; MIR monomorphization already owned by landed Shape P4. |
| `risk` | **high** — this changes a central application payload used by many targets and must coexist with the landed PH marker-hole enum surface. Appendix A and the affected-crate compile census are mandatory; a mechanical fix that drops `Size` or changes PH diagnostics is a correctness failure. |
| `est_work_tokens` | `70k–110k` |
| `est_basis` | `.tugboat/estimate-ledger.json` class `compiler-surface-feature`: 33 recorded units, 45–304 tool calls, median 150. The split retains the broad exhaustive consumer boundary but excludes interface/package behavior. |
| `tool_latency` | Cold crate checks dominate once. Run focused model crates first, then the single affected-crate compile census after fixes. No workspace suite and no shared `CARGO_TARGET_DIR`. |
| `parallel_children_considered` | **none** — AST/source arguments, semantic checked types, resolver metadata, and PH/exhaustive consumers are one coupled identity seam. |

**Retry/resume:** keep parser/model red fixtures first. If the bounded model
cannot express a case without general dependent values, stop with the exact
syntax or semantic boundary. Do not encode sizes as `TypeId`, weaken a consumer
to ignore them, or broaden PH marker-hole semantics.

### S0-R1 — package/import reconstruction and HIR Rust/TypeScript emission

> **LANDED 2026-08-25 — radix `9a78fb080` (task c6190e05), executed as the
> interface-schema row with the honest narrowing in §0.1.** Row retained as
> the contract of record; the two unexecuted-as-test proofs (faber
> package-route filter, alias size-parameter declaration emission) transfer to
> S0-T1's mandatory probe rows as observed evidence, not as prior art.

| Field | Value |
| --- | --- |
| `id` | `S0-R1` |
| `outcome` | A named Faber alias or nominal declaration carries ordered type/size parameters and applied arguments through same-file calls, loose-file interfaces, the live `radix-program` extractor, the product Faber package route, and compilable HIR Rust/TypeScript output without erasing concrete dimensions. |
| `write_scope` | Repo `radix`, based on committed S0-R0. Interface schema and loose-file extraction: `crates/radix-semantic/src/{file_interface.rs,file_interface_test.rs}`; `crates/radix-program/src/{file_interface.rs,file_interface_test.rs,analyze.rs,analyze_test.rs,library.rs}`; `crates/radix-module/src/{file_interface.rs,file_interface_test.rs,driver/mod.rs,program/compile.rs,program/compile_test.rs,import_resolve.rs,import_resolve_test.rs}`. Product-package integration: `crates/faber/src/package_test.rs`, `crates/faber/src/package/{binding.rs,binding_test.rs,fhir.rs,fhir_test.rs,mod.rs}` only where the live package route or its focused proof requires adaptation; the package producer is the live `radix-program` extractor, not a deleted Faber-local file. HIR declaration/emitter route: `crates/radix-hir/src/{nodes.rs,visit.rs}` only if interface-preserved parameter metadata requires a compile-preserving change; `crates/radix-hir-rust/src/{decl.rs,types.rs,module.rs,module_test.rs,decl_test.rs}`; `crates/radix-hir-ts/src/{decl.rs,types.rs,module.rs,decl_test.rs,expr_test.rs}`; `crates/radix-hir-faber/src/{decl.rs,types.rs}`; `crates/radix-hir-fhir/src/validate.rs`. The Hand refreshes `rg -l 'FileExportKind::TypeAlias|InterfaceStructExport\s*\{|InterfaceNominalExport\s*\{|InterfaceTypeSnapshot::Applied' crates` and admits only newly matched compile-relevant interface consumers. No MIR/device or sibling-repository files. |
| `read_scope` | All S0-R0 evidence and Appendix A; listed write files; `crates/faber/src/package/{compile.rs,import_graph.rs,library.rs,test_support.rs}` where present; `radix/AGENTS.md`; live `faber/docs/EBNF.md`; target vector/matrix shape helpers; Triga campaign/delivery; Norma `src/vector.fab`. |
| `done_when` | (0) The interface-consumer census is refreshed on the assigned base; all matches compile and every new match is classified before edit. (1) Fixtures declare `Vector<magnitudo N> = vector<f32,N>`, `Matrix<magnitudo R,magnitudo C> = matrix<f32,[R,C]>`, and nominal `Box<magnitudo N>` over the vector form. (2) Same-file, loose-file imported, and real Faber provider-package/consumer-package calls substitute literal sizes 2/3/4 and declared size parameters. (3) A portable interface schema carries ordered `{name, kind}` declaration metadata plus type/size applied arguments through semantic extraction, `radix-program`, `radix-module`, and the actual Faber package route. The implementation must extend the existing body-only/type-only snapshots; it must not restore a deleted package-local producer. (4) Type-for-size, size-for-type, vector-width, matrix-row/column, and box/vector-width mismatches reject in Faber source analysis with code+issue+args. (5) A non-zero focused `cargo test -p faber --lib package_interface_preserves_generic_size` proves provider-package reconstruction through the live `radix::program::file_interface` route and `crates/faber/src/package_test.rs`. (6) Rust and TypeScript declarations/applied uses preserve concrete 2/3/4 dimensions in a backend-owned checked form; emitted provider-consumer source compiles. The landed type-argument alias emission remains green, while size-parameter emission and size-argument preservation are added; Rust may not use an unshaped `Vec` fallback for a source-static alias. (7) Existing type-only aliases, package imports, built-in vector/matrix syntax, and PH-0..4 tests stay green. (8) No new keyword/locale alias or numbered Triga name enters Radix. |
| `validation` | Inner loop: `cargo test -p radix-semantic --lib file_interface_preserves_generic_size`; `cargo test -p radix-program --lib file_interface_preserves_generic_size`; `cargo test -p radix-module --lib file_interface_preserves_generic_size`; `cargo test -p faber --lib package_interface_preserves_generic_size`; `cargo test -p radix-hir-rust --lib generic_size_alias`; `cargo test -p radix-hir-ts --lib generic_size_alias`; `cargo test -p radix-hir-faber --lib generic_applied_arg`; `cargo test -p radix-hir-fhir --lib generic_applied_arg`. Unit gate: `cargo test -p radix-semantic --lib`; `cargo test -p radix-program --lib`; `cargo test -p radix-module --lib`; `cargo test -p faber --lib`; `cargo test -p radix-hir-rust --lib`; `cargo test -p radix-hir-ts --lib`; `cargo test -p radix-hir-faber --lib`; `cargo test -p radix-hir-fhir --lib`. Same-packet CLI gate: `(cd "$RADIX_ROOT" && cargo build -p radix --bin radix && cargo build -p faber --bin faber)`; `test -x "$RADIX_ROOT/target/debug/radix"`; `test -x "$RADIX_ROOT/target/debug/faber"`. Emitted fixture gate: `rustc --edition 2021 --crate-type lib /tmp/generic-math-types-rust/lib.rs`; `tsc --noEmit --strict --target ES2022 --module ES2022 /tmp/generic-math-types-ts/*.ts`. Every filtered command must list at least one test; zero-test success is not evidence. |
| `depends_on` | `S0-R0` committed; a refreshed Gate 0 overlap check before edits |
| `non_goals` | Selecting the Triga representation; editing Triga/Norma/Examples; native operation semantics; MIR/device monomorphization; general value const generics or arithmetic on sizes; compatibility syntax. |
| `risk` | **high** — semantic extraction, program extraction, module consumers, and the Faber package route are distinct producers/consumers. Passing one route does not imply the others. Rust/TS can also compile after dimension erasure, so emitted carrier assertions are mandatory. |
| `est_work_tokens` | `65k–95k` |
| `est_basis` | `compiler-surface-feature` ledger class, median 150 tool calls. The unit spans the live semantic/program/module interface layers, the Faber package route, and two HIR emitters but consumes the S0-R0 identity model. |
| `tool_latency` | Focused crate tests are seconds to tens of seconds warm; package and program tests dominate. Build each same-packet CLI once; tiny `rustc`/`tsc` fixtures are seconds. |
| `parallel_children_considered` | **none** — interface schema, importer reconstruction, package integration, and emitters must agree on one ordered argument identity. |

**Retry/resume:** preserve loose-file and package red fixtures independently.
A green loose-file route never permits skipping the product package route. If a
new consumer appears on the assigned base, add it to the census and exact scope
before implementation; do not silently widen into unrelated compiler work.

### S0-T1 — equal candidate probe and representation selection

> **READY — DISPATCHABLE NOW.** Dependency satisfied at radix `9a78fb080`
> (S0-R0 `ae7c5e292` + S0-R1 `9a78fb080` both ancestors of radix main). Gate 0
> at dispatch: record the radix base, confirm both commits are ancestors, and
> check for active writers overlapping the probe's read surfaces.

| Field | Value |
| --- | --- |
| `id` | `S0-T1` |
| `outcome` | Transparent alias, direct native, and generic-wrapper candidates are exercised through the same source/import/call/negative/emitter matrix in the campaign's fixed order. `representation-decision.md` selects exactly one with observed evidence. |
| `write_scope` | Repo `triga`, on a new implementation packet based on committed `S0-R1`: `exempla/conformance/generic-math-types/alias/{provider.fab,consumer.fab}`; `exempla/conformance/generic-math-types/direct/{provider.fab,consumer.fab}`; `exempla/conformance/generic-math-types/wrapper/{provider.fab,consumer.fab}`; `exempla/conformance/generic-math-types/negative/{vector-width.fab,matrix-shape.fab,box-width.fab,generic-kind.fab}`; `scripta/check-generic-math-representation`; `docs/factory/generic-math-types/representation-decision.md`. The runner may create only ignored temporary output under `${TMPDIR:-/tmp}/triga-generic-math-types/`. No `src/**`, root exempla, corpus, generated output, sibling repo, or campaign status edit in this unit. |
| `read_scope` | Triga `AGENTS.md`, `faber.toml`, `src/math.fab`, `src/math.proba`, `docs/{api-shape-policy,module-map}.md`, `scripta/check-{source,compile,transforms}`; this delivery and campaign; Norma `src/vector.fab`; landed S0-R0/S0-R1 surfaces at radix `9a78fb080` — `crates/radix-syntax/src/ast.rs` (`GenericArgExpr`), `crates/radix-types/src/types.rs` (`AppliedArg`), `crates/radix-semantic/src/file_interface.rs` (`InterfaceGenericParam`/`InterfaceAppliedArg`/`InterfaceAliasExport`), `crates/radix-program/src/file_interface_s0r1_test.rs` (round-trip + `generic_argument_kind_mismatch` proofs), `crates/radix-semantic/src/scope.rs` (decl-kind registration); private `crates/faber/src/package/**` + `package_test.rs` for the package-route probe row; same-packet `radix`/`faber` CLI help; Examples and Hosts payload consumers read-only. |
| `done_when` | (1) The runner executes all three candidates; it does not stop after the preferred one passes. (2) Each candidate has equivalent provider and consumer behavior for vector sizes 2/3/4, matrix row/column arguments, `Box<N>`, same-file calls, imported calls, and construction/component access. (3) The four negative fixtures reject at source typecheck with structured identity; the mismatch cannot first appear in `rustc` or `tsc`. (4) Candidate Rust and TypeScript provider-consumer output is emitted and compiled. (5) The matrix records exact command, exit/evidence, diagnostic identity for failures, emitted carrier/shape, and committed repo hashes. (6) The first fully passing candidate in alias→direct→wrapper order is selected; every earlier rejection has observed evidence. (7) A wrapper cannot win merely to retain fields or methods; if selected, the record proves native-value storage and the exact domain behavior unavailable to alias/direct. (8) No clean-break name or numbered constructor/helper is created. (9) `representation-decision.md` has no unresolved selection, constructor, component-access, or emitter row. |
| `validation` | `bash -n scripta/check-generic-math-representation`; same-packet build: `(cd "$RADIX_ROOT" && cargo build -p radix --bin radix && cargo build -p faber --bin faber)`; derive `RADIX_BIN="$RADIX_ROOT/target/debug/radix"` and `FABER_BIN="$RADIX_ROOT/target/debug/faber"`; `test -x "$RADIX_BIN" && test -x "$FABER_BIN"`; `RADIX_ROOT="$RADIX_ROOT" RADIX_BIN="$RADIX_BIN" FABER_BIN="$FABER_BIN" ./scripta/check-generic-math-representation --candidate alias`; same environment/command with `--candidate direct`, `--candidate wrapper`, then `--matrix`; `./scripta/check-source`; `git diff --check -- exempla/conformance/generic-math-types scripta/check-generic-math-representation docs/factory/generic-math-types/representation-decision.md`. The runner rejects a `RADIX_BIN` or `FABER_BIN` whose canonical path differs from the corresponding `$RADIX_ROOT/target/debug/*` path. Its Rust gate uses `rustc --edition 2021 --crate-type lib`; its TypeScript gate uses `tsc --noEmit --strict --target ES2022 --module ES2022`. |
| `depends_on` | `S0-R1` committed at radix `9a78fb080` — **satisfied**; both CLIs built from that same assigned `RADIX_ROOT` packet |
| `non_goals` | Public Triga migration; completing all math behavior; host payload code; device enablement; fixing a newly discovered compiler gap outside `S0-R1`; choosing a wrapper before alias/direct evidence; generated Examples or website output. |
| `risk` | **high** — a shallow source-only probe can select a representation that fails imports or target compilation. The equal matrix and actual emitted-source compilers are mandatory. Candidate fixtures must differ only where the representation requires it. |
| `est_work_tokens` | `45k–65k` |
| `est_basis` | `compiler-surface-feature` ledger class, median 150 tool calls. This unit is fixture/harness heavy rather than compiler-core heavy, but it spans provider import and two target compilers; estimate is below the class median implementation envelope and above the `pilot` median. |
| `tool_latency` | Three candidates × source check × two target emits/compiles; mostly seconds per tiny fixture after Radix is built. Budget cold `cargo build -p radix --bin radix`/`cargo build -p faber --bin faber` once in the packet. No product suite. |
| `parallel_children_considered` | **none** — candidates must share one harness and one adjudicator; parallel candidate implementations would drift and race the decision record. |

**Approval requirement:** no operator decision is needed when exactly one first
passing candidate follows the fixed preference rule. If two candidates appear
equivalent, select the earlier one. If all three fail a mandatory row, stop at
the campaign condition and report the smallest observed boundary; do not pick
the least-broken candidate.

**§0.1 narrowing transfer:** the two S0-R1 proofs not executed as focused
tests — the faber package-route reconstruction and alias size-parameter
declaration emission — are mandatory S0-T1 matrix rows (Imported substitution /
Rust / TypeScript). The probe records their live behavior for all three
candidates; an observed failure routes back through Mind per the retry rules,
it does not re-open S0-R1 in place.

### S0-T2 — selected operations, payload/device proof, and frozen migration map

| Field | Value |
| --- | --- |
| `id` | `S0-T2` |
| `outcome` | The selected representation proves the required `Vector<3>`, `Matrix<4,4>`, and `Box<N>` behavior shape; Rust and TypeScript source compile; host conversion and device posture are explicit; the representation decision is complete; the clean-break migration map and downstream Stage 1–5 graph are frozen. |
| `write_scope` | Repo `triga`, same serial implementation packet after `S0-T1`: `exempla/conformance/generic-math-types/selected/{operations.fab,payload.fab,device.fab}`; selected candidate files under `exempla/conformance/generic-math-types/{alias,direct,wrapper}/` only when the selected proof needs correction; `scripta/check-generic-math-representation`; `docs/factory/generic-math-types/{representation-decision.md,migration-map.md,CAMPAIGN.md}`. No `src/**`, root exempla, corpus, generated output, Examples, Hosts, Faberlang site, or Radix source. |
| `read_scope` | All `S0-T1` fixtures/evidence; Triga `src/math.fab` complete declaration/method/helper inventory; all owned Triga hit paths under `src/`, `exempla/`, and `corpus/`; Examples `hello-voxel`, `triga-budapest`, `triga-drift-city`, and `browser-app`, including source and generated `dist`; Hosts browser payload writers; Radix `stdlib/locale/en/pack.toml`, `crates/faber/src/package_test.rs`, and `crates/faber/src/package/**`; current Radix target capability/selected emitters; Faberlang site `src/en-US/**`, `dist/en-US/**`, `generator/scripts/generate-examples.py`, and `generator/scripts/build-site.sh`; campaign Stages 1–5. Vendored three.js and historical Factory records are exclusion evidence, not migration sources. |
| `done_when` | (1) `operations.fab` proves construction/lane access for sizes 2/3/4 and every §2.4 vector/matrix/box behavior, with operations located as intrinsic, free function, surviving receiver, or explicit type-invariant retirement. It records that `Matrix4.validum()` has no runtime replacement because `Matrix<4,4>` guarantees 16 lanes, and maps removal of all current caller guards while preserving separate domain-failure checks. No current public method/helper or required row is `TBD`. (2) Compile-time mismatch fixtures remain red while positive operations emit and compile on Rust and TypeScript. (3) `payload.fab` proves the selected `Matrix<4,4>` to `TransformPayload` conversion: model then view-projection, column-major, 32 `f32`, 128 bytes; native memory layout is not assumed. (4) `device.fab` either emits a validated selected subset or rejects before artifact use with code+issue+args. Host fallback, list substitution, panic, or unsupported output labeled success fails the gate. (5) `representation-decision.md` records the final target matrix, host boundary, device posture, and any later-stage residual. (6) `migration-map.md` maps every retired declaration, current public method/helper (including the type-level retirement of `Matrix4.validum()`), numbered constructor/helper, compound helper containing a retired token, direct source/test/exemplar/corpus consumer family, Examples source/generated family, bounded Radix metadata/package-fixture row, and Faberlang source/generated row to an exact spelling/removal/action and campaign owner. No compatibility destination exists. (7) The map includes the representation-specific ordered Stage 1–5 delivery graph, path scopes, Examples-source-before-site-generator ordering, site-source-before-`dist` ordering, and the bounded classified final grep oracle. Unrelated Radix sample types and historical/third-party rows are classified rather than globally renamed. (8) `CAMPAIGN.md` marks Stage 0 complete only after all evidence is committed; names Stage 1 as next only when no stop condition fired. (9) The checker detects a missing decision row, migration `TBD`, numbered compatibility spelling, payload-count/layout failure, and device overclaim. |
| `validation` | Derive the same-packet tools exactly as in `S0-T1`: `(cd "$RADIX_ROOT" && cargo build -p radix --bin radix && cargo build -p faber --bin faber)`; `RADIX_BIN="$RADIX_ROOT/target/debug/radix"`; `FABER_BIN="$RADIX_ROOT/target/debug/faber"`; `test -x "$RADIX_BIN" && test -x "$FABER_BIN"`. With `RADIX_ROOT`, `RADIX_BIN`, and `FABER_BIN` exported, run `./scripta/check-generic-math-representation --selected --operations`; same with `--selected --targets rust,ts`, `--selected --payload`, `--selected --device-posture`, then `--all`. Run the bounded scans in §7, `./scripta/check-source`, and `git diff --check -- exempla/conformance/generic-math-types scripta/check-generic-math-representation docs/factory/generic-math-types`. The runner rejects tool paths outside the assigned `RADIX_ROOT`; target compilation remains `rustc --edition 2021 --crate-type lib` and `tsc --noEmit --strict --target ES2022 --module ES2022`. No broad suite. |
| `depends_on` | `S0-T1` with one selected representation and complete candidate matrix |
| `non_goals` | Editing the public `triga:math` surface; migrating any caller; regenerating Examples/site outputs; enabling a device backend; changing the 128-byte host wire contract without campaign stop handling; closing campaign Stage 1 or later. |
| `risk` | **high** — operation ergonomics and target differences can invalidate an apparently good carrier; implicit host-layout assumptions can corrupt GPU data; a raw grep can misclassify third-party or historical names. Use explicit conversion and path-classified migration rows. |
| `est_work_tokens` | `45k–70k` |
| `est_basis` | `compiler-surface-feature` ledger class, 45–304 observed calls, median 150. This unit combines library operation proof, two source compilers, boundary evidence, and a cross-repo migration freeze; it remains below a compiler-core rewrite because public migration is excluded. |
| `tool_latency` | Selected operations and payload fixtures are seconds after toolchain build. Device source emission is seconds and must not trigger physical GPU execution. The migration inventory is bounded `rg` over named repos/paths. |
| `parallel_children_considered` | **none** — operation placement, host conversion, device claim, decision closeout, and migration destinations all depend on the same selected representation and share the decision/checker files. |

**Retry/resume:** if one operation exposes a real selected-representation defect,
return to `S0-T1` and update the candidate matrix. Do not locally wrap only that
operation or relax the operation map. If a new compiler prerequisite is proven,
stop and ask Mind to revise this delivery with a narrow Radix unit; `S0-T2` has
no Radix write authority.

## 5. Implementation Work

Mind should prepare exactly one live Hand at a time:

1. ~~a Radix Hand for `S0-R0` after the live-base and overlap check~~ —
   **landed `ae7c5e292`**;
2. ~~a Radix Hand for `S0-R1` from committed `S0-R0`, after refreshing overlap
   state~~ — **landed `9a78fb080`** (interface-schema row; §0.1 records the
   narrowing);
3. **next: a Triga Hand for `S0-T1`** with `radix` and `faber` binaries built
   from the committed radix `9a78fb080` packet — dispatchable NOW; then
4. the same or a fresh Triga Hand for `S0-T2` on the committed `S0-T1` result.

Do not dispatch three candidates as independent Hands. Do not dispatch public
Triga migration while Stage 0 is active. Each packet must record its committed
base and foreign dirt before edits.

### Workstream ownership

| Surface | Owner in Stage 0 | Ownership rule |
| --- | --- | --- |
| Kinded type/size applied-argument identity | `radix`, `S0-R0` | One foundational unit; exhaustively classify/compile all consumers while preserving landed Shape Generics and PH behavior. |
| Loose-file/package import and HIR emission | `radix`, `S0-R1` | Preserve ordered parameter kinds across semantic/program/module interface layers and the product package route; build both CLIs from this packet. |
| Candidate and selected proof sources | `triga`, `S0-T1/T2` | Non-public conformance fixtures only. |
| Candidate runner | `triga`, `S0-T1/T2` | One runner for equal tests and final gates. |
| Decision/migration/campaign records | `triga`, `S0-T1/T2` | Decision after probes; campaign completion last. |
| Public math and callers | nobody in Stage 0 | Campaign Stage 1 onward. |
| Physical WebGPU execution | nobody in Stage 0 | Record support/fail-closed only. |

## 6. Checkpoints And Gates

### Gate 0 — committed-base and serialization gate

Before `S0-R0` edits, and again before `S0-R1` edits:

- record `git rev-parse HEAD` and `git status --short --branch` in Radix;
- confirm the landed Shape Generics and PH receipts are ancestors of that HEAD;
- identify active worktrees touching any `S0-R1` file;
- wait or route through Mind when write overlap exists; and
- treat unmerged branches as read-only evidence.

A newer main that already satisfies part of `S0-R0` or `S0-R1` shrinks the
implementation. It does not remove the required tests.

### Gate 1 — kinded applied-argument foundation

`S0-R0` is complete only when the §2.3 model survives parser, Forma round-trip,
semantic type/index substitution, the refreshed exhaustive-consumer census, and
the affected-crate compile command on one committed tree. A compile fix that
drops or fakes a size argument does not pass.

### Gate 2 — package/import/emitter prerequisite

`S0-R1` is complete only when named literal/parameter sizes survive declaration,
application, loose-file import, the actual Faber provider-package import route,
substitution, mismatch diagnostics, Rust emission, and TypeScript emission on
one committed tree. Parser-only, loose-file-only, or HIR-only proof does not pass.

### Gate 3 — representation gate

`S0-T1` is complete only when all three candidates have equal evidence and one
winner follows the fixed preference rule. No winner or an all-fail matrix means
Stage 0 is blocked, not complete.

### Gate 4 — behavior and boundary gate

`S0-T2` is complete only when:

- the required operation table is total;
- source mismatch rejection remains compile-time;
- emitted Rust and TypeScript compile;
- host layout is explicit and byte-counted;
- device status is honest;
- the migration map has no `TBD` or compatibility destination; and
- the campaign points to committed evidence.

### Batching / Split Decision

**Discovery then batch.** `S0-R0` establishes the kinded argument identity.
`S0-R1` establishes the missing package/import/emitter behavior.
`S0-T1` selects one representation. `S0-T2` batches all remaining Stage 0
proof and freeze work. Split further only if a new compiler prerequisite is
observed, in which case planning returns to Mind instead of silently expanding
Triga scope.

### Release decision

**defer-release.** Stage 0 adds compiler support and conformance/planning
evidence but does not yet change Triga's public contract on an integrated
release surface. Release/version/changelog work belongs at the campaign's
post-migration checkpoint after Stages 1–4, not after this probe.

## 7. Validation Summary

### Radix prerequisite

```sh
cargo test -p radix-syntax --lib
cargo test -p radix-parser --lib
cargo test -p radix-types --lib
cargo test -p radix-semantic --lib
cargo test -p radix-program --lib
cargo test -p radix-module --lib
cargo test -p radix-hir-rust --lib
cargo test -p radix-hir-ts --lib
cargo check -p radix-syntax -p radix-parser -p radix-types \
  -p radix-semantic -p radix-program -p radix-module
```

Focused filters, package-route proofs, PH marker-hole tests, and emitted-source
compilation are specified in S0-R0/S0-R1. These are crate-scoped, not workspace
suites.

### Triga representation and boundary proof

```sh
: "${RADIX_ROOT:?set to the assigned committed Radix packet root}"
(
  cd "$RADIX_ROOT"
  cargo build -p radix --bin radix
  cargo build -p faber --bin faber
)
RADIX_BIN="$RADIX_ROOT/target/debug/radix"
FABER_BIN="$RADIX_ROOT/target/debug/faber"
test -x "$RADIX_BIN"
test -x "$FABER_BIN"

bash -n scripta/check-generic-math-representation
RADIX_ROOT="$RADIX_ROOT" RADIX_BIN="$RADIX_BIN" FABER_BIN="$FABER_BIN" \
  ./scripta/check-generic-math-representation --all
./scripta/check-source
git diff --check -- \
  exempla/conformance/generic-math-types \
  scripta/check-generic-math-representation \
  docs/factory/generic-math-types
```

The runner asserts that canonical `RADIX_BIN` and `FABER_BIN` paths equal
`$RADIX_ROOT/target/debug/{radix,faber}`. This guarantees both tools come from
the same assigned packet and default packet-local Cargo target; `FABER_ROOT` is
not an input. The runner owns temporary package assembly, `rustc`, `tsc`,
negative-result identity, and device-posture checks. Temporary outputs are never
committed.

### Final clean-break inventory

The migration document records a classified scan over only these live owned
roots:

```sh
PATTERN='Vector2|Vector3|Vector4|Matrix3|Matrix4|Box3'
: "${EXAMPLES_ROOT:?set to the pinned Examples checkout}"
: "${RADIX_ROOT:?set to the assigned Radix packet}"
: "${SITE_ROOT:?set to the pinned faberlang.dev checkout}"

rg -n "$PATTERN" src exempla corpus
rg -n "$PATTERN" \
  "$EXAMPLES_ROOT/hello-voxel" \
  "$EXAMPLES_ROOT/triga-budapest" \
  "$EXAMPLES_ROOT/triga-drift-city" \
  "$EXAMPLES_ROOT/browser-app"
rg -n "$PATTERN" \
  "$RADIX_ROOT/stdlib/locale/en/pack.toml" \
  "$RADIX_ROOT/crates/faber/src/package_test.rs" \
  "$RADIX_ROOT/crates/faber/src/package"
rg -n "$PATTERN" \
  "$SITE_ROOT/src/en-US" \
  "$SITE_ROOT/dist/en-US"
```

Stage 0 classifies and maps the hits. It does not require them to be zero yet.
The Radix result separates direct Triga metadata/package fixtures from unrelated
sample types. The site result separately records authored source, Examples-
generated Markdown, and rendered HTML. Stage 4 ordering is executable:

```sh
# Run only after the mapped Examples sources have migrated.
cd "$SITE_ROOT"
python3 generator/scripts/generate-examples.py --output-dir src/en-US/examples
# Update authored src/en-US/libraries/triga.md, then regenerate all HTML.
bash generator/scripts/build-site.sh
git diff --check -- src/en-US dist/en-US
```

Vendored three.js and historical evidence remain excluded and are never
rewritten to make a raw count green.

## 8. Companion Skill Plan

- `factory`: execute each delivery unit through implementation, validation,
  review, and path-limited commit.
- `clean-break`: audit every selected spelling and migration destination for
  numbered aliases/shims.
- `red-green`: add mismatch/import/emitter red tests before compiler repair and
  make only the intended cases green.
- `polish`: run on changed primary Rust or shell source before each unit closes;
  never use broad formatting over foreign work.
- `poker-face` or an independent auditor: re-run the candidate ordering,
  emitted-source compilers, payload count/layout, device claim, and migration
  completeness before Stage 0 status becomes complete.

## 9. Open Questions For Mind

No architecture question blocks dispatch. The candidate preference, clean
break, host-layout honesty, and unsupported-device posture are fixed.

Routing questions remain Mind-owned:

1. ~~Which committed Radix packet passes the live-base and overlap gate for
   `S0-R0`, and which refreshed packet consumes it for `S0-R1`?~~ **Answered:**
   both landed serially on radix main — `ae7c5e292` then `9a78fb080`; the
   S0-T1 packet consumes radix `9a78fb080`.
2. Does the same Triga Hand continue from `S0-T1` into `S0-T2`, or does Mind
   create a fresh serial packet after the decision commit?
3. (New, from §0.1) If the S0-T1 probe observes a mandatory-row failure caused
   by an S0-R1-narrowed surface (package route or alias size-param emission),
   Mind routes the narrow Radix follow-up unit rather than re-opening S0-R1.

Neither standing question changes unit behavior or write scope.

## 10. Stop Conditions

Stop and report `NOT READY` for the next unit if any of these occurs:

- the settled §2.3 literal/declared-size model proves insufficient and would
  require general dependent-value generics;
- all three candidates fail a mandatory matrix row;
- Rust and TypeScript need incompatible public Faber source contracts;
- shape mismatch survives until target compilation instead of Faber
  typechecking;
- an operation can be preserved only by restoring a numbered public carrier or
  a list-backed primary shape;
- selected values would cross the host boundary with an undocumented layout;
- a device path emits an artifact while silently substituting unsupported
  host/list behavior; or
- active generic-application, interface, package, or emitter work overlaps
  `S0-R0` or `S0-R1` and no serialized committed base exists.

Do not stop because later migration touches many internal callers. Do not begin
that migration from Stage 0.

## 11. Delivery Readiness

**READY for factory dispatch.**

Re-baselined 2026-08-25 after both serial Radix prerequisites landed
(`ae7c5e292`, `9a78fb080`; §0.1). **S0-T1 is dispatchable NOW** — dependency
satisfied, write surfaces absent and unclaimed (`exempla/conformance/
generic-math-types/`, `scripta/check-generic-math-representation`,
`representation-decision.md`), no open technical fork. **S0-T2 is READY and
blocked only on S0-T1's committed selection.** No product implementation has
been performed by this planning task; no Stage 1–4 surface (math.fab,
consumers, examples, docs) is touched by either remaining unit.


## Appendix A — live S0-R0 consumer scope at Radix `6feab5a79`

This appendix is an allowed scope, not a command to edit every file. The Hand
refreshes all four `rg -l` lists at unit start, classifies each match, and edits
only files that need a compile-preserving or behavior-preserving adaptation. A
new match on the assigned base is admitted only when it directly exhausts or
constructs the settled syntax, semantic argument, or PH marker-hole model;
unrelated refactors stay out of scope.

The refreshed counts are 23 syntax `Named`/`Qualified` files, 85 semantic
`Type::Applied` files, 17 resolver-symbol files, and 33 PH marker-hole files.

### A.1 Syntax `Named`/`Qualified` consumers (23)

```text
crates/radix-module/src/program/compile.rs
crates/radix-parser/src/decl.rs
crates/radix-parser/src/expr_test.rs
crates/radix-parser/src/expr.rs
crates/radix-parser/src/generic_call_test.rs
crates/radix-parser/src/lt_divert_regression_test.rs
crates/radix-parser/src/mod_test.rs
crates/radix-parser/src/schema_test.rs
crates/radix-parser/src/types_test.rs
crates/radix-parser/src/types.rs
crates/radix-semantic/src/annotation_contract.rs
crates/radix-semantic/src/cli.rs
crates/radix-semantic/src/lower/expr.rs
crates/radix-semantic/src/lower/stmt.rs
crates/radix-semantic/src/lower/types.rs
crates/radix-semantic/src/passes/collect_test.rs
crates/radix-semantic/src/passes/resolve_test.rs
crates/radix-semantic/src/passes/resolve.rs
crates/radix-semantic/src/tuple_labels.rs
crates/radix-syntax/src/braced_annotation.rs
crates/radix-syntax/src/visit.rs
crates/radix-types/src/instans_precision.rs
crates/radix-types/src/numeric_width.rs
```

### A.2 Semantic `Type::Applied` consumers (85)

```text
crates/radix-hir-faber/src/comma_law_test.rs
crates/radix-hir-faber/src/expr.rs
crates/radix-hir-faber/src/types.rs
crates/radix-hir-fhir/src/validate.rs
crates/radix-hir-go/src/expr/access.rs
crates/radix-hir-go/src/expr/call.rs
crates/radix-hir-go/src/expr/control.rs
crates/radix-hir-go/src/expr/convert.rs
crates/radix-hir-go/src/expr/ops.rs
crates/radix-hir-go/src/failable.rs
crates/radix-hir-go/src/go_needs.rs
crates/radix-hir-go/src/stmt.rs
crates/radix-hir-go/src/types.rs
crates/radix-hir-haskell/src/lower.rs
crates/radix-hir-haskell/src/types.rs
crates/radix-hir-lean/src/model_test.rs
crates/radix-hir-lean/src/model.rs
crates/radix-hir-rust/src/expr/access.rs
crates/radix-hir-rust/src/expr/call/mod.rs
crates/radix-hir-rust/src/expr/control/match_expr.rs
crates/radix-hir-rust/src/expr/mod.rs
crates/radix-hir-rust/src/expr/verte.rs
crates/radix-hir-rust/src/format_type.rs
crates/radix-hir-rust/src/import_params.rs
crates/radix-hir-rust/src/live_tuus_cursor.rs
crates/radix-hir-rust/src/method_calls.rs
crates/radix-hir-rust/src/module_test.rs
crates/radix-hir-rust/src/module.rs
crates/radix-hir-rust/src/needs.rs
crates/radix-hir-rust/src/types.rs
crates/radix-hir-swift/src/expr/access.rs
crates/radix-hir-swift/src/types_test.rs
crates/radix-hir-swift/src/types.rs
crates/radix-hir-ts/src/decl_test.rs
crates/radix-hir-ts/src/expr_test.rs
crates/radix-hir-ts/src/expr.rs
crates/radix-hir-ts/src/needs.rs
crates/radix-hir-ts/src/types.rs
crates/radix-mir-llvm/src/layout.rs
crates/radix-mir-sexp/src/capability.rs
crates/radix-mir-sexp/src/emit.rs
crates/radix-mir-wasm/src/collection.rs
crates/radix-mir-wasm/src/operand.rs
crates/radix-mir/src/device/safe.rs
crates/radix-mir/src/generic.rs
crates/radix-mir/src/layout_test.rs
crates/radix-mir/src/layout.rs
crates/radix-mir/src/validate/context.rs
crates/radix-mir/src/validate/intrinsic.rs
crates/radix-mir/src/validate/type.rs
crates/radix-module/src/codegen/rust/tests/types_test.rs
crates/radix-module/src/codegen/ts/mod_test.rs
crates/radix-module/src/live_tuus_cursor_test.rs
crates/radix-module/src/mir/fragment_instantiation.rs
crates/radix-module/src/mir/lower.rs
crates/radix-module/src/mir/lower/control.rs
crates/radix-module/src/mir/lower/place.rs
crates/radix-module/src/mir/lower/runtime.rs
crates/radix-program/src/mir/cli_plan.rs
crates/radix-program/src/mir/link.rs
crates/radix-semantic/src/builtins/frame_types.rs
crates/radix-semantic/src/coverage.rs
crates/radix-semantic/src/file_interface.rs
crates/radix-semantic/src/format_type.rs
crates/radix-semantic/src/function_facts.rs
crates/radix-semantic/src/live_tuus_cursor.rs
crates/radix-semantic/src/lower/annotation.rs
crates/radix-semantic/src/lower/types.rs
crates/radix-semantic/src/passes/exhaustive.rs
crates/radix-semantic/src/passes/fragment_definition.rs
crates/radix-semantic/src/passes/resolve.rs
crates/radix-semantic/src/passes/typecheck/access.rs
crates/radix-semantic/src/passes/typecheck/aggregate.rs
crates/radix-semantic/src/passes/typecheck/call.rs
crates/radix-semantic/src/passes/typecheck/convert.rs
crates/radix-semantic/src/passes/typecheck/finalize.rs
crates/radix-semantic/src/passes/typecheck/generic.rs
crates/radix-semantic/src/passes/typecheck/infer.rs
crates/radix-semantic/src/passes/typecheck/lookup.rs
crates/radix-semantic/src/passes/typecheck/mod.rs
crates/radix-semantic/src/passes/typecheck/ops.rs
crates/radix-semantic/src/resolved_use.rs
crates/radix-types/src/lattice_property_test.rs
crates/radix-types/src/types_test.rs
crates/radix-types/src/types.rs
```

### A.3 Resolver-symbol census (17)

These are the current live files matched by the bounded `Symbol {` census.
They are not all constructors. Constructor edits are compile-only unless the
file declares or installs generic declaration metadata; the lexer `Symbol`
tuple itself is not changed by this delivery.

```text
crates/radix-module/src/codegen/rust/mod.rs
crates/radix-program/src/mir/cli_bind.rs
crates/radix-program/src/mir/lower.rs
crates/radix-semantic/src/builtins/forma.rs
crates/radix-semantic/src/builtins/frame_types.rs
crates/radix-semantic/src/builtins/gpu.rs
crates/radix-semantic/src/builtins/mod.rs
crates/radix-semantic/src/lib.rs
crates/radix-semantic/src/lower/annotation.rs
crates/radix-semantic/src/lower/decl.rs
crates/radix-semantic/src/lower/expr.rs
crates/radix-semantic/src/lower/stmt.rs
crates/radix-semantic/src/passes/collect.rs
crates/radix-semantic/src/passes/companion_predeclare.rs
crates/radix-semantic/src/passes/resolve.rs
crates/radix-semantic/src/scope_test.rs
crates/radix-semantic/src/scope.rs
```

### A.4 PH-0..4 `Type::MarkerHole` serialization consumers (33)

This supplemental list is required because the PH landing added an exhaustive
serialization surface after the original delivery was written. It is not a
second size-argument model. Each match must preserve the shipped exact-marker,
unsolved-hole, family-mismatch, and explicit-union diagnostic behavior while
S0-R0 changes applied-argument identity.

```text
crates/radix-hir-faber/src/types.rs
crates/radix-hir-fhir/src/validate.rs
crates/radix-hir-go/src/expr/control.rs
crates/radix-hir-go/src/expr/ops.rs
crates/radix-hir-go/src/types.rs
crates/radix-hir-haskell/src/types.rs
crates/radix-hir-lean/src/model.rs
crates/radix-hir-rust/src/format_type.rs
crates/radix-hir-rust/src/import_params.rs
crates/radix-hir-rust/src/module.rs
crates/radix-hir-rust/src/types.rs
crates/radix-hir-swift/src/types.rs
crates/radix-hir-ts/src/needs.rs
crates/radix-hir-ts/src/types.rs
crates/radix-mir-sexp/src/capability.rs
crates/radix-mir-sexp/src/emit.rs
crates/radix-mir/src/device/safe.rs
crates/radix-mir/src/generic.rs
crates/radix-mir/src/layout_test.rs
crates/radix-mir/src/layout.rs
crates/radix-mir/src/validate/type.rs
crates/radix-program/src/mir/cli_plan.rs
crates/radix-semantic/src/coverage.rs
crates/radix-semantic/src/file_interface.rs
crates/radix-semantic/src/format_type.rs
crates/radix-semantic/src/passes/typecheck/finalize.rs
crates/radix-semantic/src/passes/typecheck/infer.rs
crates/radix-semantic/src/passes/typecheck/marker_hole_test.rs
crates/radix-semantic/src/resolved_use.rs
crates/radix-types/src/instans_precision.rs
crates/radix-types/src/lattice_property_test.rs
crates/radix-types/src/numeric_width.rs
crates/radix-types/src/types.rs
```

S0-R1 separately owns the interface schema and producer/consumer paths because
source and semantic exhaustiveness alone cannot prove the actual product Faber
package boundary. The live producer is `radix-program/src/file_interface.rs`;
Faber package tests consume it through `radix::program::file_interface`.
