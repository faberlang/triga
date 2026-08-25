# Generic Math Types — Frozen Migration Map (S0-T2)

**Status**: frozen — S0-T2 resumed 2026-08-25 (task `f53e576b`) after S0-G8 (`0f7d26f5a`, N1/N2), S0-G9 (`a7d731ec0`, N3), S0-G10 (`4628590fd`, N4/N5/N6) landed. Selected representation: **direct native types** (representation-decision.md §1). Runner rows re-executed at radix `fbec200be` (main + the in-unit G10 residual fix `fix(hir-rust): nullable lista index emits Option instead of OOB trap`); every row is mapped below — no unresolved rows, zero compatibility destinations.

**Campaign**: [`CAMPAIGN.md`](CAMPAIGN.md) · **Delivery**: [`delivery-stage0.md`](delivery-stage0.md) §4 S0-T2 done_when 6–7 · **Decision**: [`representation-decision.md`](representation-decision.md)

**Selected spellings** (the destination vocabulary for every row):

- vector family: `vector<f32, N>` (concrete `vector<f32, 2|3|4>`), construction `[…] ↦ vector<f32, N>`
- matrix family: `matrix<f32, [R, C]>` (concrete `matrix<f32, [4, 4]>`), construction via free `ex_columnis`-style column assembly
- box family: generic Triga nominal `class Box<size N>` over two `vector<f32, N>` fields (S0-G1 construction), receiver operations stay on `Box<N>`
- operations: dimension-neutral Triga free functions (`.added/.subtract/.multiply/.dot/.cross/.swizzle` intrinsics; `scala/interpolata/projecta/distantia/longitudo/normata` free functions; glyph `·` matmul; `transposita` free function) — per the §2.4 placement table in representation-decision.md §7

## 1. Retired public declarations → exact destination

| Retired declaration | Current form | Exact action | Stage |
| --- | --- | --- | --- |
| `class Vector2` | nominal `x`,`y` fields | Remove; callers use `vector<f32, 2>` directly | 1 |
| `class Vector3` | nominal fields + 10 arithmetic methods | Remove; carriers become `vector<f32, 3>`; methods become the free functions of §2 | 1 |
| `class Vector4` | nominal fields | Remove; callers use `vector<f32, 4>` | 1 |
| `class Matrix3` | flat `list<f32>` carrier | Remove; callers use `matrix<f32, [3, 3]>` | 1 |
| `class Matrix4` | flat `list<f32>` carrier + transform methods | Remove; carriers become `matrix<f32, [4, 4]>`; methods become the free functions of §2; `validum()` retires as a type invariant (§2 row) | 1 |
| `class Box3` | two `Vector3` fields + 12 receivers | Rename-reshape to generic `class Box<size N>` over `vector<f32, N>` minima/maxima (proven shape: `Box<3>` construction, field access, parametric receivers `mensura/translata` — selected/operations.fab); 3D-specific receivers constrain to `Box<3>` | 1 |
| `class TransformPayload` | wire record (NOT retired) | Keep unchanged — 32-float/128-byte model-then-VP column-major contract proven frozen under the selected representation (selected/payload.fab); only its constructor input types change to `matrix<f32, [4, 4]>` | 1 |
| `class Quaternion`, `Color`, `Euler`, `Sphere`, `Plane`, `Ray`, `RayInterval`, `FaceCodeFacts`, `RayBox3Hit`, `CameraYawPitchFacts`, `Box3OverlapFacts` | depend on retired carriers | Keep the genus; retype fields/signatures from `Vector3`/`Box3` to `vector<f32, 3>`/`Box<3>`; `Box3OverlapFacts` → `BoxOverlapFacts` (compound retired token, §3) | 1–2 |

## 2. Retired public methods/helpers → exact destination

`Matrix4.validum()` — **no runtime replacement**: `matrix<f32, [4, 4]>` makes 16 lanes a type invariant. Every caller guard is removed (see §4 family rows); the separate domain-failure checks (`matrix4_perspectiva` invalid params, `matrix4_conspectus` degenerate basis, `inversa_affinis` singular matrix) stay nullable and unchanged in behavior.

