# Campaign: Parametric Math Types Clean Break

**Status**: active — Stage 0 lowered; implementation not started

**Mode**: run

**Owner repo**: `triga`

**Affected repos**: `triga`, `radix`, `examples`, `faberlang.dev`

**Selected next stage**: Stage 0 — delivery lowered; route [`delivery-stage0.md`](delivery-stage0.md) to Factory after its Radix Shape P4 serialization gate

**Decision authority**: operator direction on 2026-08-13

## Summary

Replace Triga's dimension-suffixed public type names with a parametric math
surface. Dimensions belong in type arguments or type shapes, not in
identifiers:

```faber
Vector<3>
Matrix<4, 4>
Box<3>
```

The current `Vector2`, `Vector3`, `Vector4`, `Matrix3`, `Matrix4`, and `Box3`
names are retired in one clean break. There are no compatibility aliases and no
period in which both numbered and parametric public surfaces are supported.

The public contract is settled. Stage 0 determines the smallest compiler and
library representation that can carry it honestly across Triga's supported
targets. That representation may be a transparent generic alias, a generic
nominal wrapper over compiler-owned register types, or direct compiler-owned
types plus dimension-neutral Triga operations. It may not restore a numbered
public identifier.

## Problem

Triga currently encodes vector, matrix, and spatial dimensionality twice:

1. in the public identifier (`Vector3`, `Matrix4`, `Box3`); and
2. in fields, list lengths, or the operations that consume the value.

This makes every supported shape look like a separate concept. It also leaves
`Matrix4` as a list-backed nominal record whose primary shape check happens at
runtime. Faber already has size parameters and compiler-owned register types:
`vector<f32, N>` and `matrix<f32, [R, C]>`. The Triga API should express the
same idea: one semantic type family, with size carried by the type.

The numbered names were inherited from a three.js-shaped API. Migration ease
does not make them a required external contract.

## Desired End State

- Triga exposes `Vector<N>`, `Matrix<R, C>`, and `Box<N>` as its public math
  families, or exposes the equivalent native Faber shapes directly where a
  Triga alias adds no value.
- The type system rejects shape mismatches. Runtime list-length validation is
  not the primary representation of vector or matrix shape.
- Dimension-specific operations state their constraints in types or checked
  implementation boundaries. For example, cross products may be defined only
  for `Vector<3>` without creating a `Vector3` type.
- Dimension-coded constructor and helper names that exist only to serve the
  retired types are replaced with dimension-neutral construction or operation
  names. `vector3(...)` and `matrix4_*` do not survive as compatibility APIs.
- Existing Triga behavior remains available: vector arithmetic, transform
  composition, point application, affine inversion, cameras, bounds, rays,
  scene transforms, and payload generation.
- Rust and TypeScript generation preserve the selected representation and
  shape without hand-written generated-output patches.
- Active source, examples, current docs, locale/library metadata, and generated
  outputs agree on the new surface.
- Historical Factory evidence may continue to describe the old surface as
  history. Vendored three.js code remains unchanged.

## Settled Decisions

1. **No dimension suffixes on owned public type identifiers.** The clean-break
   set is `Vector2`, `Vector3`, `Vector4`, `Matrix3`, `Matrix4`, and `Box3`.
2. **Shape is part of the type.** Vectors use one size argument, matrices use
   row and column size arguments, and boxes use a vector-space size argument.
3. **No compatibility layer.** Do not add aliases, deprecated shims, duplicate
   constructors, adapters, or a facade that keeps the numbered API alive.
4. **No three.js naming veto.** Triga may remain behaviorally familiar without
   copying three.js type identifiers.
5. **Generated files follow source.** Regenerate them after source migration;
   do not treat generated copies as an independent implementation surface.
6. **Third-party names are not ours.** Vendored three.js `Vector3`, `Matrix4`,
   and related symbols are excluded.

## Stage 0 Decision Boundary

Stage 0 must select one of these representations:

