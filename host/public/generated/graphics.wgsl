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
  var tmp21: vec4<f32>;
  var tmp22: f32;
  var tmp23: vec4<f32>;
  var tmp24: f32;
  var tmp25: f32;
  var tmp26: f32;
  var tmp27: f32;
  var tmp28: vec4<f32>;
  var tmp29: f32;
  var tmp30: f32;
  var tmp31: f32;
  var tmp32: f32;
  var tmp33: f32;
  var tmp34: vec4<f32>;
  var tmp35: vec4<f32>;
  var tmp36: vec4<f32>;
  var tmp37: vec4<f32>;
  var tmp38: vec4<f32>;
  var tmp39: f32;
  var tmp40: f32;
  var tmp41: f32;
  var tmp42: f32;
  var tmp43: f32;
  var tmp44: vec4<f32>;
  var tmp45: vec4<f32>;
  var tmp46: vec4<f32>;
  var tmp47: f32;
  var tmp48: f32;
  var tmp49: f32;
  var tmp50: f32;
  var tmp51: f32;
  var tmp52: f32;
  var tmp53: f32;
  var tmp54: f32;
  var tmp55: f32;
  var tmp56: f32;
  var tmp57: f32;
  var tmp58: f32;
  var tmp59: f32;
  var tmp60: f32;
  var tmp61: f32;
  var tmp62: f32;
  var tmp63: f32;
  var tmp64: f32;
  var tmp65: f32;
  var tmp66: f32;
  var tmp67: f32;
  var tmp68: f32;
  var tmp69: f32;
  var tmp70: f32;
  var tmp71: f32;
  var tmp72: f32;
  var tmp73: f32;
  var tmp74: f32;
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
  tmp47 = (input.normal.x * light_direction.x);
  tmp48 = (input.normal.y * light_direction.y);
  tmp49 = (input.normal.z * light_direction.z);
  tmp50 = (tmp47 + tmp48);
  tmp18 = (tmp50 + tmp49);
  tmp19 = 0.0;
  tmp20 = max(tmp18, tmp19);
  ndotl = tmp20;
  tmp21 = textureSample(albedo, albedo_sampler, input.uv);
  sampled = tmp21;
  tmp22 = 1.0;
  tmp23 = vec4<f32>(MAT_R, MAT_G, MAT_B, tmp22);
  mat_tint = tmp23;
  tmp24 = (AMB_R * AMB_INTENSITY);
  tmp25 = (AMB_G * AMB_INTENSITY);
  tmp26 = (AMB_B * AMB_INTENSITY);
  tmp27 = 0.0;
  tmp28 = vec4<f32>(tmp24, tmp25, tmp26, tmp27);
  ambient_vec = tmp28;
  tmp29 = (ndotl * LIGHT_INTENSITY);
  dir_term = tmp29;
  tmp30 = (dir_term * LIGHT_R);
  tmp31 = (dir_term * LIGHT_G);
  tmp32 = (dir_term * LIGHT_B);
  tmp33 = 1.0;
  tmp34 = vec4<f32>(tmp30, tmp31, tmp32, tmp33);
  dir_vec = tmp34;
  tmp51 = (sampled.x * mat_tint.x);
  tmp52 = (sampled.y * mat_tint.y);
  tmp53 = (sampled.z * mat_tint.z);
  tmp54 = (sampled.w * mat_tint.w);
  tmp35 = vec4<f32>(tmp51, tmp52, tmp53, tmp54);
  tmp55 = (tmp35.x * ambient_vec.x);
  tmp56 = (tmp35.y * ambient_vec.y);
  tmp57 = (tmp35.z * ambient_vec.z);
  tmp58 = (tmp35.w * ambient_vec.w);
  tmp36 = vec4<f32>(tmp55, tmp56, tmp57, tmp58);
  ambient_lit = tmp36;
  tmp59 = (sampled.x * mat_tint.x);
  tmp60 = (sampled.y * mat_tint.y);
  tmp61 = (sampled.z * mat_tint.z);
  tmp62 = (sampled.w * mat_tint.w);
  tmp37 = vec4<f32>(tmp59, tmp60, tmp61, tmp62);
  tmp63 = (tmp37.x * dir_vec.x);
  tmp64 = (tmp37.y * dir_vec.y);
  tmp65 = (tmp37.z * dir_vec.z);
  tmp66 = (tmp37.w * dir_vec.w);
  tmp38 = vec4<f32>(tmp63, tmp64, tmp65, tmp66);
  diffuse_lit = tmp38;
  tmp39 = (ndotl * ndotl);
  spec = tmp39;
  tmp40 = (SPEC_R * spec);
  tmp41 = (SPEC_G * spec);
  tmp42 = (SPEC_B * spec);
  tmp43 = 0.0;
  tmp44 = vec4<f32>(tmp40, tmp41, tmp42, tmp43);
  spec_term = tmp44;
  tmp67 = (ambient_lit.x + diffuse_lit.x);
  tmp68 = (ambient_lit.y + diffuse_lit.y);
  tmp69 = (ambient_lit.z + diffuse_lit.z);
  tmp70 = (ambient_lit.w + diffuse_lit.w);
  tmp45 = vec4<f32>(tmp67, tmp68, tmp69, tmp70);
  tmp71 = (tmp45.x + spec_term.x);
  tmp72 = (tmp45.y + spec_term.y);
  tmp73 = (tmp45.z + spec_term.z);
  tmp74 = (tmp45.w + spec_term.w);
  tmp46 = vec4<f32>(tmp71, tmp72, tmp73, tmp74);
  out.color = tmp46;
  return out;
}

