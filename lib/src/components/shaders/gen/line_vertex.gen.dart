// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated by tool/generate_shader_code.js

// ignore_for_file: unused_import

import '../_shaders.dart';
import './ubo.gen.dart';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart';

class LineVertexShader extends VertexShaderBindings {
  LineVertexShader() : super(16, shaderLibrary['LineVertex']!) {
    frameInfoUbo = FrameInfoUbo(shader.getUniformSlot('FrameInfo'));
    lineInfoUbo = LineInfoUbo(shader.getUniformSlot('LineInfo'));
  }

  late final FrameInfoUbo frameInfoUbo;
  late final LineInfoUbo lineInfoUbo;

  @override
  List<UniformBufferObjectBindings> get ubos => [
        frameInfoUbo,
        lineInfoUbo,
      ];

  void set(
    int index, {
    required Vector2 position,
    required Vector2 normal,
  }) {
    setVector2(index * bytesPerVertex + 0, vertexData!, position);
    setVector2(index * bytesPerVertex + 8, vertexData!, normal);
  }
}
