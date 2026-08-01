# World Schema Contract — `triga.world.v1`

**Checkpoint**: triga-engine S0 freeze item (owned by the S0 deliverable; S5 implements against it)
**Author date**: 2026-08-01
**Status**: frozen contract stub — schema contract freezes now, load/save lands at engine S5
**Decision lineage** (cite these IDs in S5 delivery specs):
- **T-F §3 recommendation (c)** — hybrid world-package format: glTF/GLB for asset payloads by URI, versioned Triga world manifest (`triga.world.v1`) for world structure. (`checkpoint/T-F-capstone-first-artifact.md`)
- **S0 report §6.3** — "Persistence is **not load-bearing at S2**: S2 freezes the schema contract stub + a no-GPU/browser-handle lint; load/save lands at S5 (capstone point 1). Manifest node identity must be stable string names/UUIDs, not `{index,generation}` handles (those stay runtime-only)." (`checkpoint/report.md`)
- **GOAL.md invariants** — "World persistence does not serialize browser or GPU handles"; "World packages must be portable semantic artifacts … must not depend on the current browser, GPU vendor, adapter limits, or incidental cache layout."
- **S0 report §1** — the world concepts land in `world/{region,terrain,stream,instance,query}` (H5; `query` at H6) and `asset/{source,gltf,image,cache}` (H5). This document is the manifest-side contract those leaves implement.
- **S0 report §8 tooling gaps** — the schema must not assume cross-module enum variants (G2, unresolved — DS-D parked) or nested TS emit beyond the G1 fix. Consequence: **this contract is a plain hand-maintained JSON artifact** validated by off-the-shelf JSON Schema / `jq`. `kind`/`type` vocabulary fields are documented strings, not faber-emitted enums.

---

## 1. Purpose and scope

This document freezes the **schema contract** for the world manifest half of the hybrid
world-package format. It answers three questions S5 needs answered before writing code:

1. What is the exact shape of a `triga.world.v1` manifest? (§2)
2. How do we mechanically prove a manifest carries no browser/GPU handle? (§3)
3. Where is the line between "asset" (glTF/GLB by URI) and "world structure" (the manifest)? (§4)

It does **not** specify load/save, streaming execution, or any engine implementation (§6).

**Backend-neutral by construction.** Every value in the manifest is a semantic fact
(numbers, strings, nested data) or a reference to an external payload by stable URI.
Nothing in the schema can *type* a browser or GPU object — the JSON grammar admits only
objects, arrays, strings, numbers, booleans, and null. The lint (§3) closes the residual
leak channel: hostile or careless authors could still *write* `"gpudriver": "adapter.vendor"`
as a string, and the lint must catch that vocabulary.

---

## 2. The `triga.world.v1` manifest schema

### 2.1 Design invariants

| # | Invariant | Consequence |
| --- | --- | --- |
| I1 | **Stable string identity only.** Every node, region, instance, prefab, geometry, material, and terrain layer is keyed by a stable string `id` (UUID or dotted name). | `{index, generation}` runtime-store handles are **forbidden** in the manifest (they are runtime-only identity; see §3 W-06). |
| I2 | **World structure only.** The manifest describes *where things are and how the world is organized*. It never carries heavy payloads. | Payloads are glTF/GLB by URI (§4). |
| I3 | **Portable semantic artifacts.** No browser, GPU vendor, adapter limit, or cache-layout value may appear. | Enforced by the lint (§3). |
| I4 | **Forward-compatible schema evolution.** Unknown fields are ignored; required fields never change meaning; removal is a new major version. | `additionalProperties: true` throughout; `schema_version` reader rules in §5. |
| I5 | **Schema mirrors the `triga.threejs-host-demo.v1` precedent** where the two overlap. | Named material descriptors, structure-of-arrays geometry attributes, `localMatrix` (column-major, 16 floats) verbatim. |
| I6 | **`kind`/`type` vocabulary is documented strings.** | No reliance on G2 cross-module enum variants; a fail-closed decoder validates the vocabulary at S5. |

### 2.2 Annotated example (frozen fixture family for S5 tests)

