# Goal: Triga API Shape And Vocabulary Rework (Triga-Only)

## Summary

Reshape Triga's public `triga:*` surface from free functions with type-name
prefixes to receiver methods on `genus`, then run one vocabulary pass that aligns
operation and type names with Faber/Norma identity — executed as a single clean
break confined to the `triga/` repo. `examples/triga-drift-city` is deliberately
broken by this work and tracked as a separate follow-up goal.

## Problem

- Every public Triga operation is a top-level `functio` carrying its receiver
  type as a name prefix (~281 public functions across `src/triga.fab`,
  `src/scene.fab`, `src/geometry.fab`). The prefix plus overload disambiguation
  produces the worst names in the library: `box3_continet_box3`,
  `ray_intersecat_box3`, `matrix4_applica_punctum`.
- Free-function shape forces per-call re-validation (`box3_validum` at the top of
  nearly every `Box3` accessor), whole-store copies on every scene edit, and a
  fourteen-member `scene_visible*` family that re-walks the graph once per fact.
- The current names are stated three.js-mirror intent
  (`src/triga.fab:1-3`), not drift. This goal overturns that decision
  explicitly: the bet was made before Triga had real consumers, and it costs
  Faber's language identity plus an implied parity guarantee Triga does not
  honor.
- Receiver methods on `genus` are grammar-valid
  (`radix/EBNF.md:136-139`), have stdlib precedent (`norma/src/ordinata.fab`),
  and are already emitted by the TS backend. The shape is available; it is
  unused.

## Goals

- Fold the `vector3_*`, `matrix4_*`, `box3_*`, `camera_*`, `scene_*`,
  `geometry_*`, and `transform_payload_*` free-function families into receiver
  methods on their carrier genera, deleting the type prefix from every public
  operation name that has a receiver.
- Collapse the `scene_visible*` projection family into one query genus plus
  accessors so a frame traversal runs once per frame, not once per fact.
- Hold construction invariants inside genera (e.g. `Box3` rejects `min > max`)
  so accessors become total and the validation artifact nullability disappears.
- Run one vocabulary pass over the surviving names: Latinize operation/predicate
  stems per `radix/docs/stdlib/morphologia.md`; keep documented standard carrier
  nouns; fix the three stem violations that hold regardless of shape
  (`dot`→`productum`, `cross`→`transversum`, `normalizata`→`normata`).
- Write the accepted naming/shape policy as Triga API law so future additions
  have a rule to follow.
- Settle the three § 1a residual unknowns (cross-`triga:*` import of genus
  methods; `ego` mutation in a file-top-level user genus; genus placement) with
  one spike before any production layer is rewritten.

## Non-goals

- **`examples/triga-drift-city` migration.** Drift City breaks on purpose and is
  a separate follow-up goal in the `examples/` repo. Do not touch it from this
  goal.
- **Radix compiler work.** `de`-annotation cleanup depends on the separate
  `radix/docs/factory/pod-genus-copy-emit/goal.md`; do not strip `de` here.
- **Norma modifications.** § 1b may decide to *import* `norma:vector`, but no
  edit to `norma/` is in scope.
- **Frozen fact-genus fields (§ 1d).** Field names and numeric codes consumed by
  `radix/crates/radix-mir/src/abi.rs` (`format_code`, `step_mode_code`,
  `offset_bytes`, `stride_bytes`, `source_name`, topology/format/depth codes)
  stay frozen. Renaming them is an ABI change requiring lockstep radix work and
  is explicitly excluded.
- **Compatibility aliases.** No English→Latin alias shims. No old-name wrappers.
  Clean break.
- **Three.js material taxonomy redesign.** Carrier-noun keep/reconsider decisions
  (§ Axis 2 candidate tables) are resolved inside this goal, not spun out.

## Ground Truth Researched

- `triga/docs/api-vocabulary-proposal.md`: source proposal; both axes, per-layer
  sketches, surface budget, frozen-seam analysis, decision questions.
- `radix/EBNF.md:136-139`: `genusMember := annotation* (fieldDecl | methodDecl)`;
  `methodDecl` is grammar-valid on a user `genus`.
