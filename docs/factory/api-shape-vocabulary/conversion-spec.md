# Triga API Conversion Spec — Shape + Vocabulary Pass

## Conversion Pattern (established by Vector3 + Box3 spike)

### Free function → receiver method

**Before:**
```fab
genus Vector3 { f32 x, f32 y, f32 z }

functio vector3_addita(de Vector3 a, de Vector3 b) → Vector3 {
    redde vector3(a.x + b.x, a.y + b.y, a.z + b.z)
}
```

**After:**
```fab
genus Vector3 {
    f32 x
    f32 y
    f32 z

    functio addita(de Vector3 alter) → Vector3 {
        redde vector3(ego.x + alter.x, ego.y + alter.y, ego.z + alter.z)
    }
}
```

### Rules

1. **Drop type prefix:** `vector3_addita` → `addita`. `box3_continet` → `continet`.
2. **First argument becomes `ego`:** `de Vector3 a` → `ego`. Other params keep their `de`/`in`/`ex` mode.
3. **Body uses `ego` for the receiver:** replace `a.x` with `ego.x`, etc.
4. **Constructors stay free:** `vector3(x, y, z)` remains a top-level function. Also `box3_ex_minimo_et_maximo(...)` etc. — but these may become static methods if the compiler supports it. For now, keep as free functions with type-prefixed names.
5. **Pure scalar helpers stay free:** `_radix_f32`, `_sinus_f32`, `_cosinus_f32`, `radians_ex_gradibus`.
6. **Internal method calls:** to call another method on the same type from within a method, use `ego.methodname(args)`. To call on a parameter, use `param.methodname(args)`.
7. **Internal constructor calls:** `vector3(x, y, z)` (the free constructor) is callable from within genus methods — proven by the spike.

### Vocabulary changes (apply during conversion)

| Old stem | New stem | Reason |
|---|---|---|
| `dot` | `productum` | Match norma:vector |
| `cross` | `transversum` | Match norma:vector |
| `normalizata` | `normata` | `normalizare` is not a real Latin verb |

Other English→Latin stem fixes (apply where they appear):
- `valid` → `valida` (predicate adjective)
- `get` → `cape`
- `find` → `inveni`
- `contains` → `continet`
- `insert` → `insere`
- `attach` → `adiunge`
- `detach` → `seiunge`
- `remove` → `detrahe`
- `forward` → `prorsum`
- `right` → `dextra`

### Frozen ABI (DO NOT RENAME)

These fact-genus field names are consumed by `radix/crates/radix-mir/src/abi.rs` and must not change:
- `format_code`, `step_mode_code`, `offset_bytes`, `stride_bytes`, `source_name`
- `primitive_topology_code`, `color_target_format_code`
- Any field ending in `_code` on a fact genus

### Already completed in triga.fab

- `Vector3` genus: 10 methods added (addita, subtracta, multiplicata, productum, transversum, longitudo, normata, distantia, interpolata, projecta). Old vector3_* free functions deleted (except constructor `vector3()` and `_radix_f32`).
- `Box3` genus: 4 spike methods added (continet, intersecat, inflata, infla). Old box3_* free functions still exist alongside.

### § 1b decision: KEEP OWN TYPES

Vector2/3/4, Matrix3/4, Quaternion stay as Triga genera. No norma:vector adoption.

### § 1c decision: ARTIFACT (Imperativus)

Scene store copy-out was an artifact of free-function shape. Convert to Imperativus (in-place mutation on varia receiver). `SceneInsert` genus deleted. `scene_insert` → `SceneStore.insere()` returns `SceneHandle` only.
