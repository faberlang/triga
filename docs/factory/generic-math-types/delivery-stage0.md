# Generic Math Types — Stage 0 Delivery Spec

**Status**: delivery-lowered — implementation not started; READY for factory dispatch after the serialization gate below

**Campaign**: [`CAMPAIGN.md`](CAMPAIGN.md)

**Campaign stage**: Stage 0 — parametric representation and backend probe

**Mode**: discovery-first, then one serial proof batch

**Planner**: `planner-1`, task `6349e78e`, 2026-08-13

**Owner repo**: `triga`; one proven prerequisite unit writes `radix`

**Planning packet**: `worktrees/docs-generic-math-types/triga` on `factory/docs-generic-math-types`

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

One live compiler prerequisite is already proven. Faber can declare
`type Vector<size N> = vector<f32, N>`, but committed Radix does not yet carry a
size argument through a named application such as `Vector<3>` or through an
imported generic-alias contract. Stage 0 therefore begins with one bounded
Radix unit. No second Radix unit is assumed.

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

### 2.3 Required operation map

The selected representation proof and frozen migration map must cover at least
these current behaviors. The exact new spelling is chosen by the probe, but no
row may remain `TBD` when Stage 0 closes.

| Family | Required behavior |
| --- | --- |
| `Vector<N>` | dimension-neutral construction for 2/3/4; lane access; add; subtract; scalar scale; dot; length; guarded normalization; distance; interpolation; projection |
| `Vector<3>` | cross product and every current 3D camera/face/ray use |
| `Matrix<R,C>` | dimension-neutral construction; two-axis access; compile-time shape; matrix multiplication; transpose |
| `Matrix<4,4>` | affine determinant; homogeneous point application; affine inverse; identity; translation; scale; quaternion composition; perspective; look-at/view construction |
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

### 2.4 Stage 0 artifacts

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
| `radix` live main | at least `2a986d40a1d96e47858180c25e97c47cbc5f1a95` during final inspection | grammar/AST, generic alias resolution, type substitution, import snapshots, Rust/TS emitters, shape-generics P4 refs |
| `norma` | `2d710c2c8142f32f46e70a17a60c810ad1b3be3b` | `src/vector.fab` generic intrinsic operations |
| `examples` | `d04062f27c024a57b633deb194f1d1bfb3915bce` | hello-voxel, Budapest, Drift City, browser bridge, generated source consumers |
| `faber` | `1fb6cc97e66d9b434105e952a1dba4539daaa2b0` | package check/build/emit command surface |
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

### 3.4 Proven Radix prerequisite

One prerequisite is proven from committed code. It is not speculative:

1. The parser accepts `size`/`magnitudo` parameters on declarations.
2. Built-in `vector<T, N>` and `matrix<T, [R,C]>` parse shape arguments through
   `FiguraExpr`.
3. Named generic applications store only `Vec<TypeExpr>`. A literal such as
   the `3` in `Vector<3>` is not a type expression.
4. Semantic `Type::Applied` stores only `Vec<TypeId>`, and alias normalization
   substitutes only type-parameter identities.
5. `FileExportKind::TypeAlias` snapshots only the body. It drops alias
   parameter names and kinds before an importer installs the type.
6. Rust and TypeScript alias declaration helpers intentionally emit only
   `HirTypeParam::typus_params`; size parameters are omitted.
7. Rust falls back to `Vec<T>`/`Vec<Vec<T>>` for parametric native shapes, while
   TypeScript's current native carriers do not retain a checked dimension in
   the carrier type.

Therefore Stage 0 cannot honestly run the public `Vector<3>` / `Matrix<4,4>` /
`Box<3>` comparison without `S0-R1`.

### 3.5 Shape-generics P4 serialization

Radix Shape Generics Phase 4 is a related but distinct line. Live main observed
during lowering contained the Phase-4A MIR `ShapeSize` substitution commits
`0d9f50ab0` and `beed90b1f`. Other Shape P4 branch/worktree commits were not
assumed landed.

`S0-R1` begins only after Mind assigns one committed Radix base. The Hand must:

- inspect the live committed main and all landed Shape P4 files;
- reuse landed generic-size machinery;
- avoid replaying an unmerged branch as though it were baseline; and
- serialize with any active writer touching the same generic/application/import
  or emitter files.

Shape P4's MIR monomorphization does not by itself satisfy named source alias,
provider-import, or HIR Rust/TypeScript emission proofs.

### 3.6 Consumers and host boundary

Examples has live source consumers in hello-voxel, triga-budapest,
triga-drift-city, and the browser bridge, plus generated ESM/TypeScript copies.
Those are read-only evidence in Stage 0. They migrate only after the map is
frozen.

