# Hello Voxel Factory Readiness

**Vision source**: [`CAMPAIGN.md`](CAMPAIGN.md)
**Goal checks**: [`GOAL-CHECKS.md`](GOAL-CHECKS.md)
**Factory mode**: vision, production, and delivery lowering only
**Loop status**: HV-00 Triga reusable-contract pass complete; HV-03 browser
runtime complete for non-GPU scope; Radix red fixtures pending
**Release posture**: defer release through Goal 07; Goal 08 requires an explicit
release decision

## Vision Readiness

**Verdict**: READY

### Goal Boundary

Factory may build one bounded `32 x 16 x 32` editable voxel application in
Faber, rendered through direct WebGPU with generated or compiler-owned browser
adaptation and no third-party rendering runtime.

### Non-Goals

Infinite terrain, persistence, multiplayer, advanced lighting, textures, PBR,
general engine APIs, WebGL fallback, deployment, and successor applications are
outside the factory boundary.

### Ground Truth

- Triga source under `triga/src/` and exempla under `triga/exempla/`.
- Radix graphics and reflection code under `radix/crates/radix/src/`.
- The existing direct compute host under `radix/hosts/webgpu-browser/`.
- Faber browser packaging under `faber/src/package/`.
- Faber browser contracts and runtime bindings under `faber-web/src/` and
  `faber-web/runtime/`.
- The Hello Voxel package scaffold at `examples/hello-voxel/`.

### Invariants

- Faber owns application and shader intent.
- Triga owns reusable graphics-domain contracts.
- Radix owns lowering, WGSL, reflection, and browser WebGPU lifecycle.
- The host never parses WGSL or reconstructs scene, voxel, or draw policy.
- Blocks are authoritative; meshes and GPU buffers are derived.
- Three.js is removed, not wrapped or retained as fallback.

### Acceptance Signals

The Goal 08 scripted browser flow renders the deterministic world, moves,
selects, removes and replaces a block, resizes, and preserves bounded live GPU
resources. Structural and pixel evidence identify the same build, and a bounded
scan finds no third-party runtime renderer.

### Stop Conditions

Stop on a new language design, missing compiler-owned reflection fact,
application-specific JavaScript behavior, WGSL parsing, hidden renderer,
unavailable required browser evidence, foreign work collision, or expansion
into a follow-up target.

## Production Ledger

| Unit | Vision | Dependency state | Delivery spec | Factory state |
| --- | --- | --- | --- | --- |
| HV-00 Baseline and contract lock | READY | Triga reusable contracts complete; Radix red fixtures pending | [`deliveries/00-baseline-contract-lock-delivery.md`](deliveries/00-baseline-contract-lock-delivery.md) | active |
| HV-01 Source graphics pipeline | READY | waits for HV-00 | [`deliveries/01-source-graphics-pipeline-delivery.md`](deliveries/01-source-graphics-pipeline-delivery.md) | pending |
| HV-02 Direct WebGPU graphics host | READY | waits for HV-01 | [`deliveries/02-direct-webgpu-graphics-host-delivery.md`](deliveries/02-direct-webgpu-graphics-host-delivery.md) | pending |
| HV-03 Browser application runtime | READY | complete for current non-GPU browser lifecycle scope | [`deliveries/03-browser-application-runtime-delivery.md`](deliveries/03-browser-application-runtime-delivery.md) | complete |
| HV-04 Indexed cube crossover | READY | Triga HV-04A prerequisites and HV-03 browser runtime complete; waits for HV-01 and HV-02 | [`deliveries/04-indexed-cube-crossover-delivery.md`](deliveries/04-indexed-cube-crossover-delivery.md) | pending |
| HV-05 Voxel world and chunk meshing | READY | waits for HV-04 | [`deliveries/05-voxel-world-chunk-meshing-delivery.md`](deliveries/05-voxel-world-chunk-meshing-delivery.md) | pending |
| HV-06 First-person interaction | READY | HV-03 browser runtime complete; waits for HV-05 | [`deliveries/06-first-person-interaction-delivery.md`](deliveries/06-first-person-interaction-delivery.md) | pending |
| HV-07 Incremental chunk resources | READY | waits for HV-05, HV-06 | [`deliveries/07-incremental-chunk-resources-delivery.md`](deliveries/07-incremental-chunk-resources-delivery.md) | pending |
| HV-08 Clean break and application proof | READY | waits for HV-00 through HV-07 | [`deliveries/08-clean-break-application-proof-delivery.md`](deliveries/08-clean-break-application-proof-delivery.md) | pending |

