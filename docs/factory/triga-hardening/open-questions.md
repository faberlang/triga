# Triga Hardening — Stage 0 open questions

**Status**: recorded — Stage 0 answers and later-stage routings
**Date**: 2026-08-16
**Campaign**: [`CAMPAIGN.md`](./CAMPAIGN.md) §Open Questions
**Delivery**: [`delivery.md`](./delivery.md) unit `tgh-s0-4`
**Evidence basis**: delivery §3 live baseline and [`profile-v0.md`](./profile-v0.md)

This record answers only what the live Stage 0 evidence establishes. A routed
entry remains recorded here until its owning stage closes it. Stage 0 does not
invent later-stage policy values, proof results, or operator decisions.

## Q1 — Retain the default Core Graphics Profile v0, or reduce it?

**Status**: answered

**Decision**: **retain** the default profile, with the evidence-forced
refinements already frozen in [`profile-v0.md`](./profile-v0.md) §1:
one `MeshPhongMaterial` lit path rather than PBR, and ambient plus directional
lighting rather than `PointLight`.

The live 26-module tree has source facts for the retained perspective camera,
indexed triangle position/normal/UV geometry, model/view-projection transforms,
depth/culling policy, lit material, and ambient/directional-light rows. The
resize/device-loss row is hosts-owned, and the live host is explicitly in a
no-draw placeholder state. Those execution gaps are proof requirements for
Stages 5 and 7, not evidence for reducing the profile. The unsupported broad
horizon remains explicit in `profile-v0.md` §4, and the bounded draw
assumptions in §5 are not a stress contract.

## Q2 — Which NaN/Infinity behaviors are mathematical projections versus caller errors?

**Status**: answered

The Stage 0 policy default is to reject non-finite public inputs through typed
errors at Stage 2. A named degenerate value is preserved only where the live
operation already defines one. The live evidence shows why this policy is
needed: the Newton-style helpers in `src/math.fab`, `src/geometry/data.fab`,
and `src/primitives/basic.fab` have no finite-input guard; `_radix_f32` in
`src/math.fab:705` clamps values `≤ 0.0` to `0.0` but NaN propagates, and the
same family is used by the geometry and primitive helpers.

The named zero-length degenerates are retained: `Vector3.normata()` returns a
zero vector, and `Quaternion.normata()` returns the identity quaternion
`(0, 0, 0, 1)`. The per-operation acceptance/rejection table and typed-error
implementation are **routed to Stage 2**; those later proofs must not replace
the named degenerates with invented values.

## Q3 — Can current Faber express fixed-size matrix/transform storage directly?

**Status**: answered

**Yes.** The live Faber grammar has the fixed-size register matrix type
`matrix<T, [R, C]>` in the type table in `faber/docs/EBNF.md`. Triga's live
`Matrix3`/`Matrix4` and `TransformPayload` carriers are still `list<f32>` and
can therefore be constructed with arbitrary lengths today. The language has
an available fixed-size path; there is no Stage 0 compiler-expressiveness
blocker.

The migration to fixed-size storage versus private checked construction is
**routed to Stages 2/3**. The `_code` integer ABI facts are a separate frozen
contract and are not part of this matrix-storage decision. The independent
transform disagreement remains a live fact: Triga's canonical payload is 32
f32 / 128 bytes while the host reflection records 64 f32 / 256 bytes; Stage 7
owns the eventual versioned ABI resolution.

## Q4 — Does `faber test .` run co-located proba in this repository?

**Status**: answered

**No, not successfully.** The live sibling Faber binary exposes the `test`
subcommand, but the executed-proba tier is open in this repository:

- `faber test .` returns `cannot read '.' (os error 2)`.
- `faber test src/math.proba` returns an SEM001/SEM008 undefined-identifier
  cascade.

Thus `faber test .` does not currently provide co-located proba evidence, and
exempla compilation cannot substitute for assertions. The packaging/finder
contract and the canonical public gate are **routed to the Radix/Faber unit in
Stage 1**; until it closes, executed-proba evidence remains open.

## Q5 — Is `ResourceHandle` semantic identity only, with Hosts as the allocation/disposal authority?

**Status**: answered

**Yes at the live-fact level.** `src/resource.fab` has zero imports. Its
public `ResourceHandle` contains only a logical `index` and `generation`, and
the resource transition/lifecycle facts model replacement, creation, removal,
and stale-generation identity. No public resource genus contains a backend
object. The live Triga surface therefore describes semantic identity rather
than allocation or disposal, leaving Hosts as the allocation/disposal
authority by construction.

The formal boundary statement is **routed to Stage 4**. Replacement, teardown,
and device-loss proof of that boundary is **routed to Stage 7**, as required by
the campaign. Stage 0 does not claim those lifecycle proofs already pass.

## Q6 — Which published Faber artifact is available to public Triga CI and clean-install verification?

**Status**: routed

**None is available today.** The live Faber CLI is consumed from the private
Radix checkout, while the package facts in delivery §3.6 show no published
artifact for public CI or clean-install verification. Private-Radix local
evidence and public consumability must remain separate claims.

The public-CI posture and canonical artifact route are **routed to Stage 1**;
clean-install and package evidence are **routed to Stage 6**. No artifact name
or release claim is invented here.

## Q7 — Which license does the operator select for this public source package?

**Status**: routed

The live package has no `LICENSE`, and Stage 0 has no operator selection to
record. This is an operator decision, not a value the campaign may invent.
The license, package documentation, and aligned public support/release record
are **routed to Stage 6**.

## Q8 — What scene size, depth, geometry volume, frame/upload budget, and resource churn define the Profile v0 stress contract?

**Status**: routed

Stage 0 intentionally freezes no stress-contract values. [`profile-v0.md`](./profile-v0.md)
§5 records only bounded-draw assumptions: one small scene, one camera, one
directional light plus ambient light, at most one lit mesh, and no textures.
Those assumptions are explicitly not Stage 8 budgets. The live size facts
(`TRANSFORM_BYTE_LEN = 128` and `MAX_TRANSFORM_SEQUENCE = 600` in the host
engine, `vertex_count: 36` in host reflection, and Triga's transform count of
32) are recorded evidence, not selected stress thresholds.

Scene size/depth, geometry volume, frame/upload budget, and resource-churn
values are **routed to Stage 8**, which must freeze them before measuring.