| Candidate | Shape | Default posture |
| --- | --- | --- |
| Transparent aliases | `type Vector<size N> = vector<f32, N>` and `type Matrix<size R, size C> = matrix<f32, [R, C]>` | Preferred when aliases preserve type checking, emission, and usable operations |
| Generic nominal wrappers | `Vector<N>` and `Matrix<R, C>` wrap compiler-owned register values | Allowed only when Triga needs receiver methods or domain behavior that aliases/direct types cannot provide |
| Direct native types | Consumers use `vector<f32, N>` and `matrix<f32, [R, C]>`; Triga supplies dimension-neutral free operations | Allowed when the aliases would be pure spelling with no semantic value |

`Box<N>` should be generic over its `Vector<N>` minimum and maximum. Operations
that are genuinely three-dimensional may constrain themselves to `Box<3>`.

The default is transparent aliases over native register types. If that fails,
prefer direct native types before adding wrappers. A wrapper is justified only
by demonstrated API behavior, never by a desire to retain `.x`, `.y`, `.z`, an
`elements` list, or the old names unchanged.

## Development Posture

- Clean break. Internal callers are migration work, not compatibility
  contracts.
- Discovery first for the compiler boundary; batch-by-default after Stage 0
  locks the representation.
- Triga owns its public math vocabulary and backend-neutral behavior.
- Radix owns parser, type-system, generic-size substitution, and target emission
  support.
- Norma owns generic operations over compiler vector intrinsics. Reuse that
  behavior where it fits; do not create a second incompatible generic vector
  algebra.
- Public target support must be stated honestly. A parser-only or HIR-only
  success is not cross-target support.
- All implementation runs through role packets. Main checkouts remain
  integration surfaces.

## Implementation Workflow

1. Planner lowers the selected stage into a delivery artifact with exact paths,
   fixtures, commands, expected results, owner, lane, and done oracle.
2. Mind refreshes a non-overlapping role packet for each unit.
3. Dispatch is Vivi file plus live subagent spawn in the same turn.
4. Hands implement and commit only in their packet branches.
5. The merge lane integrates repo changes in dependency order: Radix support,
   Triga surface, consumers, generated outputs, docs.
6. A lint lane clears integrated stages 1–2 before a test lane runs stages 3–6
   or broader suites.
7. Factory status and generated README updates happen after the current foreign
   Triga Factory-documentation line and this campaign have both been integrated.

## Ground Truth

This campaign was grounded on these committed snapshots:

| Repo | Snapshot | Evidence used |
| --- | --- | --- |
| `triga` | `05c6ccff5c0d48a0cfd02b740f8caff83578e3e4` | `src/math.fab`, source consumers, exempla, corpus, API policy/docs, `faber.toml`, scripts |
| `radix` | `f4e6bec7de06a7c30f983565f1a90035e7611f80` | `EBNF.md`, generic type grammar, English reader vocabulary, vector/matrix compiler types, locale library metadata |
| `examples` | `ff321b4626fe11714ed21484a6b976a6cfe25722` | Triga consumer sources and generated hello-voxel outputs |
| `faberlang.dev` | `60552196c5201dcd06257baca13e022a5c034ea7` | Triga library source page and generated site output |

Live language facts at those snapshots:

- Faber accepts size generic parameters in type aliases.
- Faber spells the compiler-owned types `vector<f32, N>` and
  `matrix<f32, [R, C]>`.
- A matrix shape has exactly two dimensions.
- The selected Triga reader locale is English, so campaign examples use
  `type` and `size`. These are localized spellings of the same language
  identities, not a separate semantic surface.
- Norma already provides generic vector operations over compiler intrinsics.
- Current Triga `Matrix4` stores `list<f32> elements` and checks a length of 16
  at runtime.

## Current State

The owned public declarations with numeric suffixes are:

