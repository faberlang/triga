@group(0) @binding(0) var<storage, read> transform: array<f32>;

struct PresenterVertexInput {
  @location(0) position: vec3<f32>,
  @location(1) normal: vec3<f32>,
  @location(2) uv: vec2<f32>,
}

struct PresenterVertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(0) @interpolate(perspective) normal: vec3<f32>,
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
  out.normal = input.normal;
  out.uv = input.uv;
  return out;
}

@group(1) @binding(0) var albedo: texture_2d<f32>;
@group(1) @binding(1) var albedo_sampler: sampler;

struct PresenterFragmentInput {
  @location(0) @interpolate(perspective) normal: vec3<f32>,
  @location(1) @interpolate(perspective) uv: vec2<f32>,
}

struct PresenterFragmentOutput {
  @location(0) color: vec4<f32>,
}

@fragment
fn presenter_fragment(input: PresenterFragmentInput) -> PresenterFragmentOutput {
  var out: PresenterFragmentOutput;
  var light_direction: vec3<f32>;
  var diffuse: f32;
  var lighting_term: f32;
  var sampled: vec4<f32>;
  var lighting_vec: vec4<f32>;
  var tmp0: f32;
  var tmp1: f32;
  var tmp2: f32;
  var tmp3: vec3<f32>;
  var tmp4: f32;
  var tmp5: f32;
  var tmp6: f32;
  var tmp7: f32;
  var tmp8: f32;
  var tmp9: f32;
  var tmp10: f32;
  var tmp11: f32;
  var tmp12: f32;
  var tmp13: f32;
  var tmp14: f32;
  var tmp15: vec4<f32>;
  var tmp16: f32;
  var tmp17: vec4<f32>;
  var tmp18: f32;
  var tmp19: f32;
  var tmp20: f32;
  var tmp21: f32;
  var tmp22: vec4<f32>;
  tmp0 = 0.4082;
  tmp1 = 0.8165;
  tmp2 = 0.4082;
  tmp3 = vec3<f32>(tmp0, tmp1, tmp2);
  light_direction = tmp3;
  tmp4 = (input.normal.x * light_direction.x);
  tmp5 = (input.normal.y * light_direction.y);
  tmp6 = (input.normal.z * light_direction.z);
  tmp7 = (tmp4 + tmp5);
  tmp8 = (tmp7 + tmp6);
  tmp9 = 0.0;
  tmp10 = max(tmp8, tmp9);
  diffuse = tmp10;
  tmp11 = 0.25;
  tmp12 = 0.75;
  tmp13 = (tmp12 * diffuse);
  tmp14 = (tmp11 + tmp13);
  lighting_term = tmp14;
  tmp15 = textureSample(albedo, albedo_sampler, input.uv);
  sampled = tmp15;
  tmp16 = 1.0;
  tmp17 = vec4<f32>(lighting_term, lighting_term, lighting_term, tmp16);
  lighting_vec = tmp17;
  tmp18 = (sampled.x * lighting_vec.x);
  tmp19 = (sampled.y * lighting_vec.y);
  tmp20 = (sampled.z * lighting_vec.z);
  tmp21 = (sampled.w * lighting_vec.w);
  tmp22 = vec4<f32>(tmp18, tmp19, tmp20, tmp21);
  out.color = tmp22;
  return out;
}

