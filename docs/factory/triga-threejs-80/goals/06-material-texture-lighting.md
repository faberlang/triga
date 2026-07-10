# Goal 06: Materials, Textures, And Lighting

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `radix`, browser host, `faber-runtime` if required, `examples`
**Depends on**: Goal 05 and Goal 03 geometry attributes
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first for resource/shader contract; batch-by-default for coherent families

## Purpose

Establish the dominant three.js appearance workflows—unlit, classic lit, and
metallic-roughness PBR—while forcing honest texture, sampler, uniform, shader,
color-space, and light-resource semantics through Faber and Radix.

## Invariant

Materials and lights are backend-agnostic scene/domain values whose shader and
resource requirements are derived by typed compiler/library contracts rather
than host conditionals over class names.

## Scope

- Define a coherent material family covering basic/unlit, normal or classic
  lit shading, and metallic-roughness standard PBR; include only additional
  material variants that share the established implementation path.
- Define texture descriptors/resources for 2D, cube/environment, and data
  textures as required by the scorecard, with explicit format, color space,
  dimensions, mip, wrapping, filtering, and sampler policy.
- Cover base color, alpha, emissive, normal, roughness, metalness, occlusion,
  and environment-map paths needed by representative assets.
- Cover ambient, directional, point, spot, and hemisphere-style light families
  where they share the selected light representation; defer shadow behavior to
  Goal 10.
- Add reusable texture/sampler/uniform/resource facts to MIR GPU and reflection,
  plus host upload/update/disposal behavior.
- Prove material and texture validation, shader specialization/cache identity,
  and explicit color-space conversions.

Out of scope: total TSL/node-material parity, arbitrary user shader graphs,
every legacy three.js material, advanced transmission/clearcoat unless needed
to reach the final score, and shadows.

## Gate

- Deterministic scenes prove unlit, lit, textured, normal-mapped, and
  metallic-roughness paths under multiple light families.
- Textures and samplers flow through typed reflection and direct WebGPU
  resources with explicit color-space behavior.
- Material/resource sharing and cache identity work across multiple meshes.
- Invalid texture dimensions/formats, missing attributes, unsupported material
  combinations, and resource mismatches fail before draw.

## Stop Conditions

- Materials become browser-host classes or switch statements over Triga names.
- Texture format or color-space assumptions are inferred from file extensions.
- Shader source strings become the public material API.
- PBR scope expands before the basic resource and lighting path is integrated.
