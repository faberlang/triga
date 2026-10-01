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
  var MAT_R: f32;
  var MAT_G: f32;
  var MAT_B: f32;
  var AMB_R: f32;
  var AMB_INTENSITY: f32;
  var AMB_G: f32;
  var AMB_B: f32;
  var LIGHT_INTENSITY: f32;
  var LIGHT_R: f32;
  var LIGHT_G: f32;
  var LIGHT_B: f32;
  var SPEC_R: f32;
  var SPEC_G: f32;
  var SPEC_B: f32;
  var light_direction: vec3<f32>;
  var ndotl: f32;
  var sampled: vec4<f32>;
  var mat_tint: vec4<f32>;
  var ambient_vec: vec4<f32>;
  var dir_term: f32;
  var dir_vec: vec4<f32>;
  var ambient_lit: vec4<f32>;
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
  var tmp13: f32;
  var tmp14: f32;
  var tmp15: f32;
  var tmp16: f32;
  var tmp17: vec3<f32>;
  var tmp18: f32;
  var tmp19: f32;
  var tmp20: f32;
  var tmp21: f32;
  var tmp22: f32;
  var tmp23: f32;
  var tmp24: f32;
  var tmp25: vec4<f32>;
  var tmp26: f32;
  var tmp27: vec4<f32>;
  var tmp28: f32;
  var tmp29: f32;
  var tmp30: f32;
  var tmp31: f32;
  var tmp32: vec4<f32>;
  var tmp33: f32;
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
  var tmp48: vec4<f32>;
  var tmp49: f32;
  var tmp50: f32;
  var tmp51: f32;
  var tmp52: f32;
  var tmp53: vec4<f32>;
  var tmp54: f32;
  var tmp55: f32;
  var tmp56: f32;
  var tmp57: f32;
  var tmp58: vec4<f32>;
  var tmp59: f32;
  var tmp60: f32;
  var tmp61: f32;
  var tmp62: f32;
  var tmp63: f32;
  var tmp64: vec4<f32>;
  var tmp65: f32;
  var tmp66: f32;
  var tmp67: f32;
  var tmp68: f32;
  var tmp69: vec4<f32>;
  var tmp70: f32;
  var tmp71: f32;
  var tmp72: f32;
  var tmp73: f32;
  var tmp74: vec4<f32>;
  tmp0 = 0.4082;
  LIGHT_DX = tmp0;
  tmp1 = 0.8165;
  LIGHT_DY = tmp1;
  tmp2 = 0.4082;
  LIGHT_DZ = tmp2;
  tmp3 = 0.15;
  MAT_R = tmp3;
  tmp4 = 1.0;
  MAT_G = tmp4;
  tmp5 = 1.0;
  MAT_B = tmp5;
  tmp6 = 1.0;
  AMB_R = tmp6;
  tmp7 = 0.55;
  AMB_INTENSITY = tmp7;
  tmp8 = 0.0;
  AMB_G = tmp8;
  tmp9 = 1.0;
  AMB_B = tmp9;
  tmp10 = 1.0;
  LIGHT_INTENSITY = tmp10;
  tmp11 = 1.0;
  LIGHT_R = tmp11;
  tmp12 = 0.98;
  LIGHT_G = tmp12;
  tmp13 = 0.92;
  LIGHT_B = tmp13;
  tmp14 = 1.0;
  SPEC_R = tmp14;
  tmp15 = 1.0;
  SPEC_G = tmp15;
  tmp16 = 1.0;
  SPEC_B = tmp16;
  tmp17 = vec3<f32>(LIGHT_DX, LIGHT_DY, LIGHT_DZ);
  light_direction = tmp17;
  tmp18 = (input.normal.x * light_direction.x);
  tmp19 = (input.normal.y * light_direction.y);
  tmp20 = (input.normal.z * light_direction.z);
  tmp21 = (tmp18 + tmp19);
  tmp22 = (tmp21 + tmp20);
  tmp23 = 0.0;
  tmp24 = max(tmp22, tmp23);
  ndotl = tmp24;
  tmp25 = textureSample(albedo, albedo_sampler, input.uv);
  sampled = tmp25;
  tmp26 = 1.0;
  tmp27 = vec4<f32>(MAT_R, MAT_G, MAT_B, tmp26);
  mat_tint = tmp27;
  tmp28 = (AMB_R * AMB_INTENSITY);
  tmp29 = (AMB_G * AMB_INTENSITY);
  tmp30 = (AMB_B * AMB_INTENSITY);
  tmp31 = 0.0;
  tmp32 = vec4<f32>(tmp28, tmp29, tmp30, tmp31);
  ambient_vec = tmp32;
  tmp33 = (ndotl * LIGHT_INTENSITY);
  dir_term = tmp33;
  tmp34 = (dir_term * LIGHT_R);
  tmp35 = (dir_term * LIGHT_G);
  tmp36 = (dir_term * LIGHT_B);
  tmp37 = 1.0;
  tmp38 = vec4<f32>(tmp34, tmp35, tmp36, tmp37);
  dir_vec = tmp38;
  tmp39 = (sampled.x * mat_tint.x);
  tmp40 = (sampled.y * mat_tint.y);
  tmp41 = (sampled.z * mat_tint.z);
  tmp42 = (sampled.w * mat_tint.w);
  tmp43 = vec4<f32>(tmp39, tmp40, tmp41, tmp42);
  tmp44 = (tmp43.x * ambient_vec.x);
  tmp45 = (tmp43.y * ambient_vec.y);
  tmp46 = (tmp43.z * ambient_vec.z);
  tmp47 = (tmp43.w * ambient_vec.w);
  tmp48 = vec4<f32>(tmp44, tmp45, tmp46, tmp47);
  ambient_lit = tmp48;
  tmp49 = (sampled.x * mat_tint.x);
  tmp50 = (sampled.y * mat_tint.y);
  tmp51 = (sampled.z * mat_tint.z);
  tmp52 = (sampled.w * mat_tint.w);
  tmp53 = vec4<f32>(tmp49, tmp50, tmp51, tmp52);
  tmp54 = (tmp53.x * dir_vec.x);
  tmp55 = (tmp53.y * dir_vec.y);
  tmp56 = (tmp53.z * dir_vec.z);
  tmp57 = (tmp53.w * dir_vec.w);
  tmp58 = vec4<f32>(tmp54, tmp55, tmp56, tmp57);
  diffuse_lit = tmp58;
  tmp59 = (ndotl * ndotl);
  spec = tmp59;
  tmp60 = (SPEC_R * spec);
  tmp61 = (SPEC_G * spec);
  tmp62 = (SPEC_B * spec);
  tmp63 = 0.0;
  tmp64 = vec4<f32>(tmp60, tmp61, tmp62, tmp63);
  spec_term = tmp64;
  tmp65 = (ambient_lit.x + diffuse_lit.x);
  tmp66 = (ambient_lit.y + diffuse_lit.y);
  tmp67 = (ambient_lit.z + diffuse_lit.z);
  tmp68 = (ambient_lit.w + diffuse_lit.w);
  tmp69 = vec4<f32>(tmp65, tmp66, tmp67, tmp68);
  tmp70 = (tmp69.x + spec_term.x);
  tmp71 = (tmp69.y + spec_term.y);
  tmp72 = (tmp69.z + spec_term.z);
  tmp73 = (tmp69.w + spec_term.w);
  tmp74 = vec4<f32>(tmp70, tmp71, tmp72, tmp73);
  out.color = tmp74;
  return out;
}

