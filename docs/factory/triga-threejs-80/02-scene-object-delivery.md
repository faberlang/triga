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

## Stop Condition

Do not introduce numeric list indexes, copied `discretio` payload graphs,
backend handles, or compatibility wrappers around `Object3D.children` as an
interim identity model. The next Triga source change waits on the reusable
identity contract.
