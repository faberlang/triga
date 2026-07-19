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
fixtures. The Triga reusable-contract pass is complete for Goal 00. The
deferred fixture work stays part of Goal 00, but it is not a Triga-owned write.

Do not compensate for the Radix and browser gaps by moving voxel storage, DDA,
dirty chunk tracking, shader lowering, reflection, browser lifecycle, or
WebGPU host behavior into Triga. Those facts remain application, compiler, or
host-owned until a later delivery spec assigns them otherwise.

## First Draw Contract

The first draw is an indexed triangle-list draw with one position buffer, one
color buffer, one index buffer, and one transform buffer.

| Fact | Locked value | Owner | Representation | State | Evidence |
| --- | --- | --- | --- | --- | --- |
| Vertex buffer 0 | position, location 0, `float32x3`, offset 0, stride 12, vertex step | Triga source, then Radix reflection | `geometry.VertexAttributeLayout`; `MirVertexInputReflection`; WebGPU vertex buffer descriptor | implemented in Triga; partially reflected in Radix | `triga/src/geometry.fab`; `triga/exempla/triga-stage4-source-facts.fab`; `radix/crates/radix/src/mir/abi.rs` |
| Vertex buffer 1 | color, location 1, `float32x3`, offset 0, stride 12, vertex step | Triga source, then Radix reflection | `colored_indexed_geometry`; same shape as position with source name `color` | implemented in Triga; Radix reflection pending | `triga/src/geometry.fab`; `triga/exempla/hello-voxel-first-draw-facts.fab`; `radix/crates/radix/src/mir/abi.rs` |
| Index buffer | `u32` indices | Triga source; browser platform upload | `BufferGeometry.indices`; `geometry_index_format_code`; WebGPU index buffer | implemented in Triga; direct render host absent | `triga/src/geometry.fab`; `triga/exempla/triga-geometry-attributes.fab`; `triga/exempla/hello-voxel-first-draw-facts.fab` |
| Topology | triangle-list | Triga source; Radix reflection | `PrimitiveTopology.TriangleList`; `geometry_topology_code`; WebGPU primitive topology | implemented in Triga; render pipeline reflection absent | `triga/src/geometry.fab`; `triga/exempla/hello-voxel-first-draw-facts.fab` |
| Draw range | indexed draw start/count | Triga source; Radix draw reflection | `DrawRange`; `GeometryDrawCommand`; future indexed draw fields | Triga implemented; Radix draw reflection absent | `triga/src/geometry.fab`; `triga/exempla/hello-voxel-first-draw-facts.fab`; `triga/exempla/triga-geometry-attributes.fab` |
| Transform buffer | 32 `f32` values, 128 bytes: model then view-projection matrices | Triga source, then Radix binding reflection | `TransformPayload`; group 0 binding 0 read-only storage buffer | implemented in Triga; Radix binding reflection pending | `triga/src/triga.fab`; `triga/exempla/triga-transforms.fab`; Goal 01 delivery |
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
- `colored_indexed_geometry` records the Goal 01 position/color
  layout shape and returns `nihil` if the geometry does not validate.
- `geometry_topology_code` exposes validated topology facts for source and
  reflection checks. It returns `1` for triangle lists, `2` for line lists, and
  `3` for point lists.
- `geometry_index_format_code` exposes the validated source index format. It
  returns `1` for the current `u32` indexed payload and `nihil` for invalid or
  non-indexed geometry.
- `geometry_vertex_layout_count` and `geometry_vertex_layout_source_name`
  expose validated layout count and source-name facts for reflection handoff.
- `geometry_vertex_layout_step_mode_code` exposes validated layout step mode
  facts. It returns `1` for per-vertex buffers.
- `geometry_triangle_count` exposes valid triangle element counts and returns
  `nihil` for invalid or non-triangle geometry.
- `geometry_line_count` exposes valid line element counts and returns `nihil`
  for invalid or non-line geometry. Goal 06 can use this with
  `box_wire_geometry` for selection-outline draw evidence.
- `geometry_draw_command` records indexed status, element count, first element,
  base vertex, instance count, and material index for valid geometry.
- `geometry_group_draw_command` records the same draw facts from a validated
  geometry group. Goal 05 can reuse this for one draw per non-empty chunk
  without making each block a draw.
