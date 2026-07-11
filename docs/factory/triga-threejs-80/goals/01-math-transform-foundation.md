# Goal 01: Core Math And Transform Foundation

**Status**: complete (foundation) — re-poker-face CLEARED 2026-07-11 after Color call-arg fix; see [`../stage1-poker-face-recheck-2026-07-11.md`](../stage1-poker-face-recheck-2026-07-11.md)
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `radix`, `faber-runtime`, `examples`
**Depends on**: Goal 00
**Lowers to**: `delivery` → `factory`
**Batching posture**: batch-by-default after representation proof

## Purpose

Provide the numerically coherent math and transform layer needed by every
scene, camera, geometry, lighting, animation, culling, and shader workload while
using Triga pressure to complete reusable Faber vector and matrix behavior.

## Invariant

The same typed math operation has one semantic meaning above backend emission
and produces agreed results across every admitted Rust, stepper, and MIR/GPU
consumer.

## Scope

- Decide and document the relationship between Triga `Vector*`/`Matrix*`
  domain types and compiler-owned `vector<T,N>`/`matrix<T,[R,C]>` values.
- Cover vector arithmetic, dot/cross, normalization, distances, interpolation,
  projections, and component access needed by graphics.
- Cover matrix construction, multiplication, transpose, determinant, inverse,
  compose/decompose, and vector application for 3×3 and 4×4 transforms.
- Cover quaternion/Euler conversion, composition, interpolation, and stable
  transform synchronization.
- Cover colors and essential Box/Sphere/Plane/Ray operations used downstream.
- Promote only generally reusable operations to Radix intrinsics and prove them
  with non-Triga exempla plus target impact/fail-closed coverage.

Out of scope: scene ownership, rendering, shader stages, and exhaustive
three.js convenience aliases.

## Gate

- A transform-chain workload proves local/world matrix composition and inverse
  round trips within declared tolerances.
- Required matrix operations execute instead of remaining grammar-only types.
- CPU/generated-Rust and selected MIR/stepper/GPU results agree for the shared
  operation subset.
- Singular matrices, zero-length normalization, invalid dimensions, and
  unsupported target forms fail according to explicit policy.
- The public API follows Faber morphologia and does not preserve obsolete Triga
  record forms as compatibility wrappers.

## Stop Conditions

- Triga duplicates compiler-owned receiver operations under different names.
- An emitter implements math whose meaning is absent from typed MIR.
- Matrix storage and register values are conflated without explicit conversion
  and layout policy.
- Floating-point tolerances or coordinate conventions remain implicit.
