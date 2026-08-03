# Compiler-Lane Ledger — WGSL Shader Contract Boundary (U5, Triga side)

**Status**: landed (2026-08-02) — triga adapter + conformance suite green against the pinned radix revision; U5-P2 repairs applied (naga hard-require, handover status complete). **Re-pin applied** (2026-08-02, wave-close): pin moved `3cfd578b1` → `02b4cbb14` for radix U6 (explicit `stage_io_role_code` contract calls; F1/F2 role synthesis retired); adapter + exempla re-adapted to the new call shapes, suite green against the new pin (see §0 and §1). **Re-pin applied** (2026-08-03): pin moved `02b4cbb14` → `41b4c0411` — radix `crates/` moved 16,897 diff lines past the old pin (fhir/hir-* extraction, wgsl emitter fixes `abeb97cb7`, wasm/llvm/metal/ts/go fixes, docs); the suite re-ran clean with **no conformance-program re-adaptation** (emitted WGSL unchanged; §0).
**Campaign**: [`radix/docs/factory/wgsl-shader-contract-boundary`](../../../radix/docs/factory/wgsl-shader-contract-boundary/) (goal.md, delivery.md §U5)
**Repo**: `triga/` (this checkout) — write scope is triga only; radix is untouched
**Unit**: U5 — Triga adapter + conformance suite (Wave 2, sibling repo); wave-close re-pin to radix U6

## 0. Pinned radix revision

**Pin**: `41b4c0411` (radix main — U6 `02b4cbb14` landed the explicit
`stage_io_role_code` contract calls and retired F1/F2; since then radix moved
through the fhir/hir-* crate extraction (`4aeea3633`, `b20f1a82e`,
`0f6211c27`), wgsl emitter fixes (`abeb97cb7`: forward-chase, relu row-major
index, workgroup overrides, arm state, device-view scalar-local `let`
materialization), and wasm/llvm/metal/ts/go/codegen fixes).

**Re-pin decision (2026-08-03)**: radix `crates/` moved past the
`02b4cbb14` pin (16,897 diff lines) — the harness failed loudly (pin drift),
as designed. Decision: **re-pin to `41b4c0411`** (current radix main tip).
No conformance-program or adapter re-adaptation was required: the wgsl
emitter changes in the window (`abeb97cb7`) do not touch the generic
shader-contract emission surface the suite exercises (simple `@vertex` /
`@fragment` entry programs), and the suite's positive/negative WGSL
assertions plus naga validation all hold against the new pin. This is a
ledger-recorded re-pin decision, never a silent rebuild.

- Verified at re-pin: radix main is `41b4c0411`; `git diff 41b4c0411 HEAD --
  crates/` is **0 lines** — the compiled code the faber binary embeds is
  byte-identical to the pin.
- The conformance harness (`scripta/check-wgsl-shader-contract-conformance`)
  enforces the pin: it fails loudly if the radix checkout is not at/after the
  pin, or if `crates/` drifted past it (a re-pin is a ledger decision, never a
  silent rebuild).
- `faber emit -t wgsl-text` is the product surface; the faber binary is built
  from the sibling faber checkout (`faber/Cargo.toml` pins radix by path), so
  the pinned radix revision is the compiled-against radix.

## 1. Adapter contract (decision D1 + D2 + D3)

Triga maps its real API onto the compiler-owned generic shader-contract
surface. The adapter lives in **`triga/src/shader_contract.fab`** (new module)
and on the real API site **`triga/src/geometry/data.fab`** (the
`geometry_vertex_layout_matches` function carries the `@ shader_contract
"vertex_layout"` annotation).

Landed annotation grammar (verify against radix `driver/shader_contract.rs` —
the older `@ radix lane shader_contract(role = ...)` syntax from the U4-A
fixture is **not** the landed surface):

```fab
@ shader_contract "<role>"
functio <adapter>(...) → bivalens { redde verum }
```

Contract-role functions and their canonical call argument shapes (U6 shape —
`stage_io_role_code` is the explicit stage-I/O role declared on every
`vertex_layout` / `varying` / `fragment_output` / `resource_binding` call;
roles are never synthesized from source-name spelling or location):

