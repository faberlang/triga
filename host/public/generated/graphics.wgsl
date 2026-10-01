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
  var LIGHT_DX: f32;
  var LIGHT_DY: f32;
  var LIGHT_DZ: f32;
  var LIGHT_INTENSITY: f32;
  var MAT_R: f32;
  var LIGHT_R: f32;
  var MAT_G: f32;
  var LIGHT_G: f32;
  var MAT_B: f32;
  var LIGHT_B: f32;
  var SPEC_R: f32;
  var SPEC_G: f32;
  var SPEC_B: f32;
  var light_direction: vec3<f32>;
  var ndotl: f32;
  var lighting_term: f32;
  var sampled: vec4<f32>;
  var tint: vec4<f32>;
  var lighting_vec: vec4<f32>;
  var diffuse_lit: vec4<f32>;
  var spec: f32;
  var spec_term: vec4<f32>;
  var tmp0: f32;
  var tmp1: f32;
  var tmp2: f32;
  var tmp3: f32;
  var tmp4: f32;
  var tmp5: f32;
  var tmp6: f32;
  var tmp7: f32;
  var tmp8: f32;
  var tmp9: f32;
  var tmp10: f32;
  var tmp11: f32;
  var tmp12: f32;
  var tmp13: vec3<f32>;
  var tmp14: f32;
  var tmp15: f32;
  var tmp16: f32;
  var tmp17: f32;
  var tmp18: f32;
  var tmp19: f32;
  var tmp20: f32;
  var tmp21: f32;
  var tmp22: f32;
  var tmp23: f32;
  var tmp24: f32;
  var tmp25: f32;
  var tmp26: vec4<f32>;
  var tmp27: f32;
  var tmp28: f32;
  var tmp29: f32;
  var tmp30: f32;
  var tmp31: vec4<f32>;
  var tmp32: f32;
  var tmp33: vec4<f32>;
  var tmp34: f32;
  var tmp35: f32;
  var tmp36: f32;
  var tmp37: f32;
  var tmp38: vec4<f32>;
  var tmp39: f32;
  var tmp40: f32;
  var tmp41: f32;
  var tmp42: f32;
  var tmp43: vec4<f32>;
  var tmp44: f32;
  var tmp45: f32;
  var tmp46: f32;
  var tmp47: f32;
  var tmp48: f32;
  var tmp49: vec4<f32>;
  var tmp50: f32;
  var tmp51: f32;
  var tmp52: f32;
  var tmp53: f32;
  var tmp54: vec4<f32>;
  tmp0 = 0.4082;
  LIGHT_DX = tmp0;
  tmp1 = 0.8165;
  LIGHT_DY = tmp1;
  tmp2 = 0.4082;
  LIGHT_DZ = tmp2;
  tmp3 = 1.0;
  LIGHT_INTENSITY = tmp3;
  tmp4 = 0.15;
  MAT_R = tmp4;
  tmp5 = 1.0;
  LIGHT_R = tmp5;
  tmp6 = 1.0;
  MAT_G = tmp6;
  tmp7 = 0.98;
  LIGHT_G = tmp7;
  tmp8 = 1.0;
  MAT_B = tmp8;
  tmp9 = 0.92;
  LIGHT_B = tmp9;
  tmp10 = 1.0;
  SPEC_R = tmp10;
  tmp11 = 1.0;
  SPEC_G = tmp11;
  tmp12 = 1.0;
  SPEC_B = tmp12;
  tmp13 = vec3<f32>(LIGHT_DX, LIGHT_DY, LIGHT_DZ);
  light_direction = tmp13;
  tmp14 = (input.normal.x * light_direction.x);
  tmp15 = (input.normal.y * light_direction.y);
  tmp16 = (input.normal.z * light_direction.z);
  tmp17 = (tmp14 + tmp15);
  tmp18 = (tmp17 + tmp16);
  tmp19 = 0.0;
  tmp20 = max(tmp18, tmp19);
  ndotl = tmp20;
  tmp21 = 0.12;
  tmp22 = 0.88;
  tmp23 = (tmp22 * ndotl);
  tmp24 = (tmp23 * LIGHT_INTENSITY);
  tmp25 = (tmp21 + tmp24);
  lighting_term = tmp25;
  tmp26 = textureSample(albedo, albedo_sampler, input.uv);
  sampled = tmp26;
  tmp27 = (MAT_R * LIGHT_R);
  tmp28 = (MAT_G * LIGHT_G);
  tmp29 = (MAT_B * LIGHT_B);
  tmp30 = 1.0;
  tmp31 = vec4<f32>(tmp27, tmp28, tmp29, tmp30);
  tint = tmp31;
  tmp32 = 1.0;
  tmp33 = vec4<f32>(lighting_term, lighting_term, lighting_term, tmp32);
  lighting_vec = tmp33;
  tmp34 = (sampled.x * tint.x);
  tmp35 = (sampled.y * tint.y);
  tmp36 = (sampled.z * tint.z);
  tmp37 = (sampled.w * tint.w);
  tmp38 = vec4<f32>(tmp34, tmp35, tmp36, tmp37);
  tmp39 = (tmp38.x * lighting_vec.x);
  tmp40 = (tmp38.y * lighting_vec.y);
  tmp41 = (tmp38.z * lighting_vec.z);
  tmp42 = (tmp38.w * lighting_vec.w);
  tmp43 = vec4<f32>(tmp39, tmp40, tmp41, tmp42);
  diffuse_lit = tmp43;
  tmp44 = (ndotl * ndotl);
  spec = tmp44;
  tmp45 = (SPEC_R * spec);
  tmp46 = (SPEC_G * spec);
  tmp47 = (SPEC_B * spec);
  tmp48 = 0.0;
  tmp49 = vec4<f32>(tmp45, tmp46, tmp47, tmp48);
  spec_term = tmp49;
  tmp50 = (diffuse_lit.x + spec_term.x);
  tmp51 = (diffuse_lit.y + spec_term.y);
  tmp52 = (diffuse_lit.z + spec_term.z);
  tmp53 = (diffuse_lit.w + spec_term.w);
  tmp54 = vec4<f32>(tmp50, tmp51, tmp52, tmp53);
  out.color = tmp54;
  return out;
}

