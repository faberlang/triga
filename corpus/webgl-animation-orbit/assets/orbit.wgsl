// Triga corpus orbit demo shader.
//
// The scene transport publishes one interleaved 36-byte vertex record:
// position (3 f32), normal (3 f32), and color (3 f32). The current shared
// browser host admits one attribute per vertex buffer, so this demo-owned
// adapter consumes the position field and leaves the other fields available
// for the next lit-pipeline contract.

@group(0) @binding(0) var<storage, read> transform: array<f32>;

struct OrbitVertexInput {
  @location(0) position: vec3<f32>,
}

struct OrbitVertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(0) @interpolate(perspective) color: vec3<f32>,
}

@vertex
fn triga_orbit_vertex(input: OrbitVertexInput) -> OrbitVertexOutput {
  var out: OrbitVertexOutput;
  let model = mat4x4<f32>(
    vec4<f32>(transform[0], transform[1], transform[2], transform[3]),
    vec4<f32>(transform[4], transform[5], transform[6], transform[7]),
    vec4<f32>(transform[8], transform[9], transform[10], transform[11]),
    vec4<f32>(transform[12], transform[13], transform[14], transform[15])
  );
  let view_proj = mat4x4<f32>(
    vec4<f32>(transform[16], transform[17], transform[18], transform[19]),
    vec4<f32>(transform[20], transform[21], transform[22], transform[23]),
    vec4<f32>(transform[24], transform[25], transform[26], transform[27]),
    vec4<f32>(transform[28], transform[29], transform[30], transform[31])
  );
  out.position = view_proj * model * vec4<f32>(input.position, 1.0);
  let object_t = clamp((input.position.x + 4.0) / 8.0, 0.0, 1.0);
  let left_color = vec3<f32>(0.95, 0.25, 0.18);
  let right_color = vec3<f32>(0.22, 0.82, 0.42);
  let height_light = clamp(0.78 + input.position.y * 0.16, 0.48, 1.0);
  out.color = mix(left_color, right_color, object_t) * height_light;
  return out;
}

struct OrbitFragmentInput {
  @location(0) @interpolate(perspective) color: vec3<f32>,
}

struct OrbitFragmentOutput {
  @location(0) color: vec4<f32>,
}

@fragment
fn triga_orbit_fragment(input: OrbitFragmentInput) -> OrbitFragmentOutput {
  var out: OrbitFragmentOutput;
  out.color = vec4<f32>(input.color, 1.0);
  return out;
}