| Current type | Current representation | Intended family |
| --- | --- | --- |
| `Vector2` | nominal `x`, `y` fields | `Vector<2>` |
| `Vector3` | nominal `x`, `y`, `z` fields plus arithmetic methods | `Vector<3>` |
| `Vector4` | nominal `x`, `y`, `z`, `w` fields | `Vector<4>` |
| `Matrix3` | flat `list<f32>` carrier | `Matrix<3, 3>` |
| `Matrix4` | flat `list<f32>` carrier plus transform methods | `Matrix<4, 4>` |
| `Box3` | `Vector3` minimum and maximum | `Box<3>` |

The main blast radius is concentrated in `triga/src/math.fab`, then Triga's
scene, camera, object, face, and lighting consumers. Triga exempla and browser
corpus programs exercise the public surface. Examples contains additional
source consumers and generated Rust/JavaScript/TypeScript-shaped outputs.
Radix has a small amount of direct Triga locale/library metadata plus many
unrelated compiler test fixtures that happen to use names such as `Vector3`.
Those unrelated fixtures are not migration targets.

## Scope Routing

### `triga` — primary owner

In scope:

- `src/math.fab`
- direct consumers under `src/`
- `src/*.proba`
- current exempla and corpus sources
- current public API and module documentation
- current Factory artifacts whose acceptance claims depend on live paths or
  current public names

Historical evidence stays historical unless a live check hardcodes its path or
asserts it is the current API.

### `radix` — compiler and metadata dependency

In scope only when Stage 0 proves a gap:

- generic alias/type-size substitution needed by the selected representation
- Rust and TypeScript lowering/emission of the selected representation
- device/backend support or explicit fail-closed behavior
- English locale/library member metadata that directly names Triga's retired
  public types
- focused regression fixtures created for this campaign

Out of scope:

- arbitrary compiler tests that use `Vector3` or `Matrix4` as sample user type
  names
- global textual renaming of fixtures
- weakening backend rejection merely to make the new spelling compile

### `examples` — source consumer and generated artifacts

In scope:

- Triga-using source packages, including hello-voxel and current Triga tracks
- tests coupled to the retired surface
- generated outputs produced from migrated source

Source migrates first. Generated files are regenerated through their owning
workflow and checked for byte provenance; they are not hand-edited substitutes.

### `faberlang.dev` — current documentation

Update the English Triga library source page, then rebuild its generated HTML.
Do not patch `dist/` without regenerating it from the source page.

### Explicit exclusions

- `hosts/webgpu-browser/public/vendor/three@0.180/*`
- archived Faber syntax or retired compiler repositories
- historical Factory receipts that accurately report what existed at their
  recorded snapshot
- unrelated user-defined sample types in Radix tests
- a general numerical-type spelling redesign outside Triga

## Campaign Path

### Stage 0 — Parametric representation and backend probe

**Status**: active — delivery lowered; implementation not started

**Lowers to**: Factory via [`delivery-stage0.md`](delivery-stage0.md)

**Routing evidence**: planner delivery task `6349e78e`; the delivery records one proven Radix prerequisite for named size applications/imports/HIR emitters, followed by equal alias/direct/wrapper probes and the selected operation/payload/device/migration freeze. Dispatch is serial and starts only after the delivery's Shape P4 committed-base gate.

**Mode**: discovery-first

Prove the public contract before broad migration.

Required probes:

1. Parse and type-check generic aliases with `size` parameters.
2. Substitute vector size and matrix row/column sizes through calls and
   imported module boundaries.
3. Reject mismatched vector and matrix shapes at compile time.
4. Emit and compile representative Rust and TypeScript library consumers.
5. Prove constructor/literal ergonomics for sizes 2, 3, and 4.
6. Prove indexing, swizzle, or explicit accessor replacements for `.x`, `.y`,
   `.z`, and `.w` without preserving the old nominal carriers by accident.
7. Prove the required `Vector<3>` operations, including cross product,
   normalization, interpolation, projection, and point distance.
8. Prove the required `Matrix<4, 4>` operations, including multiplication,
   transpose, point application, projection/view construction, and affine
   inverse.