The browser path consumes a flat `Float32Array`/buffer write. Stage 0 must not
pass a compiler register matrix across that boundary based on assumed Rust,
JavaScript, WebGPU, or WGSL layout. The default proof posture is explicit
flattening into the existing `TransformPayload` wire contract. A different
wire contract is allowed only if the decision record names a version boundary
and the campaign stop condition is handled.

## 4. Ordered Unit Graph

```text
S0-R1  named size-generic application/import/emitter prerequisite (radix)
  -> S0-T1  equal candidate probes + representation decision (triga)
    -> S0-T2  selected operation/payload/device proof + frozen migration map (triga)
      -> campaign Stage 1 delivery lowering
```

The graph is deliberately serial. The three units share one representation
choice, and `S0-T2` cannot honestly map migration destinations before `S0-T1`
selects them.

### S0-R1 — named size-generics across source, imports, and HIR emitters

| Field | Value |
| --- | --- |
| `id` | `S0-R1` |
| `outcome` | A named Faber alias or nominal declaration can declare size parameters, apply literal/parameter size arguments, cross a provider import, participate in calls, reject kind/shape mismatches, and emit compilable Rust and TypeScript without erasing concrete dimensions. This is the only pre-proven Radix prerequisite. |
| `write_scope` | Repo `radix`, on the packet Mind assigns after the Shape P4 serialization check. Allowed implementation files: `EBNF.md`; `crates/radix-syntax/src/ast.rs`; `crates/radix-parser/src/{types.rs,types_test.rs,mod_test.rs}`; `crates/radix-types/src/{types.rs,types_test.rs}`; `crates/radix-hir/src/{nodes.rs,visit.rs}` only if the existing `HirTypeParam.kind`/visitor cannot carry the chosen applied-argument representation; `crates/radix/src/hir/lower/{types.rs,mod_test.rs}`; `crates/radix/src/semantic/passes/{resolve.rs,resolve_test.rs}`; `crates/radix/src/semantic/passes/typecheck/{collect.rs,generic.rs,infer.rs,generic_call_test.rs}`; `crates/radix/src/{file_interface.rs,semantic/scope.rs}`; `crates/radix/src/tool/commands/{compile.rs,compile_test.rs}`; `crates/radix-hir-rust/src/{decl.rs,types.rs,module_test.rs}`; `crates/radix-hir-ts/src/{decl.rs,types.rs,expr_test.rs}`. The Hand uses the smallest subset. New focused `_test.rs` files may be added beside these modules with names beginning `generic_size_alias`. No MIR/device files and no sibling repositories. |
| `read_scope` | All listed write files; `radix/AGENTS.md`; `crates/radix/src/semantic/passes/typecheck/tensor_index.rs`; `crates/radix-hir-{rust,ts}/src/{vector_width.rs,matrix_shape.rs}` where present; `docs/factory/shape-generics/**`; Shape P4 commits actually reachable from the assigned base; Triga `docs/factory/generic-math-types/{CAMPAIGN.md,delivery-stage0.md}` and `src/math.fab`; Norma `src/vector.fab`. Unmerged Shape P4 worktrees are read-only evidence, never baseline. |
| `done_when` | (1) English and canonical-reader fixtures declare aliases `Vector<size N> = vector<f32,N>` and `Matrix<size R,size C> = matrix<f32,[R,C]>`, plus a generic nominal `Box<size N>` over the vector form. (2) Named applications accept literal sizes 2/3/4 and size parameters; type arguments and size arguments remain kind-distinct. (3) Same-file and imported calls substitute vector width, both matrix dimensions, and box width. (4) Applying a type where a size is required, a size where a type is required, vector-width mismatch, matrix-row/column mismatch, and box/vector-width mismatch reject with code+issue+args, not prose-only tests. (5) The file-interface snapshot preserves generic alias parameter order and kind plus index expressions; the importer reconstructs an applicable generic identity instead of an already-flattened body. (6) Rust and TypeScript declarations and applied uses preserve concrete `2|3|4` arguments in a backend-owned checked form; emitted sources compile. Rust may not use the current unshaped `Vec` fallback for a source-static alias. (7) Existing type-only generic aliases, built-in vector/matrix syntax, and Shape P4 generic-call tests stay green. (8) No new keyword/locale alias and no numbered Triga name enters Radix. |
| `validation` | Inner loop: `cargo test -p radix-parser --lib generic_size_alias`; `cargo test -p radix-types --lib generic_size_application`; `cargo test -p radix-hir --lib generic_size_alias`; `cargo test -p radix --lib generic_size_alias`; `cargo test -p radix --lib import_contract_preserves_generic_size_alias`; `cargo test -p radix-hir-rust --lib generic_size_alias`; `cargo test -p radix-hir-ts --lib generic_size_alias`. Unit gate: `cargo test -p radix-parser --lib`; `cargo test -p radix-types --lib`; `cargo test -p radix-hir --lib`; `cargo test -p radix-hir-rust --lib`; `cargo test -p radix-hir-ts --lib`; `cargo test -p radix --lib`; `cargo check -p radix-parser -p radix-types -p radix-hir -p radix-hir-rust -p radix-hir-ts -p radix`. Emitted fixture gate: `rustc --edition 2021 --crate-type lib /tmp/generic-math-types-rust/lib.rs`; `tsc --noEmit --strict --target ES2022 --module ES2022 /tmp/generic-math-types-ts/*.ts`. Every named filtered command must list at least one new test; zero-test success is not evidence. |
| `depends_on` | none in this delivery; serialization gate requires one committed Radix base after inspection of live Shape P4 state |
| `non_goals` | Selecting the Triga representation; editing Triga/Norma/Examples; changing native operation semantics; MIR/device monomorphization already owned by Shape P4; general value const generics or arithmetic on sizes; TypeScript-wide tuple arithmetic; compatibility syntax. |
| `risk` | **high** — changes the generic application and provider-interface shape shared by aliases and nominals, and both HIR emitters. Kind erasure can produce false type equality or invalid target source. Shape P4 may have concurrent overlapping work. Tests must pin type-vs-size errors, imported reconstruction, and ordinary type-only aliases. |
| `est_work_tokens` | `70k–100k` |
| `est_basis` | `.tugboat/estimate-ledger.json` class `compiler-surface-feature`: 33 recorded units, 45–304 tool calls, median 150; Shape Generics P4 unit 4A recorded 274. This unit crosses parser, semantic, import, and two emitter seams but reuses existing size/index machinery. |
| `tool_latency` | Focused crate tests are normally seconds to tens of seconds warm; `cargo test -p radix --lib` is the dominant crate-scoped gate. Budget cold Rust compilation once, then reuse artifacts. `rustc`/`tsc` on tiny emitted fixtures are seconds. No workspace suite. |
| `parallel_children_considered` | **none** — parser/type model/import snapshot/emitter representation is one coupled identity seam, and Shape P4 overlap requires one serialized Hand. |