| Retired member | Destination (exact spelling) | Placement |
| --- | --- | --- |
| `Vector3.addita/subtracta/multiplicata(scalar)/productum` | free `fn addita<N>/subtracta<N>/scala/… (vector<f32, N>, …)`; elementwise via intrinsic `.added/.subtract/.multiply`, scalar scale via broadcast-multiply (S0-G8) | [I]+[F] |
| `Vector3.transversum` | free `fn transversum(vector<f32, 3>, vector<f32, 3>)` via intrinsic `.cross` (width-3 in types) | [I] |
| `Vector3.longitudo/normata/distantia/interpolata/projecta` | free functions per operations.fab (`longitudo`, `normata` parametric post-S0-G8; guarded norm returns `∪ null` at zero length, unchanged) | [F] |
| `Matrix4.determinans_affinis/transposita/multiplicata/applica_punctum/inversa_affinis` | free `determinans_affinis` (basis construction), `transposita` (S0-G9), `multiplicata` glyph `·`, `applica_punctum`, `inversa_affinis → matrix<f32,[4,4]> ∪ null` | [F]/[I] |
| `Matrix4.validum()` | **removed** — type invariant; caller guards deleted | [T] |
| `Box3` receivers (`continet/intersecat/inflata/infla/validum/mensura/centrum/continet_capsam/superpositio/superpositio_facta/unio/translata`) | survive on `Box<N>`/`Box<3>`: parametric `mensura/translata` proven; predicates as free functions `capsa_*` or receivers per operations.fab; mutable `infla` → immutable `capsa_inflata` + field store (mutable form re-proven in Stage 1; the Stage-0 gap probe remains routed, §8) | [R]+[F] |
| `Ray.box3_hit` / `_ray_box3_hit_normal` family | retype to `Box<3>`; rename `box3_hit` → `capsa_hit_radium`-style dimension-neutral spelling decided at Stage 2 edit (no `3` token may survive) | [R] |
| `RayBox3Hit`, `Box3OverlapFacts`, `RayBox3Hit.hit_face_*` | rename to `RayBoxHit`/`BoxOverlapFacts` family; drop the `3` token everywhere | [R] |

## 3. Numbered constructor/helper family (`src/math.fab` free functions)

| Retired helper | Exact action | Stage |
| --- | --- | --- |
| `vector3(x,y,z)` | remove; call sites use `[x, y, z] ↦ vector<f32, 3>` | 1 |
| `matrix4_identitas/translatio/scala/composita/perspectiva/conspectus` | keep as free functions, retyped to `matrix<f32, [4, 4]>` (returns `∪ null` where nullable today), renamed to drop the `4` token: `matricis_identitas/translatio/scala_diagonals/composita/perspectiva/conspectus` per the operations.fab spellings (`identitas`, `translatio`, `scala_diagonals`, `composita`, `perspectiva`, `conspectus`) | 1 |
| `box3_ex_minimo_et_maximo` / `box3_ex_minimo_et_mensura` / `box3_ex_centro_et_mensura` | remove numbered spelling; construction is `Box<3> { minima = …, maxima = … }` (S0-G1); size/center-derived constructors become free `capsa_ex_*` functions over the fields or are inlined at call sites in Stage 2 | 1–2 |
| `hit_normal` (Box3/Vector3 params) | keep, retyped (`Box<3>`, `vector<f32, 3>`) | 2 |
| `camera_*`, `face_code_*`, `axis_interval`, trig helpers, `transform_payload` | keep; retype signatures off the retired carriers; names carry no dimension token and stay | 2 |
| `Vector2/3/4`-typed params in every remaining helper | retype to `vector<f32, N>` | 1–2 |

## 4. Triga consumer families (path scopes + counts from the §7 scan, 2026-08-25)

