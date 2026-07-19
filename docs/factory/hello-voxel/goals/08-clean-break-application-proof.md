# Goal 08: Clean Break And Application Proof

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Delivery**: [`../deliveries/08-clean-break-application-proof-delivery.md`](../deliveries/08-clean-break-application-proof-delivery.md)
**Target repos**: `triga`, `radix`, `faber`, `examples`
**Depends on**: Goals 00-07
**Lowers to**: `delivery` -> `factory`
**Batching posture**: batch-by-default after proof-harness admission

## Purpose

Prove Hello Voxel as one coherent Faber application and remove obsolete
third-party rendering paths.

## Invariant

An admitted Hello Voxel build contains one canonical rendering path: Faber and
Triga intent lowered by Radix and executed through the direct browser WebGPU
host.

## Locked Proof And Removal Contract

- The canonical product is `examples/hello-voxel/` built through the Faber
  `browser-app` path and served by a checked repo script.
- The proof state records artifact identity, WebGPU adapter/device result,
  pipeline admission, submitted frame count, selected block, last edit, dirty
  chunks, and resource counters.
- The scripted success flow loads the deterministic world, waits for two frames,
  acquires pointer lock when supported, moves the camera, selects a known block,
  removes it, places it again, resizes the viewport, and verifies bounded live
  resources.
- Pixel evidence samples a deterministic viewport and tolerates only explicitly
  documented backend variance. Structural state remains required even when
  pixel evidence passes.
- Remove runtime three.js imports and import maps from
  `triga/exempla/threejs-host-demo/` and
  `radix/hosts/webgpu-browser/public/`. Preserve only concise historical prose
  when it remains accurate; do not retain an executable fallback.

## Ground Truth And Implementation Path

- Add the final proof driver beside `examples/hello-voxel/` and integrate
  producer checks from Triga, Radix, and Faber.
- Update `radix/scripta/webgpu-browser-proof` so its admitted graphics path no
  longer requires three.js while its compute proof remains honest.
- Update `triga/scripta/check-capabilities` only for evidence that actually
  reaches the declared proof level. Do not convert source or static evidence
  into `host_graphics` success.
- Run a repository-bounded dependency scan across `triga`, `radix`, `faber`,
  and `examples`; documentation/oracle references are allowed, runtime imports
  are not.
- Record the independent completion review under
  `docs/factory/hello-voxel/` before changing campaign status.

## Scope

- Assemble the shader, browser runtime, renderer, voxel, interaction, and
  incremental-resource results into one reproducible package.
- Add structural artifact and third-party dependency scans.
- Add browser execution evidence for initialization, multiple frames, visible
  voxel output, movement, selection, removal, placement, and resize.
- Add deterministic canvas or pixel evidence tied to the built artifacts.
- Exercise unsupported WebGPU, denied pointer lock, stale artifact, invalid
  reflection, resize, and device-loss outcomes where automation permits.
- Remove three.js imports, import maps, runtime objects, and obsolete accepted
  fixtures from the visible Triga/Radix proof path.
- Update campaign and capability documentation without upgrading unsupported
  later targets.
- Run an independent completion audit before campaign closeout.

## Non-Goals

- Publish or deploy the application without separate authorization.
- Claim Minecraft, Doom, CAD, or general engine completion.
- Add compatibility fallbacks for removed three.js paths.
- Convert unavailable browser evidence into a passing claim.

## Gate

- A clean build opens as an interactive bounded voxel application.
- The user can move, select, remove, and place blocks.
- Edits update only affected chunk resources.
- The same artifact identity supports structural and browser evidence.
- No admitted runtime imports or embeds a third-party renderer.
- Failure modes are actionable and do not silently stall.
- An independent audit finds no proxy success or hidden rendering shim.

## Validation

Run the complete Triga, Radix, Faber, and example validation named by prior
goals. Execute the browser proof, scripted interaction sequence, deterministic
pixel/canvas comparison, resource-lifecycle cycle, and runtime dependency scan.
Record unavailable evidence as unavailable.

## Stop Conditions

- The proof passes only because three.js or handwritten shader/application code
  remains in an unscanned path.
- Structural and browser evidence come from different artifact builds.
- A screenshot substitutes for scripted state and interaction assertions.
- Cleanup removes historical evidence needed to explain the migration.
- Release, hosting, or external publication proceeds without authorization.