**Retry/resume:** preserve red fixtures first. If the chosen mixed generic-argument
representation makes ordinary `X<T>` aliases regress, revert only the unit's
uncommitted implementation in its dedicated packet and resume from the red
fixtures. Do not weaken import reconstruction or shape mismatch checks.

**Stop and route:** if named size arguments require a general dependent-value
type system rather than a bounded literal/`size` argument form, stop. Report the
exact parser/type-model boundary to Mind; do not encode sizes as fake user
types.

### S0-T1 — equal candidate probe and representation selection

| Field | Value |
| --- | --- |
| `id` | `S0-T1` |
| `outcome` | Transparent alias, direct native, and generic-wrapper candidates are exercised through the same source/import/call/negative/emitter matrix in the campaign's fixed order. `representation-decision.md` selects exactly one with observed evidence. |
| `write_scope` | Repo `triga`, on a new implementation packet based on committed `S0-R1`: `exempla/conformance/generic-math-types/alias/{provider.fab,consumer.fab}`; `exempla/conformance/generic-math-types/direct/{provider.fab,consumer.fab}`; `exempla/conformance/generic-math-types/wrapper/{provider.fab,consumer.fab}`; `exempla/conformance/generic-math-types/negative/{vector-width.fab,matrix-shape.fab,box-width.fab,generic-kind.fab}`; `scripta/check-generic-math-representation`; `docs/factory/generic-math-types/representation-decision.md`. The runner may create only ignored temporary output under `${TMPDIR:-/tmp}/triga-generic-math-types/`. No `src/**`, root exempla, corpus, generated output, sibling repo, or campaign status edit in this unit. |
| `read_scope` | Triga `AGENTS.md`, `faber.toml`, `src/math.fab`, `src/math.proba`, `docs/{api-shape-policy,module-map}.md`, `scripta/check-{source,compile,transforms}`; this delivery and campaign; Norma `src/vector.fab`; committed Radix generic/import/Rust/TS files and tests from `S0-R1`; Faber package command/help and existing temp-package harnesses; Examples and Hosts payload consumers read-only. |
| `done_when` | (1) The runner executes all three candidates; it does not stop after the preferred one passes. (2) Each candidate has equivalent provider and consumer behavior for vector sizes 2/3/4, matrix row/column arguments, `Box<N>`, same-file calls, imported calls, and construction/component access. (3) The four negative fixtures reject at source typecheck with structured identity; the mismatch cannot first appear in `rustc` or `tsc`. (4) Candidate Rust and TypeScript provider-consumer output is emitted and compiled. (5) The matrix records exact command, exit/evidence, diagnostic identity for failures, emitted carrier/shape, and committed repo hashes. (6) The first fully passing candidate in alias→direct→wrapper order is selected; every earlier rejection has observed evidence. (7) A wrapper cannot win merely to retain fields or methods; if selected, the record proves native-value storage and the exact domain behavior unavailable to alias/direct. (8) No clean-break name or numbered constructor/helper is created. (9) `representation-decision.md` has no unresolved selection, constructor, component-access, or emitter row. |
| `validation` | `bash -n scripta/check-generic-math-representation`; `RADIX_ROOT=/path/to/assigned/radix FABER_ROOT=/path/to/faber ./scripta/check-generic-math-representation --candidate alias`; same command with `--candidate direct`; same with `--candidate wrapper`; `./scripta/check-generic-math-representation --matrix`; `./scripta/check-source`; `git diff --check -- exempla/conformance/generic-math-types scripta/check-generic-math-representation docs/factory/generic-math-types/representation-decision.md`. The runner's Rust gate uses `rustc --edition 2021 --crate-type lib`; its TypeScript gate uses `tsc --noEmit --strict --target ES2022 --module ES2022`. |
| `depends_on` | `S0-R1` committed and consumed by the assigned Radix/Faber toolchain |
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
| `read_scope` | All `S0-T1` fixtures/evidence; Triga `src/math.fab` complete declaration/operation inventory; all owned Triga hit paths under `src/`, `exempla/`, and `corpus/`; Examples hello-voxel/Budapest/Drift City/browser bridge and generated outputs; Hosts browser payload writers; current Radix target capability and selected representation emitters; campaign Stages 1–5. Vendored three.js is read only for exclusion classification, not a migration source. |
| `done_when` | (1) `operations.fab` proves construction/lane access for sizes 2/3/4 and every §2.3 vector/matrix/box behavior, with operations located as intrinsic, free function, surviving receiver, or named residual. No required row is `TBD`. (2) Compile-time mismatch fixtures remain red while positive operations emit and compile on Rust and TypeScript. (3) `payload.fab` proves the selected `Matrix<4,4>` to `TransformPayload` conversion: model then view-projection, column-major, 32 `f32`, 128 bytes; native memory layout is not assumed. (4) `device.fab` either emits a validated selected subset or rejects before artifact use with code+issue+args. Host fallback, list substitution, panic, or unsupported output labeled success fails the gate. (5) `representation-decision.md` records the final target matrix, host boundary, device posture, and any later-stage residual. (6) `migration-map.md` maps every retired declaration, numbered constructor/helper, compound helper containing a retired token, direct source/test/exemplar/corpus consumer family, Examples source/generated family, Radix direct metadata row, and Faberlang site row to an exact new spelling/action and campaign owner. No compatibility destination exists. (7) The map includes the representation-specific ordered Stage 1–5 delivery graph, path scopes, generator-before-output rules, and classified final grep oracle. (8) `CAMPAIGN.md` marks Stage 0 complete only after all evidence is committed; names Stage 1 as next only when no stop condition fired. (9) The checker detects a missing decision row, migration `TBD`, numbered compatibility spelling, payload-count/layout failure, and device overclaim. |
| `validation` | `RADIX_ROOT=/path/to/assigned/radix FABER_ROOT=/path/to/faber ./scripta/check-generic-math-representation --selected --operations`; same with `--selected --targets rust,ts`; same with `--selected --payload`; same with `--selected --device-posture`; final `./scripta/check-generic-math-representation --all`; `./scripta/check-source`; `git diff --check -- exempla/conformance/generic-math-types scripta/check-generic-math-representation docs/factory/generic-math-types`. Target compilation remains `rustc --edition 2021 --crate-type lib` and `tsc --noEmit --strict --target ES2022 --module ES2022` inside the runner. No broad Triga/Radix suite. |
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

