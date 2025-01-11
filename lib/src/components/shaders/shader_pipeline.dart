import 'package:maplibre_flutter_gpu/src/components/shaders/shader_bindings.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

class ShaderPipeline<TV extends VertexShaderBindings, TF extends FragmentShaderBindings> {
  ShaderPipeline(this.vertex, this.fragment);

  final TV vertex;
  final TF fragment;
  gpu.RenderPipeline? pipeline;

  bool _isUploaded = false;
  bool get isUploaded => _isUploaded;

  void upload(gpu.GpuContext context) {
    vertex.upload(context);
    fragment.upload(context);

    pipeline = context.createRenderPipeline(vertex.shader, fragment.shader);
    _isUploaded = true;
  }

  void bind(gpu.GpuContext context, gpu.RenderPass pass) {
    if (pipeline == null) throw Exception('Pipeline not uploaded');

    pass.bindPipeline(pipeline!);

    vertex.bind(context, pass);
    fragment.bind(context, pass);
  }
}
