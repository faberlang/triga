# Shader seam: Triga owns shader vocabulary, Radix lowers it

**Date**: 2026-10-01
**Kind**: design proposal, partly superseded 2026-10-01 by a head-cto review
  (handoff into this session). The split still holds. The gap list and Vivi
  handles below are stale where they disagree with Settled below.
**Checked against**: radix `e50192807`, triga `8824b11`.
**Audience**: the session working on the Triga presenter and textured meshes.

## Settled (supersedes parts of this proposal)

Operator handoff 2026-10-01, after head-cto review.

1. **Gap 1 was a misdiagnosis.** `source-fragment-lambert.fab` failed because
   a 2026-08-21 sweep rewrote `.maximus(0.0)` to `.max(0.0)`. In English
   Faber `.max` is the collection reduction; the two-value max is `.maximum`.
   That is a Triga fixture fix, not a Radix call-lowering unit.
2. **Bound functions** are body-less `fn` declarations in Triga, mapped
   through a `[target.wgsl]` bindings manifest. The manifest also maps Triga
   types to opaque target spellings (`Texture2D` → `texture_2d<f32>`,
   `Sampler` → `sampler`).
3. **A stage-function parameter whose type has a `types` entry is a resource
   binding.** The body names it by the parameter name. Group and binding
   numbers come from the existing `resource_binding` contract call, matched
   by parameter name and carrying no kind code.
4. **Radix names or validates no library vocabulary.** It never learns
   textures, samplers, or WGSL built-in names for library functions. It only
   emits the spellings the manifest gives it.
5. **Helper-function calls inside stage bodies are deferred.** Do not depend
   on them. `sample(...)` may be declared; stage bodies must not call it yet.
6. **Until the `uv` interim lands**, a fragment body naming `uv` fails with
   SEM001.

Radix chain landed on `main` (`241f3a0b6` closeout; `uv` / types table /
bound-type parameters). Textured meshes are a Triga presenter unit.

## Summary

The textured-mesh unit ("Unit 5") was scoped as a Radix change: add a texture
resource kind to the compiler's code table and emit the matching WGSL.

This document proposes a different split. Triga declares its shader
vocabulary — resource types, built-in functions, stage inputs — in Faber
source plus a binding manifest, the same way `tela:dom` declares the browser
DOM. Radix lowers ordinary Faber function bodies to WGSL and looks names up in
that manifest. Radix stops knowing what a texture, a transform, or a colour
is.

Radix still has to change before textures can work. The change is a small,
one-time set of generic mechanisms. After it lands, new materials, resource
types, and built-ins are Triga-only changes.

## The problem with the current shape

Three pieces of Triga's rendering vocabulary are hard-coded in Radix today.

1. **Closed code tables.** `radix/crates/radix-mir/src/shader_contract.rs`
   maps integer codes to resource kinds, vertex formats, stage-I/O roles, and
   so on. Resource kinds are storage buffer and runtime extent only; any other
   code fails with `mir_shader_resource_kind_code_unsupported`. Triga's
   `src/shader_contract.fab` passes those integers through
   `assert …_matches(…)` calls.

2. **Template shader bodies.** When a stage function is empty, as in
   `host/fixtures/box.fab`, Radix writes the body itself
   (`radix/crates/radix-mir-wgsl/src/emit/entry.rs`, the fallback branch near
   line 116). A resource with the `transform` role and at least 32 floats
   becomes `view_proj * model * vec4(position, 1.0)`. A `color` varying is
   copied to the output. That is material logic inside the compiler.

3. **Injected names.** `@ vertex` and `@ fragment` silently define locals in
   the function body (`radix/crates/radix-semantic/src/passes/resolve.rs`,
   near line 2769): `position` and `out_position` for vertex; `normal`,
   `color` and `out_color` for fragment. A shader cannot name any other input.
   `uv` is not on the list. Confirmed: a fragment body that mentions `uv`
   fails with `SEM001 unknown_identifier`.

Adding a texture under this shape means a new resource-kind code, a new role,
and a new body template for "sample the texture at the UV". The next material
costs the same again. Every Triga rendering feature becomes a compiler unit.

## The model: `tela:dom`

Tela binds the browser DOM without Radix knowing what the DOM is.

- `tela/src/dom.fab` declares the classes and functions in plain Faber.
- `tela/faber.toml` has `[target.ts] bindings = "bindings/ts.toml"`.
- `tela/bindings/ts.toml` maps each route to a host symbol, for example
  `tela:dom.scope` → `webDomScope`.
- `radix/crates/faber/src/package/binding.rs` checks the table against the
  declarations.

No annotation carries the binding. The table is keyed by target and owned by
the library.

There is one real difference. In tela, the far side of the seam is a runtime
that executes the call, so the Faber bodies can be stubs. In a shader there is
no runtime: the function body itself becomes the artifact. Body lowering is
therefore load-bearing here in a way it is not for tela.

## Proposed shape

### Triga owns

- **Opaque resource types**, declared in Faber: `Texture2D`, `Sampler`.
- **Built-in functions**, declared in Faber: `sample(texture, sampler, uv)`.
- **A WGSL binding manifest**: `[target.wgsl] bindings = "bindings/wgsl.toml"`
  in `triga/faber.toml`. It maps functions to WGSL spellings
  (`triga:shader.sample` → `textureSample`) and types to WGSL spellings
  (`Texture2D` → `texture_2d<f32>`).
- **Stage bodies.** Real `@ vertex` and `@ fragment` functions, including the
  transform maths Radix bakes in today.
- **The presenter** (`triga/host`): texture creation, upload, bind groups, and
  its own admission list.

The declaration, the WGSL spelling, and the presenter code that answers it
must agree and change together. They now live in one repository.

### Radix owns