1. a Radix Hand for `S0-R1` after the Shape P4 serialization check;
2. a Triga Hand for `S0-T1` after consuming the committed Radix result; then
3. the same or a fresh Triga Hand for `S0-T2` on the committed `S0-T1` result.

Do not dispatch three candidates as independent Hands. Do not dispatch public
Triga migration while Stage 0 is active. Each packet must record its committed
base and foreign dirt before edits.

### Workstream ownership

| Surface | Owner in Stage 0 | Ownership rule |
| --- | --- | --- |
| Named size generic source/import/HIR emission | `radix`, `S0-R1` | One prerequisite unit; serialize with Shape P4. |
| Candidate and selected proof sources | `triga`, `S0-T1/T2` | Non-public conformance fixtures only. |
| Candidate runner | `triga`, `S0-T1/T2` | One runner for equal tests and final gates. |
| Decision/migration/campaign records | `triga`, `S0-T1/T2` | Decision after probes; campaign completion last. |
| Public math and callers | nobody in Stage 0 | Campaign Stage 1 onward. |
| Physical WebGPU execution | nobody in Stage 0 | Record support/fail-closed only. |

## 6. Checkpoints And Gates

### Gate 0 — committed-base and serialization gate

Before `S0-R1` edits:

- record `git rev-parse HEAD` and `git status --short --branch` in Radix;
- inspect which Shape P4 commits are ancestors of that HEAD;
- identify active worktrees touching any `S0-R1` file;
- wait or route through Mind when write overlap exists; and
- treat unmerged branches as read-only evidence.

