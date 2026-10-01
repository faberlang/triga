#!/usr/bin/env python3
"""Write presenter bins for the SceneStore two-box fixture.

`faber run` cannot import `triga:geometry/data` (MIR vector-method residual),
so this evaluates `box()` lists from source and the same camera / translation
matrices as `host/fixtures/scene.fab`. Two TransformPayloads (left/right)
match `visible_meshes` packet order after refresh_world.
"""

from __future__ import annotations

import json
import math
import re
import struct
import sys
import zlib
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


def mat4_translation(offset):
    return [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        offset[0], offset[1], offset[2], 1.0,
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


def transform_payload(model, view_proj):
    return model + view_proj


def generate_transforms(output_dir: Path) -> list[dict]:
    # Matches host/fixtures/scene.fab camera + left/right translations.
    eye = (0.0, 1.8, 4.2)
    view = mat4_look_at(eye, (0.0, 0.0, 0.0), (0.0, 1.0, 0.0))
    projection = mat4_perspective(42.0, 1.0, 0.1, 40.0)
    view_proj = mat4_mul(projection, view)
    left_model = mat4_translation((-1.25, 0.0, 0.0))
    right_model = mat4_translation((1.25, 0.0, 0.0))
    payloads = [
        transform_payload(left_model, view_proj),
        transform_payload(right_model, view_proj),
    ]
    flat: list[float] = []
    draws = []
    for index, values in enumerate(payloads):
        if len(values) != 32:
            raise SystemExit(f"TransformPayload must be 32 floats, got {len(values)}")
        draws.append({
            "instance_count": 1,
            "base_vertex": 0,
            "first_index": 0,
            "index_count": 36,
            "transform_float_offset": index * 32,
        })
        flat.extend(values)
    write_f32_array(output_dir / "graphics-transforms.bin", flat)
    # First payload also at the legacy single-buffer name for admission size checks.
    write_f32_array(output_dir / "graphics-transform.bin", payloads[0])
    return draws


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
    uvs = [float(value) for value in eval_box_list(match.group(3), x, y, z)]
    if len(positions) != 72 or len(normals) != 72 or len(uvs) != 48 or len(indices) != 36:
        raise SystemExit("unexpected box() list lengths")
    if positions[:3] != [-0.5, -0.5, 0.5]:
        raise SystemExit(f"unexpected box(1,1,1) first vertex: {positions[:3]}")
    return positions, normals, uvs, indices


def write_checkerboard_png(path: Path, size: int = 8, tile: int = 2) -> None:
    rows = bytearray()
    for y in range(size):
        rows.append(0)
        for x in range(size):
            on = ((x // tile) + (y // tile)) % 2 == 0
            rows.extend((220, 40, 40, 255) if on else (240, 230, 80, 255))

    def chunk(tag: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)

    ihdr = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(bytes(rows), 9))
        + chunk(b"IEND", b"")
    )


def main() -> None:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <output_dir> <basic.fab>", file=sys.stderr)
        sys.exit(2)

    output_dir = Path(sys.argv[1])
    basic_fab = Path(sys.argv[2])
    output_dir.mkdir(parents=True, exist_ok=True)
    positions, normals, uvs, indices = load_box_mesh(basic_fab)
    draws = generate_transforms(output_dir)

    write_f32_array(output_dir / "graphics-vertex-positions.bin", positions)
    write_f32_array(output_dir / "graphics-vertex-normals.bin", normals)
    write_f32_array(output_dir / "graphics-vertex-uvs.bin", uvs)
    write_u32_array(output_dir / "graphics-indices.bin", indices)
    write_checkerboard_png(output_dir / "albedo.png")
    (output_dir / "draw.json").write_text(
        json.dumps({
            "index_format": "uint32",
            "instance_count": 1,
            "base_vertex": 0,
            "first_index": 0,
            "index_count": 36,
            "draws": draws,
        })
        + "\n"
    )

    for name in (
        "graphics-vertex-positions.bin",
        "graphics-vertex-normals.bin",
        "graphics-vertex-uvs.bin",
        "graphics-indices.bin",
        "graphics-transform.bin",
        "graphics-transforms.bin",
        "albedo.png",
        "draw.json",
    ):
        print(f"generated {output_dir / name}")


if __name__ == "__main__":
    main()
