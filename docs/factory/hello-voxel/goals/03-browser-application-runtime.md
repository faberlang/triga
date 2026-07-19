# Goal 03: Faber Browser Application Runtime

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Delivery**: [`../deliveries/03-browser-application-runtime-delivery.md`](../deliveries/03-browser-application-runtime-delivery.md)
**Target repos**: `faber-web`, `faber`, `examples`
**Depends on**: Goal 00
**May overlap**: Goal 01
**Lowers to**: `delivery` -> `factory`
**Batching posture**: split-on-boundary

## Purpose

Let a Faber package own an interactive browser application's lifecycle without
application-specific handwritten JavaScript.

## Invariant

Faber source owns application behavior. Generated platform bindings own browser
API adaptation and expose typed events and lifecycle operations.

## Locked Runtime Contract

- Extend the existing `browser-app` product and `WebController` packaging path;
  do not add a Radix `web` target or a second bundler.
- One generated controller mounts one canvas selected by a static selector.
- The application receives `init`, `frame(timestamp_ms)`, `resize(width,
  height, pixel_ratio)`, keyboard, pointer-move, pointer-button, focus, and
  pointer-lock state events.
- Keyboard state uses physical key codes. Pointer movement is relative only
  while locked. Focus or lock loss clears pressed keys and pending deltas.
- One outstanding animation-frame request is allowed. Shutdown cancels future
  scheduling and removes generated listeners.
- Browser capability failures are returned as typed application failures; they
  are not logged-and-ignored callbacks.

## Ground Truth And Implementation Path

- Extend packaging in `faber/src/package/product.rs` and manifest admission in
  `faber/src/package/manifest.rs`.
- Extend generated ambient browser declarations and controller emission in
  `product.rs`; cover them in the existing WEB3 tests in
  `faber/src/package_test.rs`.
- Extend the canonical `web:web` and `web:dom` contracts in
  `faber-web/src/web.fab` and `faber-web/src/dom.fab`, with browser effects in
  `faber-web/runtime/dom.ts`. Do not define local look-alike annotations in the
  application package.
- Place the first consuming package at `examples/hello-voxel/` with generated
  output kept outside its static asset root under existing browser-product law.
- Keep WebGPU object creation in the Radix browser host from Goal 02. This goal
  owns event and application lifecycle only.

## Scope

- Produce a browser-loadable package entrypoint from Faber source.
- Expose frame scheduling and monotonic frame timing.
- Expose canvas dimensions, resize, visibility, and device-pixel-ratio changes.
- Expose keyboard, pointer movement, pointer buttons, focus, and pointer lock.
- Define initialization, steady-state frame, failure, and shutdown behavior.
- Keep DOM and WebGPU platform objects outside Triga domain types.
- Provide deterministic non-GPU tests for event conversion and lifecycle state.

## Non-Goals

- A general DOM framework or UI toolkit.
- Touch/mobile controls, gamepad support, audio, networking, or storage.
- Voxel rules, camera math, or renderer policy in the generated adapter.
- Handwritten JavaScript callbacks that implement application behavior.

## Gate

- A Faber package receives frame, resize, keyboard, pointer, and pointer-lock
  events through one generated browser path.
- The package updates visible application state across multiple frames.
- Unsupported or denied browser capabilities produce typed failures.
- Generated artifacts remain inside the package output boundary.
- No application behavior must be duplicated in JavaScript.

## Validation

Use package build checks, generated-artifact containment tests, event conversion
tests, and browser automation for frame and input delivery where supported.

## Stop Conditions

- A browser controller becomes a second application implementation.
- Platform objects leak into Triga source contracts.
- Global callbacks or ambient state become the canonical application API.
- Pointer lock or browser permission denial causes an unreported stall.