- Lowering a Faber function body to WGSL.
- Printing WGSL grammar: functions, structs, vector and matrix types, binding
  attributes, stage attributes.
- Looking up bound names in the manifest and emitting the spelling it gives.
- Emitting reflection from the declared bindings and signatures.

Radix owns the WGSL **grammar**. It does not own the WGSL **library** — which
resource types and built-in functions exist.

### Stage functions get real signatures

`@ vertex` and `@ fragment` stay as stage markers. That fact is part of the
target grammar and stage functions are written by the application, so it
cannot move to the library manifest.

The name injection goes. Inputs become typed parameters and the output becomes
the return value:

```
@ fragment
fn box_fragment(vector<f32, 3> color, vector<f32, 2> uv) → vector<f32, 4>
```

The interstage interface is then read from the signature. `varying_matches`
and `fragment_output_matches` become redundant. The integer-tuple asserts
shrink to the vertex buffer layout, which is a fact about mesh data.

## What Radix has to change

Four gaps. All are generic mechanisms; none names a Triga concept.

| # | Gap | Where |
| --- | --- | --- |
| 1 | Stage bodies cannot contain function calls. A call is rejected in MIR lowering, before the emitter (`CODEGEN001 … method call before runtime/provider MIR lowering`). The emitter itself special-cases only `max`. | `radix-module/src/mir/lower*`, then `radix-mir-wgsl/src/emit/entry.rs`, `BodyEmissionContext::emit_statement` |
| 2 | The WGSL lane does not read a binding manifest, and the manifest schema has `functions` and `shim` only — no type table. | `crates/faber/src/package/binding.rs`; today only `product/ts_emit.rs` consumes it |
| 3 | Resource bindings can only be declared through the code table. A binding whose type is a bound opaque type has no path. | `radix-mir/src/shader_contract.rs`, `radix-module/src/driver/shader_contract.rs`, reflection output |
| 4 | Stage inputs and outputs come from injected names, not the signature. | `radix-semantic/src/passes/resolve.rs` and `lower/decl.rs`; name maps in `entry.rs` |

One generic rule replaces the lost validation: a bound opaque type may only be
declared as a binding and passed as an argument. That is a property of the
mechanism, not of textures.

No parser, grammar, or locale-pack change is needed. The annotations and the
manifest file both exist already.

The existing body lowering already covers assignment, `+ - * /`, vector
construction, lane access, scalar/vector/matrix types, float constants, and
straight-line control flow.

Measured at the commits above with `scripta/check-wgsl-shader-contract-conformance`:
`source-fragment-emits-wgsl`, `source-fragment-body-color-widening` and
`vertex-body-emits-wgsl` emit. `source-fragment-lambert` fails with the
`CODEGEN001` error in gap 1, because its body calls `.max(0.0)`. The script
reports 1 failure. Gap 1 is therefore also a repair of an existing red.

## Tracking

The compiler work is filed as Vivi needs in the `faberlang` mailspace. See
the handles recorded at the end of this document.

## Costs and risks

- **Validation moves downstream.** Radix fails closed on an unknown code
  today. With opaque bound spellings, a wrong spelling is caught by the WGSL
  validator, later and with a worse message. The presenter already runs that
  validator on load, so the failure lands in Triga's own test loop.
- **Radix must not check spellings against a list.** If the compiler validates
  that `textureSample` is a known WGSL function, the table is back in the
  compiler.
- **A second target costs a second manifest and a second presenter.** That is
  the right owner for the cost. Do not design a multi-target table until a
  second target exists.

## Open items

1. **Scope of the first request.** Textures need gaps 1, 2 and 3. Gap 4 is
   the clean design; a textured box could ship without it by adding `uv` to
   the injected-name list. Gap 4 is filed as deferred until items 2 and 3
   below are ruled on.
2. **Vertex position output.** The vertex stage must mark one output as the
   clip-space position. A plain return type cannot say that. A Triga-declared
   type bound through the manifest type table is one option; unchecked.
3. **Reading a buffer inside a body.** The authored vertex transform needs to
   index the transform storage buffer. Index projections are rejected by the
   body emitter today. Either this is a fifth gap, or the transform arrives as
   a bound matrix type.

## What Triga can do before Radix changes

- Author fragment bodies that use only `normal` and `color` with plain
  arithmetic and no calls.
  `exempla/conformance/shader-contract/source-fragment-emits-wgsl.fab` is the
  working pattern. Lambert is `.maximum(0.0)` (not `.max`); it is a
  language intrinsic, not a library call.
- Draft `src/shader.fab` declarations and `bindings/wgsl.toml` as the target
  shape, so the Radix work has a concrete consumer to test against.
- Build the presenter side: PNG decode, texture upload, sampler creation, bind
  group layout. None of it depends on the compiler.

Textures on a mesh are blocked on Radix under either architecture. Under this
one the cost is paid once.

## Do not

- Do not add resource-kind code 3 plus a sampling template to Radix. It
  unblocks one box and commits every later material to the same path.
- Do not hand-write WGSL in Triga. The seam stays: Faber source in, emitted
  WGSL out.
- Do not pack texels into a storage buffer as a stand-in for a sampler.

## Vivi handles

Mailspace `faberlang`, from `operator`, held by `mind`.

| Handle | Kind | Subject |
| --- | --- | --- |
| `c896e69c` | need | 1/3 function calls inside shader stage bodies |
| `a053dc25` | need | 2/3 WGSL lane reads library binding manifest; type table (depends on `c896e69c`) |
| `468add5c` | need | 3/3 resource bindings declared with a bound opaque type (depends on `a053dc25`) |
| `5861e409` | want | 4 stage inputs/outputs from the function signature (depends on `c896e69c`, `468add5c`; needs operator rulings) |
