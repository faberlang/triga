@group(0) @binding(0) var<storage, read> transform: array<f32>;

struct PresenterVertexInput {
  @location(0) position: vec3<f32>,
  @location(1) color: vec3<f32>,
  @location(2) uv: vec2<f32>,
}

struct PresenterVertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(0) @interpolate(perspective) color: vec3<f32>,
  @location(1) @interpolate(perspective) uv: vec2<f32>,
}

@vertex
fn presenter_vertex(input: PresenterVertexInput) -> PresenterVertexOutput {
  var out: PresenterVertexOutput;
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
  out.color = input.color;
  out.uv = input.uv;
  return out;
}

@group(1) @binding(0) var albedo: texture_2d<f32>;
@group(1) @binding(1) var albedo_sampler: sampler;

struct PresenterFragmentInput {
  @location(0) @interpolate(perspective) color: vec3<f32>,
  @location(1) @interpolate(perspective) uv: vec2<f32>,
}

struct PresenterFragmentOutput {
  @location(0) color: vec4<f32>,
}

@fragment
fn presenter_fragment(input: PresenterFragmentInput) -> PresenterFragmentOutput {
  var out: PresenterFragmentOutput;
  var sampled: vec4<f32>;
  var tmp0: vec4<f32>;
  tmp0 = textureSample(albedo, albedo_sampler, input.uv);
  sampled = tmp0;
  out.color = sampled;
  return out;
}

