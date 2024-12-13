import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

abstract class ShaderBindings {
  ShaderBindings(this.shader);

  final gpu.Shader shader;

  gpu.DeviceBuffer? _uboBuffer;

  List<UniformBufferObjectBindings> get ubos;

  int get _ubosLengthInBytes => ubos.fold(0, (acc, ubo) => acc + ubo.lengthInBytes);
  void _iterateUbos(void Function(UniformBufferObjectBindings ubo, int offset) iter) {
    var offset = 0;

    for (final ubo in ubos) {
      iter(ubo, offset);
      offset += ubo.lengthInBytes;
    }
  }

  @mustCallSuper
  void upload(gpu.GpuContext context) {
    if (_ubosLengthInBytes == 0) return;
    _uboBuffer ??= context.createDeviceBuffer(gpu.StorageMode.hostVisible, _ubosLengthInBytes);

    _iterateUbos((ubo, offset) {
      _uboBuffer!.overwrite(ubo.data, destinationOffsetInBytes: offset);
      ubo.needsFlush = false;
    });

    _uboBuffer!.flush();
  }

  @mustCallSuper
  void bind(gpu.GpuContext context, gpu.RenderPass pass) {
    if (_uboBuffer == null) return;

    var ubosNeededFlush = false;

    _iterateUbos((ubo, offset) {
      if (ubo.needsFlush) {
        _uboBuffer!.overwrite(ubo.data, destinationOffsetInBytes: offset);
        ubo.needsFlush = false;
        ubosNeededFlush = true;
      }

      pass.bindUniform(
        ubo.slot,
        gpu.BufferView(_uboBuffer!, offsetInBytes: offset, lengthInBytes: ubo.lengthInBytes),
      );
    });

    if (ubosNeededFlush) {
      _uboBuffer!.flush();
    }
  }
}

abstract class UniformBufferObjectBindings {
  UniformBufferObjectBindings(this.slot, this.lengthInBytes) : data = ByteData(lengthInBytes);

  final gpu.UniformSlot slot;
  final int lengthInBytes;
  final ByteData data;

  bool needsFlush = true;

  void onSetData() {
    needsFlush = true;
  }
}

abstract class VertexShaderBindings extends ShaderBindings {
  VertexShaderBindings(this.bytesPerVertex, super.shader);

  final int bytesPerVertex;

  int? _vertexCount;
  int? _indexCount;

  ByteData? vertexData;
  ByteData? indexData;

  gpu.DeviceBuffer? _buffer;
  gpu.BufferView? _vertexBufferView;
  gpu.BufferView? _indexBufferView;

  void _maybeResetBuffers() {
    if (_buffer == null) return;

    _buffer = null;
    _vertexBufferView = null;
    _indexBufferView = null;
  }

  void allocateVertices(gpu.GpuContext context, int vertexCount) {
    if (_vertexCount == vertexCount) return;

    _vertexCount = vertexCount;
    vertexData = ByteData(vertexCount * bytesPerVertex);

    _maybeResetBuffers();
  }

  void allocateIndices(gpu.GpuContext context, List<int> indices) {
    if (_indexCount == indices.length) return;

    _indexCount = indices.length;
    indexData = Int32List.fromList(indices).buffer.asByteData();

    _maybeResetBuffers();
  }

  @override
  void upload(gpu.GpuContext context) {
    super.upload(context);

    var lengthInBytes = 0;

    if (vertexData != null) lengthInBytes += vertexData!.lengthInBytes;
    if (indexData != null) lengthInBytes += indexData!.lengthInBytes;

    if (lengthInBytes == 0) return;

    _buffer ??= context.createDeviceBuffer(gpu.StorageMode.hostVisible, lengthInBytes);

    if (vertexData != null) {
      _buffer!.overwrite(
        vertexData!,
        destinationOffsetInBytes: 0,
      );

      _vertexBufferView = gpu.BufferView(
        _buffer!,
        offsetInBytes: 0,
        lengthInBytes: vertexData!.lengthInBytes,
      );
    }

    if (indexData != null) {
      _buffer!.overwrite(
        indexData!,
        destinationOffsetInBytes: vertexData!.lengthInBytes,
      );

      _indexBufferView = gpu.BufferView(
        _buffer!,
        offsetInBytes: vertexData!.lengthInBytes,
        lengthInBytes: indexData!.lengthInBytes,
      );
    }

    _buffer!.flush();
  }

  @override
  void bind(gpu.GpuContext context, gpu.RenderPass pass) {
    super.bind(context, pass);
    if (_buffer == null) return;

    if (_vertexBufferView != null) {
      pass.bindVertexBuffer(_vertexBufferView!, _vertexCount!);
    }

    if (_indexBufferView != null) {
      pass.bindIndexBuffer(_indexBufferView!, gpu.IndexType.int32, _indexCount!);
    }
  }
}

abstract class FragmentShaderBindings extends ShaderBindings {
  FragmentShaderBindings(super.shader);

  @override
  @mustCallSuper
  void upload(gpu.GpuContext context) {
    super.upload(context);
  }

  @override
  @mustCallSuper
  void bind(gpu.GpuContext context, gpu.RenderPass pass) {
    super.bind(context, pass);
  }
}
