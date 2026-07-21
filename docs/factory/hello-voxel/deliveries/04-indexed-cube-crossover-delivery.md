# HV-04 Delivery: Indexed Cube Crossover

**Parent goal**: [`../goals/04-indexed-cube-crossover.md`](../goals/04-indexed-cube-crossover.md)
**Factory admission**: READY — HV-01, HV-02, and HV-03 complete on tip
**Primary repo**: `examples`
**Supporting repos**: `triga`, `radix`, `faber`, `hosts`
**Re-grounded**: 2026-07-21 (head-ceo lower f5b932fe; campaign re-ground triga
`62220b5`). Verified: radix Goal 01 `50d300b98`…`98db3a504` on tip; hosts HV-02
`168edcb`/`5b77ef8`/`cb3fbde` + `0152ad0`/`7920a03` on tip; Goal 03
`examples/browser-app` + `examples/hello-voxel` packages live; HV-04A
`./scripta/check-source` green.

## Interpreted Unit

Assemble the admitted shader, host, browser runtime, and Triga contracts into
the first visible Faber-authored indexed 3D application.

## Normalized Spec

- Build the locked 8-position, RGB-color, 36-index cube in Faber.
- Produce model and view-projection matrices from Triga operations.
- Update model rotation from Faber frame time and projection from resize state.
- Render one indexed instance with depth through the direct host.
- Tie structural, submission, and pixel evidence to one artifact build.
- Do not add voxel, lighting, texture, or host-side scene behavior.

## Repo-Aware Baseline

- Triga math: `triga/src/triga.fab` and transform exemplar. The source now
  includes perspective projection and look-at view matrix helpers for the
  crossover camera, reusable perspective-camera projection facts for aspect,
  near/far, projection scale evidence, and composed view-projection facts. The
  exemplar also validates the 32-float, 128-byte transform payload constructor
  that stores model matrix values before view-projection matrix values.
- Triga material: `triga/src/triga.fab` and basics exemplar. It includes a
  validated material constructor, side-code projection, combined and per-flag
  depth-policy checks, double-sided material helper, and minimal unlit
  `MeshBasicMaterial` constructor with validated RGB and alpha projections for
  source-owned cube material intent. It also exposes reusable material pipeline
  facts for side, depth, transparency, alpha, and alpha-test policy.
- Triga geometry: `triga/src/geometry.fab` and geometry exemplar. It includes a
  validated colored indexed constructor for position/color payloads and
  explicit layout facts for count, source name, format, stride, and vertex step
  mode, plus a source draw command for indexed count, first element, base
  vertex, and instance count. It also exposes indexed draw batch facts for draw
  count, grouped element total, and upload byte counts.
- Triga scene: `triga/src/scene.fab` and scene-store exemplar. It includes
  visible mesh resource facts, transform-payload projection, visible draw
  packets, and draw batch facts, so the cube proof can hand one source-owned
  node/resource/transform packet and its resource and transform-upload counts
  to the host without host-side scene reconstruction.
- Application root: `examples/hello-voxel/` exists as a package-admission
  scaffold with generated mount automation. HV-03 browser lifecycle support is
  complete for the current non-GPU scope; HV-04 can consume that runtime after
  shader and host dependencies are available.
- Shader/reflection producer: HV-01 Radix fixture and artifact command.
- Browser graphics runtime: sibling monorepo `hosts/webgpu-browser/` (HV-02
  complete; the goal doc's `radix/hosts/` path is stale).
- Browser lifecycle: Faber `browser-app` output (HV-03 complete).

## Stage Graph

### HV-04A - Reusable Triga Prerequisites

**Status**: complete for current reusable Triga scope
**Output**: only missing generic matrix/camera/material/geometry helpers with
focused Triga exempla.
**Write scope**: `triga/src/` and `triga/exempla/`.
**Gate**: helpers compile and emit through existing Triga checks; no cube-specific
state enters Triga.
**Evidence**: `triga/src/triga.fab`, `triga/src/geometry.fab`,
`triga/src/scene.fab`, `triga/exempla/triga-basics.fab`,
`triga/exempla/triga-geometry-attributes.fab`,
`triga/exempla/triga-scene-store.fab`, and
`triga/exempla/triga-transforms.fab`. The current source covers the reusable
cube prerequisites: position/color indexed geometry, indexed draw batch facts,
minimal unlit material and pipeline facts, perspective/view-projection math,
32-float transform payloads, and visible mesh draw-packet facts. The HV-01,
HV-02, and HV-03 dependencies are now complete on tip; HV-04B/HV-04C are the
remaining units.

### HV-04B - Faber Cube Application

**Depends on**: HV-04A and HV-01/HV-03 artifacts
**Output**: cube payload, camera, frame update, artifact manifest, and proof
state added to the existing `examples/hello-voxel/` scaffold.
**Write scope**: Hello Voxel example package only.
**Gate**: generated artifacts match the locked contract and change model matrix
across frames.

### HV-04C - Direct Visible Proof

**Depends on**: HV-04B and HV-02
**Output**: reproducible browser run with indexed submission, depth, resize, and
non-background pixel evidence.
**Write scope**: example proof script and narrowly required host integration.
**Gate**: visible result and structural state identify the same artifact build.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-04A | Generic Triga gaps are closed and tested | No app state in Triga |
| HV-04B | Faber owns cube, camera, matrices, and frame update | No host reconstruction |
| HV-04C | Direct indexed output is visible and evidenced | No voxel scope |

Triga helper work and application assembly can overlap only when their files are
disjoint and the helper signatures are frozen. Browser integration follows.

## Checkpoints And Gates

- **Checkpoint**: direct-render milestone; HV-05 becomes unblocked.
- **Batching / Split Decision**: split library prerequisites, application, and
  browser proof at repo/validation boundaries; preserve one end-to-end gate.
- **Release decision**: defer; record an internal milestone only.
- A clear color, host-constructed cube, or handwritten WGSL does not pass.

## Validation

- `./scripta/check-source` and `./scripta/check-compile` from Triga.
- Build/check the Hello Voxel package through sibling Faber.
- Run Radix WGSL/reflection artifact freshness checks.
- Execute the browser proof at two frame times and after resize.
- Assert 36 indexed elements, one instance, increasing frame count, changed
  model matrix, and non-background central-region pixels.

## Companion Skill Plan

- `correctness`: matrix order, aspect, depth, index winding, and artifact identity.
- `cleanliness`: keep example application separate from generic Triga modules.
- `polish`: all modified primary Faber, Rust, JavaScript, and script files.

## Cross-Goal Dependency (residual soft_gate)

Indexed-draw facts (`index_format`, `index_count`, `instance_count`,
`base_vertex`, `first_index`) are not yet compiler-emitted in Radix graphics
reflection. The HV-02 fixture consumes them from a `draw.json` generated by
`hosts/scripta/generate-graphics-payloads.py`. That is a soft_gate, not a hard
gate: HV-04 may proceed, but the cube application must not inherit host-script
ownership of draw policy. Default: HV-04B owns the cube draw facts as
Faber-package source data and emits the draw manifest through the Faber/Radix
artifact path (generated `draw.json` refresh), keeping the runtime host a pure
consumer. A later Radix unit can fold indexed-draw facts into graphics
reflection and retire the script (do not block HV-04 on it).

## Open Questions

None blocking. Browser pixel tolerance is established from the first admitted
run and recorded before later proofs reuse it.
