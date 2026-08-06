// Triga procedural-terrain shader.
//
// The controller publishes a flat 36-byte grid record. Terrain is generated
// from that grid here so the demo can show layered value noise, ridges,
// terraces, slope-aware detail, and height fog without a second GPU input.

@group(0) @binding(0) var<storage, read> transform: array<f32>;

struct TerrainVertexInput {
  @location(0) position: vec3<f32>,
}

struct TerrainVertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(0) @interpolate(perspective) color: vec3<f32>,
}

fn hash2(point: vec2<f32>) -> f32 {
  return fract(sin(dot(point, vec2<f32>(127.1, 311.7))) * 43758.5453);
}

fn value_noise(point: vec2<f32>) -> f32 {
  let cell = floor(point);
  let local = fract(point);
  let smooth_local = local * local * (3.0 - 2.0 * local);
  let a = hash2(cell);
  let b = hash2(cell + vec2<f32>(1.0, 0.0));
  let c = hash2(cell + vec2<f32>(0.0, 1.0));
  let d = hash2(cell + vec2<f32>(1.0, 1.0));
  let row_a = mix(a, b, smooth_local.x);
  let row_b = mix(c, d, smooth_local.x);
  return mix(row_a, row_b, smooth_local.y);
}

fn fbm(point: vec2<f32>) -> f32 {
  return value_noise(point) * 0.5
    + value_noise(point * 2.03) * 0.25
    + value_noise(point * 4.06) * 0.125;
}

fn ridge_fbm(point: vec2<f32>) -> f32 {
  let first = 1.0 - abs(value_noise(point) * 2.0 - 1.0);
  let second = 1.0 - abs(value_noise(point * 2.07) * 2.0 - 1.0);
  return first * 0.55 + second * 0.275;
}

fn terrain_base(point: vec2<f32>) -> f32 {
  let broad = fbm(point * 0.052);
  let ridges = ridge_fbm(point * 0.095);
  let combined = clamp(broad * 0.92 + ridges * 0.42, 0.0, 1.0);
  let peaked = pow(combined, 1.55);
  let terrace_count = 5.0;
  let terrace_cell = fract(peaked * terrace_count);
  let terraces = floor(peaked * terrace_count) / terrace_count
    + smoothstep(0.16, 0.84, terrace_cell) * 0.18;
  return clamp(mix(peaked, terraces, 0.62), 0.0, 1.0);
}

fn terrain_height(point: vec2<f32>) -> f32 {
  let base = terrain_base(point);
  let derivative_step = 0.24;
  let slope_x = terrain_base(point + vec2<f32>(derivative_step, 0.0)) - base;
  let slope_z = terrain_base(point + vec2<f32>(0.0, derivative_step)) - base;
  let slope = clamp(length(vec2<f32>(slope_x, slope_z)) * 8.0, 0.0, 1.0);
  let weathered_detail = fbm(point * 0.24) - 0.38;
  let detail = weathered_detail * 0.34 * (1.0 - slope);
  return (base + detail) * 9.0 - 3.2;
}

fn terrain_normal(point: vec2<f32>) -> vec3<f32> {
  let step = 0.18;
  let left = terrain_height(point - vec2<f32>(step, 0.0));
  let right = terrain_height(point + vec2<f32>(step, 0.0));
  let down = terrain_height(point - vec2<f32>(0.0, step));
  let up = terrain_height(point + vec2<f32>(0.0, step));
  return normalize(vec3<f32>(left - right, step * 2.0, down - up));
}

fn model_matrix() -> mat4x4<f32> {
  return mat4x4<f32>(
    vec4<f32>(transform[0], transform[1], transform[2], transform[3]),
    vec4<f32>(transform[4], transform[5], transform[6], transform[7]),
    vec4<f32>(transform[8], transform[9], transform[10], transform[11]),
    vec4<f32>(0.0, 0.0, 0.0, 1.0)
  );
}

fn view_projection() -> mat4x4<f32> {
  return mat4x4<f32>(
    vec4<f32>(transform[16], transform[17], transform[18], transform[19]),
    vec4<f32>(transform[20], transform[21], transform[22], transform[23]),
    vec4<f32>(transform[24], transform[25], transform[26], transform[27]),
    vec4<f32>(transform[28], transform[29], transform[30], transform[31])
  );
}

@vertex
fn triga_terrain_vertex(input: TerrainVertexInput) -> TerrainVertexOutput {
  var out: TerrainVertexOutput;
  let phase = transform[12];
  let terrain_point = input.position.xz + vec2<f32>(phase * 0.018, phase * 0.009);
  let height = terrain_height(terrain_point);
  let terrain_position = vec3<f32>(input.position.x, height, input.position.z);
  let normal = terrain_normal(terrain_point);

  let slope = 1.0 - clamp(normal.y, 0.0, 1.0);
  let lowland = smoothstep(-2.5, 0.9, height);
  let highland = smoothstep(3.2, 6.4, height);
  let sand = vec3<f32>(0.54, 0.43, 0.28);
  let grass = vec3<f32>(0.17, 0.31, 0.19);
  let rock = vec3<f32>(0.32, 0.34, 0.33);
  let snow = vec3<f32>(0.82, 0.87, 0.86);
  var terrain_color = mix(sand, grass, lowland);
  terrain_color = mix(terrain_color, rock, smoothstep(0.22, 0.58, slope));
  terrain_color = mix(terrain_color, snow, highland);

  let sun_direction = normalize(vec3<f32>(-0.48, 0.84, 0.32));
  let light = 0.34 + max(dot(normal, sun_direction), 0.0) * 0.72;
  terrain_color *= light;

  let distance_from_center = length(input.position.xz);
  let distance_fog = clamp(pow(distance_from_center / 31.0, 2.0), 0.0, 1.0);
  let valley_fog = 1.0 - smoothstep(-2.1, 2.2, height);
  let fog_amount = clamp(distance_fog * 0.66 + valley_fog * 0.52, 0.0, 0.9);
  let extinction = exp(-fog_amount * 1.35);
  let sky_haze = vec3<f32>(0.34, 0.53, 0.67) * fog_amount * 0.9;
  out.color = terrain_color * extinction + sky_haze;
  out.position = view_projection() * model_matrix() * vec4<f32>(terrain_position, 1.0);
  return out;
}

struct TerrainFragmentInput {
  @location(0) @interpolate(perspective) color: vec3<f32>,
}

struct TerrainFragmentOutput {
  @location(0) color: vec4<f32>,
}

@fragment
fn triga_terrain_fragment(input: TerrainFragmentInput) -> TerrainFragmentOutput {
  var out: TerrainFragmentOutput;
  out.color = vec4<f32>(input.color, 1.0);
  return out;
}
