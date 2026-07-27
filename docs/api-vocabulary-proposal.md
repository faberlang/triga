# Triga API Shape And Vocabulary Proposal

**Status:** proposal — shape direction endorsed, vocabulary still open  
**Date:** 2026-07-27  
**Revisions:**

- 2026-07-27 — restructured so API shape decisions precede vocabulary decisions
- 2026-07-27 — receiver-method shape promoted from open question to proposed
  design with concrete per-layer sketches; codegen, receiver-mode, and MIR-ABI
  evidence added; frozen-seam and `de`-annotation sections added

**Scope:** public `triga:*` source-library surface, especially `triga/src/*.fab`
and early users such as `examples/triga-drift-city`

## Summary

Triga's public API diverges from Norma on **two independent axes**, decided in
order:

| Axis | Question | Status | Blast radius |
| --- | --- | --- | --- |
| **Shape** | Free functions with type-name prefixes, or receiver methods on `genus`? Own math types, or `norma:vector`? | Receiver methods **endorsed as direction**; carrier-type and mutability questions open | Rewrites or deletes most public names |
| **Vocabulary** | Latin, English/WebGPU, or technical-Latin hybrid spelling? | Open | Renames the names that survive |

An earlier draft treated only the vocabulary axis. That was the wrong starting
point. Most of the names that read worst today (`box3_continet_box3`,
`matrix4_applica_punctum`, `geometry_payload_byte_count`) are ugly because of
**shape**, not because of English words. Deciding vocabulary first means renaming
names the shape decision would have deleted, and rewriting
`examples/triga-drift-city` twice.

**Endorsement note:** the receiver-method direction in § 1a was reviewed and
endorsed by the operator on 2026-07-27. That endorses the *direction*, not an
implementation authorization. The residual unknowns in § 1a still need a spike,
and §§ 1b–1c remain genuinely open.

## Why this matters now

`examples/triga-drift-city` has started using Triga directly for a
browser/WebGPU proof of concept. It is roughly 2,000 lines of `.fab` across
`src/` and `tests/`, depending on about 32 distinct public Triga names,
including:

- `triga.Box3`, `triga.Vector3`, `triga.Matrix4`, `triga.TransformPayload`
- `triga.camera_forward_planus_ex_yaw`, `triga.vector3_dot`, `triga.matrix4_composita`
- `geometry.BufferGeometry`, `geometry.geometry_vertex_payload_byte_count`

The proof of concept is still young enough to absorb one clean break. It is not
young enough to absorb two.

## What the current design already claims

The three.js-shaped names are not drift. They are stated intent:

```1:5:triga/src/triga.fab
# src/triga.fab — Geometry, math, scene, and material types for Faber's GPU lane
#
# Shapes modeled closely after three.js abstractions for LLM familiarity
# and migration ease. Not a binding to three.js — these are native Faber
# types that define the data contract between compiled Faber output and
```

The same header partitions three.js mirror types into `triga.fab` and forbids
them in `geometry.fab`. Any proposal to Latinize type names is therefore a
proposal to **overturn a documented design decision**, and must argue against it
rather than treat the current names as unexamined legacy.

The counter-argument: "LLM familiarity and migration ease" was a bet made before
Triga had real consumers. It buys discoverability for graphics developers
arriving from three.js, and costs Faber's language identity plus an implied
parity guarantee Triga does not intend to honor. That trade is worth re-opening,
but explicitly.

## Existing policy context

`radix/docs/stdlib/morphologia.md` is the authority for public API shape in
Faber. Its central claim is **not** "use Latin words." It is that **inflection
carries behavior**:

- one stem per operation; conjugated form carries posture
- Axis A: time and flow (sync/async × finite/stream)
- Axis B: result ownership (Imperativus mutates receiver ↔ Perfectum returns a copy)
- one Latin word when possible; `snake_case` only when one word cannot carry the meaning
- real Latin forms, not invented endings
- no Latin paint: do not calque English APIs into Latin-looking tokens
- no same-behavior aliases
- technical loanwords acceptable where the standard identity is the point

Norma is not perfectly pure. It keeps `json`, `toml`, `yaml`, `http`,
`sgd_step`, and `safetensors` where the standard matters. Those are useful
precedent for Triga's carrier nouns.

