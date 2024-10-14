import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/drawable/shaders.dart';
import 'package:maplibre_flutter_gpu/src/utils/extensions.dart';
import 'package:maplibre_flutter_gpu/src/utils/tessellator.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/model/_model.dart' as vt;
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

abstract class Drawable with ChangeNotifier {
  Drawable();

  var _isReady = false;
  var _isPreparing = false;

  Future<void> prepare([gpu.GpuContext? context]) async {
    if (_isReady || _isPreparing) return;
    _isPreparing = true;

    await prepareImpl(context ?? gpu.gpuContext);
    _isReady = true;
    _isPreparing = false;

    notifyListeners();
  }

  Future<void> prepareImpl(gpu.GpuContext context);

  void draw(
    gpu.GpuContext context,
    gpu.RenderPass pass,
    Matrix4? mvp,
    spec.EvaluationContext evalContext,
  ) {
    if (!_isReady) return;
    drawImpl(context, pass, mvp, evalContext);
  }

  void drawImpl(
    gpu.GpuContext context,
    gpu.RenderPass pass,
    Matrix4? mvp,
    spec.EvaluationContext evalContext,
  );

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
  }
}

abstract class TileDrawable extends Drawable {
  TileDrawable({
    required this.coordinates,
    required this.extent,
  });

  final TileCoordinates coordinates;
  final double extent;
}

class FillLayerDrawable extends TileDrawable {
  FillLayerDrawable({
    required super.coordinates,
    required this.vectorTileLayer,
    required this.specLayer,
  }) : super(extent: vectorTileLayer.extent.toDouble());

  final vt.Layer vectorTileLayer;
  final spec.LayerFill specLayer;

  int vertexCount = 0;
  int indexCount = 0;

  int get vertexBytes => vertexCount * perVertexBytes;
  int get indexBytes => indexCount * perIndexBytes;

  gpu.DeviceBuffer? buffer;
  gpu.BufferView get vertexBufferView => gpu.BufferView(buffer!, offsetInBytes: 0, lengthInBytes: vertexBytes);
  gpu.BufferView get indexBufferView => gpu.BufferView(buffer!, offsetInBytes: vertexBytes, lengthInBytes: indexBytes);

  // 2 * 4 (position - float) + 4 * 4 (rgba - float)
  static const perVertexBytes = 2 * 4;
  static const perIndexBytes = 4;

  @override
  Future<void> prepareImpl(gpu.GpuContext context) async {
    final evalContext = spec.EvaluationContext.empty();

    final features = vectorTileLayer.features.whereType<vt.MultiPolygonFeature>().where((feature) {
      if (specLayer.minzoom != null) {
        if (coordinates.z < specLayer.minzoom!) return false;
      }

      if (specLayer.maxzoom != null) {
        if (coordinates.z > specLayer.maxzoom!) return false;
      }

      if (specLayer.filter == null) return true;

      return specLayer.filter!(evalContext.extendWith(properties: feature.attributes));
    });

    if (features.isEmpty) return;

    final polygons = features.map((f) => f.polygons).expand((p) => p).toList();

    final indicesList = <int>[];

    vertexCount = polygons.vertexCount;
    final vertexList = Float32List(vertexCount * 2);

    var vertexIndex = 0;

    // Tessellate polygons
    for (final polygon in polygons) {
      final indices = Tessellator.tessellatePolygon(polygon);
      indicesList.addAll(indices.map((index) => index + vertexIndex));

      // While we're at it, set the vertices in the buffer
      for (final vertex in polygon.vertices) {
        final offset = vertexIndex * 2;

        vertexList[offset + 0] = vertex.x.toDouble();
        vertexList[offset + 1] = vertex.y.toDouble();

        vertexIndex += 1;
      }
    }

    final vertexByteData = vertexList.buffer.asByteData();

    final indexByteData = Int32List.fromList(indicesList).buffer.asByteData();
    indexCount = indicesList.length;

    // Create device buffer
    buffer = context.createDeviceBuffer(
      gpu.StorageMode.hostVisible,
      vertexByteData.lengthInBytes + indexByteData.lengthInBytes,
    );

    // Upload to buffer
    buffer!.overwrite(vertexByteData);
    buffer!.overwrite(indexByteData, destinationOffsetInBytes: vertexByteData.lengthInBytes);

    buffer!.flush();
  }

  @override
  void drawImpl(
    gpu.GpuContext context,
    gpu.RenderPass pass,
    Matrix4? mvp,
    spec.EvaluationContext evalContext,
  ) {
    if (buffer == null) return;

    // // Create pipeline
    final vert = shaderLibrary['SimpleVertex']!;
    final frag = shaderLibrary['SimpleFragment']!;
    final pipeline = context.createRenderPipeline(vert, frag);

    pass.bindPipeline(pipeline);

    // Bind buffers
    pass.bindVertexBuffer(vertexBufferView, vertexCount);
    pass.bindIndexBuffer(indexBufferView, gpu.IndexType.int32, indexCount);

    // Set uniforms
    final transients = gpu.gpuContext.createHostBuffer();

    final layout = specLayer.layout;
    final paint = specLayer.paint;

    final visibility = layout.visibility.evaluate(evalContext);

    final color = paint.fillColor.evaluate(evalContext);
    final opacity = paint.fillOpacity.evaluate(evalContext);

    if (mvp != null) {
      final frameInfoFloats = Float32List.fromList([
        mvp.storage[0],
        mvp.storage[1],
        mvp.storage[2],
        mvp.storage[3],
        mvp.storage[4],
        mvp.storage[5],
        mvp.storage[6],
        mvp.storage[7],
        mvp.storage[8],
        mvp.storage[9],
        mvp.storage[10],
        mvp.storage[11],
        mvp.storage[12],
        mvp.storage[13],
        mvp.storage[14],
        mvp.storage[15],
        color.r,
        color.g,
        color.b,
        color.a * opacity,
      ]);

      pass.bindUniform(
        vert.getUniformSlot('FrameInfo'),
        transients.emplace(float32(frameInfoFloats)),
      );
    }

    print('draw');
    print(specLayer.id);

    pass.draw();
  }

  @override
  void dispose() {
    buffer = null;
    super.dispose();
  }
}

ByteData float32(List<double> values) {
  return Float32List.fromList(values).buffer.asByteData();
}

ByteData float32Mat(Matrix4 matrix) {
  return Float32List.fromList(matrix.storage).buffer.asByteData();
}