- `geometry_group_draw_commands` returns the validated draw command list for all
  groups in group order. Goal 05 can use it to submit one chunk geometry without
  host-side group inference.
- `scene_visible_mesh_transform_payloads`,
  `scene_visible_mesh_transform_payload_count`, and
  `scene_visible_mesh_transform_payload_byte_count` project effectively visible
  mesh world matrices into validated 128-byte model/view-projection payloads.
  Goals 04 and 05 can use them to prove one transform upload per visible mesh or
  non-empty chunk without host-side scene traversal.
- `scene_visible_mesh_draw_packets` and
  `scene_visible_mesh_draw_packet_count` combine the visible mesh node,
  geometry handle, material handle, and transform payload into one source-owned
  packet per effectively visible mesh. Goals 04 and 05 can pass draw assembly
  facts to the host without JavaScript reconstructing scene policy.
- `scene_visible_mesh_draw_batch_facts` ties the visible draw packet count to
  the total transform payload byte count. Goals 04 and 05 can prove draw count
  and transform upload size with one source-owned scene fact.
- `visible_face_vertex_count`, `visible_face_index_count`,
  `visible_face_triangle_count`, and visible-face payload byte helpers expose
  deterministic quad-face mesh accounting for chunk meshing. Goal 05 can use
  them to prove vertex, index, triangle, and upload-size scaling before the
  application emits concrete mesh buffers.
- `visible_face_mesh_facts` packages the same face, vertex, index, triangle,
  and payload byte facts into one source-owned record. Goal 05 can use it as a
  chunk mesh proof object without making the host recalculate draw-scale
  accounting.
- `geometry_vertex_count`, `geometry_index_count`, `geometry_group_count`,
  `geometry_group_element_total`, `geometry_attribute_scalar_count`,
  `geometry_attribute_byte_count`, `geometry_vertex_payload_byte_count`,
  `geometry_index_payload_byte_count`, and `geometry_payload_byte_count` expose
  validated payload, byte-size, and draw-count facts. Goals 02, 05, and 08 can
  use these facts to prove upload sizes, chunk resource size, expected index
  totals, and draw scaling without host-side geometry scans.
- `geometry_group_bounding_box` returns bounds for one validated draw group.
  Goal 05 can use it to associate chunk draw groups with chunk-local bounds
  without host-side vertex scanning.
- `geometry_group_bounding_sphere` returns a center and enclosing radius for
  one validated draw group. Goal 05 can use it for chunk-local coarse culling
  or selection volumes without host-side vertex scanning.
- `geometry_valid` rejects malformed attributes, duplicate names, duplicate
  shader locations, out-of-range indices, and partial triangle draw ranges.
- `geometry_vertex_layouts` converts valid geometry into layout records.
- `box_geometry` emits a deterministic indexed box with 24 vertices and 36
  indices. Goal 05 can reuse this as a reference for voxel face meshing, but
  the voxel world must remain in the example package until it proves reusable.
- `box_wire_geometry` emits a deterministic indexed line-list box with 8
  vertices and 24 indices. Goal 06 can reuse this for a minimal selection
  indicator without host-side shape construction.

The current Stage 4 exemplar proves position, normal, and UV layout facts.
`triga/exempla/hello-voxel-first-draw-facts.fab` proves the locked first-draw
position and color pair with triangle-list topology, `u32` index format, 8
vertices, 36 `u32` indices, a full draw range, and one indexed instance command.
`triga/exempla/triga-geometry-attributes.fab` proves topology codes,
group-scoped draw command creation, full group draw command lists, and
rejection cases.

## Material Facts

`triga/src/triga.fab` provides `Material` and material-family records for
source-owned material data. `material` records default opaque material state,
`material_side_code` exposes validated side intent, `material_double_sided`
records disabled face culling intent through `side = 2`,
`material_est_double_sided` checks that intent, `material_depth_enabled` checks
the combined depth-test and depth-write policy, `material_depth_test_enabled`
and `material_depth_write_enabled` expose each depth flag for pipeline
reflection, `mesh_basic_material` records minimal unlit color material intent,
`color_valid` rejects invalid normalized RGB values, and
`mesh_basic_material_color_r`, `mesh_basic_material_color_g`,
`mesh_basic_material_color_b`, and `mesh_basic_material_alpha` expose validated
fragment color and alpha facts. `material_valid` plus
`mesh_basic_material_valid` reject invalid base material or color state. The
pipeline reflection for culling, depth target format, depth compare, and color
target format remains Radix-owned.