```json
{
  "schema": "triga.world.v1",
  "schema_version": 1,

  "source": {
    "trigaModules": ["triga:world/region", "triga:world/terrain", "triga:world/instance"],
    "sceneFacts": [
      "World manifests are stable semantic data + asset references; no browser or GPU handles.",
      "Node identity is stable string ids; runtime store-handle pairs are never persisted.",
      "Matrix4 elements are column-major and multiply column vectors."
    ]
  },

  "meta": {
    "id": "world.drift-city-plains",
    "name": "Drift City Plains",
    "generator": "faber/exempla/world-basic.fab",
    "created_at": "2026-08-01"
  },

  "materials": [
    {
      "id": "mat.ground",
      "type": "MeshStandardMaterial",
      "color": "#82d173",
      "roughness": 0.8,
      "metalness": 0.0
    }
  ],

  "geometries": [
    {
      "id": "geo.small-crate",
      "kind": "BufferGeometry",
      "vertex_count": 8,
      "attributes": {
        "position": { "component_width": 3, "values": [-1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, -1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1] },
        "normal":   { "component_width": 3, "values": [0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1] },
        "uv":       { "component_width": 2, "values": [0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1] }
      },
      "indices": [0, 2, 1, 0, 3, 2, 4, 5, 6, 4, 6, 7]
    }
  ],

  "nodes": [
    {
      "id": "node.world-root",
      "name": "world-root",
      "kind": "group",
      "parent": null,
      "children": ["node.sun", "node.ground-mesh"],
      "region": "region.alpha",
      "localMatrix": [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
    },
    {
      "id": "node.sun",
      "name": "sun",
      "kind": "directional-light",
      "parent": "node.world-root",
      "children": [],
      "color": "#ffffff",
      "intensity": 2.4,
      "localMatrix": [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 3, 4, 5, 1]
    },
    {
      "id": "node.ground-mesh",
      "name": "ground-mesh",
      "kind": "mesh",
      "parent": "node.world-root",
      "children": [],
      "geometry": "geo.small-crate",
      "material": "mat.ground",
      "localMatrix": [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -0.5, 0, 1]
    }
  ],

  "regions": [
    {
      "id": "region.alpha",
      "name": "alpha",
      "bounds": { "min": [0, 0, 0], "max": [256, 64, 256] },
      "content": ["node.world-root"],
      "streaming": {
        "policy": "resident",
        "priority": 1.0,
        "prefetch": false,
        "budget_hint_bytes": 8388608
      }
    }
  ],

  "prefabs": [
    {
      "id": "prefab.rock",
      "name": "rock",
      "asset": {
        "uri": "assets/rock.glb",
        "semantics": "glb",
        "version": "1.2.0",
        "checksum": { "algorithm": "sha256", "value": "3b4a90c2e11" }
      },
      "entry_node": "RockMesh",
      "mounts": [{ "id": "mount.top", "gltf_node": "RockTop" }]
    },
    {
      "id": "prefab.tent",
      "name": "tent",
      "nodes": ["node.tent-root", "node.tent-roof"],
      "mounts": []
    }
  ],

  "instances": [
    {
      "id": "inst.rock-01",
      "name": "rock-01",
      "prefab": "prefab.rock",
      "parent": "node.world-root",
      "region": "region.alpha",
      "transform": { "localMatrix": [0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 4, 0, 4, 1] },
      "overrides": {
        "material": { "default": "mat.ground" },
        "hidden": false
      }
    },
    {
      "id": "inst.tent-01",
      "name": "tent-01",
      "prefab": "prefab.tent",
      "parent": "node.world-root",
      "region": "region.alpha",
      "transform": { "localMatrix": [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 20, 0, 20, 1] },
      "overrides": {}
    }
  ],

  "terrain": [
    {
      "id": "terrain.plains",
      "name": "plains",
      "bounds": { "min": [0, 0, 0], "max": [256, 64, 256] },
      "cell_size": 1.0,
      "layers": [
        {
          "id": "layer.plains-height",
          "kind": "heightfield",
          "source": "inline",
          "component_width": 1,
          "width": 4,
          "depth": 4,
          "values": [0.0, 0.1, 0.2, 0.15, 0.1, 0.3, 0.4, 0.25, 0.2, 0.35, 0.5, 0.3, 0.15, 0.2, 0.25, 0.1],
          "vertical_scale": 1.0,
          "material": "mat.ground"
        },
        {
          "id": "layer.hills-mask",
          "kind": "mask",
          "source": "asset",
          "asset": {
            "uri": "assets/plains-hills.glb",
            "semantics": "glb",
            "version": "1.0.0",
            "checksum": { "algorithm": "sha256", "value": "9c0f6d122d" }
          }
        }
      ]
    }
  ],

  "placement": [
    {
      "id": "placement.rocks-alpha",
      "region": "region.alpha",
      "prefab": "prefab.rock",
      "rule": {
        "kind": "scatter",
        "seed": 1337,
        "count": 120,
        "constraint": "snap-to-terrain"
      },
      "overrides": { "scale_jitter": 0.2 }
    }
  ],

  "session": {
    "spawn_points": [
      { "id": "spawn.main", "name": "main", "position": [10, 2, 10], "yaw": 0.0 }
    ],
    "camera_bookmarks": [
      {
        "id": "cam.overview",
        "name": "overview",
        "localMatrix": [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 40, 20, 60, 1],
        "lookAt": [128, 0, 128]
      }
    ],
    "default_camera": "cam.overview"
  },

  "migrations": [
    {
      "from_version": 1,
      "to_version": 2,
      "change": "example only — v1 records what a v2 reader would upgrade",
      "note": "forward-compatible: v2 additions must be optional fields"
    }
  ]
}
```

