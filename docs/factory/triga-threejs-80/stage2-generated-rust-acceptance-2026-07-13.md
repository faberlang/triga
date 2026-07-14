# Stage 2 Generated-Rust Acceptance Attempt: Scene Identity

**Date**: 2026-07-13
**Scope**: provider-imported `exempla/triga-scene-store.fab`
**Result**: generated-Rust acceptance green after producer fixes and Triga
fixture correction on 2026-07-14. The direct Radix scene-store check is also
green in the current local workspace and is covered by `scripta/check-compile`.

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

## 2026-07-14 Reduced Blocker Before Triga Review

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

no longer reported unresolved `Matrix4` types and no longer reported missing
`Some(...)` nullable returns. Before Triga source/fixture review, the remaining
Cargo blocker was reduced to seven Rust ownership/mutability errors:

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

At that point, direct Radix check remained a separate provider-interface
residual:

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
- Keep any remaining provider-interface diagnostics as Radix/Faber tasks unless
  a Triga source error is proven by direct source inspection.

Historical queue-ready backlog packet before producer fix:

- **Owner**: Radix/Faber, not Triga.
- **Preconditions**: none from Triga; Stage 2 source/fixture ownership review is
  complete through `e26aabd`.
- **Repro**:

```bash
FABER_LIBRARY_HOME=/home/ianzepp/work/faberlang \
  cargo run -q --manifest-path /home/ianzepp/work/faberlang/faber/Cargo.toml -- \
  run --compile exempla/triga-scene-store.fab
```

- **Expected current result**: provider check passes, generated Rust reaches
  Cargo, and the Stage 2 blocker is down to two generated-Rust lowering defects:
  the intra-library `matrix4_multiplicata` call emits owned `Matrix4` arguments
  for `de Matrix4` params, and `scene_set_local_matrix` moves out of borrowed
  `local_matrix`.
- **Historical separate residual**: at this point, direct Radix provider check
  still owned `WARN014.file_interface_export_skipped:scene.scene_node` plus
  downstream `SEM004`/`SEM010` diagnostics.

## 2026-07-14 Acceptance Result

After Radix/Faber producer fixes at Radix `7d32673f8`, generated Rust reached
runtime and exposed one Triga-owned fixture assertion bug:

```text
thread 'main' panicked at src/main.rs:456:5:
reparent removes old edge
```

The failing assertion expected the old root to have zero children after
reparenting `mesh` under `group`. That expectation was too strong: the old root
should lose only the moved `mesh` edge while preserving the `shared-mesh`,
`camera`, and `light` siblings in order. The fixture now asserts that remaining
sibling list instead.

Validation after the Triga fixture fix:

```bash
./scripta/check-source
./scripta/check-compile
FABER_LIBRARY_HOME=/home/ianzepp/work/faberlang \
  cargo run -q --manifest-path /home/ianzepp/work/faberlang/faber/Cargo.toml -- \
  check exempla/triga-scene-store.fab
FABER_LIBRARY_HOME=/home/ianzepp/work/faberlang \
  cargo run -q --manifest-path /home/ianzepp/work/faberlang/faber/Cargo.toml -- \
  run --compile exempla/triga-scene-store.fab
```

All four commands pass. The generated-Rust scene identity acceptance gate is
green.

Current direct Radix check:

```bash
FABER_LIBRARY_HOME=/home/ianzepp/work/faberlang \
  cargo run -q -p radix --bin radix \
  --manifest-path /home/ianzepp/work/faberlang/radix/Cargo.toml -- \
  check exempla/triga-scene-store.fab
```

now passes for `exempla/triga-scene-store.fab`. This direct source-interface
probe is included in `scripta/check-compile` so Triga's Stage 2 evidence cannot
drift behind the local Radix provider-interface behavior.

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

The historical generated Rust failure placed `SceneNode` inside `mod scene`
with:

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

The Stage 2 generated-Rust scene identity gate is accepted: the provider
package path builds and runs `exempla/triga-scene-store.fab` assertions without
a host-side graph or Triga-specific compiler branch. Keep the separate direct
Radix provider-interface diagnostics routed to Radix/Faber.