| Family | Paths (hit counts) | Action | Stage |
| --- | --- | --- | --- |
| Core math | `src/math.fab` (112), `src/math.proba` (78) | §1–§3 replacements; proba rewritten against the new surface; no compatibility import | 1 |
| Scene/graph consumers | `src/scene.fab` (7), `src/graph/camera.fab` (11) + `camera.proba` (7), `src/graph/object.fab` (3) | retype + constructor-spelling swap; camera ray/facts logic unchanged | 2 |
| Geometry/face/lighting | `src/face.fab` (5), `src/geometry/{data,bounds}.fab` (1+1), `src/lighting/light.fab` (1) + `light.proba` (3) | retype; `Box3`→`Box<3>`, `Vector3`→`vector<f32, 3>` | 2 |
| Root exempla | `triga-transforms` (25), `triga-normal-oracle` (20), `triga-math-edge-cases` (9), `triga-box3-genus-spike` (11, rename file+decls to `box-genus`), `triga-types-untested` (7), `triga-basics` (3), `triga-hello-voxel-pipeline` (2), `exempla/README.md` (2), `threejs-host-demo/{README.md,triga-scene.json}` (2+1, JSON fixture keys re-keyed) | migrate to new spellings; keep behavioral oracles | 2 |
| Browser corpus | `corpus/webgl-animation-{terrain,orbit,water}/src/main.fab` (12 each), `webgl-geometries` + `webgl-geometry-terrain` `camera_controls.fab` (7+7) | retype + constructor swap; payload writes unchanged (wire contract frozen) | 2 |
| Conformance fixtures (self) | `exempla/conformance/generic-math-types/selected/{operations,payload}.fab` (1+1) | **not usage** — comment rows documenting the `Matrix4.validum()` retirement; classified retirement record; leave | — |

## 5. Examples repo (source before generated)

| Family | Paths | Action | Stage |
| --- | --- | --- | --- |
| hello-voxel source | `src/{application,main,meshing}.fab` (16+13+7), `tests/application-{motion-facts,dda-edit-facts}.fab` (5+2) | retype + new spellings; then regenerate outputs through the owning workflow | 3 |
| triga-budapest source | `src/{bridge,box_geom,camera,scene}.fab` (4+1+7+1) | same | 3 |
| triga-drift-city source | `src/{city,vehicle,main,box_geom,scene}.fab` (23+15+6+5+3), `tests/{city,vehicle,scene}-facts.fab` (8+3+4), `README.md` (1) | same; README prose updated | 3 |
| browser-app | clean (0 hits) | none | — |
| Generated outputs (all repos) | regenerated by their owning workflows **after** source migrates | no hand-edits; byte provenance checked | 4 |

## 6. Radix bounded rows (metadata vs unrelated samples)

| Path (hits) | Classification | Action | Stage |
| --- | --- | --- | --- |
| `stdlib/locale/en/pack.toml` | 0 hits — clean | none | — |
| `crates/faber/src/package/product/{product_test.rs}` (11) | sample user-type fixtures (unrelated sample types, not Triga metadata) | classify, leave unchanged | — |
| `crates/faber/src/package/{fhir_test.rs,frontmatter_integration_test.rs}` (3+4) | Triga-shaped locale/package fixtures | retype only where a fixture asserts Triga's surface; else classify | 3 |
| `crates/faber/src/package/product/{ts_emit.rs,ts_rewrite.rs}` (1+2) | emitter naming of sample types | classify, leave | — |
| `crates/faber/src/package_test.rs` (3) | direct Triga package fixture rows | retype to the new surface | 3 |

No global textual rename of radix fixtures; only rows that assert Triga's actual public surface move.

## 7. Faberlang site (source before `dist`)

| Path (hits) | Action | Stage |
| --- | --- | --- |
| `src/en-US/libraries/triga.md` (8) | authored page rewritten to the parametric surface | 4 |
| `src/en-US/examples/triga-budapest.md` (1) | regenerated by `generator/scripts/generate-examples.py` **after** Examples source migrates (ordering: Examples source → generator → authored source → `build-site.sh` → `dist/`) | 4 |
| `dist/en-US/libraries/triga.html` (8), `dist/en-US/examples/triga-budapest.html` (1) | rebuilt by `build-site.sh`; never hand-patched | 4 |