The load-bearing point for Triga: **morphologia is written for receivers.** Its
examples are `xs.inversa()`, `n.addita(2)`, `solum.lege(path)`,
`conn.quaeret(sql)`. Triga has no receivers.

---

# Axis 1 — API shape

## 1a. Receiver methods on `genus` (proposed design)

### The problem

Every public operation in Triga is a top-level `functio` that carries its
receiver type in the name as a prefix:

| File | Public `functio` count |
| --- | --- |
| `src/triga.fab` | 110 |
| `src/scene.fab` | 85 |
| `src/geometry.fab` | 86 |

That prefix is the source of the worst names. The type appears in the function
name, and for overload disambiguation the argument type appears again
(`box3_continet_box3`, `ray_intersecat_box3`).

### The shape is available

Four independent pieces of evidence, not one grammar reading.

**Grammar.** `radix/EBNF.md` allows methods on a user `genus`:

```136:137:radix/EBNF.md
genusDecl    := 'abstractus'? 'genus' IDENTIFIER genericParams? ('sub' IDENTIFIER)? ('implet' IDENTIFIER (',' IDENTIFIER)*)? '{' genusMember* '}'
genusMember  := annotation* (fieldDecl | methodDecl)
```

**Stdlib precedent.** `norma/src/ordinata.fab` is a user-space genus with
receiver methods, reasoned explicitly against morphologia:

```26:33:norma/src/ordinata.fab
# Morphologia: receiver methods on the Ordinata<K, V> genus (implicit ego),
# matching how the builtin tabula<K, V> exposes its surface (myOrdinata.pone(),
# myOrdinata.accipe(), ...). Stems reuse builtin tabula stems where the
# operation is identical (pone, accipe, dele, habet) so users cross-walking
# between tabula and ordinata see the same verbs. Imperativus for in-place
# mutation (varia receiver required); nominal for projections (longitudo,
# claves, valores); the sorted-iteration surface (claves, valores, fines) is
# what ordinata adds on top of tabula.
```

**Browser-lane codegen.** The TypeScript backend emits genus methods as class
members, and receiver analysis runs before emit:

```98:102:radix/crates/radix-codegen-ts/src/decl.rs
/// Emits a HIR struct as a TypeScript class declaration.
///
/// Faber receiver analysis has already decided whether methods are instance or
/// static members. This emitter reflects that decision directly and leaves
/// object-layout validity to earlier semantic passes.
```

**Receiver modes.** `HirReceiver` in `radix/crates/radix-hir/src/nodes.rs:578`
has four cases — `None`, `Ref`, `MutRef`, `Owned`. Two consequences: `ego`
carries the same `de` / `in` / `ex` semantics as a parameter, which is how the
Imperativus/Perfectum split below is expressed; and `None` means **static
methods exist**, so constructors do not have to stay free functions.

### Layer 1 — Math carriers

Today the type is repeated in the name and the receiver is the first argument:

```564:582:triga/src/triga.fab
functio vector3_addita(de Vector3 a, de Vector3 b) → Vector3 {
    redde vector3(a.x + b.x, a.y + b.y, a.z + b.z)
}

functio vector3_subtracta(de Vector3 a, de Vector3 b) → Vector3 {
    redde vector3(a.x - b.x, a.y - b.y, a.z - b.z)
}

functio vector3_multiplicata(de Vector3 v, f32 scalar) → Vector3 {
    redde vector3(v.x * scalar, v.y * scalar, v.z * scalar)
}

functio vector3_dot(de Vector3 a, de Vector3 b) → f32 {
    redde (a.x * b.x + a.y * b.y) + a.z * b.z
}
```

Folded into the genus:

