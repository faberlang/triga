// Triga corpus flowing-water shader.
//
// The Faber controller publishes a flat 36-byte grid record. The current
// browser host admits one position attribute, so the shader performs the
// water deformation from position and the model translation slot. The
// translation is consumed as a monotonic phase channel and is deliberately
// omitted from the model matrix used for placement.

@group(0) @binding(0) var<storage, read> transform: array<f32>;

struct WaterVertexInput {
  @location(0) position: vec3<f32>,
}

struct WaterVertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(0) @interpolate(perspective) color: vec3<f32>,
}

@vertex
fn triga_water_vertex(input: WaterVertexInput) -> WaterVertexOutput {
  var out: WaterVertexOutput;
  let model = mat4x4<f32>(
    vec4<f32>(transform[0], transform[1], transform[2], transform[3]),
    vec4<f32>(transform[4], transform[5], transform[6], transform[7]),
    vec4<f32>(transform[8], transform[9], transform[10], transform[11]),
    vec4<f32>(0.0, 0.0, 0.0, 1.0)
  );
  let view_proj = mat4x4<f32>(
    vec4<f32>(transform[16], transform[17], transform[18], transform[19]),
    vec4<f32>(transform[20], transform[21], transform[22], transform[23]),
    vec4<f32>(transform[24], transform[25], transform[26], transform[27]),
    vec4<f32>(transform[28], transform[29], transform[30], transform[31])
  );

  let phase = transform[12] * 2.6;
  let wave_a = sin(input.position.x * 0.72 + phase) * 0.38;
  let wave_b = cos(input.position.z * 0.86 - phase * 1.2) * 0.24;
  let wave_c = sin((input.position.x + input.position.z) * 0.42 + phase * 1.7) * 0.16;
  let wave_height = wave_a + wave_b + wave_c;
  let water_position = vec3<f32>(input.position.x, wave_height, input.position.z);

  out.position = view_proj * model * vec4<f32>(water_position, 1.0);
  let crest = clamp((wave_height + 0.55) / 1.1, 0.0, 1.0);
  let deep_water = vec3<f32>(0.02, 0.12, 0.28);
  let bright_water = vec3<f32>(0.08, 0.68, 0.86);
  out.color = mix(deep_water, bright_water, crest);
  return out;
}

struct WaterFragmentInput {
  @location(0) @interpolate(perspective) color: vec3<f32>,
}

struct WaterFragmentOutput {
  @location(0) color: vec4<f32>,
}

@fragment
fn triga_water_fragment(input: WaterFragmentInput) -> WaterFragmentOutput {
  var out: WaterFragmentOutput;
  out.color = vec4<f32>(input.color, 1.0);
  return out;
}
