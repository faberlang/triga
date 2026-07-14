# Stage 2 Generated-Rust Acceptance Attempt: Scene Identity

**Date**: 2026-07-13
**Scope**: provider-imported `exempla/triga-scene-store.fab`
**Result**: reduced blocker. Initial reusable Radix/Faber generated-Rust seams
were partially cleared on 2026-07-14; provider-imported generated-Rust
execution is still not accepted.

## Commands

From `/home/ianzepp/work/faberlang/triga`:

```bash
./scripta/check-source
./scripta/check-compile
FABER_LIBRARY_HOME=/home/ianzepp/work/faberlang \
  /home/ianzepp/work/faberlang/faber/target/debug/faber check \
  exempla/triga-scene-store.fab
FABER_LIBRARY_HOME=/home/ianzepp/work/faberlang \
  /home/ianzepp/work/faberlang/faber/target/debug/faber run --compile \
  exempla/triga-scene-store.fab
FABER_LIBRARY_HOME=/home/ianzepp/work/faberlang \
  /home/ianzepp/work/faberlang/radix/target/debug/radix check \
  exempla/triga-scene-store.fab
```

## Initial 2026-07-13 Evidence

- Existing Triga gates remain green: `check-source` and `check-compile` pass
  with existing unused-function warnings.
- Faber provider check is now green for
  `exempla/triga-scene-store.fab`: `ok: exempla/triga-scene-store.fab`.
- Initial generated-Rust acceptance was not green. `faber run --compile
  exempla/triga-scene-store.fab` reaches Cargo and fails generated Rust with:
  - unqualified cross-module imported field types: `Matrix4` appears inside
    generated `mod scene` as a bare type instead of `crate::triga::Matrix4` or
    an imported alias.
  - nullable return wrapping gaps: functions returning `T ∪ nihil` emit bare
    `ResourceHandle` / `Vec<SceneHandle>` returns in some paths instead of
    `Some(...)`.
- Direct Radix provider check reproduced the earlier interface residual:
  `WARN014.file_interface_export_skipped:scene.scene_node`, followed by
  `SEM004.unknown_field` on `SceneNode` fields and `SEM010` mismatches around
  `Matrix4`-backed calls.

## 2026-07-14 Reduced Blocker

Follow-up handoff evidence from Vivi task `8448830`:

- Radix focused tests passed:
  - `cargo test -p radix nullable_return_wraps -- --nocapture`
  - `cargo test -p radix nested_module_type_rendering_uses_unique -- --nocapture`
- Faber package compile passed:
  - `cargo check --manifest-path /home/ianzepp/work/faberlang/faber/Cargo.toml`
- Re-running provider-imported generated Rust with:

```bash
FABER_LIBRARY_HOME=/home/ianzepp/work/faberlang \
  cargo run -q --manifest-path /home/ianzepp/work/faberlang/faber/Cargo.toml -- \
  run --compile exempla/triga-scene-store.fab
```

no longer reports unresolved `Matrix4` types and no longer reports missing
`Some(...)` nullable returns. The remaining Cargo blocker is reduced to seven
Rust ownership/mutability errors:

- `src/main.rs:1659`: generated intra-library call to
  `crate::triga::matrix4_multiplicata((*parent_world),
  node.local_matrix.clone())` passes owned `Matrix4` values where generated
  Rust expects `&Matrix4`.
- `src/main.rs:409`, `414`, `419`: `world_store` is consumed by one negative
  assertion path and then reused.
- `src/main.rs:464`, `473`: `reparented_store` is consumed by a cycle-rejection
  assertion and then reused.
- `src/main.rs:324`, `495`: `attached_store` is consumed by
  `scene_set_local_matrix` and then reused later for cycle setup.
- `src/main.rs:869`: generated `handles.push(...)` mutates a parameter emitted
  as immutable.
- `src/main.rs:1604`: generated Rust moves out of borrowed `local_matrix`
  inside `scene_set_local_matrix`; it should clone or otherwise lower the
  borrowed value safely.

Direct Radix check remains a separate provider-interface residual:

```text
WARN014.file_interface_export_skipped:scene.scene_node
SEM004.unknown_field
SEM010.expression_type_mismatch / initializer_annotation_mismatch
```

## Next Producer Units

Triga-owned source/fixture review:

- Review `exempla/triga-scene-store.fab` as an executable acceptance fixture for
  value-consuming APIs. The current fixture reuses `SceneStore` values after
  calls that intentionally take store ownership. If the API ownership contract
  is correct, adjust the fixture to clone or rebuild stores for independent
  negative assertions instead of relying on post-move reuse. This is a tiny
  acceptance-fixture correction, not a scene model redesign.
- Review the `src/scene.fab` traversal helper that appends to `handles`; if the
  source declares immutable storage where mutation is intended, correct it in
  Triga source. If the source is already mutable and generated Rust drops that
  mutability, route it back to Radix.

2026-07-14 review result:

- Triga fixture/source corrections were made for the Triga-owned portion:
  `exempla/triga-scene-store.fab` now creates explicit store snapshots before
  independent assertions that consume `SceneStore`, and `src/scene.fab` now
  mutates a local traversal accumulator instead of the immutable `handles`
  parameter.
- Required Triga gates passed: `./scripta/check-source`,
  `./scripta/check-compile`, and Faber provider check for
  `exempla/triga-scene-store.fab`.
- Provider-imported generated Rust is reduced from seven errors to two:
  `matrix4_multiplicata((*parent_world), node.local_matrix.clone())` still
  passes owned `Matrix4` values where `&Matrix4` is expected, and
  `scene_set_local_matrix` still moves out of borrowed `local_matrix`.

Radix/Faber-owned next unit:

- Fix generated-Rust reference argument lowering for local and provider calls
  whose Faber params are `de`, including the intra-library
  `triga.matrix4_multiplicata(parent_world, node.local_matrix)` call.
- Fix borrowed-value lowering for struct fields populated from `de` params, as
  shown by `local_matrix = local_matrix` moving out of `&Matrix4`.
- Keep the direct provider-interface diagnostic set (`WARN014`/`SEM004`/`SEM010`)
  as a separate Radix/Faber provider interface task unless a Triga source error
  is proven by direct source inspection.

## Minimal Repros

Cross-module generated Rust type qualification:

```faber
# file: triga.fab
genus Matrix4 { lista<f32> elements }

# file: scene.fab
importa ex "triga:triga" privata triga
genus SceneNode {
    triga.Matrix4 local_matrix
}
```

Generated Rust currently places `SceneNode` inside `mod scene` with:

```rust
pub local_matrix: Matrix4
```

but `Matrix4` is defined in `crate::triga`, so Cargo reports
`cannot find type Matrix4 in this scope`.

Nullable field-load return wrapping:

```faber
genus Node { textus name }
genus Slot { Node node }
genus Store { lista<Slot> slots }

functio get(de Store store, numerus i) → Node ∪ nihil {
    si i >= store.slots.longitudo() ergo redde nihil
    redde store.slots[i].node
}
```

The generated Rust must return `Some(...node...)`; the scene acceptance failure
shows the same class in `scene_mesh_geometry`, `scene_mesh_material`, and
`scene_traverse`.

## Decision

Do not claim Stage 2 accepted yet. The scene identity model remains
Triga-source-complete, but provider-imported generated-Rust execution still
needs a final ownership/mutability pass. Triga should keep the scene exemplar as
the acceptance workload, make only fixture/source corrections that preserve the
public ownership contract, and route remaining generated-Rust lowering defects
to Radix/Faber rather than hiding them with Triga-specific rewrites.
