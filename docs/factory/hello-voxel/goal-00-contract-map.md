# Goal 00 Contract Map

**Goal**: [`goals/00-baseline-contract-lock.md`](goals/00-baseline-contract-lock.md)
**Delivery**: [`deliveries/00-baseline-contract-lock-delivery.md`](deliveries/00-baseline-contract-lock-delivery.md)
**State**: Triga-side inventory and first-draw layout proof complete. Radix red fixtures are deferred to the Radix owner.
**Last checked**: 2026-07-19

## Invariant

Every fact required by the first indexed WebGPU draw has one owner and one
source or emitted representation. The browser host must consume emitted
reflection and data. It must not parse WGSL or infer Triga field names.

## Operating Scope

This pass writes only Triga planning evidence. Radix has active foreign
implementation work, so this pass does not add Radix tests or browser-host
fixtures. The deferred fixture work stays part of Goal 00, but it is not a
Triga-owned write.

## First Draw Contract

The first draw is an indexed triangle-list draw with one position buffer, one
color buffer, one index buffer, and one transform buffer.

| Fact | Locked value | Owner | Representation | State | Evidence |
| --- | --- | --- | --- | --- | --- |
| Vertex buffer 0 | position, location 0, `float32x3`, offset 0, stride 12, vertex step | Triga source, then Radix reflection | `geometry.VertexAttributeLayout`; `MirVertexInputReflection`; WebGPU vertex buffer descriptor | implemented in Triga; partially reflected in Radix | `triga/src/geometry.fab`; `triga/exempla/triga-stage4-source-facts.fab`; `radix/crates/radix/src/mir/abi.rs` |
| Vertex buffer 1 | color, location 1, `float32x3`, offset 0, stride 12, vertex step | Triga source, then Radix reflection | `colored_indexed_triangle_geometry`; same shape as position with source name `color` | implemented in Triga; Radix reflection pending | `triga/src/geometry.fab`; `triga/exempla/hello-voxel-first-draw-facts.fab`; `radix/crates/radix/src/mir/abi.rs` |
| Index buffer | `u32` indices | Triga source; browser platform upload | `BufferGeometry.indices`; WebGPU index buffer | implemented in Triga; direct render host absent | `triga/src/geometry.fab`; `triga/exempla/triga-geometry-attributes.fab` |
| Topology | triangle-list | Triga source; Radix reflection | `PrimitiveTopology.TriangleList`; WebGPU primitive topology | implemented in Triga; render pipeline reflection absent | `triga/src/geometry.fab` |
| Draw range | indexed draw start/count | Triga source; Radix draw reflection | `DrawRange`; `GeometryDrawCommand`; future indexed draw fields | Triga implemented; Radix draw reflection absent | `triga/src/geometry.fab`; `triga/exempla/hello-voxel-first-draw-facts.fab`; `triga/exempla/triga-geometry-attributes.fab` |
| Transform buffer | 32 `f32` values: model then view-projection matrices | Application Faber; Radix binding reflection | group 0 binding 0 read-only storage buffer | planned; no Triga core type change needed | `triga/src/triga.fab`; Goal 01 delivery |
| Vertex entry | `@vertex` entry emits builtin position and color varying | Radix source lowering | vertex WGSL plus reflection | position-only scaffold exists; color varying absent | `radix/crates/radix/src/driver/mod.rs`; `radix/crates/radix/src/mir/wgsl_text.rs` |
| Fragment entry | fragment returns location 0 RGBA with alpha 1 | Radix source lowering | fragment WGSL plus reflection | absent | `radix/crates/radix/src/mir/abi.rs` has no fragment stage |
| Color target | `bgra8unorm` | Radix reflection; browser platform host | render pipeline descriptor | absent | browser host is compute-only |
| Depth target | `depth24plus`, write enabled, compare less | Radix reflection; browser platform host | render pipeline and depth texture descriptor | absent | browser host is compute-only |
| Culling | none | Radix reflection | render pipeline primitive state | absent | no direct graphics host descriptor |
| Instance count | one | Triga source; Radix draw reflection | `GeometryDrawCommand.instance_count`; future indexed draw command | Triga implemented; Radix draw reflection absent | `triga/src/geometry.fab`; `triga/exempla/hello-voxel-first-draw-facts.fab` |

## Triga Source Facts

Triga already provides the source-owned geometry data needed by the first draw:

- `BufferAttribute` records attribute name, shader location, component width,
  element count, usage, and typed data.
- `VertexAttributeLayout` records source name, shader location, vertex format,
  offset, stride, and step mode.
- `indexed_triangle_geometry` records indexed triangle geometry with `u32`
  indices and a `DrawRange`.
- `colored_indexed_triangle_geometry` records the Goal 01 position/color
  layout shape and returns `nihil` if the geometry does not validate.
- `geometry_triangle_count` exposes valid triangle element counts and returns
  `nihil` for invalid or non-triangle geometry.
- `geometry_draw_command` records indexed status, element count, first element,
  base vertex, instance count, and material index for valid geometry.
