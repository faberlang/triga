# HV-01 Delivery: Source Graphics Pipeline

**Parent goal**: [`../goals/01-source-graphics-pipeline.md`](../goals/01-source-graphics-pipeline.md)
**Factory admission**: READY after HV-00
**Primary repo**: `radix`
**Supporting repo**: `triga`

## Interpreted Unit

Replace the driver-only vertex scaffold with a canonical source-to-MIR graphics
path that emits the locked vertex and fragment WGSL, reflection, and draw
contract while preserving compute behavior.

## Normalized Spec

- Admit vertex and fragment roles through HIR, semantic validation, device role,
  MIR lowering, ABI reflection, WGSL emission, and tool JSON.
- Implement exactly the Goal 01 position/color/index/transform contract.
- Reflect all bind group, pipeline, target, depth, index, and draw facts.
- Validate varying compatibility and reject illegal or incomplete stage pairs.
- Preserve current compute kernels and target behavior.
- Do not implement browser effects, textures, lighting, or general shader APIs.

## Repo-Aware Baseline

- Annotation/HIR: `crates/radix/src/hir/lower/decl.rs`, `hir/nodes.rs`, and
  semantic typecheck tests.
- Current roles: `mir/device.rs` and `mir/lower.rs` support `Kernel`/`Device`.
- Current stage ABI: `mir/abi.rs` supports `Compute`/`Vertex` and vertex formats
  `Float32x2`/`Float32x3`.
- Source vertex scaffold: `driver/mod.rs::emit_wgsl_vertex_source_output`.
- WGSL contract: `mir/wgsl_text.rs` and `mir/wgsl_text_test.rs`.
- JSON: `tool/commands/reflection.rs` and `tool_test.rs`.
- Triga agreement: `triga/src/geometry.fab` for vertex layout facts and
  `triga/src/triga.fab` for validated material RGB/alpha facts and locked
  32-float, 128-byte transform payload order.

## Stage Graph

### HV-01A - Canonical Shader Roles

**Output**: vertex and fragment device roles attached to lowered functions with
semantic exclusivity and negative diagnostics.
**Write scope**: HIR, semantic, device role, and MIR lowering modules plus tests.
**Gate**: source annotations reach MIR roles; compute/device roles regressions
remain green.

### HV-01B - Graphics ABI And Pipeline Contract

**Depends on**: HV-01A
**Output**: fragment stage, stage IO, transform binding, pipeline/depth/target,
index, and draw reflection types with fail-closed constructors.
**Write scope**: `mir/abi.rs`, focused ABI modules/tests, and public re-exports.
**Gate**: the locked contract constructs once and all malformed variants reject.

### HV-01C - WGSL And Tool Reflection

**Depends on**: HV-01B
**Output**: source bodies lower to one vertex/fragment WGSL pair and one complete
JSON reflection document.
**Write scope**: `mir/wgsl_text*`, `driver/mod.rs`, tool reflection, fixtures,
and tests.
**Gate**: emitted WGSL validates; JSON matches ABI; current compute proof remains
unchanged or explicitly migrates through the shared contract.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-01A | Source vertex/fragment functions have canonical MIR roles | No host code |
| HV-01B | Locked first pipeline is fully representable and validated | No PBR/textures |
| HV-01C | Faber fixture emits admitted WGSL plus complete JSON | No handwritten WGSL success |

HV-01A and ABI design must be serialized. Tests for independent negative cases
can be batched after the first pattern is established.

## Checkpoints And Gates

- **Checkpoint**: HV-02 can consume the emitted artifact without guessing.
- **Batching / Split Decision**: split at semantic/MIR, ABI, and emission/JSON
  ownership boundaries; batch homogeneous diagnostics within each stage.
- **Release decision**: defer; internal compiler capability is not yet a visible
  application release.
- Stop if current syntax cannot express the locked bodies; route a language
  decision before editing grammar.

## Validation

- One filtered Radix test command per role, ABI, WGSL, and tool JSON family,
  each with a 120-second runner timeout.
- Emit WGSL and reflection from the named Faber fixture through `radix emit`.
- Validate WGSL with the repository's admitted WGSL validator path.
- Run the existing compute WebGPU reflection tests and device-role tests.
- Run `triga/scripta/check-source` and the Stage 4 source fact check if Triga
  source changes.

## Companion Skill Plan

- `red-green`: preserve the HV-00 red fixtures and close them in order.
- `correctness`: stage IO, matrix/resource layout, and fail-closed diagnostics.
- `cleanliness`: prevent more driver special cases and ABI dispatch sprawl.
- `polish`: all modified primary Rust and Faber sources.

## Open Questions

None blocking after HV-00. If HV-00 proves a locked field belongs to a different
canonical ABI type, revise this spec before factory loop execution.