```fab
genus Vector3 {
    f32 x
    f32 y
    f32 z

    functio addita(de Vector3 alter) → Vector3 {
        redde vector3(ego.x + alter.x, ego.y + alter.y, ego.z + alter.z)
    }

    functio subtracta(de Vector3 alter) → Vector3 {
        redde vector3(ego.x - alter.x, ego.y - alter.y, ego.z - alter.z)
    }

    functio multiplicata(f32 scalar) → Vector3 {
        redde vector3(ego.x * scalar, ego.y * scalar, ego.z * scalar)
    }

    functio productum(de Vector3 alter) → f32 {
        redde (ego.x * alter.x + ego.y * alter.y) + ego.z * alter.z
    }

    functio transversum(de Vector3 alter) → Vector3 { … }
    functio longitudo() → f32 { … }
    functio normata() → Vector3 { … }
    functio distantia(de Vector3 alter) → f32 { … }
    functio interpolata(de Vector3 alter, f32 ratio) → Vector3 { … }
    functio projecta(de Vector3 axis) → Vector3 { … }
}
```

Same ten operations, same bodies, no prefix. The only vocabulary decisions that
survive this layer are the three real stem fixes in Axis 2: `dot` → `productum`,
`cross` → `transversum`, `normalizata` → `normata`.

This entire layer is **deleted rather than converted** if § 1b adopts
`norma:vector`.

### Layer 2 — `Box3`, and the nullable cleanup

This is where shape buys the most. `box3_validum` is called at the top of nearly
every `Box3` function, and eight of the seventeen return `∪ nihil` only because
validity is re-checked per call:

```794:802:triga/src/triga.fab
functio box3_mensura(de Box3 bounds) → Vector3 ∪ nihil {
    si box3_validum(bounds) ≡ falsum ergo redde nihil
    redde vector3_subtracta(bounds.max, bounds.min)
}

functio box3_centrum(de Box3 bounds) → Vector3 ∪ nihil {
    si box3_validum(bounds) ≡ falsum ergo redde nihil
    redde vector3_multiplicata(vector3_addita(bounds.min, bounds.max), 0.5)
}
```

Validity is already established at construction — `box3_ex_minimo_et_maximo`
returns `Box3 ∪ nihil` and rejects `min > max`. But a bare
`Box3 { min = …, max = … }` literal bypasses that, so every accessor re-checks.
Hold the invariant at construction and the accessors become total:

```fab
genus Box3 {
    Vector3 min
    Vector3 max

    # Constructors reject min > max; accessors below assume the invariant.
    functio mensura() → Vector3 {
        redde ego.max.subtracta(ego.min)
    }

    functio centrum() → Vector3 {
        redde ego.min.addita(ego.max).multiplicata(0.5)
    }

    functio continet(de Vector3 punctum) → bivalens { … }

    functio continet_capsam(de Box3 alia) → bivalens {
        redde ego.continet(alia.min) et ego.continet(alia.max)
    }

    functio intersecat(de Box3 alia) → bivalens { … }

    # Stays nullable: nihil means the boxes do not overlap. Real absence.
    functio superpositio(de Box3 alia) → Vector3 ∪ nihil { … }

    functio unio(de Box3 alia) → Box3 { … }

    functio infla(f32 amount) → vacuum { … }      # Imperativus, varia receiver
    functio inflata(f32 amount) → Box3 { … }      # Perfectum, copy-out
    functio transfer(de Vector3 offset) → vacuum { … }
    functio translata(de Vector3 offset) → Box3 { … }
}
```

Not every `∪ nihil` here is shape debt, and the distinction matters:
`superpositio` stays nullable because non-overlap is genuine absence, while
`mensura` and `centrum` stop being nullable because their nullability was only
ever a re-validation artifact.

Three further consequences. `box3_continet_box3` becomes `continet_capsam`
because the receiver type no longer needs stating. `box3_superpositio_x`, `_y`,
and `_z` — three functions that each recompute the whole overlap to read one
field — are deleted, since the caller writes
`bounds.superpositio(alia)!.x`. And chaining replaces inside-out nesting:

```fab
# now
vector3_multiplicata(vector3_addita(bounds.min, bounds.max), 0.5)

# proposed
ego.min.addita(ego.max).multiplicata(0.5)
```

### Layer 3 — `SceneStore` and in-place mutation

Because free functions cannot mutate, every scene edit rebuilds the store.
`scene_insert` copies the entire slot list one element at a time:

