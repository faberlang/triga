# Language-Lane Handoff — G2 / G3 (nested-package blockers)

**Status**: routed to the faber/radix compiler lane (2026-08-01); not owned by the engine campaign
**Source decision**: user decision — park DS-D scene split; route the two language gaps to the compiler lane
**Evidence**: probe roots `/tmp/dsd-probe-1/` (enum variant access, 5 consumer variants),
`/tmp/dsd-probe-2/` (import-cycle), `/tmp/dsd-leaves/` (the as-built scene leaf split +
relocation recipe), `/tmp/dsa-probe/` (union variant probes, control + same-module);

## The two gaps

### G2 — enum (`discretio`) variants are module-scoped

**Observation**: a `discretio` enum's variants can be neither constructed nor
pattern-matched outside the declaring module. Verified empirically across five
syntax attempts:

| Attempt | Result |
| --- | --- |
| `finge enumtest.Actus` | `PARSE030.expected_expression` (parser takes a single ident) |
| `finge enumtest.Status.Actus` | `PARSE030.expected_expression` |
| `casu Actus` (namespace import only) | `SEM001.unknown_variant` |
| `casu enumtest.Status.Actus` | `SEM001.unknown_variant` |
| `importa ex "…" privata Actus` + `finge Actus` | `SEM001.name_not_variant` (named imports bind `SymbolKind::Module`) |

**Root cause**: `crates/radix/src/semantic/passes/resolve.rs::resolve_variant_ident`
only accepts `SymbolKind::Variant` via a bare scope probe; the parser's `finge`
grammar is a single ident (`crates/radix-parser/src/expr.rs::parse_variant_expr`);
union member patterns are `Struct` symbols invisible in the value scope, and the
typecheck pattern pass (`…/typecheck/pattern.rs`) is enum-only.

**Why it blocks scene**: `SceneNodeKind`'s variants (SceneGroup/SceneMesh/
SceneCamera/SceneLight) are consumed in all three target leaves — node (fields),
store (five `casu` sites in `matrix_mundi_mesh` + traversal preorders), query
(`visibilia`). No placement of the enum satisfies every variant consumer; the
split collapses back to the monolith without this feature.

**Fix options** (for the compiler lane to choose):
1. Qualified variants in `finge`/`casu` (e.g. `finge node.SceneMesh`,
   `casu node.SceneMesh`), including the parser grammar + semantic resolution +
   faber/radix codegen for both Rust and TS emitters.
2. Named variant imports binding `SymbolKind::Variant` (e.g.
   `importa ex "…" privata Actus`).
3. Same-module union-member pattern matching (`casu` over `∪` variant genera) —
   separate but adjacent gap (G2b): union `casu` fails even same-module; the
   parser's `pattern.rs` already parses qualified path patterns and a comment
   anticipates "enum variant, union variant", but semantics never implemented it.

### G3 — faber rejects library import cycles (`PKG001`)

**Observation**: `faber check` fails with `PKG001:library_import_cycle` on a
library whose modules import each other (radix check tolerates cycles). The
scene package is genuinely cyclic: node's `SceneNode.parent/children` are
`SceneHandle` (→ store), store methods use `SceneNode`/`SceneSlot` (→ node),
store traversal-method signatures return `SceneTraversal`/`SceneMeshResources`/
`SceneMeshResourceTraversal` (→ query), query's `visibilia` takes
`SceneStore`/`SceneHandle` (→ store).

**Fix options**:
1. Cycle tolerance in faber's provider check (the resolver already handles
   cycles — only the `PKG001` diagnostic rejects them).
2. Leaf-map adjustment (co-locate traversal accumulators with store,
   `SceneHandle` with node) — changes the frozen map, does NOT solve G2 alone.

## The relocation recipe (preserved for when the language lands)

`/tmp/dsd-leaves/` holds the exact as-built leaf split (`node-actual.fab`,
`store-actual.fab`, `query-actual.fab`), the original `scene-original.fab`, the
fixture originals, and the sed line ranges. The recipe: pure relocation with
unchanged interface names; five node constructors co-located in node (forced by
`finge` scoping); cross-leaf qualifications; module-internal `theca` alias to
avoid the `store`-parameter shadowing (shadowing a module alias is illegal —
`SEM002.qualified_type_prefix_not_namespace`); fixtures use the fallback alias
(`importa ex "triga:scene/store" privata scene` + `query` alias) because
`triga-scene-store.fab` has a local variable named `store`.

## Definition of done for the handoff

- G2 (or G2b) lands: cross-module `discerne` enum variants construct/match, OR
  the language decision explicitly defers scene permanently.
- G3 lands: faber `PKG001` cycle tolerance OR an accepted leaf-map adjustment.
- Re-run: DS-D tooling probe (three-part: radix check, faber check, faber
  run --compile on a scratch scene import) → relocation per the recipe →
  fixture migration → scene-side compile-gate restoration (the 4 E0308 faber
  emitter items remain a separate lane).