A newer main that already satisfies part of `S0-R1` shrinks the implementation.
It does not remove the required tests.

### Gate 1 — prerequisite gate

`S0-R1` is complete only when named literal/parameter sizes survive declaration,
application, import, substitution, mismatch diagnostics, Rust emission, and
TypeScript emission on one committed tree. Parser-only or HIR-only proof does
not pass.

### Gate 2 — representation gate

`S0-T1` is complete only when all three candidates have equal evidence and one
winner follows the fixed preference rule. No winner or an all-fail matrix means
Stage 0 is blocked, not complete.

### Gate 3 — behavior and boundary gate

`S0-T2` is complete only when:

- the required operation table is total;
- source mismatch rejection remains compile-time;
- emitted Rust and TypeScript compile;
- host layout is explicit and byte-counted;
- device status is honest;
- the migration map has no `TBD` or compatibility destination; and
- the campaign points to committed evidence.

### Batching / Split Decision

**Discovery then batch.** `S0-R1` establishes the missing language seam.
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
bash -n scripta/check-generic-math-representation
RADIX_ROOT=/path/to/assigned/radix \
FABER_ROOT=/path/to/faber \
  ./scripta/check-generic-math-representation --all
./scripta/check-source
git diff --check -- \
  exempla/conformance/generic-math-types \
  scripta/check-generic-math-representation \
  docs/factory/generic-math-types
```

The runner owns exact `radix`/`faber` invocation, temporary package assembly,
`rustc`, `tsc`, negative-result identity, and device-posture checks. Temporary
outputs are never committed.

### Final clean-break inventory

The migration document records a classified scan over only these live owned
roots:

```sh
rg -n 'Vector2|Vector3|Vector4|Matrix3|Matrix4|Box3' \
  src exempla corpus
rg -n 'Vector2|Vector3|Vector4|Matrix3|Matrix4|Box3' \
  /path/to/examples/hello-voxel \
  /path/to/examples/triga-budapest \
  /path/to/examples/triga-drift-city \
  /path/to/examples/browser-app
```

Stage 0 classifies and maps the hits. It does not require them to be zero yet.
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

1. Which committed Radix packet follows the current Shape P4 integration line?
2. Does the same Triga Hand continue from `S0-T1` into `S0-T2`, or does Mind
   create a fresh serial packet after the decision commit?

Neither question changes unit behavior or write scope.

## 10. Stop Conditions

Stop and report `NOT READY` for the next unit if any of these occurs:

- named size applications require general dependent-value generics rather than
  the bounded literal/`size` form;
- all three candidates fail a mandatory matrix row;
- Rust and TypeScript need incompatible public Faber source contracts;
- shape mismatch survives until target compilation instead of Faber
  typechecking;
- an operation can be preserved only by restoring a numbered public carrier or
  a list-backed primary shape;
- selected values would cross the host boundary with an undocumented layout;
- a device path emits an artifact while silently substituting unsupported
  host/list behavior; or
- active Shape P4 work overlaps `S0-R1` and no serialized committed base exists.

Do not stop because later migration touches many internal callers. Do not begin
that migration from Stage 0.

## 11. Delivery Readiness

**READY for factory dispatch, subject to Gate 0 serialization.**

This spec names one proven Radix prerequisite, three serial units, exact write
and read scopes, objective done conditions, crate-scoped and Triga validation,
estimates grounded in the project ledger, decision artifacts, stop conditions,
and the handoff into campaign Stage 1. No product implementation has been
performed by this planning task.