## Dependency Graph

```text
HV-00 -> HV-01 -> HV-02 --+
   |                       +-> HV-04 -> HV-05 -> HV-06 -> HV-07 -> HV-08
   +-> HV-03 -------------+               +------^         |
   +--------------------------------------------------------+
```

HV-03 is complete for the current non-GPU browser lifecycle scope. HV-01 is the
next compiler-side dependency after HV-00; HV-02 depends on HV-01. Later units
converge on shared application and host surfaces and should be serialized
unless delivery-specific write scopes prove otherwise.

## Factory Admission Rules

- Before loop execution, re-run the selected goal's readiness check against the
  live tree and inspect dirt in every target repo.
- Execute one delivery-sized unit per factory phase. Do not run the entire
  campaign as one phase.
- Save implementation evidence and commits per repo. Serialize lock-producing
  Git operations.
- Run correctness, cleanliness, housekeeping, and polish as required by the
  factory loop before admitting each checkpoint.
- Dependency completion requires the delivery gate and recorded evidence, not
  only a commit or self-authored green test.
- No cross-repo implementation is authorized by this readiness document alone.
  A Triga-only Goal 00 inventory pass is recorded in
  [`goal-00-contract-map.md`](goal-00-contract-map.md).

## Pending Units

All nine delivery specs exist. HV-00 is active. Its Triga-side reusable
contract pass is complete, including first-draw layout, material, transform,
camera yaw/pitch fact records, scene/resource lifecycle handles and batch
facts, packaged `Box3` overlap facts, packaged face-code facts, face-code unit
quads, face-code colored mesh append, visible resource facts,
visible-mesh packet, visible-face accounting,
colored quad finalization, colored mesh fact records, colored mesh draw-batch
facts, colored mesh bounds, line draw-batch facts, and direct wire-box
draw-batch facts for selection outlines. The
`triga/scripta/check-hello-voxel-contract` gate packages the Triga-owned
executable evidence and compile viability without claiming browser rendering.
Scene lifecycle facts now also expose unchanged resource counters, unchanged
logical indices, and unchanged handles so HV-07 can prove stable unaffected
chunk identities directly.
The `examples/hello-voxel` scaffold now builds as a browser package and proves
package/controller admission plus generated controller mount automation. The
Faber browser-product path now proves generated mount/failure/dispose
lifecycle, frame and resize delivery, physical key-code delivery, pointer
movement delivery, focus delivery, pointer-lock request/state delivery, typed
denied failure handling, visible state updates, and generated listener/frame
cleanup through `examples/browser-app`. This completes HV-03 for the current
non-GPU browser runtime scope. The Triga capability checker records this as the
non-scoring prerequisite manifest
`proof/prerequisites/hello-voxel-browser-runtime.json`, but it does not satisfy
HV-04 rendering gates.
HV-04A's
reusable Triga prerequisite scope is also complete for the current indexed-cube
delivery, but HV-04 itself still waits for the shader and host dependencies to
become render-capable. The first remaining
executable campaign gate
is the Radix-owned HV-00B red fixture pass. No release is authorized.

## Blocking Questions

None for planning admission. Implementation discoveries that contradict a
locked contract must return to the owning goal and delivery spec before work
continues.