### 2.3 JSON Schema draft (draft-07; S5 validation tooling may use this verbatim)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "triga.world.v1",
  "title": "Triga world manifest — world structure only",
  "type": "object",
  "required": ["schema", "schema_version"],
  "properties": {
    "schema":            { "const": "triga.world.v1" },
    "schema_version":    { "type": "integer", "minimum": 1 },
    "source":            { "$ref": "#/definitions/source" },
    "meta":              { "$ref": "#/definitions/meta" },
    "materials":         { "type": "array", "items": { "$ref": "#/definitions/material" } },
    "geometries":        { "type": "array", "items": { "$ref": "#/definitions/geometry" } },
    "nodes":             { "type": "array", "items": { "$ref": "#/definitions/node" } },
    "regions":           { "type": "array", "items": { "$ref": "#/definitions/region" } },
    "prefabs":           { "type": "array", "items": { "$ref": "#/definitions/prefab" } },
    "instances":         { "type": "array", "items": { "$ref": "#/definitions/instance" } },
    "terrain":           { "type": "array", "items": { "$ref": "#/definitions/terrain" } },
    "placement":         { "type": "array", "items": { "$ref": "#/definitions/placement_rule" } },
    "session":           { "$ref": "#/definitions/session" },
    "migrations":        { "type": "array", "items": { "$ref": "#/definitions/migration" } }
  },
  "additionalProperties": true,
  "definitions": {
    "stable_id": { "type": "string", "minLength": 1, "pattern": "^[A-Za-z0-9._:-]+$" },
    "asset_ref": {
      "type": "object",
      "required": ["uri"],
      "properties": {
        "uri":         { "type": "string" },
        "semantics":   { "type": "string", "enum": ["gltf", "glb", "image", "heightfield", "audio"] },
        "version":     { "type": "string" },
        "checksum":    { "$ref": "#/definitions/checksum" }
      },
      "additionalProperties": true
    },
    "checksum": {
      "type": "object",
      "required": ["algorithm", "value"],
      "properties": {
        "algorithm": { "type": "string", "enum": ["sha256"] },
        "value":     { "type": "string", "pattern": "^[0-9a-f]+$" }
      }
    },
    "local_matrix": {
      "type": "array",
      "items": { "type": "number" },
      "minItems": 16,
      "maxItems": 16
    },
    "source": {
      "type": "object",
      "properties": {
        "trigaModules": { "type": "array", "items": { "type": "string" } },
        "sceneFacts":   { "type": "array", "items": { "type": "string" } }
      }
    },
    "meta": {
      "type": "object",
      "properties": {
        "id":          { "$ref": "#/definitions/stable_id" },
        "name":        { "type": "string" },
        "generator":   { "type": "string" },
        "created_at":  { "type": "string", "format": "date-time" }
      }
    },
    "material": {
      "type": "object",
      "required": ["id", "type"],
      "properties": {
        "id":         { "$ref": "#/definitions/stable_id" },
        "type":       { "type": "string", "enum": ["MeshStandardMaterial", "MeshBasicMaterial", "MeshLambertMaterial", "MeshPhongMaterial"] },
        "color":      { "type": "string" },
        "roughness":  { "type": "number" },
        "metalness":  { "type": "number" },
        "emissive":   { "type": "string" },
        "opacity":    { "type": "number" },
        "transparent":{ "type": "boolean" }
      }
    },
    "geometry": {
      "type": "object",
      "required": ["id", "kind", "attributes"],
      "properties": {
        "id":           { "$ref": "#/definitions/stable_id" },
        "kind":         { "const": "BufferGeometry" },
        "vertex_count": { "type": "integer", "minimum": 0 },
        "attributes": {
          "type": "object",
          "patternProperties": {
            "^(position|normal|uv|color|tangent|vertexID)$": {
              "type": "object",
              "required": ["component_width"],
              "properties": {
                "component_width": { "type": "integer", "minimum": 1, "maximum": 4 },
                "values":          { "type": "array", "items": { "type": "number" } }
              }
            }
          }
        },
        "indices": { "type": "array", "items": { "type": "integer" } }
      }
    },
    "node": {
      "type": "object",
      "required": ["id", "kind", "parent", "children"],
      "properties": {
        "id":          { "$ref": "#/definitions/stable_id" },
        "name":        { "type": "string" },
        "kind":        { "type": "string", "enum": ["group", "mesh", "directional-light", "point-light", "spot-light", "hemisphere-light", "camera"] },
        "parent":      { "anyOf": [ { "type": "null" }, { "$ref": "#/definitions/stable_id" } ] },
        "children":    { "type": "array", "items": { "$ref": "#/definitions/stable_id" } },
        "region":      { "$ref": "#/definitions/stable_id" },
        "geometry":    { "$ref": "#/definitions/stable_id" },
        "material":    { "$ref": "#/definitions/stable_id" },
        "color":       { "type": "string" },
        "intensity":   { "type": "number" },
        "localMatrix": { "$ref": "#/definitions/local_matrix" }
      }
    },
    "region": {
      "type": "object",
      "required": ["id", "bounds"],
      "properties": {
        "id":      { "$ref": "#/definitions/stable_id" },
        "name":    { "type": "string" },
        "bounds":  {
          "type": "object",
          "required": ["min", "max"],
          "properties": {
            "min": { "type": "array", "items": { "type": "number" }, "minItems": 3, "maxItems": 3 },
            "max": { "type": "array", "items": { "type": "number" }, "minItems": 3, "maxItems": 3 }
          }
        },
        "content":  { "type": "array", "items": { "$ref": "#/definitions/stable_id" } },
        "streaming": { "$ref": "#/definitions/streaming_hint" }
      }
    },
    "streaming_hint": {
      "type": "object",
      "properties": {
        "policy":          { "type": "string", "enum": ["resident", "streamed", "lazy"] },
        "priority":        { "type": "number", "minimum": 0.0, "maximum": 1.0 },
        "prefetch":        { "type": "boolean" },
        "budget_hint_bytes": { "type": "integer", "minimum": 0 }
      }
    },
    "prefab": {
      "type": "object",
      "required": ["id"],
      "oneOf": [
        { "required": ["asset"] },
        { "required": ["nodes"] }
      ],
      "properties": {
        "id":          { "$ref": "#/definitions/stable_id" },
        "name":        { "type": "string" },
        "asset":       { "$ref": "#/definitions/asset_ref" },
        "entry_node":  { "type": "string" },
        "nodes":       { "type": "array", "items": { "$ref": "#/definitions/stable_id" } },
        "mounts":      { "type": "array", "items": { "$ref": "#/definitions/mount" } }
      }
    },
    "mount": {
      "type": "object",
      "required": ["id"],
      "properties": {
        "id":        { "$ref": "#/definitions/stable_id" },
        "gltf_node": { "type": "string" }
      }
    },
    "instance": {
      "type": "object",
      "required": ["id", "prefab"],
      "properties": {
        "id":        { "$ref": "#/definitions/stable_id" },
        "name":      { "type": "string" },
        "prefab":    { "$ref": "#/definitions/stable_id" },
        "parent":    { "$ref": "#/definitions/stable_id" },
        "region":    { "$ref": "#/definitions/stable_id" },
        "transform": { "type": "object", "properties": { "localMatrix": { "$ref": "#/definitions/local_matrix" } } },
        "overrides": {
          "type": "object",
          "properties": {
            "material": { "type": "object", "additionalProperties": { "$ref": "#/definitions/stable_id" } },
            "hidden":   { "type": "boolean" },
            "scale":    { "type": "array", "items": { "type": "number" }, "minItems": 3, "maxItems": 3 }
          }
        }
      }
    },
    "terrain": {
      "type": "object",
      "required": ["id", "bounds", "layers"],
      "properties": {
        "id":        { "$ref": "#/definitions/stable_id" },
        "name":      { "type": "string" },
        "bounds":    { "type": "object", "required": ["min", "max"], "properties": { "min": { "type": "array", "items": { "type": "number" }, "minItems": 3, "maxItems": 3 }, "max": { "type": "array", "items": { "type": "number" }, "minItems": 3, "maxItems": 3 } } },
        "cell_size": { "type": "number", "exclusiveMinimum": 0 },
        "layers":    { "type": "array", "items": { "$ref": "#/definitions/terrain_layer" } }
      }
    },
    "terrain_layer": {
      "type": "object",
      "required": ["id", "kind", "source"],
      "properties": {
        "id":              { "$ref": "#/definitions/stable_id" },
        "kind":            { "type": "string", "enum": ["heightfield", "mask", "splat", "normal"] },
        "source":          { "type": "string", "enum": ["inline", "asset"] },
        "component_width": { "type": "integer", "minimum": 1, "maximum": 4 },
        "width":           { "type": "integer", "minimum": 2 },
        "depth":           { "type": "integer", "minimum": 2 },
        "values":          { "type": "array", "items": { "type": "number" } },
        "asset":           { "$ref": "#/definitions/asset_ref" },
        "vertical_scale":  { "type": "number" },
        "material":        { "$ref": "#/definitions/stable_id" }
      }
    },
    "placement_rule": {
      "type": "object",
      "required": ["id", "prefab", "rule"],
      "properties": {
        "id":        { "$ref": "#/definitions/stable_id" },
        "region":    { "$ref": "#/definitions/stable_id" },
        "parent":    { "$ref": "#/definitions/stable_id" },
        "prefab":    { "$ref": "#/definitions/stable_id" },
        "rule":      { "$ref": "#/definitions/rule_kind" },
        "overrides": { "type": "object" }
      }
    },
    "rule_kind": {
      "type": "object",
      "required": ["kind"],
      "properties": {
        "kind":        { "type": "string", "enum": ["grid", "scatter", "jitter", "snap-to-terrain", "custom"] },
        "seed":        { "type": "integer" },
        "count":       { "type": "integer", "minimum": 0 },
        "density":     { "type": "number", "minimum": 0 },
        "spacing":     { "type": "number", "minimum": 0 },
        "constraint":  { "type": "string" }
      }
    },
    "session": {
      "type": "object",
      "properties": {
        "spawn_points":     { "type": "array", "items": { "type": "object", "required": ["id"], "properties": { "id": { "$ref": "#/definitions/stable_id" }, "name": { "type": "string" }, "position": { "type": "array", "items": { "type": "number" }, "minItems": 3, "maxItems": 3 }, "yaw": { "type": "number" } } } },
        "camera_bookmarks": { "type": "array", "items": { "type": "object", "required": ["id"], "properties": { "id": { "$ref": "#/definitions/stable_id" }, "name": { "type": "string" }, "localMatrix": { "$ref": "#/definitions/local_matrix" }, "lookAt": { "type": "array", "items": { "type": "number" }, "minItems": 3, "maxItems": 3 } } } },
        "default_camera":   { "$ref": "#/definitions/stable_id" }
      }
    },
    "migration": {
      "type": "object",
      "required": ["from_version", "to_version", "change"],
      "properties": {
        "from_version": { "type": "integer" },
        "to_version":   { "type": "integer" },
        "change":       { "type": "string" },
        "note":         { "type": "string" }
      }
    }
  }
}
```

Schema-level assertions the JSON Schema cannot express (enforced by the S5 loader
*and* the §3 lint, not by draft-07):

- At least one of `nodes`, `regions`, `terrain`, `instances` is non-empty (a manifest
  with only metadata is an error).
- All `id` values are unique across their declaring collection (a node id may not equal
  a region id; duplicates fail).
- `parent`/`children` reference existing node ids; `region`/`material`/`geometry`/
  `prefab`/`asset`-side ids reference existing records.
- `localMatrix` is column-major and multiplies column vectors (precedent:
  `triga.threejs-host-demo.v1`).
- Inline `geometries[].attributes` and `terrain[].layers[].values` are structure-of-arrays
  with `component_width` describing the width of each row (precedent).

### 2.4 Field tables

**Top level** (field | type | required | semantic rule)

| Field | Type | Required | Semantic rule |
| --- | --- | --- | --- |
| `schema` | string | yes | Const `triga.world.v1` — schema identity; the reader selects a decoder from this. |
| `schema_version` | integer | yes | `1` today; reader migration rules in §5. Never the writer's library version. |
| `source` | object | no | Provenance mirroring the `triga.threejs-host-demo.v1` `source` block; `trigaModules` + `sceneFacts` strings. |
| `meta` | object | no | `id`, `name`, `generator`, `created_at`; provenance only, never behavioral. |
| `materials` | array | no | Named semantic material descriptors (precedent). World-level material table; see §4 material rule. |
| `geometries` | array | no | Inline SoA geometry — small geometry only; large geometry is glTF-referenced (§4). |
| `nodes` | array | no | World scene-graph nodes; stable string `id`; see node table. |
| `regions` | array | no | Persistent world regions/chunks with bounds + streaming hints; see region table. |
| `prefabs` | array | no | Reusable prefab definitions — a glTF/GLB asset reference *or* an inline subgraph of manifest nodes. |
| `instances` | array | no | Placed prefab references: type (`prefab` id) + transform + per-instance overrides. |
| `terrain` | array | no | Terrain layer records; heightfield data inline-as-SoA or glTF-referenced. |
| `placement` | array | no | Placement-rule hooks; declared but **not evaluated** by the manifest; evaluation is S6 `world/query`. |
| `session` | object | no | Engine/session state — spawn points, camera bookmarks, default camera. Optional by design. |
| `migrations` | array | no | Forward-compatible migration records (§5). Optional; informational for readers. |

**`node`** (world scene graph — precedent `triga.threejs-host-demo.v1` `nodes`)

| Field | Type | Required | Semantic rule |
| --- | --- | --- | --- |
| `id` | string | yes | Stable string identity (UUID or dotted name). Never `{index,generation}`. |
| `name` | string | no | Human-readable name; not an identity. |
| `kind` | string | yes | `group`, `mesh`, `directional-light`, `point-light`, `spot-light`, `hemisphere-light`, `camera`. |
| `parent` | string \| null | yes | Parent node id or `null` for root(s). |
| `children` | string[] | yes | Child node ids; must match declared nodes. |
| `region` | string | no | Owning region id; residency is derived from region policy. |
| `geometry` | string | no | Inline geometry id (`geometries[]`) for `mesh` kind. Asset-referenced content enters the world **only** through prefabs+instances (§4). |
| `material` | string | no | Material id (`materials[]`) for `mesh` kind. |
| `color`, `intensity` | string / number | no | Light descriptor fields (precedent). |
| `localMatrix` | number[16] | no | Column-major local transform (precedent). Optional; identity when absent. |

**`region`**

| Field | Type | Required | Semantic rule |
| --- | --- | --- | --- |
| `id` | string | yes | Stable string identity. |
| `name` | string | no | Human-readable. |
| `bounds` | `{min:number[3], max:number[3]}` | yes | World-space axis-aligned bounds. Box3 family semantics from `triga:math`. |
| `content` | string[] | no | Node ids owned by this region (may be empty; ownership can be derived from `node.region`). |
| `streaming` | object | no | **Policy hint, not execution**: `policy` (`resident`\|`streamed`\|`lazy`), `priority` (0..1), `prefetch` (bool), `budget_hint_bytes`. Executed by `world/stream` at S5/S6; the manifest never records residency *state*. |

**`instance`** (prefab reference)

| Field | Type | Required | Semantic rule |
| --- | --- | --- | --- |
| `id` | string | yes | Stable string identity. |
| `name` | string | no | Human-readable. |
| `prefab` | string | yes | Prefab id — the instance *type*. |
| `parent` | string | no | Node id the instance attaches under. |
| `region` | string | no | Owning region id. |
| `transform` | `{localMatrix}` | no | Local transform; column-major. Optional (identity). |
| `overrides` | object | no | Per-instance overrides: `material` (map of asset material slot → manifest material id), `hidden`, `scale[3]`. |

**`prefab`**

| Field | Type | Required | Semantic rule |
| --- | --- | --- | --- |
| `id` | string | yes | Stable string identity. |
| `name` | string | no | Human-readable. |
| `asset` | AssetRef | one-of | glTF/GLB/asset reference by URI (boundary rule §4). |
| `entry_node` | string | no | Named entry point *inside* the asset (glTF node name) — the asset's internal hierarchy stays opaque to the manifest except for named entry points. |
| `nodes` | string[] | one-of | Inline subgraph of manifest node ids (asset-free prefab). |
| `mounts` | mount[] | no | Named attachment points (`id` + `gltf_node`) for world-level composition. |

**`asset_ref`** (used by `prefab.asset` and terrain layers)

| Field | Type | Required | Semantic rule |
| --- | --- | --- | --- |
| `uri` | string | yes | Stable, package-relative or explicit URI. The only way payload bytes enter a world. |
| `semantics` | string | no | `gltf`, `glb`, `image`, `heightfield`, `audio` — what the reader must build. |
| `version` | string | no | Payload version tag; changed → stale-artifact detection. |
| `checksum` | `{algorithm, value}` | no | `sha256` hex; the S5 admission check ("stale/missing artifact" production outcome) compares this. |

**`terrain` / terrain layer**

| Field | Type | Required | Semantic rule |
| --- | --- | --- | --- |
| `id`, `name` | string | yes / no | Identity + label. |
| `bounds` | `{min, max}` | yes | Extent in world units. |
| `cell_size` | number | no | Grid cell size in world units. |
| `layers[]` | array | yes | Ordered terrain layers; first is the base. |
| `layers[].id` | string | yes | Stable id. |
| `layers[].kind` | string | yes | `heightfield`, `mask`, `splat`, `normal`. |
| `layers[].source` | string | yes | `inline` (SoA `values`) or `asset` (AssetRef) — the two sanctioned forms. |
| `layers[].component_width` | int | inline | SoA row width (precedent attribute rule). |
| `layers[].width` / `depth` | int | inline | Grid resolution. |
| `layers[].values` | number[] | inline | Structure-of-arrays data. |
| `layers[].asset` | AssetRef | asset | glTF-referenced heightfield/mask payload. |
| `layers[].vertical_scale` | number | no | Height multiplier (semantic; applied by the world layer, not a GPU state). |
| `layers[].material` | string | no | Manifest material id for the layer. |

**`placement`** (hooks only)

| Field | Type | Required | Semantic rule |
| --- | --- | --- | --- |
| `id` | string | yes | Stable id. |
| `region` / `parent` | string | no | Placement scope: region or node. |
| `prefab` | string | yes | Prefab id the rule instantiates. |
| `rule` | object | yes | `kind` (`grid`, `scatter`, `jitter`, `snap-to-terrain`, `custom`), `seed`, `count`, `density`, `spacing`, `constraint`. Declared only; evaluated by S6 `world/query` placement. |
| `overrides` | object | no | Passed through to instances the rule produces. |

**`session`** (optional by design)

| Field | Type | Required | Semantic rule |
| --- | --- | --- | --- |
| `spawn_points` | array | no | `id`, `name`, `position[3]`, `yaw` — authoring/entry hints. |
| `camera_bookmarks` | array | no | `id`, `name`, `localMatrix`, `lookAt` — navigation hints. |
| `default_camera` | string | no | Bookmark id used at load. |

---

## 3. The no-GPU/browser-handle lint spec

Target: become a `scripta` check at S5. Two halves — **negative** (forbidden vocabulary)
and **positive** (structural guarantees). The negative half is a token/pattern search
over the JSON text; the positive half is structural validation (draft-07 + the §2.3
assertions).

### 3.1 Negative rules (forbidden content)

| # | Rule id | Forbidden token / pattern | Rationale |
| --- | --- | --- | --- |
| N1 | `no-gpu-device` | `GPUDevice`, `device` used as a handle, `requestDevice`, `adapter` | Device/adapter objects are host-owned and session-scoped. A manifest mentioning them depends on the current browser/GPU. |
| N2 | `no-gpu-buffer` | `GPUBuffer`, `buffer` with runtime semantics (upload/usage flags) | Vertex/index payloads are glTF bytes by URI or inline SoA; buffer *objects* are host residency. |
| N3 | `no-gpu-texture` | `GPUTexture`, `GPUSampler`, `GPUTextureView` | Texture payloads live at image/glTF URIs; sampled objects are host residency. |
| N4 | `no-gpu-pipeline` | `GPURenderPipeline`, `GPUShaderModule`, `GPUBindGroup`, `bindGroupLayout`, `pipeline`, `shaderModule` | Pipelines/shader modules are cache artifacts — "incidental cache layout" per the goal invariant. |
| N5 | `no-wgsl` | `wgsl`, `"@vertex"`, `"@fragment"`, `"@compute"`, `shaderSource`, `kernel` | Raw shader source is compiler/host territory (stop condition: demos carrying WGSL). |
| N6 | `no-store-handle` | `"index"` + `"generation"` object pairs, e.g. `{"index": N, "generation": N}` | `{index,generation}` is runtime-store identity (S0 report §6.3). Persistence keys by stable strings. |
| N7 | `no-adapter-limits` | `maxTextureDimension2D`, `maxVertexBufferStride`, `maxStorageBufferBindingSize`, `limits`, `requestAdapterInfo`, `vendor`, `architecture` | Adapter limits make the package vendor-dependent. |
| N8 | `no-canvas` | `canvas`, `offscreenCanvas`, `getContext`, `GPUTextureFormat`, `GPUCanvasContext`, `presentation` | Presentation is browser-session state. |
| N9 | `no-reflection` | `reflection`, `strideBytes`, `offsetBytes`, `vertexLayout`, `bindings`, `pipelineFacts` | Render/geometry layout facts are Radix reflection and `geometry/layout` — runtime, not persistence. |
| N10 | `no-browser-globals` | `window`, `document`, `navigator`, `localStorage`, `sessionStorage`, `requestAnimationFrame`, `location` | Browser global state is never world data. |
| N11 | `no-residency-state` | `loaded`, `resident` used as *state* (`"loaded": true`, `resident` outside the `streaming.policy` hint vocabulary) | Residency is runtime state; only *policy hints* may appear (§2.4 region). |
| N12 | `no-cache-keys` | `cacheKey`, `cache_key`, `fingerprint` of pipeline artifacts | Reproducible cache identities are engine-internal; a manifest carrying them binds to a session's cache layout. |

Match style: grep is case-insensitive on the token in the JSON *string* values and
object keys. A positive statement about these words (e.g., a `sceneFacts` note quoting
the rule) is a false positive only if the check is naive; the S5 scripta check should
scan *object keys* and *string values* and may allow a whitelist exact quote of the rule
text. Simpler: forbidden keys and `"…": "…"` value tokens; the lint ships with the fixture
`triga-scene.json`-style examples that must pass.

### 3.2 Positive rules (structural guarantees)

| # | Rule id | Assertion |
| --- | --- | --- |
| P1 | `schema-declared` | `schema` key exists and equals `triga.world.v1` for every file in the manifest corpus. |
| P2 | `version-integer` | `schema_version` is an integer ≥ 1. |
| P3 | `stable-ids` | Every `id` in `nodes`/`regions`/`prefabs`/`instances`/`geometries`/`materials`/`terrain`/`placement` matches `^[A-Za-z0-9._:-]+$`; no numeric-only id. |
| P4 | `no-numeric-identity` | No `{index,generation}` shaped object anywhere (§N6), and no `id` that is a bare integer. |
| P5 | `id-uniqueness` | Ids are unique per collection and across collections where references resolve (node id ≠ region id, etc.). |
| P6 | `references-resolve` | `parent`/`children`/`region`/`geometry`/`material`/`prefab`/`content`/`mounts` ids exist in their target collections. |
| P7 | `uri-only-payloads` | Any `uri` value points at `assets/…` (package-relative) or `https://`/`file://` (explicit); no inline `data:` blobs of payload bytes beyond the sanctioned inline SoA geometry/terrain fields. |
| P8 | `matrix-shape` | Every `localMatrix` is exactly 16 numbers. |
| P9 | `handles-free` | Union of N1–N12 tokens present nowhere. |
| P10 | `loadable` | Manifest parses and validates against §2.3 draft-07 with the §2.3 assertions; the S5 loader returns the same semantic model on two independent reads (round-trip oracle). |

