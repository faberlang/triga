#!/usr/bin/env python3
"""Write presenter bins from `triga:primitives/basic` `box(1,1,1)`.

`faber run` cannot import `triga:geometry/data` (MIR vector-method residual),
so this evaluates the `box()` `assemble_geometry` lists from source. Colors
are those face normals remapped from [-1, 1] to [0, 1]. Transform is the
32-float / 128-byte `TransformPayload` (identity model, PerspectiveCamera
view-projection). Python evaluates the same `matrix_look_at` /
`matrix_perspective` formulas as `triga:math`; `faber run` cannot import
those modules yet.
"""

from __future__ import annotations

import json
import math
import re
import struct
import sys
from pathlib import Path

BOX_ASSEMBLE = re.compile(
    r"fn box\(f32 width.*?return assemble_geometry\(24, "
    r"(\[[^\]]+\]), (\[[^\]]+\]), (\[[^\]]+\]), (\[[^\]]+\])\)",
    re.S,
)


def write_f32_array(path: Path, values: list[float]) -> None:
    path.write_bytes(struct.pack(f"<{len(values)}f", *values))


def write_u32_array(path: Path, values: list[int]) -> None:
    path.write_bytes(struct.pack(f"<{len(values)}I", *values))


def vec_sub(a, b):
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def vec_cross(a, b):
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def vec_dot(a, b):
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def vec_norm(v):
    length = math.sqrt(vec_dot(v, v))
    if length == 0.0:
        return (0.0, 0.0, 0.0)
    return (v[0] / length, v[1] / length, v[2] / length)


def mat4_identity():
    return [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ]


def mat4_mul(a, b):
    out = [0.0] * 16
    for col in range(4):
        for row in range(4):
            out[col * 4 + row] = (
                a[0 * 4 + row] * b[col * 4 + 0]
                + a[1 * 4 + row] * b[col * 4 + 1]
                + a[2 * 4 + row] * b[col * 4 + 2]
                + a[3 * 4 + row] * b[col * 4 + 3]
            )
    return out


def mat4_look_at(eye, target, up):
    z_axis = vec_norm(vec_sub(eye, target))
    x_axis = vec_norm(vec_cross(up, z_axis))
    y_axis = vec_cross(z_axis, x_axis)
    return [
        x_axis[0], y_axis[0], z_axis[0], 0.0,
        x_axis[1], y_axis[1], z_axis[1], 0.0,
        x_axis[2], y_axis[2], z_axis[2], 0.0,
        -vec_dot(x_axis, eye), -vec_dot(y_axis, eye), -vec_dot(z_axis, eye), 1.0,
    ]


def mat4_perspective(fov_y_degrees, aspect, near, far):
    f = 1.0 / math.tan(math.radians(fov_y_degrees) * 0.5)
    return [
        f / aspect, 0.0, 0.0, 0.0,
        0.0, f, 0.0, 0.0,
        0.0, 0.0, far / (near - far), -1.0,
        0.0, 0.0, (near * far) / (near - far), 0.0,
    ]


def generate_transform(output_dir: Path) -> None:
    # Same camera as host/fixtures/box.fab: PerspectiveCamera fov 42,
    # aspect 1, near 0.1, far 20, eye (1.8, 1.5, 2.6) looking at origin.
    model = mat4_identity()
    view = mat4_look_at((1.8, 1.5, 2.6), (0.0, 0.0, 0.0), (0.0, 1.0, 0.0))
    projection = mat4_perspective(42.0, 1.0, 0.1, 20.0)
    view_proj = mat4_mul(projection, view)
    values = model + view_proj
    if len(values) != 32:
        raise SystemExit(f"TransformPayload must be 32 floats, got {len(values)}")
    write_f32_array(output_dir / "graphics-transform.bin", values)


def eval_box_list(source: str, x: float, y: float, z: float):
    return eval(source, {"__builtins__": {}}, {"x": x, "y": y, "z": z})  # noqa: S307


def load_box_mesh(basic_fab: Path, width: float = 1.0, height: float = 1.0, depth: float = 1.0):
    match = BOX_ASSEMBLE.search(basic_fab.read_text())
    if match is None:
        raise SystemExit(f"could not find box() assemble_geometry lists in {basic_fab}")
    x = width * 0.5
    y = height * 0.5
    z = depth * 0.5
    positions = [float(value) for value in eval_box_list(match.group(1), x, y, z)]
    normals = [float(value) for value in eval_box_list(match.group(2), x, y, z)]
    indices = [int(value) for value in eval_box_list(match.group(4), x, y, z)]
    if len(positions) != 72:
        raise SystemExit(f"expected 72 position floats from box(), got {len(positions)}")
    if len(normals) != 72:
        raise SystemExit(f"expected 72 normal floats from box(), got {len(normals)}")
    if len(indices) != 36:
        raise SystemExit(f"expected 36 indices from box(), got {len(indices)}")
    if positions[:3] != [-0.5, -0.5, 0.5]:
        raise SystemExit(f"unexpected box(1,1,1) first vertex: {positions[:3]}")
    colors = [(value + 1.0) * 0.5 for value in normals]
    return positions, colors, indices


def main() -> None:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <output_dir> <basic.fab>", file=sys.stderr)
        sys.exit(2)

    output_dir = Path(sys.argv[1])
    basic_fab = Path(sys.argv[2])
    output_dir.mkdir(parents=True, exist_ok=True)
    positions, colors, indices = load_box_mesh(basic_fab)

    write_f32_array(output_dir / "graphics-vertex-positions.bin", positions)
    write_f32_array(output_dir / "graphics-vertex-colors.bin", colors)
    write_u32_array(output_dir / "graphics-indices.bin", indices)
    generate_transform(output_dir)
    (output_dir / "draw.json").write_text(
        json.dumps({
            "index_format": "uint32",
            "instance_count": 1,
            "base_vertex": 0,
            "first_index": 0,
            "index_count": 36,
        })
        + "\n"
    )

    print(f"generated {output_dir / 'graphics-vertex-positions.bin'}")
    print(f"generated {output_dir / 'graphics-vertex-colors.bin'}")
    print(f"generated {output_dir / 'graphics-indices.bin'}")
    print(f"generated {output_dir / 'graphics-transform.bin'}")
    print(f"generated {output_dir / 'draw.json'}")


if __name__ == "__main__":
    main()
