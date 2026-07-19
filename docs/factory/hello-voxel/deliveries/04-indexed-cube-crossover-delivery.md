# HV-04 Delivery: Indexed Cube Crossover

**Parent goal**: [`../goals/04-indexed-cube-crossover.md`](../goals/04-indexed-cube-crossover.md)
**Factory admission**: READY after HV-01, HV-02, and HV-03
**Primary repo**: `examples`
**Supporting repos**: `triga`, `radix`, `faber`

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

- Triga math: `triga/src/triga.fab` and transform exemplar. It now includes
  perspective projection and look-at view matrix helpers for the crossover
  camera.
- Triga material: `triga/src/triga.fab` and basics exemplar. It includes a
  validated material constructor, side-code projection, combined and per-flag
  depth-policy checks, double-sided material helper, and minimal unlit
  `MeshBasicMaterial` constructor with validated RGB and alpha projections for
  source-owned cube material intent.
- Triga geometry: `triga/src/geometry.fab` and geometry exemplar. It includes a
  validated colored indexed constructor for position/color payloads and
  explicit layout facts for count, source name, format, stride, and vertex step
  mode, plus a source draw command for indexed count, first element, base
  vertex, and instance count.
- Application root: `examples/hello-voxel/` created by HV-03.
- Shader/reflection producer: HV-01 Radix fixture and artifact command.
- Browser graphics runtime: `radix/hosts/webgpu-browser/` after HV-02.
- Browser lifecycle: Faber `browser-app` output after HV-03.

## Stage Graph

### HV-04A - Reusable Triga Prerequisites

**Output**: only missing generic matrix/camera/material/geometry helpers with
focused Triga exempla.
**Write scope**: `triga/src/` and `triga/exempla/`.
**Gate**: helpers compile and emit through existing Triga checks; no cube-specific
state enters Triga.

### HV-04B - Faber Cube Application

**Depends on**: HV-04A and HV-01/HV-03 artifacts
**Output**: cube payload, camera, frame update, artifact manifest, and proof state
under `examples/hello-voxel/`.
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

## Open Questions

None blocking. Browser pixel tolerance is established from the first admitted
run and recorded before later proofs reuse it.