Reviewable form for S5: `./scripta/check-world-manifest` = P1–P10 over every JSON file
declaring `schema: triga.world.v1` in the corpus/exempla; failures are fail-closed
(report naming layer/artifact, matching the production-outcomes vocabulary of 80
manifests).

---

## 4. The manifest ↔ glTF boundary rule

Per **T-F §3 (c)**'s stated weakness — "two formats to maintain; the manifest↔glTF
boundary (what is 'asset' vs 'world structure') must be pinned in the S0 checkpoint or
the boundary drifts" — this rule is the pin. It is deliberately asymmetric so there is
**one sanctioned direction**: payloads enter the world through `prefab.asset` /
`terrain.layers[].asset` / `geometries[]` (inline only, small).

### 4.1 The three buckets

| Bucket | Owns | Lives in |
| --- | --- | --- |
| **ASSET** | Heavy, byte-carrying, self-contained data: vertex/index buffers, images/textures, mesh data, animation curves, skins, morph targets, and the glTF scene's *internal* hierarchy | glTF/GLB files referenced by stable `uri` (AssetRef). Must remain a valid standalone glTF file. |
| **WORLD STRUCTURE** | Placement and organization: which assets are placed where, transforms, world-level hierarchy above assets, regions/bounds, residency *policy* hints, prefab/instance composition, placement rules, terrain as layers, spawn points, camera bookmarks, and the world-level material table | The `triga.world.v1` manifest. |
| **ALLOWED-EITHER (bounded)** | Small structure-of-arrays geometry (`geometries[]`) and terrain heightfield data inline-as-SoA | Manifest, bounded by the precedent's scale (~thousands of values); the exact threshold is pinned at S5. Anything larger **must** be ASSET. |

