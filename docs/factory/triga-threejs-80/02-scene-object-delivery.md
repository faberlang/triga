# Stage 2 Delivery: Scene Identity Foundation

## Interpreted Unit

Select and prove the identity and ownership representation that can support a
heterogeneous scene graph without copying nodes, geometry, or materials. This
discovery unit precedes traversal and transform propagation because those
algorithms must operate on stable identities rather than list positions.

## Invariant

Every scene node and shared resource has stable identity independent of list
position, and graph edits preserve that identity without host-owned shadow
objects or value-copy aliases.

## Current Evidence

- `Object3D.children` is `lista<Object3D>`, so it cannot contain meshes,
  cameras, lights, or future node families.
- `discretio` can describe heterogeneous variants, but payloads remain values;
  wrapping current records would copy embedded objects and resources.
- `cura "arena"` is documented as a design target and a Rust no-op warning, not
  a portable identity or reference contract.
- Integer list positions are not identities: removal and reordering would make
  them stale or silently retarget them.

## Bounded First Unit

1. Radix defines a reusable stable-reference or arena-handle contract with
   explicit allocation, lookup, stale-handle rejection, and generated-Rust
   execution semantics.
2. Prove recursive heterogeneous payloads can store those handles through
   `discretio` without deep-copying the referenced values.
3. Triga then replaces `lista<Object3D>` with a canonical scene store and node
   references covering at least group, mesh, camera, and light variants.
4. Add operations for add, remove, reparent, ordered traversal, and cycle
   rejection before world-transform propagation begins.

## Acceptance Evidence

- Two nodes may share one geometry and material identity.
- Reparenting preserves node and resource identities.
- Removing or reordering siblings does not retarget references.
- Stale references and cycles fail explicitly.
- Provider-imported generated Rust builds and runs the same assertions without
  a host-side graph or Triga-specific compiler branch.

## Current Status

Triga-owned source is complete on the packet through `15edfbf`: the public
scene store and executable exemplar cover the graph, identity, traversal,
transform, resource-sharing, and rejection behavior above. Acceptance remains
open until the provider-imported generated Rust builds and runs those assertions
without a host-side graph or Triga-specific compiler branch.

## World-Transform Unit

Scene nodes now carry explicit local and derived world matrices. Updating a
root walks children in stored order, composes parent-before-child transforms,
and clears dirty state on the same stable handles. Local edits and graph edits
dirty the affected subtree; stale roots, non-root entry points, malformed
matrices, cycles, and removal of parents with live children reject explicitly.

## Ordered-Traversal Unit

`scene_traverse` exposes deterministic parent-before-child traversal in stored
sibling order while preserving stable handles. Stale roots, stale child edges,
cycles, and repeated identities reject explicitly instead of returning a
partial or ambiguous traversal.

## Heterogeneous-Resource Unit

Group, mesh, camera, and light nodes now share one canonical scene store and
ordered hierarchy. Mesh payload accessors expose geometry and material handles
without copying resources, and the executable scene exemplar proves that two
mesh nodes retain identical resource generations while coexisting with camera
and light siblings.

## Stable-Lookup Unit

`scene_find_name` resolves the first matching node in deterministic preorder and
returns its stable handle rather than a copied node or list position. Lookup
validates the full traversal, rejects stale roots and malformed graph edges, and
the executable scene exemplar proves lookup through a multilevel hierarchy.

## Provider-Interface Validation Residual

The public scene source and its exemplar remain a distinct upstream validation
residual. `scripta/check-compile` intentionally covers the passing Triga math
and geometry targets while excluding `exempla/triga-scene-store.fab`: the
provider-imported check currently reports `SEM004`/`SEM010` diagnostics for
scene-node fields and Matrix4-backed calls. This is tracked by upstream Vivi
need `bac61aa`; the exclusion is not a passing claim, and Stage 2 acceptance
remains open until the scene exemplar compiles and runs through the provider
path.

The 2026-07-13 generated-Rust acceptance attempt is recorded in
[`stage2-generated-rust-acceptance-2026-07-13.md`](stage2-generated-rust-acceptance-2026-07-13.md):
Faber provider check now accepts the exemplar, but generated Rust still fails
on reusable cross-module nominal type qualification and nullable return wrapping
gaps, while direct Radix provider check still reproduces the earlier
`SEM004`/`SEM010` residual.

## Stop Condition

Do not introduce numeric list indexes as identity, copied `discretio` payload
graphs, backend handles, or compatibility wrappers around `Object3D.children`.
Do not claim Stage 2 accepted until the generated-Rust execution evidence proves
the identity contract at the reusable language/runtime seam.