| Role | Adapter function (triga) | Call argument shape |
| --- | --- | --- |
| `vertex_layout` | `vertex_layout_matches` (maps `geometry.geometry_vertex_layout_matches`) | `(geo, index, source_name, location, format_code, offset_bytes, stride_bytes, step_mode_code, stage_io_role_code)` |
| `varying` | `varying_matches` | `(source_name, location, format_code, interpolation_code, stage_io_role_code)` |
| `fragment_output` | `fragment_output_matches` | `(location, format_code, stage_io_role_code)` |
| `pipeline` | `pipeline_matches` (maps `geometry.geometry_pipeline_descriptor_matches`) | `(color_target_format_code, depth_compare_code, depth_write_enabled_code, primitive_topology_code, vertex_count)` (unchanged — no stage-I/O role) |
| `resource_binding` | `resource_binding_matches` | `(group, binding, kind_code, role_code, access_code, element_count, layout_code, source_name, stage_io_role_code)` |

**U6 contract-shape change (re-adapt record)**: at the U5 pin (`3cfd578b1`)
the four stage-I/O roles were declared without `stage_io_role_code` (the
driver synthesized the stage-I/O role from source-name spelling and a
location-0 color heuristic — F1/F2). Radix U6 (`02b4cbb14`) retired that
synthesis: each `vertex_layout` / `varying` / `fragment_output` /
`resource_binding` contract call now carries an explicit `stage_io_role_code`
(`radix_mir::shader_contract::stage_io_role_from_code`), and resource
reflections carry `ShaderStageIoRole`. The triga adapter
(`src/shader_contract.fab`) and all conformance exempla were re-adapted to the
new shapes at the re-pin (this unit). `pipeline` is untouched. The real-API
site `src/geometry/data.fab` (`geometry_vertex_layout_matches`) keeps its
library-surface signature (library-declared annotations are not ingested — §2);
only the adapter pattern and the conformance programs declare contract calls.

Canonical codes (radix_mir::shader_contract tables; unknown codes fail closed):

- vertex format 2 = float32x2, 3 = float32x3, 4 = float32x4
- color target 1 = bgra8unorm, 2 = bgra8unorm-srgb
- topology 1 = triangle-list, 2 = line-list, 3 = point-list
- depth compare 0 = no depth attachment (driver sentinel), 1 = less, 2 = equal,
  3 = less-equal, 4 = greater, 5 = not-equal, 6 = greater-equal, 7 = always
- step mode 1 = vertex, 2 = instance
- interpolation 1 = perspective, 2 = linear, 3 = flat
- stage-io role 1 = position, 2 = color, 3 = transform, 4 = other
  (`stage_io_role_code`, radix U6 — explicit on each vertex_layout / varying /
  fragment_output / resource_binding call)
- resource kind 1 = storage buffer, 2 = runtime extent
- resource role 1 = input, 2 = output
- resource access 1 = read, 2 = write, 3 = read-write
- scalar layout 1 = f32 (4B), 2 = f64 (8B), 3 = i32 (4B), 4 = u32 (4B)

**Goal-01 pipeline defaults (decision D2 — Triga's contract, not radix's)**:
declared as named constants in `triga/src/shader_contract.fab`:
bgra8unorm (1), depth compare less (1) + writes enabled, triangle-list (1),
36 vertices, and the group-0 binding-0 read-only transform storage buffer
(32 f32). This is the lock from
`docs/factory/hello-voxel/goals/01-source-graphics-pipeline.md`; radix owns no
invented defaults (acceptance criterion 5 of the goal).

**Varying derivation (decision D3)**: Triga declares explicit varying facts via
the `varying` role; the old consecutive-location heuristic is gone.

**Council lock (non-goal)**: Triga never emits WGSL. It maps its API to the
generic surface; radix emits. No `wgsl`/reflection generation exists in triga.

## 2. Adapter recognition model (verified against the pin)

Verified empirically against the pinned radix: the driver registers
`@ shader_contract "<role>"` functions declared **in the compiled unit** and
ingests facts from `adfirma` assertions whose condition is a direct-Path call
to a registered function with constant arguments. Library-declared annotations
and member/namespace calls (`geometry.geometry_vertex_layout_matches(...)`) are
not ingested. Consequences for the triga side:

- The adapter source (`src/shader_contract.fab`, the `data.fab` annotation) is
  the documented contract and the pattern source of truth.
- Conformance programs declare the contract-role functions (mirroring the
  adapter) and assert facts with constant arguments; real `triga:*` imports
  supply the geometry API (`basic.plane_geometry`, `data.BufferGeometry`).
- Library-surface ingestion (annotations recognized from imported libraries) is
  future radix work; when it lands, triga's `@ shader_contract` annotations are
  already in place on the real API.

## 3. Moved conformance tests (handover from radix U4)

The 7 triga-importing tests from
`radix/crates/radix/src/tool_test.rs:2373-2864` plus the old fixture
`radix/crates/radix/src/fixtures/triga-stage4-source-facts.fab` move to this
repo's conformance suite. Mapping (radix test name → triga corpus file):

| Moved radix test | Triga conformance file |
| --- | --- |
| `triga_stage4_vertex_body_emits_wgsl` | `exempla/conformance/shader-contract/vertex-body-emits-wgsl.fab` |
| `triga_stage4_vertex_body_validates_with_naga` | `exempla/conformance/shader-contract/vertex-body-naga.fab` |
| `triga_stage4_source_fragment_emits_wgsl` | `exempla/conformance/shader-contract/source-fragment-emits-wgsl.fab` |
| `triga_stage4_fragment_entry_validates_with_naga` | `exempla/conformance/shader-contract/fragment-entry-naga.fab` |
| `triga_stage4_source_fragment_body_emits_authored_color_widening` | `exempla/conformance/shader-contract/source-fragment-body-color-widening.fab` |
| `triga_stage4_source_fragment_lambert_emits_authored_math` | `exempla/conformance/shader-contract/source-fragment-lambert.fab` |
| `triga_stage4_source_fragment_lambert_negative_empty_body_has_no_lambert_math` | `exempla/conformance/shader-contract/source-fragment-lambert-negative-empty.fab` |
| `fixtures/triga-stage4-source-facts.fab` (old) | `exempla/triga-stage4-source-facts.fab` (triga leaf-import version, supersedes the old `triga:geometry`/`triga:primitives` pre-split fixture) |

The moved tests were rewritten onto the generic contract surface (see §2): real
`triga:*` imports → generic contract (adapter declarations + constant
assertions) → `faber emit -t wgsl-text` → Naga-valid WGSL.

**Naming reconciliation**: earlier radix delivery docs (e.g.
`radix/docs/factory/shader-body-lowering/delivery.md` and
`radix/docs/factory/mir-gpu/phase-9gj-fragment-source-driver-test-delivery.md`)
refer to **combined** test names —
`triga_stage4_vertex_body_emits_wgsl_and_validates` and
`triga_stage4_source_fragment_emits_wgsl_and_validates_with_naga`. The triga
conformance corpus splits each combined test into two files — an emit-and-assert
file plus a dedicated naga-validation file — because every corpus file must be a
standalone program and the harness validates each emitted WGSL with naga. The
one-to-many mapping is:

| Radix-doc combined name | Triga emit/assert file | Triga naga file |
| --- | --- | --- |
| `triga_stage4_vertex_body_emits_wgsl_and_validates` | `vertex-body-emits-wgsl.fab` | `vertex-body-naga.fab` |
| `triga_stage4_source_fragment_emits_wgsl_and_validates_with_naga` | `source-fragment-emits-wgsl.fab` | `fragment-entry-naga.fab` |

Both triga files carry identical contract facts; the naga file's WGSL is
additionally validated (harness `validate_naga`).

**Atomic handover** (coordination with U4 / hand-1): agreed file list + pinned
revision in mail hand-3→hand-1 (handle `c8677712`). Sequencing: triga lands
first (commit `b3d3326`), hand-1 deletes the radix tests after confirming;
radix deletion and triga landing stay atomic. Handover status: **COMPLETE** —
the radix-side deletion is done. Verified 2026-08-02: zero `triga_stage4_*` /
`triga:geometry` / `triga:primitives` references remain in
`radix/crates/radix/src/tool_test.rs`, and
`radix/crates/radix/src/fixtures/triga-stage4-source-facts.fab` is gone
(replaced by the triga-free U4-A fixtures). The radix-side delivery doc's
staleness is Mind's closeout item; the triga ledger reflects the actual state.
Re-pin policy: if radix `crates/` moves past the pin, the harness fails loudly
and the pin is re-validated in this ledger — never a silent rebuild.