```700:713:triga/src/scene.fab
functio scene_insert(SceneStore store, SceneNode node) → SceneInsert {
    varia lista<SceneSlot> slots ← vacua
    varia numerus i ← 0
    dum i < store.slots.longitudo() {
        slots.appende(store.slots[i])
        i ← i + 1
    }
    fixum numerus index ← slots.longitudo()
    slots.appende(SceneSlot { generation = 0, alive = verum, node = node })
    redde SceneInsert {
        store = SceneStore { slots = slots },
        handle = SceneHandle { index = index, generation = 0 }
    }
}
```

`scene_attach` is worse: it hand-copies two `SceneNode` structs field by field
just to change a parent pointer, and returns `SceneStore ∪ nihil` where `nihil`
means the attach failed. As Imperativus on a `varia` receiver:

```fab
genus SceneStore {
    lista<SceneSlot> slots = vacua

    functio insere(SceneNode nodus) → SceneHandle {
        fixum numerus index ← ego.slots.longitudo()
        ego.slots.appende(SceneSlot { generation = 0, alive = verum, node = nodus })
        redde SceneHandle { index = index, generation = 0 }
    }

    functio adiunge(de SceneHandle filius, de SceneHandle parens) → bivalens { … }
    functio seiunge(de SceneHandle filius) → bivalens { … }
    functio detrahe(de SceneHandle manubrium) → bivalens { … }
    functio continet(de SceneHandle manubrium) → bivalens { … }
    functio cape(de SceneHandle manubrium) → SceneNode ∪ nihil { … }
}
```

Thirteen lines become four, and three things are deleted outright: the
`SceneInsert` genus (`src/scene.fab:66`), which exists only to return a store and
a handle together; the clone-per-edit; and the `SceneStore ∪ nihil`
return-the-whole-world pattern, replaced by a `bivalens` success flag.

**This layer depends on § 1c** and must not be implemented before it is
answered. If returning a fresh store was a deliberate persistent-data-structure
choice, Imperativus is the wrong call.

### Layer 4 — Projection families collapse

`src/scene.fab` has fourteen functions in the `scene_visible*` family:
`scene_visible_traverse`, `scene_visible_mesh_traverse`, then `_count`,
`_resources`, `_resource_pair_count`, `_geometry_handles`, `_material_handles`,
`_resource_facts`, `_transform_payloads`, `_transform_payload_count`,
`_transform_payload_byte_count`, `_draw_packets`, `_draw_packet_count`, and
`_draw_batch_facts`. Each one re-walks the scene graph to project a different
fact from the same work.

One query object replaces the family:

```fab
genus VisibiliaRetium {
    lista<SceneHandle> manubria = vacua
    lista<TransformPayload> onera = vacua

    functio numerus() → numerus { … }
    functio geometriae() → lista<ResourceHandle> { … }
    functio materiae() → lista<ResourceHandle> { … }
    functio octeta() → numerus { … }
    functio ductus() → lista<DrawPacket> { … }
}
```

with a single entry point on the store:

```fab
functio visibilia(de SceneHandle radix) → VisibiliaRetium ∪ nihil { … }
```

Fourteen names become one method plus five accessors, and the traversal runs once
per frame instead of once per fact. The same pattern applies to the thirty-three
`geometry_*` functions in `src/geometry.fab` (methods on `BufferGeometry`) and the
five `transform_payload_*` functions (methods on `TransformPayload`).

### Surface budget

Estimates, not a counted plan:

| Family | Now | Proposed |
| --- | --- | --- |
| `vector3_*` | 10 | 10 methods on `Vector3`, or deleted if § 1b adopts `norma:vector` |
| `matrix4_*` | 12 | 12 methods on `Matrix4` |
| `box3_*` | 17 | ~12 methods; drop the three `superpositio_` field readers, fold `validum` into the invariant |
| `camera_*` | 11 | methods on the camera genera plus a few free angle helpers |
| `scene_visible*` | 14 | 1 method + ~5 accessors on a query genus |
| `geometry_*` | 33 | methods on `BufferGeometry` |
| `transform_payload_*` | 5 | 5 methods on `TransformPayload` |
| **Total public** | **281** | **~230, none carrying a type prefix** |

### What stays a free or static function