- `triga/src/triga.fab:1-3`: documented three.js-mirror intent this goal
  overturns; `:20-22` confirms file-top-level genus placement (residual unknown
  #3 is real).
- `norma/src/ordinata.fab:26-33`: user-space genus with receiver methods,
  reasoned against morphologia — precedent that mutation through `ego` works.
- `radix/crates/radix-codegen-ts/src/decl.rs:98-102`: TS backend emits genus
  methods as class members today.
- `radix/crates/radix-hir/src/nodes.rs:578`: `HirReceiver` has `None | Ref |
  MutRef | Owned` — static constructors and instance methods both supported.
- `radix/crates/radix-mir/src/abi.rs:2392-2408`: radix couples to Triga only via
  fact-struct field names and numeric codes, never by function name. Confirms
  the frozen-seam split.
- `radix/docs/stdlib/morphologia.md`: authority for public API shape; its
  examples are receiver methods (`xs.inversa()`, `solum.lege(path)`).
- Operator clarification 2026-07-27: scope is triga-only; Drift City breaks and
  is a follow-up; fact-genus fields stay frozen; `norma:vector` and scene-store
  persistence remain open decisions at goal level.

## Reference Packet

Before editing, inspect:

- `triga/docs/api-vocabulary-proposal.md`: the proposal; per-layer before/after
  sketches are the implementation authority.
- `triga/src/triga.fab`, `triga/src/scene.fab`, `triga/src/geometry.fab`: the
  three source files being rewritten.
- `triga/exempla/`: 12 `.fab` exempla that name public symbols and must track
  the rename. Before any rewrite, run `triga/scripta/check-exempla-inventory`
  (the repo's canonical exempla inventory, also invoked by `check-compile`) and
  map each exemplum to the public symbols it references. Files known to import
  `triga:`/`geometry:`/`scene:` symbols today:
  `triga-basics.fab`, `triga-math-edge-cases.fab`, `triga-transforms.fab`,
  `triga-types-untested.fab`, `triga-geometry-attributes.fab`,
  `triga-graphics-pipeline-facts.fab`, `triga-hello-voxel-pipeline.fab`,
  `triga-hello-voxel-shaders.fab`, `hello-voxel-first-draw-facts.fab`,
  `triga-scene-store.fab`, `triga-scene-store-empty.fab`,
  `triga-stage4-source-facts.fab`, `triga-vertex-fragment-stub.fab`.
- `triga/scripta/check-source`: repo source checker; gains a naming lint once
  vocabulary is accepted (open question #10).
- `radix/docs/stdlib/morphologia.md`: inflection/carrier-noun rules to honor.
- `norma/src/vector.fab` and `norma/src/ordinata.fab`: precedent for § 1b and
  receiver-method shape.
- `radix/crates/radix-mir/src/abi.rs`: the frozen seam — confirm no rename
  crosses it.

## Constraints And Invariants

- **Containment:** all edits land inside `triga/`. No edit to `examples/`,
  `radix/`, `norma/`, `hosts/`, or any other sibling repo.
- **Frozen ABI:** fact-genus field names and numeric codes consumed by radix MIR
  are exempt from the vocabulary pass until a lockstep radix change is planned.
- **One clean break (final committed state):** shape and vocabulary land
  together in the completed break, not two separate breaks. The proposal is
  explicit that Drift City cannot absorb two breaks; doing them separately also
  rewrites intermediate names twice. Factory phases may land incrementally
  during implementation; the break is complete only when all acceptance criteria
  pass. Intermediate phases are not a second break — they are progress toward
  the single break.
- **`de` stays:** do not strip `de` annotations. That cleanup is a radix goal.
- **Morphologia compliance:** one stem per operation; conjugated form carries
  posture (Imperativus mutates `varia` receiver ↔ Perfectum returns a copy); real
  Latin forms, no invented endings; no English aliases; technical loanwords
  acceptable where standard identity is the point.
- **Order:** shape (Axis 1) before vocabulary (Axis 2). Vocabulary-only would
  rename names the shape decision deletes.

## Supporting Skills

- `factory`: execute the spike, then the per-layer rewrite phases.
- `delivery`: lower each implementation slice into a repo-aware spec before
  factory (the layers have different risk profiles and the open decisions gate
  different layers).
- `clean-break`: this is a clean-break rework by intent; load to validate no
  compatibility shims survive.
- `poker-face`: audit the completed pass against this goal and the proposal
  before declaring done.
- `correctness`: the `Box3` invariant folding and scene-store mutability change
  are semantic; review for behavior preservation.

## Implementation Shape

- **Phase 0 — Spike (gates everything):** `Box3` as a `genus` with `continet`,
  `intersecat`, `infla`, `inflata`, plus a caller, inside `triga/exempla/`.
  Settles the three § 1a residual unknowns with evidence. No production rewrite
  yet.
- **Phase 1 — Open decisions:** resolve § 1b (`norma:vector` adoption vs own
  types) and § 1c (scene store persistent-by-intent vs free-function artifact).
  Both gate a specific layer (1b gates Layer 1; 1c gates Layer 3). Do not write
  the gated layer until its decision lands.
- **Phase 2 — Shape pass (Axis 1):** fold free-function families into receiver
  methods per the proposal's Layer 1–4 sketches, in dependency order, skipping
  any layer still gated by Phase 1.
- **Phase 3 — Vocabulary pass (Axis 2):** one rename sweep over the surviving
  names plus the three unconditional stem fixes, with the § 1d frozen-seam
  exemption applied.
- **Phase 4 — Policy law + lint:** write the accepted Triga API shape/vocabulary
  policy at `triga/docs/api-shape-policy.md` (the accepted law that supersedes
  `triga/docs/api-vocabulary-proposal.md`, which keeps its proposal status for
  revision history); add a naming lint to `triga/scripta/check-source` if the
  open question resolves yes.

## Release Posture

Decision: release prep only.

- This is a public-API break for any external `triga:*` consumer. There is
  exactly one known consumer (`examples/triga-drift-city`) and it is broken on
  purpose by this goal.
- No version bump, tag, or publication inside this goal. Surface the break
  honestly in the Drift City follow-up handoff and any triga changelog/README
  that claims a stable API.

## Exit Strategy

Decision: included.

- The work is a clean break with no compatibility layer, so the rollback is
  `git revert` of the break commit(s). Record the commit range in the goal
  closeout.
- If the spike (Phase 0) fails — genus methods do not export across `triga:*`,
  or `ego` mutation does not work at file top level — stop. The whole shape
  direction depends on it; do not paper over with free-function renames.

## Acceptance Criteria

- The § 1a spike is green and its evidence is recorded (the three residual
  unknowns answered yes/no with a cited exemplum).
- § 1b and § 1c are decided and the decision is recorded in the policy law.
- No public function in `triga/src/*.fab` carries a receiver-type prefix
  (`vector3_*`, `box3_*`, `scene_*`, `geometry_*`, etc.) except constructors and
  pure scalar helpers that the proposal names as legitimate free/static
  functions.
- The `scene_visible*` family is collapsed to one query genus plus accessors.
- `Box3` accessors that were nullable only as a re-validation artifact are total;
  genuine-absence nullability (e.g. `superpositio`) is preserved.
- The three unconditional stem fixes are in (`productum`, `transversum`,
  `normata`).
- No fact-genus field name or numeric code consumed by
  `radix/crates/radix-mir/src/abi.rs` was renamed.
- No `de` annotation was stripped.
- No compatibility alias or old-name shim exists.
- All `triga/exempla/` that name public symbols compile against the new surface.
- The accepted shape/vocabulary policy is written as Triga API law.

## Validation

- `triga/scripta/check-compile` is the canonical build gate. It parses
  `src/triga.fab`, `src/geometry.fab`, and the named exempla through the radix
  binary, runs the scene-store through the Faber provider path, and invokes
  `check-transforms` + `check-exempla-inventory`. It must pass after the break.
- `triga/scripta/check-source` should pass after the rename (and enforce the
  naming lint if Phase 4 question resolves yes).
- `grep -rnE 'functio (vector3|matrix4|box3|camera|scene|geometry|transform_payload)_' triga/src`
  should return only legitimate constructors/helpers explicitly named in the
  proposal's "stays free" list.
- `grep -rnE 'format_code|step_mode_code|offset_bytes|stride_bytes|source_name' triga/src`
  should show no renames relative to the pre-break tree.
- Manual review: a `poker-face` pass comparing the completed break against this
  goal and `api-vocabulary-proposal.md` before closeout.

## Open Questions

- **§ 1b — `norma:vector` adoption.** Adopt `vector<elem, N>` (deletes Layer 1,
  inherits SIMD lowering, splits the math surface across two idioms for
  `Matrix3/4`) or keep own `Vector2/3/4` types? Largest blast radius in the
  document. Default if unresolved: **keep own types** (self-contained idiom, no
  dependency on Norma register-lane maturity), but do not write Layer 1 until
  decided.
- **§ 1c — Scene store mutability.** Was the copy-out `SceneStore` pattern
  deliberate (persistent store for snapshots/undo/rollback) or an artifact of
  free-function shape? Default if unresolved: **artifact** (the failure signal
  is `SceneStore ∪ nihil`, an error channel not a version chain), but do not
  write Layer 3 until confirmed.
- **Naming lint.** Does `triga/scripta/check-source` gain a vocabulary lint once
  the policy is accepted? Default: **yes**, but deferred to Phase 4.
- **`BufferGeometry`, `Object3D`, three.js material names.** Keep for GPU/three.js
  familiarity or redefine as Faber-native taxonomy? Resolved inside the Phase 3
  vocabulary pass against the policy law, not deferred further.

## Stop Conditions

- Stop if the Phase 0 spike fails on any of the three § 1a residual unknowns —
  the entire shape direction is unproven until it passes.
- Stop if Phase 1 cannot resolve § 1b or § 1c without a cross-repo change (e.g.
  `norma:vector` adoption reveals a Norma gap that requires editing `norma/`).
  Escalate; do not silently widen scope.
- Stop if any proposed rename touches a § 1d frozen field without an authorized
  lockstep radix plan.
- Stop if Drift City breakage needs to be avoided — that reverses the agreed
  scope boundary and requires re-running goal-forge.
- Stop before any publication, version bump, or tag — this goal is release-prep
  only.