## 4. Harness + validation evidence

Harness: `scripta/check-wgsl-shader-contract-conformance`.

```
$ ./scripta/check-wgsl-shader-contract-conformance
check-wgsl-shader-contract-conformance: naga validation required (/Users/ianzepp/.cargo/bin/naga)
check-wgsl-shader-contract-conformance: faber .../faber/target/debug/faber (radix pinned 41b4c0411)
check-wgsl-shader-contract-conformance: conformance corpus .../exempla/conformance/shader-contract
ok vertex-body-emits-wgsl
ok vertex-body-naga
ok source-fragment-emits-wgsl
ok fragment-entry-naga
ok source-fragment-body-color-widening
ok source-fragment-lambert
ok source-fragment-lambert-negative-empty
check-wgsl-shader-contract-conformance: source-facts fixture check
check-wgsl-shader-contract-conformance: ok (7 moved conformance tests + source-facts fixture)
```

Each file: `faber emit -t wgsl-text` → positive/negative WGSL assertions
(carrying the moved tests' assertions: `@vertex`/`@fragment` entries, position
writes, fragment input varyings, default vs authored color output, Lambert math
presence/absence) → `naga` validation (naga 30.0.0 on PATH) where the moved
test validated.

**Naga is a hard requirement** (P2-1 fix; auditor-1 residual `7b946d8d`): the
moved conformance tests assert Naga-valid WGSL, so a naga-less environment
must fail the suite, never silently pass without validation. The harness exits
non-zero with a clear message when naga is absent from PATH or when `NAGA` is
set empty (forced-absent path); `NAGA=/path/to/naga` overrides detection.

## 5. Pinned end-to-end run (done_when)

One pinned `faber emit -t wgsl-text` run on a triga corpus package — the
flagship conformance file:

```
$ faber emit -t wgsl-text exempla/conformance/shader-contract/vertex-body-emits-wgsl.fab
struct HelloVoxelVertexInput {
  @location(0) position: vec3<f32>,
  @location(1) color: vec3<f32>,
}
struct HelloVoxelVertexOutput {
  @builtin(position) position: vec4<f32>,
}
@vertex
fn hello_voxel_vertex(input: HelloVoxelVertexInput) -> HelloVoxelVertexOutput {
  var out: HelloVoxelVertexOutput;
  var tmp0: f32;
  tmp0 = 1.0;
  out.position = vec4<f32>(input.position.x, input.position.y, input.position.z, tmp0);
  return out;
}
```

Real `triga:*` imports → generic contract → `faber emit -t wgsl-text` → naga
validates the same file in the harness (`vertex-body-naga`). Re-verified at the
re-pins (2026-08-02 against `02b4cbb14`, 2026-08-03 against `41b4c0411`):
emission output is byte-identical — the explicit `stage_io_role_code` facts are
carried in reflections and do not change WGSL emission, and the wgsl emitter
fixes in the `02b4cbb14`→`41b4c0411` window do not touch this surface.

## 6. Radix unaffected

- No dependency added from radix onto triga; radix builds and tests without
  triga present.
- `triga/src/geometry/data.fab` gained only the `@ shader_contract
  "vertex_layout"` annotation on `geometry_vertex_layout_matches` (compiles
  clean; `radix check` green).
- Triga gates: `scripta/check-compile` leaf parsing (including the new
  `src/shader_contract.fab` leaf) and the conformance suite are green; the
  generated-Rust E0308 step and the `check-source`
  `geometry_vertex_layout_matches` genus-prefix lint are pre-existing,
  documented items (compiler-lane ledger E0308; decision-gated DS-E C3) and
  are untouched by this unit.

## 7. Out of scope (unchanged)

- No WGSL/reflection generation in triga.
- No change to radix's gate to depend on triga.
- No radix repo changes from this unit.
- U6 (radix cleanup: delete `MirTriga*` / `triga_*` and retire F1/F2 role
  synthesis) **has landed** at `02b4cbb14`; this wave-close unit is the
  triga-side re-pin + re-adapt (see §0, §1).
