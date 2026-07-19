# HV-03 Delivery: Faber Browser Application Runtime

**Parent goal**: [`../goals/03-browser-application-runtime.md`](../goals/03-browser-application-runtime.md)
**Factory admission**: READY after HV-00
**Primary repo**: `faber`
**Supporting repos**: `faber-web`, `examples`

## Interpreted Unit

Extend the existing Faber `browser-app` product so Faber source owns a bounded
interactive frame and input lifecycle through generated browser adaptation.

## Normalized Spec

- Preserve `WebController` as the package entry contract.
- Add typed frame, resize, keyboard, pointer, focus, and pointer-lock events.
- Generate listener registration, one-frame scheduling, state conversion, and
  cleanup without embedding application decisions.
- Add a minimal Hello Voxel controller fixture that demonstrates state updates.
- Keep WebGPU effects, camera math, and gameplay out of this unit.

## Repo-Aware Baseline

- Browser manifest/product definitions: `faber/src/package/manifest.rs` and
  `product.rs`.
- Controller discovery, ambient declarations, entry rendering, and `tsc`
  invocation: `product.rs`.
- WEB3 and containment tests: `faber/src/package_test.rs`.
- Product source authority: imported `WebController` from `web:web`; local
  look-alike annotations already fail closed.
- Framework source: `faber-web/src/web.fab` and `faber-web/src/dom.fab`.
- Browser runtime effects and bindings: `faber-web/runtime/dom.ts` and
  `faber-web/bindings/ts.toml`.
- Existing consuming proof: `examples/browser-app/`.
- New application consumer: `examples/hello-voxel/`.

## Stage Graph

### HV-03A - Typed Platform Contract

**Output**: Faber-visible event/state types and lifecycle functions in the live
`web:web`/`web:dom` owner.
**Write scope**: `faber-web/src/`, `runtime/dom.ts`, `bindings/ts.toml`, and
focused `faber-web/tests/` coverage.
**Gate**: the contract expresses every locked event without DOM object leakage.

### HV-03B - Generated Browser Adapter

**Depends on**: HV-03A
**Output**: generated TypeScript/ESM listener, scheduling, pointer-lock, failure,
and cleanup code from one admitted controller.
**Write scope**: `faber/src/package/product.rs`, manifest code if required, and
adjacent package tests.
**Gate**: generated output is deterministic, contained, typed, and removes
listeners on shutdown.

### HV-03C - Consuming Package Proof

**Depends on**: HV-03B
**Output**: minimal `examples/hello-voxel/` browser package that receives frames
and input and exposes deterministic state without rendering policy.
**Write scope**: the example package and its check script.
**Gate**: browser automation observes frame progress and input/focus transitions
originating from Faber state.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-03A | Typed Faber lifecycle contract compiles | No renderer objects |
| HV-03B | Packaging emits contained adapter and cleanup | No app behavior in TS |
| HV-03C | Faber state changes across frames and events | No 3D scene |

Contract and generator changes are serialized. Independent event conversion
fixtures can be batched after the first event pattern passes.

## Checkpoints And Gates

- **Checkpoint**: HV-04 can drive a frame-updated Faber application.
- **Batching / Split Decision**: split library contract, package generator, and
  consuming proof at repo and validation boundaries.
- **Release decision**: defer; browser runtime remains an internal application
  prerequisite.
- Stop if the only route requires a new Radix web backend rather than existing
  TypeScript browser packaging.

## Validation

- One filtered `cargo test` command per Faber browser-product test family, each
  with an explicit 120-second runner timeout.
- Build the Hello Voxel `browser-app` package twice and compare generated files.
- Run TypeScript checking through the existing Faber packaging command.
- Browser checks for frame count, resize, key state, pointer movement, focus
  loss, pointer-lock denial, and listener cleanup.

## Companion Skill Plan

- `correctness`: event ordering, focus cleanup, scheduling, and generated-output
  containment.
- `cleanliness`: prevent `render_browser_entry` and ambient declarations from
  becoming unstructured string sprawl.
- `polish`: modified Rust, Faber, TypeScript template, and example sources.

## Open Questions

None blocking. `faber-web` is the canonical contract/runtime owner; Faber owns
product packaging and generated controller entry code.