## Scene And Resource Facts

`triga/src/scene.fab` provides stable logical identity through
`SceneHandle` and `ResourceHandle`. Each handle has an index and generation.
`resource_handle_equals` and `resource_handle_next` define logical identity and
derived-resource generation advance. Goal 07 can use this pattern for chunk mesh
resource generations. `resource_transition_valid` and
`resource_transitions_valid` validate single and batched logical resource
transitions without GPU lifetime policy. `resource_transition_changed_count`,
`resource_transition_unchanged_count`, and
`resource_transition_changed_indices`, and
`resource_transition_changed_handles` expose validated batch facts for exact
affected-chunk evidence in Goal 07. `resource_transition_current_handles`
exposes the full validated current generation set after changed and unchanged
transitions. `resource_transition_unchanged_indices` and
`resource_transition_unchanged_handles` expose stable unaffected logical
resource indices and generations for identity-preservation assertions.
`ResourceLifecycleTransition` and its constructors lock unchanged, replaced,
created, and removed single-resource states. Goal 07 can use removed lifecycle
states to represent empty chunk remeshes with no current GPU resource while
keeping actual retirement and queue completion host-owned.
`resource_lifecycles_valid`, `resource_lifecycle_changed_count`,
`resource_lifecycle_created_count`, `resource_lifecycle_removed_count`,
`resource_lifecycle_live_count`, and `resource_lifecycle_current_handles`
expose validated batch lifecycle facts for exact per-chunk generation and
live-resource evidence before host-owned retirement and destruction.
`scene_set_visible`,
`scene_visible_traverse`, `scene_visible_mesh_traverse`, and
`scene_visible_mesh_resources`, `scene_visible_mesh_resource_pair_count`,
`scene_visible_mesh_geometry_handles`, `scene_visible_mesh_material_handles`,
`scene_visible_mesh_transform_payloads`, `scene_visible_mesh_draw_packets`,
`scene_mesh_world_matrix`, and `scene_effective_visible` define source-level
visibility filtering, renderable resource projection, transform payload
projection, draw packet assembly, and mesh transform access without host
renderer policy. Goal 05 can use that contract for visible chunk draw filtering,
resource-pair count evidence, geometry/material handle projection, transform
upload evidence, draw packet evidence, and world-matrix lookup. The scene store
does not define voxel storage, dirty chunk sets, or GPU lifetime policy. Those
remain application and host facts.

## Matrix Facts

`triga/src/triga.fab` defines `Matrix4` as `lista<f32>` and states that
elements are column-major and multiply column vectors. It provides matrix
length validation, identity, translation, scale, composition, multiplication,
point application, transpose, affine inverse helpers, and a `TransformPayload`
constructor that packs model matrix values before view-projection values. It
also provides min-max, min-size, and center-size
`Box3` construction, point and box containment, `Box3` overlap extents for
axis-ordered collision fixtures, `Box3` union for aggregate chunk or selection
bounds, `Box3` inflation for source-owned selection and collision tolerances,
camera yaw/pitch ray construction, yaw-derived horizontal movement basis
vectors, normalized planar movement deltas with speed and frame time,
ray-to-`Box3` entry distance, and `RayBox3Hit`
distance/point/normal facts plus stable face-code projection. Generic
face-code validation, axis classification, opposite-face projection, face
offsets, and face colors define reusable axis-direction facts for meshing,
selection indicators, neighbor updates, and edit-adjacent-cell derivation.
Voxel DDA remains application-owned.

The first draw uses one transform storage buffer with 32 `f32` values and 128
bytes. `transform_payload_float_count`, `transform_payload_byte_count`,
`transform_payload_model_value`, and `transform_payload_view_projection_value`
expose the locked count, byte size, and order. The host must not split this
buffer or reorder the matrices unless Radix reflection says so.

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
compute-only graphics-host rejection. They are the first remaining executable
Goal 00 gate, but this Triga pass did not write them because Radix has foreign
work in progress.

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