9. Prove the selected host/payload layout or define an explicit conversion at
   the host boundary.
10. Record device/backend support. Unsupported paths must reject clearly.

Deliverables:

- a representation decision record in this campaign directory;
- focused positive and negative fixtures;
- a delivery graph for Stages 1–5;
- any required Radix unit split, with its own owner and proof;
- an explicit migration table from each retired symbol and helper to its new
  spelling.

Done oracle:

- one representation is selected with observed Rust and TypeScript proof;
- compile-time shape rejection is observed;
- every current Triga operation has a mapped destination;
- remaining target gaps are named and fail closed;
- the suffix-free public contract remains unchanged.

### Stage 1 — Core Triga math surface

Implement the selected `Vector<N>`, `Matrix<R, C>`, and `Box<N>` surface in
Triga. Migrate vector/matrix/box methods and constructors. Remove the six
retired declarations and their dimension-coded helper surface in the same
change set.

Done oracle:

- no numbered compatibility declaration exists;
- shape mismatch tests fail at compile time;
- focused Triga math behavior tests pass;
- `./scripta/check-source`, `./scripta/check-compile`, and
  `./scripta/check-transforms` pass in the assigned Triga packet.

### Stage 2 — Triga consumers and corpus

Migrate Triga-owned scene, camera, graph, face, lighting, exempla, proba, and
browser corpus consumers. Update host payload conversion only where Stage 0
requires it.

Done oracle:

- all current Triga sources compile against only the new surface;
- exempla and transform proofs preserve their behavioral oracles;
- current Triga corpus programs no longer reference retired symbols;
- no extra compatibility layer was introduced to reduce migration work.

### Stage 3 — Cross-repo consumers and compiler metadata

Apply the frozen migration map to Examples. Land any Stage 0-proven Radix
support and update only direct Triga locale/library metadata. Keep unrelated
compiler fixtures unchanged.

Done oracle:

- source packages compile against the new surface;
- focused Radix positive and negative tests pass;
- direct Triga metadata names the new public identities;
- a classified grep distinguishes migrated owned references from excluded
  arbitrary sample names.

### Stage 4 — Generated outputs and current documentation

Regenerate Examples outputs from migrated source. Update Triga current API
documentation and the Faberlang site source, then rebuild generated site output.
Keep historical receipts factual.

Done oracle:

- generated files contain only output derived from the new source surface;
- current Triga documentation teaches parametric shapes;
- current site source and built HTML agree;
- vendored three.js files are byte-unchanged.

### Stage 5 — Integrated acceptance and closeout

Integrate in dependency order, clear lint, run the relevant Faber acceptance
ladder, classify remaining numeric-name hits, update campaign status, archive
superseded goal material where appropriate, and regenerate the Factory README.

Done oracle:

- integrated Triga gates are green;
- relevant Radix stages are green on the committed integrated tree;
- every remaining `Vector2|Vector3|Vector4|Matrix3|Matrix4|Box3` hit is either
  third-party, historical evidence, or an unrelated user-defined fixture;
- no current owned public API or current consumer uses a retired symbol;
- Factory audit and README freshness checks pass after all documentation lines
  are integrated.

## Dependencies and Ordering

```text
Stage 0 representation proof
  -> Radix prerequisite, if any
  -> Stage 1 Triga core surface
  -> Stage 2 Triga consumers
  -> Stage 3 cross-repo consumers and metadata
  -> Stage 4 generated outputs and docs
  -> Stage 5 integrated acceptance and closeout
```

- Do not begin broad consumer edits before Stage 0 freezes the representation
  and migration table.
- A Radix prerequisite must land before Triga depends on it.
- Triga source must land before Examples and site outputs are regenerated.
- Source docs must change before generated docs.
- The generated Factory README is last because Triga main already has a
  separate Factory-documentation line in progress.

## Batching and Split Policy