Constructors, because there is no receiver yet: `vector3(x, y, z)`,
`box3_ex_centro_et_mensura(...)`, `matrix4_conspectus(eye, target, up)`. These
keep a type prefix, and that is correct — the prefix does real work when it names
the thing being built. Because `HirReceiver::None` exists, they may alternatively
become static members (`Box3.ex_centro_et_mensura(...)`); that is a style choice
for the delivery spec, not a blocker.

Pure scalar helpers stay free: `radians_ex_gradibus`, `_sinus_f32`,
`_cosinus_f32`, `_radix_f32`.

### Residual unknowns for the spike

The earlier draft treated codegen support as the main risk. It is not — the TS
backend emits genus methods today. What remains unverified:

1. Whether a Triga `genus` with methods **exports across the `triga:*` import
   boundary**. `radix/crates/radix-codegen-rust/src/import_params.rs:254`
   documents a flat mapping in which functions become `crate::triga::vector3` and
   types become `crate::triga::Vector3`; method resolution through that seam is
   untested from Triga.
2. Whether **mutation through `ego`** works for Imperativus forms in a
   user-space genus, or whether it is limited to builtin receivers. `ordinata.fab`
   suggests it works, but Triga's own genera live at file top level outside a
   `modulus`, which is a different arrangement.
3. Whether the file-top-level `genus` placement noted in `src/triga.fab:20-22`
   interacts with method declarations.

A one-genus spike settles all three cheaply: `Box3` with `continet`,
`intersecat`, `infla`, and `inflata`, called from `examples/triga-drift-city`.

## 1b. Own math types vs `norma:vector` (open)

Triga imports nothing from Norma. Its only imports are `triga:geometry` and
`triga:triga`. It defines `genus Vector3 { f32 x, f32 y, f32 z }` and hand-rolls
vector math.

Norma already ships vector operations over a compiler-owned register type:

```21:27:norma/src/vector.fab
functio productum<elem, magnitudo N>(vector<elem, N> a, vector<elem, N> b) → elem {
    redde a.productum(b)
}

functio transversum<elem>(vector<elem, 3> a, vector<elem, 3> b) → vector<elem, 3> {
    redde a.transversum(b)
}
```

So the question is not how to spell `vector3_dot`. It is **whether
`triga.Vector3` should exist at all**, or whether Triga's math carriers should be
`vector<f32, 3>` and `vector<f32, 4>` with the operations Norma already has.

| Option | Gain | Cost |
| --- | --- | --- |
| **Adopt `vector<elem, N>`** | Deletes Layer 1 entirely (~30 functions); inherits SIMD register lowering; automatic Norma naming consistency | Field access shape changes (`.x`/`.y`/`.z` vs swizzle); `Matrix3`/`Matrix4` have no Norma equivalent, so the math surface splits across two idioms |
| **Keep own types** | One self-contained idiom; explicit named fields; no dependency on Norma's register lane maturity | Duplicated math; permanent divergence from Norma naming; no SIMD lowering |

This has the largest blast radius of any question in the document. Decide it
before writing the Layer 1 methods, or Layer 1 gets written twice.

## 1c. Scene mutability posture (open — a real semantic decision)

`scene_insert`, `scene_attach`, `scene_detach`, `scene_remove`,
`scene_set_visible`, and `scene_set_local_matrix` all take a `SceneStore` and
return a rebuilt one. Layer 3 above assumes that was an artifact of free-function
shape and converts them to Imperativus.

That assumption needs confirming, because the alternative reading is legitimate:
a persistent store supports snapshots, undo, and rollback. Evidence for the
artifact reading is that the failure signal is `SceneStore ∪ nihil`, which is an
error channel rather than a version chain — but that is inference, not a
documented intent.

If persistence was deliberate, Layer 3 should stay copy-out and only lose the
prefix, not the immutability.

## 1d. The frozen seam: radix MIR ABI

Relevant to any rename, and easy to get wrong. Radix does couple to Triga, in
`radix/crates/radix-mir/src/abi.rs`, but it never calls a Triga function by name.
It reads **fact-struct field names and numeric codes**:

```2392:2408:radix/crates/radix-mir/src/abi.rs
fn vertex_inputs_from_triga_layout_facts(
    facts: &[MirTrigaVertexLayoutFact],
) -> Result<Vec<MirVertexInputReflection>, MirAbiError> {
    facts
        .iter()
        .map(|fact| {
            Ok(MirVertexInputReflection {
                source_name: fact.source_name.clone(),
                location: fact.location,
                format: MirVertexInputFormat::from_triga_format_code(fact.format_code)?,
                step_mode: if fact.step_mode_code == 2 {
                    MirInputStepMode::Instance
                } else {
                    MirInputStepMode::Vertex
                },
                offset_bytes: fact.offset_bytes,
                stride_bytes: fact.stride_bytes,
            })
        })
        .collect()
}
```

That splits the rename surface cleanly:

| Surface | Rename freedom |
| --- | --- |
| Every public **function name** in Triga | Free. Nothing in radix binds them |
| **Fact-genus field names and code values** — `format_code`, `step_mode_code`, `offset_bytes`, `stride_bytes`, `source_name`, plus `primitive_topology_code`, `color_target_format_code`, and the depth-compare codes consumed by `from_triga_code` | **Frozen**, or changed in lockstep with radix |

So `material_side_code` → `materia_lateris_codex` is not an ordinary naming
choice; it is an ABI change. Axis 2 must treat fact-genus fields as a separate
category from operations.

## 1e. `de` annotations, and why they are not Triga's problem

Triga writes `de` on essentially every parameter. Worth recording what that
annotation does, because it looks like Rust-lane noise in a browser-targeted
library and is easy to "clean up" wrongly.

`de` is a **target-neutral language mode**, enforced on every lane
(`radix/crates/radix/src/semantic/passes/borrow.rs:5-13`,
`radix/crates/radix/src/semantic/mod.rs:425-434`). It emits `&T` in the Rust lane
and nothing at all in the TypeScript lane; `HirParamMode` never appears in
`radix-codegen-ts`.

The reason Triga carries it everywhere is narrower: without `de`, Rust emit
appends `.clone()` to every owned-mode struct argument
(`radix/crates/radix-codegen-rust/src/expr/call/args.rs:322-344`). Faber itself
does not require `de` — the mode checker registers no move for the default mode
(`borrow.rs:355-356`).

**Do not strip `de` from Triga as part of this work.** The clean fix is a
compiler change, filed as
`radix/docs/factory/pod-genus-copy-emit/goal.md` — derive `Copy` for genera whose
fields are transitively scalar (`Vector2/3/4`, `Quaternion`, `Color`, `Box3`,
`FaceCodeFacts`) and stop emitting the clone. Once that lands, `de` on those
types becomes redundant rather than load-bearing, and Triga can drop it as a
follow-up. `Matrix3`, `Matrix4`, `TransformPayload`, and `Euler` are not eligible
and keep `de`.

---

# Axis 2 — Vocabulary (decide second)

Everything below is **conditional on Axis 1**. With receiver methods, the
type-prefix rows disappear and only carrier nouns, stems, and fact-genus fields
remain to decide.

## Proposed policy: technical Latin

1. Keep universal graphics/math carrier nouns when they are standard or tool-facing.
2. Latinize operations, predicates, constructors, and fact/projection helpers.
3. Avoid casual English verbs in public APIs: `get`, `set`, `find`, `insert`,
   `attach`, `remove`, `valid`.
4. Do not keep three.js-specific type names unless Triga explicitly chooses to be
   a three.js-shaped migration layer.
5. No English aliases for Latin names absent a real external compatibility contract.
6. Keep exception lists small and documented.
7. **Fact-genus fields consumed by the radix MIR ABI (§ 1d) are exempt** until a
   lockstep change is planned with radix.

## Candidate carrier nouns to keep

| Term | Reason |
| --- | --- |
| `Vector2`, `Vector3`, `Vector4` | universal math/graphics carriers — **unless § 1b replaces them** |
| `Matrix3`, `Matrix4` | universal math/graphics carriers |
| `Quaternion` | standard 3D rotation term |
| `Euler` | standard rotation term and proper-name convention |
| `f32`, `u32` | numeric carrier syntax |
| `UV` / `uv` | graphics-standard texture coordinate term |
| `WGSL`, `WebGPU` | standards |
| `vertex`, `fragment`, `shader`, `pipeline` | likely standards; fix the Faber spelling before shader APIs expand |
| `yaw`, `pitch` | standard 3D orientation terms |
| `BufferGeometry` | GPU/three.js familiarity; decision needed |

