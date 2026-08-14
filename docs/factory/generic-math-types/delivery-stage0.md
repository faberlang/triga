# Generic Math Types — Stage 0 Delivery Spec

**Status**: delivery-corrected — implementation not started; READY for factory dispatch after the serial committed-base gates below

**Campaign**: [`CAMPAIGN.md`](CAMPAIGN.md)

**Campaign stage**: Stage 0 — parametric representation and backend probe

**Mode**: discovery-first, then one serial proof batch

**Planner**: initial lowering `planner-1`, task `6349e78e`; audit correction `planner-2`, task `b4c25788`, 2026-08-13

**Owner repo**: `triga`; one proven prerequisite unit writes `radix`

**Planning correction packet**: `worktrees/planner-2/triga` on `factory/planner-2-generic-math-stage0`

**Implementation readiness**: `READY` — this is a delivery verdict, not a GO or ship approval

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
declare `type Vector<size N> = vector<f32, N>`, but named applications currently
store only type expressions/IDs, and both the loose-file and Faber product
package-interface producers erase declaration parameter kind/order for imported
aliases and nominals. Stage 0 therefore splits the bounded kinded applied-argument
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


### 2.3 Settled bounded applied-argument model

`S0-R0` does not ask its Hand to invent how a named application carries a
mixture of type and size arguments. The delivery selects this bounded model:

- Syntax replaces the second field of `TypeExprKind::{Named, Qualified}` with
  ordered `GenericArgExpr` values.
- `GenericArgExpr` has three source-preserving cases: `Type(TypeExpr)`,
  `Size(FiguraExpr)`, and `Name(Ident)`. Natural literals, shape tuples, and
  explicit shape holes parse as `Size`. A bare identifier stays `Name` until
  the declaration's ordered generic parameter kinds are known; it is then
  resolved as a type name/parameter or a size/index parameter. It is never
  encoded as a fake user type.
- The resolver stores every local type declaration's ordered
  `Vec<GenericParamKind>` beside its `Symbol`. Imported declarations receive
  the same metadata from the interface snapshot in `S0-R1`. A namespace lookup
  therefore returns both the base type and parameter kinds; kind-directed
  lowering never guesses from identifier spelling.
- The checked model is `AppliedArg::{Type(TypeId), Size(IndexId)}` and
  `Type::Applied(TypeId, Vec<AppliedArg>)`. `AppliedArg` is owned by
  `radix-types`; its kind tag uses `radix_syntax::GenericParamKind`, which is an
  existing `radix-types -> radix-syntax` dependency. Order is preserved. Type
  substitution consumes only `Type`; index substitution consumes only `Size`.
  Kind/arity disagreement emits a structured diagnostic before HIR target
  emission.
- The portable interface model uses the same distinction:
  `InterfaceAppliedArg::{Type(InterfaceTypeSnapshot),
  Size(InterfaceIndexSnapshot)}`. Alias and nominal export snapshots carry an
  ordered list of `{name, kind}` declaration parameters. Alias exports carry
  both that list and the body; struct/`Box<size N>` exports carry the list with
  their fields and methods.
- HIR declaration parameters already retain `GenericParamKind`. Faber, Rust,
  TypeScript, and FHIR consumers must preserve or validate `AppliedArg` by
  kind. Other compile-relevant targets may keep their existing behavior for
  type-only applications, but a surviving size argument must be represented or
  rejected explicitly; it may not be dropped or converted to `TypeId`.

The model is intentionally limited to existing `FiguraExpr`/`IndexExpr` forms:
natural literals, declared size variables, tuples where the receiving parameter
admits them, and `_`. It does not add arithmetic on sizes, general dependent
values, a new keyword, or a compatibility spelling.

The committed-base census is executable and mandatory before edits:

```sh
cd "$RADIX_ROOT"
rg -l 'TypeExprKind::(Named|Qualified)' EBNF.md crates \
  | sort > /tmp/generic-math-syntax-consumers.txt
rg -l 'Type::Applied' crates \
  | sort > /tmp/generic-math-applied-consumers.txt
rg -l 'Symbol[[:space:]]*\{' crates/radix/src \
  | sort > /tmp/generic-math-symbol-constructors.txt
test "$(wc -l < /tmp/generic-math-syntax-consumers.txt)" -ge 22
test "$(wc -l < /tmp/generic-math-applied-consumers.txt)" -ge 73
test "$(wc -l < /tmp/generic-math-symbol-constructors.txt)" -ge 11
```