## 8. Exclusions (classified, never rewritten)

- `hosts/webgpu-browser/public/vendor/three@0.180/*` — vendored three.js `Vector3`/`Matrix4` are third-party names (campaign settled decision 6).
- `archivum/**`, archived Factory receipts, historical delivery text — historical evidence.
- Radix unrelated sample user types (§6 classified rows).
- `exempla/conformance/generic-math-types/**` — Stage-0 probe fixtures, spellings are the new surface already.

## 9. Ordered Stage 1–5 delivery graph

```text
Stage 1  triga core: src/math.fab + math.proba — §1–§3 replacements,
         retired decls removed in the same change set; checker:
         check-source/check-compile/check-transforms + the five
         --selected runner invocations stay green
Stage 2  triga consumers: §4 scene/graph/face/lighting/exempla/corpus rows
         (after Stage 1; internal callers are migration work, not contracts)
Stage 3  cross-repo: Examples source families (§5) + bounded Radix
         fixture/metadata rows (§6) — Examples source only, no generated
         output yet
Stage 4  generated + docs: regenerate Examples outputs; site source
         (authored triga.md; then generate-examples.py output);
         then build-site.sh → dist/ (§7 ordering)
Stage 5  integrated acceptance: lint/test lanes, classified final grep
         oracle (§10), campaign closeout
```

Hard ordering edges: Stage 1 → 2 → 3 → 4 → 5; within Stage 4, Examples-source migration precedes `generate-examples.py`, and all site source is final before `build-site.sh` rewrites `dist/`. The host wire contract (32 f32 / 128 bytes, model-then-VP, column-major) is frozen — any change is a campaign stop condition, not a migration row.

## 10. Bounded classified final grep oracle

```sh
PATTERN='Vector2|Vector3|Vector4|Matrix3|Matrix4|Box3'
rg -n "$PATTERN" src exempla corpus                       # triga
rg -n "$PATTERN" "$EXAMPLES_ROOT"/{hello-voxel,triga-budapest,triga-drift-city,browser-app}
rg -n "$PATTERN" "$RADIX_ROOT"/stdlib/locale/en/pack.toml \
                 "$RADIX_ROOT"/crates/faber/src/package_test.rs \
                 "$RADIX_ROOT"/crates/faber/src/package
rg -n "$PATTERN" "$SITE_ROOT"/src/en-US "$SITE_ROOT"/dist/en-US
```

Closeout classification — every remaining hit must be exactly one of: vendored three.js; archived/historical evidence; unrelated Radix sample fixture; Stage-0 probe retirement-record comment. Zero hits may resolve to a live owned declaration, caller, constructor, helper, doc page, or generated artifact. `Box<3>`/`matrix<f32, [4, 4]>` spellings are not hits (no identifier token); the oracle measures identifiers, not type arguments.

## 11. Routed residuals at freeze (recorded, not map blockers)

Carrier-independent compiler residuals observed by the resumed five-invocation run at radix `fbec200be` (full rows in representation-decision.md §8): rust emission of the size-parametric glyph-matmul body (`CODEGEN001`, the S0-T1R R4 route); TS emission of `Box<N>` receiver calls over tuple-carrier parameters + untyped `reduce` accumulators (`TS2339`/`TS7006`); TS index-assignment/coordinate emission in the payload flatten (`TS2364`/`TS2304`). Each blocks a Stage 1–4 emitted-artifact check, not a migration destination; Stage 1 routes them as narrow Radix units before its rust/ts compile gates are claimed. The nullable Rust list-index residual (G10 N-rust) was fixed in-unit (radix `fbec200be`); the TS2307 runtime-staging artifact was fixed runner-side in this unit (module staged by `compile_ts`).
