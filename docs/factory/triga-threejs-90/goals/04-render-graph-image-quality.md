# Goal 04: Render Graph And Image Quality

**Status**: parked surface brief
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Reserved increment**: 1.5 points
**Likely owners**: `triga`, `radix`, graphics host/runtime, `examples`
**Depends on**: successor Stage 0, verified predecessor multipass rendering, and stable programmable materials where consumed
**Lowers to**: `delivery` → `factory` only after campaign activation

## Purpose

Turn the predecessor's bounded multipass proof into an explicit render
orchestration model that stresses pass dependencies, transient resources,
hazards, attachment variants, and image-quality pipelines.

## Surface Area

- A typed render/pass graph with declared reads, writes, ordering, attachments,
  formats, sizes, samples, and lifecycle intent.
- Transient resource allocation/reuse, resize behavior, hazard validation, and
  fail-closed cycle or incompatibility handling.
- A bounded image-quality family drawn from multisampling, tone mapping, bloom,
  antialiasing, multiple render targets, and compatible post effects.
- Full-screen and scene passes that consume programmable materials through the
  same typed resource/reflection contracts.
- Deterministic structural, numeric, and image evidence for the selected chain.

## Boundary

This brief does not commit to deferred rendering, temporal upscalers, exhaustive
effect-composer parity, or production graph optimization. The delivery spec
must first locate graph ownership from the live predecessor implementation.
