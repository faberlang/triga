import fs from "node:fs";

const [, , inputPath, outputPath] = process.argv;
if (!inputPath || !outputPath) {
  throw new Error("usage: adapt-graphics-reflection.mjs INPUT OUTPUT");
}

const reflection = JSON.parse(fs.readFileSync(inputPath, "utf8"));
if (reflection.schema_version !== 1 || reflection.target !== "wgsl-text") {
  throw new Error("the host graphics reflection is not the admitted schema-1 WGSL contract");
}

const vertex = reflection.kernels?.find((kernel) => kernel.shader_stage === "vertex");
const fragment = reflection.kernels?.find((kernel) => kernel.shader_stage === "fragment");
if (!vertex || !fragment) {
  throw new Error("the host graphics reflection must contain vertex and fragment kernels");
}

vertex.entry_name = "triga_water_vertex";
vertex.vertex_input_count = 1;
vertex.vertex_inputs = [
  {
    source_name: "position",
    location: 0,
    format: "float32x3",
    step_mode: "vertex",
    offset_bytes: 0,
    stride_bytes: 36,
  },
];
vertex.launch.entry_name = vertex.entry_name;

const vertexAdapter = vertex.launch.webgpu_adapter;
vertexAdapter.vertex_buffer_layout_descriptor_count = 1;
vertexAdapter.vertex_buffer_layout_descriptor_indexes = [0];
vertexAdapter.vertex_buffer_layout_descriptor_index_count = 1;
vertexAdapter.vertex_buffer_layout_descriptors = [
  {
    buffer_index: 0,
    array_stride: 36,
    step_mode: "vertex",
    attribute_count: 1,
    attributes: [
      {
        shader_location: 0,
        format: "float32x3",
        offset: 0,
        source_name: "position",
      },
    ],
  },
];

fragment.entry_name = "triga_water_fragment";
fragment.launch.entry_name = fragment.entry_name;

reflection.pipeline.vertex_input_count = 1;
reflection.pipeline.varying_count = 1;

fs.writeFileSync(outputPath, `${JSON.stringify(reflection, null, 2)}\n`);
