import 'dart:ui' as ui;

import 'package:flutter_gpu/gpu.dart';
import 'package:gpu_vector_tile_renderer/_isolates.dart';
import 'package:gpu_vector_tile_renderer/_renderer.dart';
import 'package:gpu_vector_tile_renderer/_spec.dart' as spec;
import 'package:gpu_vector_tile_renderer/_utils.dart';
import 'package:gpu_vector_tile_renderer/_vector_tile.dart' as vt;
import 'package:gpu_vector_tile_renderer/src/shaders/bindings/shader_bindings.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class FillLayerRenderer extends SingleTileLayerRenderer<spec.LayerFill> {
  FillLayerRenderer({
    required super.coordinates,
    required super.container,
    required super.specLayer,
    required super.vtLayer,
  });

  RenderPipelineBindings get pipeline;

  int setFeatureVertices(spec.EvaluationContext eval, vt.PolygonFeature feature, int index);
  void setUniforms(
    RenderContext context,
    Matrix4 cameraWorldToGl,
    double cameraZoom,
    double pixelRatio,
    Matrix4 tileLocalToWorld,
    double tileSize,
    double tileExtent,
    double tileOpacity,
  );

  @override
  Future<void> prepare(PrepareContext context) async {
    final features = filterFeatures<vt.PolygonFeature>(
      vtLayer,
      specLayer,
      context.eval,
      sortKey: specLayer.layout.fillSortKey,
    );

    if (features.isEmpty) return;

    var vertexCount = 0;
    final indicesList = <int>[];

    for (final feature in features) {
      for (final polygon in feature.polygons) vertexCount += polygon.vertexCount;
    }

    // Allocate vertices
    pipeline.vertex.allocateVertices(gpuContext, vertexCount);

    // temporary!
    var vertexIndex = 0;
    var indicesVertexIndex = 0;
    for (final feature in features) {
      final featureEval = context.eval.forFeature(feature);
      final polygons = feature.polygons;

      for (final polygon in polygons) {
        final indices = await Isolates.instance.tesselator.execute(polygon);
        indicesList.addAll(indices.map((i) => i + indicesVertexIndex));
        indicesVertexIndex += polygon.vertexCount;
      }

      vertexIndex = setFeatureVertices(featureEval, feature, vertexIndex);
    }

    pipeline.vertex.allocateIndices(gpuContext, indicesList);
    pipeline.upload(gpuContext);
  }

  @override
  void draw(RenderContext context) {
    if (!pipeline.isReady) return;

    final tileSize = context.getScaledTileSize(coordinates);
    final origin = ui.Offset(coordinates.x * tileSize, coordinates.y * tileSize);
    final tileLocalToWorld = Matrix4.identity()..translate(origin.dx, origin.dy);

    setUniforms(
      context,
      context.worldToGl,
      context.camera.zoom,
      context.pixelRatio,
      tileLocalToWorld,
      tileSize,
      vtLayer.extent.toDouble(),
      container.opacityAnimation.value,
    );

    context.setTileScissor(context.pass, coordinates);
    pipeline.bind(gpuContext, context.pass);

    context.pass.draw();
    context.pass.clearBindings();
  }
}
