# Receipt — release Faber face visibility probe

**Handle:** `1c6fb0c0`
**Memo:** `e05f78fa`
**Scope:** one targeted face probe only; no Triga visibility sweep.

## Command and boundary

The requested release binary is `/Users/ianzepp/.local/bin/faber` (`faber
1.7.0`). The direct probe command was:

```text
cd /Users/ianzepp/work/faberlang/triga
FABER_LIBRARY_HOME=/Users/ianzepp/work/faberlang \
  /Users/ianzepp/.local/bin/faber test src/face.proba
```

The release package-test route stops before semantic analysis with:

```text
frontmatter declares locale 'en' but no standard library path is configured
```

To inspect the same face probe's provider boundary without changing the
checkout, the release binary checked `src/face.fab` with the same
`FABER_LIBRARY_HOME`. That produced the SEM002/SEM004 cascade below. This is
not a second coverage unit; it is the provider-side check for the one face
probe.

## Provider and locale diagnosis

The `triga:math` provider resolves. There is no provider-not-found or import
path diagnostic, and `triga:geometry/data` also resolves. The failure is an
export projection failure in the release tool's view of the current provider,
not a missing checkout or a bad `triga:*` path.

The release check produced **4 `SEM002.unknown_qualified_type`** diagnostics
and **26 `SEM004.namespace_missing_export`** diagnostics. The first distinct
qualified missing names are:

1. `math.Vector3` — `SEM002`
2. `math.face_code_valida` — `SEM004`
3. `math.vector3` — `SEM004`
4. `math.face_code_color` — `SEM004`

There are no further distinct names in this probe.

Every one is already public in the live source:

- `Vector3`: `src/math.fab:33`
- `face_code_valida`: `src/math.fab:631`
- `face_code_color`: `src/math.fab:690`
- `vector3`: `src/math.fab:726`

The current `face.fab` imports are also the intended public imports at
`src/face.fab:8-10`; no obsolete `private` modifier remains.

## Classification and recommendation

This is **not** a Triga `@ public` gap and does not justify adding annotations.
The release binary timestamp is 2026-08-15 18:51, while the live export-wave
commits landed afterward (`94c8da7` for math on 2026-08-16 and `9d9246c` for
face/geometry on 2026-08-17). The release binary is stale relative to the
current source/export surface. Its package-test route also lacks the standard
library path needed by the `.proba` frontmatter.

**Recommended action:** rebuild or select a release Faber binary from the
current Radix tip, then rerun `src/face.proba`. Do not change `src/math.fab`,
`src/face.fab`, or add a broad `@ public` map for this receipt.
