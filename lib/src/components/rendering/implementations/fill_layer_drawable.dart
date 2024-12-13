import 'dart:ui';

import 'package:flutter_gpu/gpu.dart';
import 'package:maplibre_flutter_gpu/src/components/rendering/drawable.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/gen/fill_fragment.gen.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/gen/fill_vertex.gen.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/shader_pipeline.dart';
import 'package:maplibre_flutter_gpu/src/utils/extensions.dart';
import 'package:maplibre_flutter_gpu/src/utils/tessellator.dart';
import 'package:vector_math/vector_math.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;

class FillLayerShaderPipeline extends ShaderPipeline<FillVertexShader, FillFragmentShader> {
  FillLayerShaderPipeline() : super(FillVertexShader(), FillFragmentShader());
}

class FillLayerDrawable extends TileLayerDrawable<spec.LayerFill> {
  FillLayerDrawable({
    required super.vectorTileLayer,
    required super.specLayer,
    required super.coordinates,
  });

  FillLayerShaderPipeline? _pipeline;

  @override
  Future<bool> prepareImpl(GpuContext context, spec.EvaluationContext evalContext) async {
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

    if (features.isEmpty) return false;

    _pipeline = FillLayerShaderPipeline();

    final polygons = features.map((f) => f.polygons).expand((p) => p).toList();
    final indicesList = <int>[];

    _pipeline!.vertex.allocateVertices(context, polygons.vertexCount);
    var vertexIndex = 0;

    // Tessellate polygons
    for (final polygon in polygons) {
      final indices = await Tessellator.tessellatePolygonAsync(polygon);
      indicesList.addAll(indices.map((index) => index + vertexIndex));

      // While we're at it, set the vertices in the buffer
      for (final vertex in polygon.vertices) {
        _pipeline!.vertex.set(
          vertexIndex,
          position: Vector2(vertex.x.toDouble(), vertex.y.toDouble()),
        );

        vertexIndex++;
      }
    }

    _pipeline!.vertex.allocateIndices(context, indicesList);
    _pipeline!.upload(context);

    return true;
  }

  @override
  void drawImpl(
    Canvas canvas,
    GpuContext context,
    spec.EvaluationContext evalContext,
    RenderPass pass,
    Matrix4 camera,
  ) {
    if (_pipeline == null) return;
    final paint = specLayer.paint;

    final tileOpacity = (evalContext.opacity ?? 1.0);
    final color = paint.fillColor.evaluate(evalContext);
    final opacity = paint.fillOpacity.evaluate(evalContext) * tileOpacity;

    _pipeline!.vertex.frameInfoUbo.set(
      mvp: camera,
      color: Vector4(
        color.r,
        color.g,
        color.b,
        color.a * opacity,
      ),
    );

    _pipeline!.bind(context, pass);
    pass.draw();
  }
}