The counts are a stale-base alarm from Radix `2a986d40`; they are not a license
to ignore new matches. `S0-R0` must classify every current match as
behavior-bearing, type-only pass-through, explicit unsupported-size rejection,
or test fixture, and commit that census in its unit evidence. Appendix A is the
allowed exhaustive-consumer scope on the inspected base.

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

The campaign was authored against Triga `05c6ccf` and Radix `f4e6bec7d`. This
lowering rechecked the named repositories read-only. Concurrent integration can
move sibling `main`, so Hands must record their actual committed bases again at
unit start.

| Repo | Committed snapshot observed during lowering | Evidence |
| --- | --- | --- |
| `triga` planning packet | `05c6ccff5c0d48a0cfd02b740f8caff83578e3e4` | `src/math.fab`, `src/math.proba`, direct source/exempla/corpus consumers, scripts, API/module policy |
| `radix` live main | `2a986d40a1d96e47858180c25e97c47cbc5f1a95` during correction inspection | grammar/AST, `Applied` consumers, loose-file interfaces, private `crates/faber` package-interface producer/tests and CLI, Rust/TS/Faber/FHIR consumers, shape-generics P4 refs |
| `norma` | `2d710c2c8142f32f46e70a17a60c810ad1b3be3b` | `src/vector.fab` generic intrinsic operations |
| `examples` | `d04062f27c024a57b633deb194f1d1bfb3915bce` | hello-voxel, Budapest, Drift City, browser bridge, generated source consumers |
| `hosts` | `57d659d604309c11b6046a514317c22dd6b468f1` | browser WebGPU payload writers/readers |
| `faberlang.dev` | `60552196c5201dcd06257baca13e022a5c034ea7` | current Triga documentation consumer |

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
`src/math.proba`, 13 root exempla, and five corpus camera/animation files. The
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

### 3.4 Proven Radix prerequisites

Two serial prerequisites are proven from committed code. They are not speculative:

1. The parser accepts `size`/`magnitudo` parameters on declarations.
2. Built-in `vector<T, N>` and `matrix<T, [R,C]>` parse shape arguments through
   `FiguraExpr`.
3. Named generic applications store only `Vec<TypeExpr>`. A literal such as
   the `3` in `Vector<3>` is not a type expression, while a bare `N` is
   ambiguous until the declaration parameter kind is known.
4. Semantic `Type::Applied` stores only `Vec<TypeId>`, and alias normalization
   substitutes only type-parameter identities. The settled §2.3 kinded model
   is required; sizes may not be encoded as fake `TypeId` values.
5. `FileExportKind::TypeAlias` snapshots only the body. `InterfaceStructExport`
   also omits declaration generic parameters. Both lose parameter order/kind
   before an importer installs the declaration.
6. The Faber product package producer at
   `crates/faber/src/package/file_interface.rs` independently builds those
   incomplete snapshots. Repairing only `radix/src/file_interface.rs` would
   leave the package route used by `S0-T1` broken.
7. Rust and TypeScript alias declaration helpers intentionally emit only
   `HirTypeParam::typus_params`; size parameters are omitted.
8. Rust falls back to `Vec<T>`/`Vec<Vec<T>>` for parametric native shapes, while
   TypeScript's current native carriers do not retain a checked dimension in
   the carrier type.
9. Radix `2a986d40` has 22 syntax `Named`/`Qualified` consumer files and 73
   direct `Type::Applied` consumer files. At minimum these include
   `radix-syntax/src/visit.rs`, both Forma emitters,
   `radix-hir-faber/src/types.rs`, and `radix-hir-fhir/src/validate.rs`; an
   arity change without the Appendix A census cannot compile honestly.

Therefore Stage 0 cannot honestly run the public `Vector<3>` / `Matrix<4,4>` /
`Box<3>` comparison without `S0-R0` followed by `S0-R1`.

### 3.5 Shape-generics P4 serialization

Radix Shape Generics Phase 4 is a related but distinct line. Live main observed
during lowering contained the Phase-4A MIR `ShapeSize` substitution commits
`0d9f50ab0` and `beed90b1f`. Other Shape P4 branch/worktree commits were not
assumed landed.

`S0-R0` begins only after Mind assigns one committed Radix base. The Hand must:

- inspect the live committed main and all landed Shape P4 files;
- reuse landed generic-size machinery;
- avoid replaying an unmerged branch as though it were baseline; and
- serialize `S0-R0` and `S0-R1` with any active writer touching the same
  generic/application/import, package-interface, or emitter files.

