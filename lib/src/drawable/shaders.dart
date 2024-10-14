import 'package:flutter_gpu/gpu.dart' as gpu;

const String _kShaderBundlePath = 'build/shaderbundles/TestLibrary.shaderbundle';

gpu.ShaderLibrary? _shaderLibrary;
gpu.ShaderLibrary get shaderLibrary {
  if (_shaderLibrary != null) {
    return _shaderLibrary!;
  }
  _shaderLibrary = gpu.ShaderLibrary.fromAsset(_kShaderBundlePath);
  if (_shaderLibrary != null) {
    return _shaderLibrary!;
  }

  throw Exception("Failed to load shader bundle! ($_kShaderBundlePath)");
}
