# Goal 02: Scene Graph And Object Model

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `radix` when language ownership/identity facts are missing, `faber-runtime`, `examples`
**Depends on**: Goals 00–01
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first for identity; batch-by-default afterward

## Purpose

Replace the initial homogeneous `lista<Object3D>` sketch with a usable,
heterogeneous scene model that stresses Faber identity, recursive data,
ownership, mutation, traversal, and shared-resource semantics.

## Invariant

Scene hierarchy and resource identity are explicit language/runtime facts;
renderers consume the graph but do not invent, clone, or privately reinterpret
it.

## Scope

- Select an object identity and ownership model for scenes, groups, meshes,
  cameras, lights, lines, points, bones, and future node families.
- Support parent/child add, remove, reparent, lookup, traversal, visibility,
  layers/tags, names, and stable local/world transform propagation.
- Permit geometry and material sharing without deep-copying resources on scene
  mutation.
- Define lifecycle/dirty-state boundaries required by render caches while
  keeping backend handles out of the public object model.
- Provide deterministic traversal/update ordering and cycle rejection.
- Route missing reusable discriminated-data, reference, arena, or ownership
  facts to Radix rather than building a host-only object system.

Out of scope: renderer scheduling, full event dispatch, editor undo/redo, and
network replication.

## Gate

- A heterogeneous multilevel scene supports reparenting and deterministic world
  transform updates.
- Shared geometry/material identity survives graph edits and generated-code
  execution.
- Cycles, stale identities, invalid parentage, and illegal concurrent mutation
  fail clearly.
- The hierarchical lit-scene capstone can use the public model without a shadow
  host graph.

## Stop Conditions

- `Object3D` children remain unable to hold renderable/camera/light families.
- Host-language objects become the authoritative scene graph.
- Identity is inferred from list position or copied value equality.
- Compiler changes are specialized to the Triga type names instead of reusable
  language semantics.
