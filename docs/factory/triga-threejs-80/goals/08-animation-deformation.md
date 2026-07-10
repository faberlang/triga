# Goal 08: Animation And Deformation

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `radix`, `faber-runtime`, browser host, `examples`
**Depends on**: Goals 01–05
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first for binding/update model; batch-by-default for track families

## Purpose

Support time-based scene behavior and loaded character motion while using
animation to stress typed property binding, interpolation, mutation, matrices,
large numeric buffers, render-loop integration, and GPU deformation.

## Invariant

Animation data and playback semantics live in Triga/Faber; CPU and GPU
deformation consume the same clip, binding, timing, and scene identity facts.

## Scope

- Define clips, typed keyframe tracks, actions, mixers, loop modes, time scale,
  interpolation, weights, fades/crossfades, additive behavior, and deterministic
  update ordering for the campaign subset.
- Bind tracks to scene transforms, morph weights, visibility, and selected
  material properties without stringly host-side property walks.
- Add morph target attributes and influence evaluation.
- Define bones, skeleton hierarchy, bind matrices, skin indices/weights, and an
  admitted skinning path; route reusable matrix/vector/device facts to Radix.
- Integrate animation updates with dirty transforms, bounds, culling, resource
  updates, and render frames.
- Prove CPU reference results and selected GPU deformation results where the
  campaign claims GPU execution.

Out of scope: animation authoring tools, inverse kinematics suites, physics
simulation, motion retargeting completeness, and every interpolation addon.

## Gate

- A mixer plays, pauses, loops, blends, and seeks transform tracks
  deterministically.
- At least one morph-target or skinned-mesh scene deforms correctly through the
  direct render path.
- Track bindings survive scene hierarchy and asset identity changes according
  to explicit policy.
- Invalid key times, target types, weights, skeleton graphs, and buffer shapes
  fail clearly.

## Stop Conditions

- Animation playback is implemented only in browser JavaScript.
- Property bindings depend on unchecked dotted strings.
- GPU skinning invents a separate skeleton or transform convention.
- Animation breadth expands before transform-track and one deformation proof
  are integrated.