Shape P4's MIR monomorphization does not by itself satisfy named source alias,
provider-import, or HIR Rust/TypeScript emission proofs.

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
  -> S0-R1  loose-file/Faber-package import + Rust/TypeScript emitter prerequisite (radix)
    -> S0-T1  equal candidate probes + representation decision (triga)
      -> S0-T2  selected operation/payload/device proof + frozen migration map (triga)
        -> campaign Stage 1 delivery lowering
```

The graph is deliberately serial. `S0-R0` fixes the shared identity model before
`S0-R1` persists or emits it. The Triga units share one representation choice,
and `S0-T2` cannot honestly map migration destinations before `S0-T1` selects
them.

### S0-R0 — kinded applied-argument foundation and exhaustive consumers

| Field | Value |
| --- | --- |
| `id` | `S0-R0` |
| `outcome` | Radix represents every named generic application as the ordered §2.3 `AppliedArg::{Type, Size}` model from source AST through checked semantic types. Literal and declared size arguments are never fake user types. Existing type-only applications preserve behavior, and every compile-relevant consumer on the assigned base either handles size arguments or rejects them explicitly. |
| `write_scope` | Repo `radix`, on the packet Mind assigns after the Shape P4 serialization check. Core model files: `crates/radix-syntax/src/{ast.rs,visit.rs}`; `crates/radix-parser/src/{types.rs,types_test.rs,mod_test.rs}`; `crates/radix-types/src/{index.rs,types.rs,types_test.rs}`; `crates/radix/src/forma/{pretty,author}/emit.rs`; `crates/radix/src/hir/lower/{types.rs,mod_test.rs}`; `crates/radix/src/semantic/{scope.rs,scope_test.rs,format_type.rs,resolved_use.rs}`; `crates/radix/src/semantic/passes/{collect.rs,collect_test.rs,resolve.rs,resolve_test.rs}`; `crates/radix/src/semantic/passes/typecheck/{generic.rs,generic_call_test.rs,infer.rs,finalize.rs,convert.rs,call.rs,aggregate.rs,ops.rs,access.rs,lookup.rs,mod.rs}`. Compile-preserving exhaustive-consumer edits are allowed only in the exact Appendix A files matched on the assigned base. Because `Symbol` gains declaration parameter kinds, compile-only constructor updates are also allowed in the Appendix A.3 `Symbol` constructor files; they must initialize an empty vector unless they construct a declared generic type. New focused tests may be added beside these modules with names beginning `generic_applied_arg`. No file-interface producer, package import behavior, target size emission, Triga, or sibling-repo edits. |
| `read_scope` | `radix/AGENTS.md`; `EBNF.md`; all write-scope and Appendix A files; `docs/factory/shape-generics/**`; Shape P4 commits reachable from the assigned base; Triga `docs/factory/generic-math-types/{CAMPAIGN.md,delivery-stage0.md}`. Unmerged worktrees are evidence only. |
| `done_when` | (1) `TypeExprKind::{Named,Qualified}` use ordered `GenericArgExpr`; literals/tuples/holes are `Size`, complex type syntax is `Type`, and bare names resolve by the callee declaration's ordered parameter kind. (2) Local declaration `Symbol` metadata records ordered `GenericParamKind` values and named/qualified lookup exposes those kinds to lowering; no spelling heuristic chooses a kind. (3) Checked applications use `Type::Applied(base, Vec<AppliedArg>)`; each `Size` carries an existing `IndexId`. (4) Local aliases and nominals accept literal sizes 2/3/4 and declared size parameters, while type/size arity or kind swaps reject with code+issue+args. (5) Type substitution and index substitution are separate and preserve vector width, both matrix dimensions, and `Box<N>` width. (6) The Appendix A census is refreshed against the assigned base; every match is classified and every affected crate compiles. Type-only generic behavior remains green. (7) `radix-syntax/src/visit.rs`, both Forma emitters, `radix-hir-faber/src/types.rs`, and `radix-hir-fhir/src/validate.rs` explicitly visit/print/validate the new argument kind. Faber source round-trip preserves `Vector<3>` and `Matrix<R,C>`. (8) Non-Rust/TS consumers may preserve type-only behavior, but a surviving size argument is handled or rejected explicitly and is never silently discarded. (9) No new keyword, locale alias, arithmetic-on-size syntax, or numbered Triga name is added. |
| `validation` | Census commands from §2.3. Focused red/green: `cargo test -p radix-parser --lib generic_applied_arg`; `cargo test -p radix-types --lib generic_applied_arg`; `cargo test -p radix --lib generic_applied_arg`; `cargo test -p radix-hir-faber --lib generic_applied_arg`; `cargo test -p radix-hir-fhir --lib generic_applied_arg`. Existing gates: `cargo test -p radix-parser --lib`; `cargo test -p radix-types --lib`; `cargo test -p radix --lib`; `cargo test -p radix-hir-faber --lib`; `cargo test -p radix-hir-fhir --lib`. Compile census: `cargo check -p faber -p radix -p radix-syntax -p radix-parser -p radix-types -p radix-hir-faber -p radix-hir-fhir -p radix-hir-go -p radix-hir-lean -p radix-hir-rust -p radix-hir-swift -p radix-hir-ts -p radix-mir -p radix-mir-llvm -p radix-mir-sexp -p radix-mir-wasm`. Every filtered command must list at least one test; zero-test success is not evidence. |
| `depends_on` | none in this delivery; Gate 0 requires one committed Radix base after live Shape P4/worktree inspection |
| `non_goals` | File/package interface persistence; provider-package import proof; final Rust/TypeScript dimension carrier; Triga representation selection; general dependent values; size arithmetic; MIR monomorphization already owned by Shape P4. |
| `risk` | **high** — this changes a central enum payload used by many targets. Appendix A and the full affected-crate `cargo check` are mandatory. A mechanical compile fix that drops `Size` is a correctness failure. |
| `est_work_tokens` | `70k–110k` |
| `est_basis` | `.tugboat/estimate-ledger.json` class `compiler-surface-feature`: 33 recorded units, 45–304 tool calls, median 150. The explicit split removes package/emitter behavior but retains a broad exhaustive compile boundary. |
| `tool_latency` | Cold crate checks dominate once. Run focused model crates first, then the single affected-crate compile census after fixes. No workspace suite and no shared `CARGO_TARGET_DIR`. |
| `parallel_children_considered` | **none** — the AST and semantic enum shape is one coupled identity seam; independent edits would race exhaustive match consumers. |

**Retry/resume:** keep parser/model red fixtures first. If the bounded model
cannot express a case without general dependent values, stop with the exact
syntax or semantic boundary. Do not encode sizes as `TypeId` or weaken an
exhaustive consumer to ignore them.

### S0-R1 — package/import reconstruction and HIR Rust/TypeScript emission

| Field | Value |
| --- | --- |
| `id` | `S0-R1` |
| `outcome` | A named Faber alias or nominal declaration carries ordered type/size parameters and applied arguments through same-file calls, loose-file interfaces, the product Faber package-interface producer/importer, and compilable HIR Rust/TypeScript output without erasing concrete dimensions. |
| `write_scope` | Repo `radix`, based on committed `S0-R0`. Interface model and loose-file route: `crates/radix/src/{file_interface.rs,file_interface_test.rs}`; `crates/radix/src/semantic/{scope.rs,scope_test.rs,annotation_contract_test.rs}`; `crates/radix/src/semantic/passes/{resolve_test.rs,typecheck/generic_call_test.rs,typecheck/union_construction_test.rs,typecheck/union_pattern_test.rs,typecheck/union_value_test.rs}`; `crates/radix/src/tool/commands/{compile.rs,compile_test.rs}`; compile-only interface constructor adaptation in `crates/radix/examples/flib_preview.rs`. Product package producer/tests: `crates/faber/src/package/file_interface.rs`; `crates/faber/src/package_test.rs`; `crates/faber/src/package/mir/cli_plan.rs`; an adjacent `crates/faber/src/package/file_interface_test.rs` may be added and wired only through `crates/faber/src/package/mod.rs`. HIR declaration/emitter route: `crates/radix-hir/src/{nodes.rs,visit.rs}` only if interface-preserved parameter metadata requires a compile-preserving change; `crates/radix/src/hir/lower/{decl.rs,types.rs,mod_test.rs}`; `crates/radix-hir-rust/src/{decl.rs,types.rs,module.rs,module_test.rs}`; `crates/radix-hir-ts/src/{decl.rs,types.rs,expr_test.rs}`; `crates/radix-hir-faber/src/{decl.rs,types.rs}`; `crates/radix-hir-fhir/src/validate.rs`. `EBNF.md` only if the implemented bounded source grammar differs from its current generic-argument production. The Hand refreshes `rg -l 'FileExportKind::TypeAlias|InterfaceStructExport\s*\{|InterfaceNominalExport\s*\{|InterfaceTypeSnapshot::Applied' crates` and may add only newly matched compile-relevant interface consumers to this scope. No MIR/device or sibling repository files. |
| `read_scope` | All `S0-R0` evidence and Appendix A; listed write files; `crates/faber/src/package/{compile.rs,import_graph.rs,library.rs,test_support.rs}`; `radix/AGENTS.md`; target vector/matrix shape helpers; committed Shape P4 files; Triga campaign/delivery; Norma `src/vector.fab`. |
| `done_when` | (0) The interface-consumer census from `write_scope` is refreshed on the assigned base; all matches compile, and any new match is classified before edit. (1) English and canonical-reader fixtures declare `Vector<size N> = vector<f32,N>`, `Matrix<size R,size C> = matrix<f32,[R,C]>`, and nominal `Box<size N>` over the vector form. (2) Same-file, loose-file imported, and real Faber provider-package/consumer-package calls substitute literal sizes 2/3/4 and declared size parameters. (3) A new `InterfaceTypeAliasExport { params, body }` replaces the body-only alias payload; `InterfaceStructExport` and other applicable nominal exports gain ordered `params`; each parameter is `{ name, kind }`. `InterfaceAppliedArg::{Type, Size}` preserves checked applied arguments. Both loose-file and Faber package producers populate that schema, and the importer installs the same ordered kinds into imported declaration metadata instead of flattening the body. (4) Type-for-size, size-for-type, vector-width, matrix-row/column, and box/vector-width mismatches reject in Faber source analysis with code+issue+args. (5) A non-zero focused `cargo test -p faber --lib package_interface_preserves_generic_size` proves alias and `Box<size N>` provider-package reconstruction through `crates/faber/src/package/file_interface.rs`. (6) Rust and TypeScript declarations/applied uses preserve concrete 2/3/4 dimensions in a backend-owned checked form; emitted provider-consumer source compiles. Rust may not use the unshaped `Vec` fallback for a source-static alias. (7) Existing type-only aliases, package imports, built-in vector/matrix syntax, and Shape P4 generic-call tests stay green. (8) No new keyword/locale alias or numbered Triga name enters Radix. |
| `validation` | Inner loop: `cargo test -p radix --lib file_interface_preserves_generic_size`; `cargo test -p radix --lib import_contract_preserves_generic_size_alias`; `cargo test -p faber --lib package_interface_preserves_generic_size`; `cargo test -p radix-hir-rust --lib generic_size_alias`; `cargo test -p radix-hir-ts --lib generic_size_alias`; `cargo test -p radix-hir-faber --lib generic_applied_arg`; `cargo test -p radix-hir-fhir --lib generic_applied_arg`. Unit gate: `cargo test -p radix --lib`; `cargo test -p faber --lib`; `cargo test -p radix-hir-rust --lib`; `cargo test -p radix-hir-ts --lib`; `cargo test -p radix-hir-faber --lib`; `cargo test -p radix-hir-fhir --lib`; `cargo check -p faber -p radix -p radix-hir -p radix-hir-rust -p radix-hir-ts -p radix-hir-faber -p radix-hir-fhir`. Same-packet CLI gate: `(cd "$RADIX_ROOT" && cargo build -p radix --bin radix && cargo build -p faber --bin faber)`; `test -x "$RADIX_ROOT/target/debug/radix"`; `test -x "$RADIX_ROOT/target/debug/faber"`. Emitted fixture gate: `rustc --edition 2021 --crate-type lib /tmp/generic-math-types-rust/lib.rs`; `tsc --noEmit --strict --target ES2022 --module ES2022 /tmp/generic-math-types-ts/*.ts`. Every filtered command must list at least one test; zero-test success is not evidence. |
| `depends_on` | `S0-R0` committed; a refreshed Gate 0 overlap check before edits |
| `non_goals` | Selecting the Triga representation; editing Triga/Norma/Examples; native operation semantics; MIR/device monomorphization; general value const generics or arithmetic on sizes; compatibility syntax. |
| `risk` | **high** — loose-file and product package interfaces are distinct producers. Passing one route does not imply the other. Rust/TS can also compile after dimension erasure, so emitted carrier assertions are mandatory. |
| `est_work_tokens` | `65k–95k` |
| `est_basis` | `compiler-surface-feature` ledger class, median 150 tool calls. The unit spans two interface producers/importers and two HIR emitters but consumes the already-settled `S0-R0` identity model. |
| `tool_latency` | Focused crate tests are seconds to tens of seconds warm; `cargo test -p faber --lib` and `cargo test -p radix --lib` dominate. Build each same-packet CLI once; tiny `rustc`/`tsc` fixtures are seconds. |
| `parallel_children_considered` | **none** — interface schema, importer reconstruction, package producer, and emitters must agree on one ordered argument identity. |

**Retry/resume:** preserve loose-file and package red fixtures independently.
A green loose-file route never permits skipping the package producer. If a new
consumer appears on the assigned base, add it to the census and exact scope
before implementation; do not silently widen into unrelated compiler work.

### S0-T1 — equal candidate probe and representation selection

| Field | Value |
| --- | --- |
| `id` | `S0-T1` |
| `outcome` | Transparent alias, direct native, and generic-wrapper candidates are exercised through the same source/import/call/negative/emitter matrix in the campaign's fixed order. `representation-decision.md` selects exactly one with observed evidence. |
| `write_scope` | Repo `triga`, on a new implementation packet based on committed `S0-R1`: `exempla/conformance/generic-math-types/alias/{provider.fab,consumer.fab}`; `exempla/conformance/generic-math-types/direct/{provider.fab,consumer.fab}`; `exempla/conformance/generic-math-types/wrapper/{provider.fab,consumer.fab}`; `exempla/conformance/generic-math-types/negative/{vector-width.fab,matrix-shape.fab,box-width.fab,generic-kind.fab}`; `scripta/check-generic-math-representation`; `docs/factory/generic-math-types/representation-decision.md`. The runner may create only ignored temporary output under `${TMPDIR:-/tmp}/triga-generic-math-types/`. No `src/**`, root exempla, corpus, generated output, sibling repo, or campaign status edit in this unit. |
| `read_scope` | Triga `AGENTS.md`, `faber.toml`, `src/math.fab`, `src/math.proba`, `docs/{api-shape-policy,module-map}.md`, `scripta/check-{source,compile,transforms}`; this delivery and campaign; Norma `src/vector.fab`; committed Radix generic/import/Rust/TS and private `crates/faber` package files/tests from `S0-R0/R1`; same-packet `radix`/`faber` CLI help; Examples and Hosts payload consumers read-only. |
| `done_when` | (1) The runner executes all three candidates; it does not stop after the preferred one passes. (2) Each candidate has equivalent provider and consumer behavior for vector sizes 2/3/4, matrix row/column arguments, `Box<N>`, same-file calls, imported calls, and construction/component access. (3) The four negative fixtures reject at source typecheck with structured identity; the mismatch cannot first appear in `rustc` or `tsc`. (4) Candidate Rust and TypeScript provider-consumer output is emitted and compiled. (5) The matrix records exact command, exit/evidence, diagnostic identity for failures, emitted carrier/shape, and committed repo hashes. (6) The first fully passing candidate in alias→direct→wrapper order is selected; every earlier rejection has observed evidence. (7) A wrapper cannot win merely to retain fields or methods; if selected, the record proves native-value storage and the exact domain behavior unavailable to alias/direct. (8) No clean-break name or numbered constructor/helper is created. (9) `representation-decision.md` has no unresolved selection, constructor, component-access, or emitter row. |
| `validation` | `bash -n scripta/check-generic-math-representation`; same-packet build: `(cd "$RADIX_ROOT" && cargo build -p radix --bin radix && cargo build -p faber --bin faber)`; derive `RADIX_BIN="$RADIX_ROOT/target/debug/radix"` and `FABER_BIN="$RADIX_ROOT/target/debug/faber"`; `test -x "$RADIX_BIN" && test -x "$FABER_BIN"`; `RADIX_ROOT="$RADIX_ROOT" RADIX_BIN="$RADIX_BIN" FABER_BIN="$FABER_BIN" ./scripta/check-generic-math-representation --candidate alias`; same environment/command with `--candidate direct`, `--candidate wrapper`, then `--matrix`; `./scripta/check-source`; `git diff --check -- exempla/conformance/generic-math-types scripta/check-generic-math-representation docs/factory/generic-math-types/representation-decision.md`. The runner rejects a `RADIX_BIN` or `FABER_BIN` whose canonical path differs from the corresponding `$RADIX_ROOT/target/debug/*` path. Its Rust gate uses `rustc --edition 2021 --crate-type lib`; its TypeScript gate uses `tsc --noEmit --strict --target ES2022 --module ES2022`. |
| `depends_on` | `S0-R1` committed; both CLIs built from that same assigned `RADIX_ROOT` packet |
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

1. a Radix Hand for `S0-R0` after the Shape P4 serialization check;
2. a Radix Hand for `S0-R1` from committed `S0-R0`, after refreshing overlap state;
3. a Triga Hand for `S0-T1` with `radix` and `faber` binaries built from the
   same committed `S0-R1` packet; then
4. the same or a fresh Triga Hand for `S0-T2` on the committed `S0-T1` result.

Do not dispatch three candidates as independent Hands. Do not dispatch public
Triga migration while Stage 0 is active. Each packet must record its committed
base and foreign dirt before edits.

### Workstream ownership

| Surface | Owner in Stage 0 | Ownership rule |
| --- | --- | --- |
| Kinded type/size applied-argument identity | `radix`, `S0-R0` | One foundational unit; exhaustively classify/compile all consumers and serialize with Shape P4. |
| Loose-file/package import and HIR emission | `radix`, `S0-R1` | Preserve ordered parameter kinds in both interface producers; build both CLIs from this packet. |
| Candidate and selected proof sources | `triga`, `S0-T1/T2` | Non-public conformance fixtures only. |
| Candidate runner | `triga`, `S0-T1/T2` | One runner for equal tests and final gates. |
| Decision/migration/campaign records | `triga`, `S0-T1/T2` | Decision after probes; campaign completion last. |
| Public math and callers | nobody in Stage 0 | Campaign Stage 1 onward. |
| Physical WebGPU execution | nobody in Stage 0 | Record support/fail-closed only. |

## 6. Checkpoints And Gates

### Gate 0 — committed-base and serialization gate

Before `S0-R0` edits, and again before `S0-R1` edits:

- record `git rev-parse HEAD` and `git status --short --branch` in Radix;
- inspect which Shape P4 commits are ancestors of that HEAD;
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
cargo test -p radix-parser --lib
cargo test -p radix-types --lib
cargo test -p radix-hir --lib
cargo test -p radix-hir-rust --lib
cargo test -p radix-hir-ts --lib
cargo test -p radix --lib
cargo check -p radix-parser -p radix-types -p radix-hir \
  -p radix-hir-rust -p radix-hir-ts -p radix
```

Focused filters and emitted-source compilation are specified in `S0-R1`.
These are crate-scoped, not workspace suites.

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

1. Which committed Radix packet follows the current Shape P4 integration line
   for `S0-R0`, and which refreshed packet consumes it for `S0-R1`?
2. Does the same Triga Hand continue from `S0-T1` into `S0-T2`, or does Mind
   create a fresh serial packet after the decision commit?

Neither question changes unit behavior or write scope.

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
- active Shape P4 work overlaps `S0-R0` or `S0-R1` and no serialized committed
  base exists.

Do not stop because later migration touches many internal callers. Do not begin
that migration from Stage 0.

## 11. Delivery Readiness

**READY for factory dispatch, subject to Gate 0 serialization.**

This corrected spec names two proven serial Radix prerequisites plus two
serial Triga units, exact write/read scopes, objective done conditions,
crate-scoped and Triga validation,
estimates grounded in the project ledger, decision artifacts, stop conditions,
and the handoff into campaign Stage 1. No product implementation has been
performed by this planning task.


## Appendix A — S0-R0 exhaustive consumer scope at Radix `2a986d40`

This appendix is an allowed scope, not a command to edit every file. The Hand
refreshes both `rg -l` lists at unit start, classifies each match, and edits only
files that need a compile-preserving or behavior-preserving adaptation. A new
match on the assigned base is admitted only when it directly exhausts or
constructs the settled syntax/semantic argument model; unrelated refactors stay
out of scope.

### A.1 Syntax `Named`/`Qualified` consumers

```text
crates/radix-parser/src/decl.rs
crates/radix-parser/src/expr_test.rs
crates/radix-parser/src/expr.rs
crates/radix-parser/src/generic_call_test.rs
crates/radix-parser/src/mod_test.rs
crates/radix-parser/src/schema_test.rs
crates/radix-parser/src/types_test.rs
crates/radix-parser/src/types.rs
crates/radix-syntax/src/braced_annotation.rs
crates/radix-syntax/src/visit.rs
crates/radix-types/src/instans_precision.rs
crates/radix-types/src/numeric_width.rs
crates/radix/src/cli.rs
crates/radix/src/forma/author/emit.rs
crates/radix/src/forma/pretty/emit.rs
crates/radix/src/hir/lower/expr.rs
crates/radix/src/hir/lower/types.rs
crates/radix/src/semantic/annotation_contract.rs
crates/radix/src/semantic/passes/collect_test.rs
crates/radix/src/semantic/passes/resolve_test.rs
crates/radix/src/semantic/passes/resolve.rs
crates/radix/src/tool/commands/compile.rs
```

### A.2 Semantic `Type::Applied` consumers

```text
crates/faber/src/package/mir/cli_plan.rs
crates/faber/src/package/mir/link.rs
crates/radix-hir-faber/src/types.rs
crates/radix-hir-fhir/src/validate.rs
crates/radix-hir-go/src/expr/call.rs
crates/radix-hir-go/src/expr/control.rs
crates/radix-hir-go/src/expr/convert.rs
crates/radix-hir-go/src/expr/ops.rs
crates/radix-hir-go/src/failable.rs
crates/radix-hir-go/src/go_needs.rs
crates/radix-hir-go/src/stmt.rs
crates/radix-hir-go/src/types.rs
crates/radix-hir-lean/src/model.rs
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
crates/radix-hir-swift/src/types.rs
crates/radix-hir-ts/src/decl.rs
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
crates/radix-mir/src/layout.rs
crates/radix-mir/src/validate/context.rs
crates/radix-mir/src/validate/intrinsic.rs
crates/radix-mir/src/validate/type.rs
crates/radix-types/src/lattice_property_test.rs
crates/radix-types/src/types_test.rs
crates/radix-types/src/types.rs
crates/radix/src/builtins/frame_types.rs
crates/radix/src/codegen/coverage.rs
crates/radix/src/codegen/needs/rust.rs
crates/radix/src/codegen/needs/ts.rs
crates/radix/src/codegen/rust/tests/types_test.rs
crates/radix/src/codegen/ts/mod_test.rs
crates/radix/src/file_interface.rs
crates/radix/src/hir/lower/annotation.rs
crates/radix/src/hir/lower/types.rs
crates/radix/src/live_tuus_cursor_test.rs
crates/radix/src/live_tuus_cursor.rs
crates/radix/src/mir/lower/control.rs
crates/radix/src/mir/lower/runtime.rs
crates/radix/src/semantic/format_type.rs
crates/radix/src/semantic/function_facts.rs
crates/radix/src/semantic/passes/exhaustive.rs
crates/radix/src/semantic/passes/resolve.rs
crates/radix/src/semantic/passes/typecheck/access.rs
crates/radix/src/semantic/passes/typecheck/aggregate.rs
crates/radix/src/semantic/passes/typecheck/call.rs
crates/radix/src/semantic/passes/typecheck/convert.rs
crates/radix/src/semantic/passes/typecheck/finalize.rs
crates/radix/src/semantic/passes/typecheck/generic.rs
crates/radix/src/semantic/passes/typecheck/infer.rs
crates/radix/src/semantic/passes/typecheck/lookup.rs
crates/radix/src/semantic/passes/typecheck/mod.rs
crates/radix/src/semantic/passes/typecheck/ops.rs
crates/radix/src/semantic/resolved_use.rs
```

### A.3 Resolver `Symbol` constructor files

```text
crates/radix/src/builtins/forma.rs
crates/radix/src/builtins/frame_types.rs
crates/radix/src/builtins/gpu.rs
crates/radix/src/builtins/mod.rs
crates/radix/src/hir/lower/decl.rs
crates/radix/src/semantic/mod.rs
crates/radix/src/semantic/passes/collect.rs
crates/radix/src/semantic/passes/companion_predeclare.rs
crates/radix/src/semantic/passes/resolve.rs
crates/radix/src/semantic/scope.rs
crates/radix/src/semantic/scope_test.rs
```

The source census also finds function return signatures containing the word
`Symbol`; those are not constructors and are excluded. Constructor edits in
A.3 are compile-only unless the file declares a generic type identity.

`S0-R1` separately owns the interface schema/producer paths because source and
semantic exhaustiveness alone cannot prove the actual Faber package boundary.
