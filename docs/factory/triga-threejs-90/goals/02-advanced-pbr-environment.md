# Goal 02: Advanced PBR And Environment Lighting

**Status**: parked surface brief
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Reserved increment**: 2.0 points
**Likely owners**: `triga`, `radix`, graphics host/runtime, `examples`
**Depends on**: successor Stages 0–1 and verified standard PBR/texturing
**Lowers to**: `delivery` → `factory` only after campaign activation

## Purpose

Extend ordinary metallic-roughness rendering into a coherent advanced physical
family that pressures numeric behavior, color science, shader composition,
texture sampling, preprocessing, and resource reflection.

## Surface Area

- A bounded family selected from clearcoat, transmission/refraction, sheen,
  iridescence, IOR, attenuation, and volume behavior.
- HDR environment textures, image-based lighting, diffuse/specular environment
  response, and environment preprocessing such as filtered mip chains.
- Explicit linear/display color behavior, exposure, tone interaction, texture
  encodings, precision, and sampler requirements.
- Reuse and specialization through the programmable-material foundation rather
  than parallel hard-coded shader paths.
- Reference scenes covering opaque, layered, and transmissive materials under
  controlled lighting and environments.

## Boundary

The delivery spec must select a coherent subset from evidence. Exhaustive
physical parameter parity, offline path tracing, and renderer-specific shader
forks are outside this brief.