- `geometry_group_draw_command` records the same draw facts from a validated
  geometry group. Goal 05 can reuse this for one draw per non-empty chunk
  without making each block a draw.
- `geometry_valid` rejects malformed attributes, duplicate names, duplicate
  shader locations, out-of-range indices, and partial triangle draw ranges.
- `geometry_vertex_layouts` converts valid geometry into layout records.
- `box_geometry` emits a deterministic indexed box with 24 vertices and 36
  indices. Goal 05 can reuse this as a reference for voxel face meshing, but
  the voxel world must remain in the example package until it proves reusable.

The current Stage 4 exemplar proves position, normal, and UV layout facts.
`triga/exempla/hello-voxel-first-draw-facts.fab` proves the locked first-draw
position and color pair with 8 vertices, 36 `u32` indices, a full draw range,
and one indexed instance command. `triga/exempla/triga-geometry-attributes.fab`
proves group-scoped draw command creation and rejection cases.

## Material Facts

`triga/src/triga.fab` provides `Material` and material-family records for
source-owned material data. `material` records default opaque material state,
`material_double_sided` records disabled face culling intent through `side = 2`,
`material_est_double_sided` checks that intent, `material_depth_enabled` checks
depth-test and depth-write policy, and `material_valid` rejects empty names and
out-of-range material scalars. The pipeline reflection for culling, depth target
format, depth compare, and color target format remains Radix-owned.

## Scene And Resource Facts

`triga/src/scene.fab` provides stable logical identity through
`SceneHandle` and `ResourceHandle`. Each handle has an index and generation.
`resource_handle_equals` and `resource_handle_next` define logical identity and
derived-resource generation advance. Goal 07 can use this pattern for chunk mesh
resource generations. The scene store does not define voxel storage, dirty chunk
sets, or GPU lifetime policy. Those remain application and host facts.

## Matrix Facts

`triga/src/triga.fab` defines `Matrix4` as `lista<f32>` and states that
elements are column-major and multiply column vectors. It provides identity,
translation, scale, composition, multiplication, point application, transpose,
and affine inverse helpers.

The first draw uses one transform storage buffer with 32 `f32` values. The
buffer order is model matrix first and view-projection matrix second. The host
must not split this buffer or reorder the matrices unless Radix reflection says
so.

## Radix And Browser State

This pass read the current Radix and browser surfaces without writing them.

| Surface | Current state | Required downstream owner |
| --- | --- | --- |
| `MirKernelShaderStage` | `Compute` and `Vertex` only | Radix |
| Source vertex entry | accepts exactly one empty `@ vertex` function and Triga layout facts | Radix |
| Vertex WGSL contract | emits reflected input signature and builtin position from `position` | Radix |
| Fragment stage | absent | Radix |
| Render pipeline reflection | absent | Radix |
| Indexed draw reflection | absent | Radix |
| Browser reflection consumer | requires one compute kernel | Radix browser host |
| Browser runtime | creates compute pipeline, compute pass, storage buffers, and readback | Radix browser host |
| Visible runtime without three.js | absent | Radix browser host plus Faber packaging |

## Missing Fact Register

| Missing fact | Owner | Downstream goal | Required evidence |
| --- | --- | --- | --- |
| Color layout reflection for locked first draw | Radix | Goal 01 | Faber fixture emits/reflection admits location 0 position and location 1 color |
| Non-empty vertex body lowering | Radix | Goal 01 | WGSL computes clip position from transform buffer and emits color varying |
| Fragment stage and reflection | Radix | Goal 01 | `MirKernelShaderStage` or successor model carries fragment; WGSL and JSON reflection include fragment entry |
| Render pipeline descriptor | Radix | Goal 01/02 | reflection records vertex buffers, shader entries, primitive, target, depth, and culling |
| Indexed draw command | Radix | Goal 01/02 | reflection records index format, index count, first index, base vertex, instance count |
| Graphics host admission | Radix browser host | Goal 02 | host rejects malformed graphics descriptors and creates a render pipeline from reflection |
| Browser app lifecycle | Faber/faber-web | Goal 03 | generated app owns init, frame, resize, input, focus, and cleanup events |
| Indexed cube package | examples/Triga | Goal 04 | visible direct WebGPU cube proof with no third-party renderer |

## Deferred Red Fixtures

Goal 00 requested red fixtures for missing fragment admission and
compute-only graphics-host rejection. They are still useful, but this Triga
pass did not write them because Radix has foreign work in progress.

The intended Radix fixture boundaries are:

- a compiler/reflection fixture that reaches the missing fragment-stage
  assertion; and
- a browser-consumer fixture that proves the current host rejects a graphics
  descriptor because it is compute-only, not because artifact fetch or setup
  failed.

## Validation Commands

Use these checks for this Triga-side contract pass:

```bash
git -C triga diff --check
./scripta/check-source
./scripta/check-compile
```

Use these checks when Radix owns the deferred red fixture pass:

```bash
cargo test -p radix <new_fragment_filter>
node hosts/webgpu-browser/public/src/product-boundary-check.mjs
```

The deferred red tests must fail at the intended assertion before Goal 01 or
Goal 02 turns them green.
