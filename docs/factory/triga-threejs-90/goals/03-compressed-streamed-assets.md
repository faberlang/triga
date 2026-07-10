# Goal 03: Compressed And Streamed Assets

**Status**: parked surface brief
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Reserved increment**: 1.5 points
**Likely owners**: `triga`, `faber`, runtime/host providers, `examples`
**Depends on**: successor Stage 0 and verified core glTF/GLB ingestion
**Lowers to**: `delivery` → `factory` only after campaign activation

## Purpose

Exercise real asset-delivery pressure across bytes, codecs, asynchronous
providers, validation, memory bounds, resource residency, and GPU upload
without letting transport or decoders own a shadow scene model.

## Surface Area

- A selected compressed geometry path such as Meshopt or Draco.
- A selected compressed texture path such as KTX2/Basis.
- HDR environment/image assets needed by advanced lighting.
- Clear acquisition, container parsing, decode, validation, Triga construction,
  residency, upload, replacement, cancellation, and disposal boundaries.
- Bounded dimensions, counts, memory, work, and malformed-input behavior.
- Progressive or asynchronous availability where the live Faber/runtime model
  can represent it honestly.

## Boundary

The later delivery spec chooses codecs and provider ownership after inspecting
the verified asset path. Exhaustive formats, production CDN policy, authoring,
and silent fallback from unsupported compressed content are outside this brief.