## Candidate type names to reconsider

| Current | Concern |
| --- | --- |
| `Object3D` | strong three.js identity; vague as a Faber-native type |
| `MeshStandardMaterial` | three.js material taxonomy, not a Faber-native concept |
| `MeshBasicMaterial` | three.js material taxonomy |
| `MeshPhongMaterial` | `Phong` is a legitimate proper-name shading model; the wrapper is three.js-shaped |
| `PerspectiveCamera` | standard concept; ordering could become `CameraPerspectiva` |
| `OrthographicCamera` | standard concept; ordering could become `CameraOrthographica` |

## Stem decisions that hold regardless of shape

| Current | Proposed | Rationale |
| --- | --- | --- |
| `vector3_dot` | stem `productum` | Matches the shipped `norma:vector` operation, not merely its spelling |
| `vector3_cross` | stem `transversum` | Same |
| `vector3_normalizata` | stem `normata` | **Rule violation, not preference:** `normalizare` is not a Latin verb, so `normalizata` is an invented ending (morphologia principle 3). `normare` is real |
| `material_valid` | stem `valida` | Latin adjective predicate; `valid` is English API paint |
| `geometry_valid` | stem `valida` | Same |
| `material_double_sided` | stem `bilateralis` | Faber-native adjective |
| `scene_get` | stem `cape` | Norma retrieval verb |
| `scene_find_name` | stem `inveni` | Search stem |
| `scene_contains` | stem `continet` | Already the Triga predicate stem for `Box3`; reuse it |
| `camera_forward_*` | stem `prorsum` | Latinize the direction word; keep `yaw` |
| `camera_right_*` | stem `dextra` | Same |

## Latin forms with known problems

An earlier draft offered these as neutral options. They are not.

| Candidate | Problem |
| --- | --- |
| `Ray` → `Radius` | **Name collision.** `radius` is already a field: `Sphere.radius` (`src/triga.fab:143`), `BoundingSphere.radius` (`src/geometry.fab:114`), and the `circle_geometry(f32 radius)` parameter (`src/geometry.fab:1296`). If `Ray` is Latinized it needs a different stem |
| `ScaenaManubrium`, `ResManubrium` | English compounding in Latin costume. `ManubriumScaenae` (noun + genitive) is correct Latin; the reversed forms are not. Same risk in `CameraYawPitchFacta` |
| `MateriaRetisSimplex` | Three-word type name is less clear than the English original it replaces; violates "one Latin word when possible" in spirit |
| `geometria_onus_octetorum_numerus` | Own reductio. Do not translate `byte`/`payload` without a settled vocabulary |
| `box3_punctum_applicata` family | Participle agrees with the receiver type while the object is a different noun; word-salad. Symptom of § 1a, not a naming fix |

## Names that are already correct

Keep these stems whatever else changes: `addita`, `subtracta`, `multiplicata`,
`longitudo`, `distantia`, `interpolata`, `projecta`, `identitas`, `transposita`,
`inversa_affinis`, `conspectus`, `composita`, `continet`, `intersecat`, `unio`,
`inflata`, `translata`, `mensura`, `centrum`, `validum`, `coercita`.

## Type-noun Latinization (only in a full Latin pass)

Do not do these piecemeal. They are coherent only as one break:

| Current | Latin |
| --- | --- |
| `Material` | `Materia` |
| `Scene` | `Scaena` — check for retired compiler meaning first |
| `SceneNode` | `NodusScaenae` |
| `SceneStore` | `RepositoriumScaenae` |
| `SceneHandle` | `ManubriumScaenae` |
| `Mesh` | `Rete` |
| `Box3` | `Capsa3` — note the Latin-noun-plus-numeral hybrid is itself awkward |

## Example call-site shift

Current Drift City style:

