# Stage 2 Generated-Rust Acceptance Attempt: Scene Identity

**Date**: 2026-07-13
**Scope**: provider-imported `exempla/triga-scene-store.fab`
**Result**: blocked at reusable Radix/generated-Rust seams; no Triga source
workaround admitted

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

## Evidence

- Existing Triga gates remain green: `check-source` and `check-compile` pass
  with existing unused-function warnings.
- Faber provider check is now green for
  `exempla/triga-scene-store.fab`: `ok: exempla/triga-scene-store.fab`.
- Generated-Rust acceptance is not green. `faber run --compile
  exempla/triga-scene-store.fab` reaches Cargo and fails generated Rust with:
  - unqualified cross-module imported field types: `Matrix4` appears inside
    generated `mod scene` as a bare type instead of `crate::triga::Matrix4` or
    an imported alias.
  - nullable return wrapping gaps: functions returning `T ∪ nihil` emit bare
    `ResourceHandle` / `Vec<SceneHandle>` returns in some paths instead of
    `Some(...)`.
- Direct Radix provider check still reproduces the earlier interface residual:
  `WARN014.file_interface_export_skipped:scene.scene_node`, followed by
  `SEM004.unknown_field` on `SceneNode` fields and `SEM010` mismatches around
  `Matrix4`-backed calls.

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
Triga-source-complete, but generated-Rust/provider execution needs reusable
Radix/Faber fixes for imported nominal type qualification and nullable return
wrapping. Triga should keep the scene exemplar as the acceptance workload and
avoid source-only rewrites that hide these language/runtime seams.