### 4.2 The pinned rules

1. **Payload rule.** Any payload beyond the inline-SoA bound is glTF/GLB by URI. The
   manifest never embeds byte blobs; P7 enforces this.
2. **Semantics rule.** "Where it goes, how it is organized, when it is resident" =
   world structure → manifest. "What the object's own data is" = asset → glTF.
3. **Hierarchy rule.** Hierarchy *inside* an asset (a glTF scene's node tree) stays in
   the asset; the manifest names only entry points (`prefab.entry_node`, `mounts[].gltf_node`)
   by stable string. Hierarchy *across* assets (parenting, transforms, grouping in the
   world) is world structure → manifest nodes/instances.
4. **Material rule.** The manifest's `materials[]` is the single world-level material
   table (precedent `triga.threejs-host-demo.v1`). A glTF asset's own materials are the
   asset's, consumed by `asset/gltf` ingestion at S5 and **not** re-declared in the
   manifest. Overriding an asset material at world level is an instance override
   (`overrides.material`: asset material slot → manifest material id). This prevents two
   competing material tables from drifting.
5. **Ingress rule.** Asset-referenced content enters the world **only** through
   `prefab.asset` (placed by `instances[]`) or `terrain.layers[].asset`. A `node` of
   kind `mesh` may reference only inline `geometries[]` ids. There is no "node directly
   references a glTF file" path. This single-ingress rule is the anti-drift mechanism.
6. **Anti-drift test.** A manifest must remain loadable and semantically meaningful with
   zero GPU/browser context (pure data); a referenced glTF file must remain valid
   standalone. If a change makes either claim false, the boundary has drifted and the
   change belongs on the other side.

---

## 5. Migration policy sketch

**Versioning model.** `schema` is the schema *identity* (`triga.world.v1`); `schema_version`
is the *revision* integer (currently `1`). A breaking change to the schema identity is a
new `$id` (`triga.world.v2`); a backward-compatible change is a new `schema_version`.

**Reader rules (fail-closed).**

| Manifest `schema_version` | Reader supports | Action |
| --- | --- | --- |
| `1` | `1` | Load directly. |
| `< 1` (older) | `1` | Upgrade-on-read (apply `migrations` records in order); never mutate the file in place. |
| `> 1` (newer) | `1` | **Reject** with a structured `version_too_new` diagnostic naming layer/artifact (production-outcomes vocabulary). No silent partial read. |

**Forward-compatible record pattern.** Every new version:

1. Adds only **optional** fields (schema `additionalProperties: true` is mandatory;
   a required field is a schema-identity change).
2. Never changes the meaning of an existing field; removal = new `$id`.
3. Records itself in `migrations[]`: `{from_version, to_version, change, note}`.
   The record is informational — readers transform by version, and the array documents
   the transform ("rename x → y", "add optional z defaulting to …").
4. Emits the **current** `schema_version` on write (S5 save), never the version that was
   read. Round-trip is idempotent for the current writer version.

**Stale-artifact interaction.** `asset_ref.version`/`checksum` is the *asset* freshness
line; `schema_version` is the *manifest* freshness line. Both feed the S5
`artifact-admission` fail-closed seam ("stale/missing artifact → admission rejects,
render status reports failed") — they are distinct axes and must not be conflated.

---

## 6. Deliberately NOT in this contract

This document is the **frozen input to S5, not S5 itself**. The following are
explicitly out of scope and must not be inferred from it:

- **Load/save implementation.** No file layout, no read/write API, no editor round-trip
  semantics. The contract is the manifest's *shape*; the loader/saver lands at S5
  (capstone point 1: "Build a persistent world package from Faber source").
- **Streaming execution.** `streaming` fields are policy hints; acquisition/residency/
  eviction execution is `world/stream` (H5/H6). No scheduler, no budget machinery.
- **Any `world/`, `asset/`, `animation/` leaf code.** `world/{region,terrain,stream,
  instance,query}`, `asset/{source,gltf,image,cache}`, `animation/*` — the module map
  freezes their names; this document freezes only the manifest data those leaves consume
  and produce.
- **The S5 engine implementation.** No host code, no scene-extractor/resource-manager
  behavior, no shader/pipeline facts (those are the S0 reflection boundary's domain).
- **Binary encoding (option (d) from T-F §3).** Later a *lossless serialization of the
  same semantic model* — this JSON contract is the model; the binary encoder is not.
- **Placement rule evaluation.** `placement[]` declares; `world/query` evaluates at S6.
- **Scale targets, LOD, culling measurements** (S6), **programmable materials** (S7),
  and **physics/audio/editor/WebXR adapters**.
- **Tooling assumptions the S0 report §8 ruled out.** No cross-module enum variants
  (G2 — unresolved), no nested TS emit beyond the G1 fix; validation uses plain JSON
  Schema draft-07 + `jq`/scripta, not faber-emitted schemas.

Open items pinned for S5 (recorded, not decided here): the inline-vs-asset size
threshold (P7), the exact `material.type` vocabulary growth path, and whether
`materials[]` gains a version field.

---

## 7. Conformance checklist (for the S5 delivery spec to cite)

1. Decision IDs cited: **T-F §3 recommendation (c)**; **S0 report §6.3**; GOAL.md
   invariants (world persistence, portability); S0 report §1 module map; S0 report §8
   tooling gaps.
2. Schema identity `triga.world.v1` / `schema_version: 1`; §2.3 draft-07 validates.
3. Lint §3 P1–P10 implemented as `./scripta/check-world-manifest`; N1–N12 present.
4. Boundary §4 rules 1–6 hold for every fixture; the anti-drift test runs in CI.
5. Migration §5 reader matrix implemented fail-closed (`version_too_new` rejects).
6. No `world/`/`asset/`/`animation/` leaf, no engine code, no load/save delivered with
   this contract — those land at S5.