```fab
fixum triga.Vector3 forward ← triga.camera_forward_planus_ex_yaw(heading_degrees)
fixum triga.Vector3 right ← triga.camera_right_ex_yaw(heading_degrees)
fixum f32 forward_speed ← triga.vector3_dot(old_velocity, forward)
fixum triga.Matrix4 model ← triga.matrix4_composita(position, rotation, scale)
```

Vocabulary only (Axis 2 without Axis 1):

```fab
fixum triga.Vector3 prorsum ← triga.camera_prorsum_planum_ex_yaw(heading_degrees)
fixum triga.Vector3 dextra ← triga.camera_dextra_ex_yaw(heading_degrees)
fixum f32 celeritas_prorsum ← triga.vector3_productum(old_velocity, prorsum)
fixum triga.Matrix4 exemplar ← triga.matrix4_composita(position, rotation, scala)
```

Shape plus vocabulary (both axes):

```fab
fixum triga.Vector3 prorsum ← camera.prorsum_planum(heading_degrees)
fixum triga.Vector3 dextra ← camera.dextra(heading_degrees)
fixum f32 celeritas_prorsum ← old_velocity.productum(prorsum)
fixum triga.Matrix4 exemplar ← triga.matrix4_composita(position, rotation, scala)
```

The third form is shorter than the current English and shorter than the
Latin-only rename. That is the case for shape leading.

## Risks of going too Latin

- Graphics developers expect standardized terms from engines, shaders, WebGPU docs, and three.js.
- LLMs likely produce more correct 3D code when names include standard technical terms.
- Fully translated compounds can be longer and less clear than the English original.
- Debugging across host JavaScript, WGSL, browser APIs, and generated output gets harder as vocabulary diverges.

## Risks of staying too English

- Triga feels unlike Norma and unlike Faber's public language identity.
- Mixed English/Latin is harder to learn than either consistent approach.
- English verbs (`get`, `set`, `find`, `insert`, `remove`) become precedent for future Faber libraries.
- three.js-shaped names imply parity Triga does not guarantee.

## Decision questions, in order

**Shape:**

1. ~~Do public Triga operations move to receiver methods on `genus`?~~
   **Endorsed 2026-07-27** — § 1a is the proposed design. Residual spike items
   remain.
2. Does Triga adopt `norma:vector` / `vector<elem, N>` as its math carrier, or
   keep `Vector2`/`Vector3`/`Vector4`? (§ 1b)
3. Is the scene store persistent by intent, or is copy-out an artifact of
   free-function shape? (§ 1c)

**Vocabulary:**

4. Is Triga a Faber-native graphics library, or does the three.js migration intent in the `src/triga.fab` header stand?
5. Which carrier nouns are standard enough to keep: `Vector`, `Matrix`, `Quaternion`, `Buffer`, `Vertex`, `Shader`, `Pipeline`, `Mesh`, `Scene`, `Camera`, `Material`?
6. Must public operations always be Latin even when carrier nouns stay English?
7. Do three.js material names remain, or does Triga define its own material taxonomy?
8. When, if ever, do the frozen fact-genus fields in § 1d get renamed in lockstep with radix?

**Execution:**

9. Is Drift City the first clean-break consumer after the pass?
10. Does `triga/scripta/check-source` gain a naming lint once the vocabulary is accepted?

## Recommended next step

Do not rename code yet.

1. **Spike** `Box3` as a genus with `continet`, `intersecat`, `infla`, and
   `inflata`, called from `examples/triga-drift-city`. This settles the three
   residual unknowns in § 1a with evidence.
2. **Decide § 1b** — `norma:vector` adoption or own types. Largest blast radius;
   Layer 1 cannot be written twice.
3. **Answer § 1c** — persistent store by intent, or artifact.
4. **Write the accepted policy** as Triga API law, covering both axes and the
   § 1d frozen-seam exemption.
5. **Rename and reshape once**, in one clean break across `triga/src`,
   `triga/exempla`, `examples/triga-drift-city/src`,
   `examples/triga-drift-city/tests`, and the docs and capability ledgers that
   name public symbols.

Related compiler work, tracked separately and not a prerequisite:
`radix/docs/factory/pod-genus-copy-emit/goal.md` (§ 1e).

Avoid compatibility aliases unless a real external package has already committed
to current names.
