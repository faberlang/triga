# Goal 03: Faber Browser Application Runtime

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `faber`, `radix`, `examples`
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