- Stage 0 is one bounded compiler/library seam investigation.
- After Stage 0, split implementation by non-overlapping ownership:
  Radix prerequisite, Triga core math, Triga consumers/corpus, Examples, and
  docs/site.
- Do not split a single public surface across numbered and generic forms.
- Do not place generated source and its generator input in independent units
  that can land out of order.
- If a target cannot represent the frozen contract, route a specific Radix
  unit. Do not hide the gap in Triga with list-backed compatibility types.

## Acceptance Matrix

| Requirement | Evidence |
| --- | --- |
| Public names carry no dimension suffix | declaration scan plus classified workspace grep |
| Shape is compile-time information | positive and negative compiler fixtures |
| Vector behavior preserved | focused Triga proba and exempla |
| Matrix transform behavior preserved | `check-transforms` and focused transform fixtures |
| Box behavior preserved | bounds, overlap, containment, and ray fixtures using `Box<3>` |
| Rust target works | generated library consumer builds and focused Radix test |
| TypeScript target works | generated library consumer builds and focused Radix test |
| Unsupported device paths are honest | observed success or explicit fail-closed diagnostic |
| Consumers migrated | Triga and Examples source checks |
| Generated outputs have provenance | regeneration command plus clean diff review |
| Current docs agree | Triga docs and rebuilt Faberlang site |
| No compatibility residue | no aliases, adapters, duplicate constructors, or deprecated numbered exports |

## Validation Strategy

Inner-loop commands from the assigned Triga packet:

```sh
./scripta/check-source
./scripta/check-compile
./scripta/check-transforms
```

Stage 0 must add and run focused Radix tests for generic size substitution,
shape mismatch rejection, and the selected Rust/TypeScript lowering path. The
delivery artifact must name their exact `cargo test -p ...` commands after the
owning crate is identified from live code.

After integration, route Radix stages 1–2 to a lint lane. Route the relevant
stages 3–6 and any declared broader suite to a test lane. Do not use a full
suite as the first proof.

The final clean-break scan must be path-classified. A raw workspace count is
not an oracle because third-party three.js and unrelated compiler fixtures
legitimately contain the same spellings.

## Open Questions for Stage 0

These questions may change representation and operation placement. They may
not change the suffix-free public contract.

1. Do transparent aliases preserve generic size arguments through imported
   library boundaries and both current source emitters?
2. Can aliases or native register values receive the required Triga methods, or
   should dimension-neutral operations be free functions?
3. What is the clean replacement for named component fields on generic values:
   indexing, swizzle, accessors, or destructuring?
4. Can `matrix<f32, [R, C]>` express the full current `Matrix4` CPU transform
   behavior on Rust and TypeScript today?
5. Which host payloads require conversion from register values, and where is
   that conversion owned?
6. Is `Box<N>` directly viable, or does current generic-member support require
   a bounded Radix prerequisite?

## Stop Conditions

Pause this campaign and route a decision only if:

- Faber cannot represent size-parameterized public types across the required
  library boundary without a compiler change whose scope exceeds this
  campaign;
- Rust and TypeScript require incompatible public source contracts;
- an actual external Triga consumer contract requiring numbered exports is
  produced; or
- the selected representation would silently change host payload layout with
  no explicit conversion or version boundary.

Do not stop because migration touches many internal callers. That work is the
campaign.

## Readiness

**Stage 0 is lowered and READY for factory dispatch after its serialization gate.**

[`delivery-stage0.md`](delivery-stage0.md) is the implementation authority. It
keeps Stage 0 active, not complete; defines the proven Radix prerequisite and
the serial Triga candidate/selection/freeze units; and requires committed Rust,
TypeScript, host-layout, device-posture, decision-record, and migration-map
evidence before this campaign may select Stage 1.

The public naming decision, scope, exclusions, ownership, dependency order,
proof obligations, and stop conditions remain fixed. Stage 0 is intentionally
a probe because live compiler and emitter behavior must select the internal
representation before implementation fans out.
