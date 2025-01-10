import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_gpu/gpu.dart';
import 'package:maplibre_flutter_gpu/src/components/_components.dart';
import 'package:maplibre_flutter_gpu/src/components/rendering/drawable.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/gen/line_fragment.gen.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/gen/line_vertex.gen.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/model/_model.dart' as vt;
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:vector_math/vector_math.dart';

class LineLayerShaderPipeline extends ShaderPipeline<LineVertexShader, LineFragmentShader> {
  LineLayerShaderPipeline() : super(LineVertexShader(), LineFragmentShader());
}

class LineLayerDrawable extends TileLayerDrawable<spec.LayerLine> {
  LineLayerDrawable({
    required super.coordinates,
    required super.specLayer,
    required super.vectorTileLayer,
  });

  LineLayerShaderPipeline? _pipeline;

  @override
  Future<bool> prepareImpl(GpuContext context, spec.EvaluationContext evalContext) async {
    final features = vectorTileLayer.features.whereType<vt.MultiLineStringFeature>().where((feature) {
      if (specLayer.minzoom != null) {
        if (coordinates.z < specLayer.minzoom!) return false;
      }

      if (specLayer.maxzoom != null) {
        if (coordinates.z > specLayer.maxzoom!) return false;
      }

      if (specLayer.filter == null) return true;

      return specLayer.filter!(evalContext.extendWith(properties: feature.attributes));
    });

    // TODO
    final lineCap = specLayer.layout.lineCap.evaluate(evalContext);
    final lineJoin = specLayer.layout.lineJoin.evaluate(evalContext);
    final miterLimit = specLayer.layout.lineMiterLimit.evaluate(evalContext);
    final roundLimit = specLayer.layout.lineRoundLimit.evaluate(evalContext);

    if (features.isEmpty) return false;
    _pipeline = LineLayerShaderPipeline();

    var totalVertices = 0;

    for (final feature in features) {
      for (final line in feature.lines) {
        final points = line.points;
        if (points.length < 2) continue;
        totalVertices += (points.length - 1) * 4;
      }
    }

    final indices = <int>[];
    _pipeline!.vertex.allocateVertices(context, totalVertices);
    var vertexI = 0;

    for (final feature in features) {
      for (final line in feature.lines) {
        final points = line.points;
        if (points.length < 2) continue;

        for (var i = 0; i < points.length - 1; i++) {
          final a = points[i];
          final b = points[i + 1];

          final dx = b.x - a.x;
          final dy = b.y - a.y;

          final normal = Vector2(dy.toDouble(), -dx.toDouble()).normalized();

          _pipeline!.vertex.set(
            vertexI,
            position: Vector2(a.x.toDouble(), a.y.toDouble()),
            normal: normal,
          );

          _pipeline!.vertex.set(
            vertexI + 1,
            position: Vector2(a.x.toDouble(), a.y.toDouble()),
            normal: -normal,
          );

          _pipeline!.vertex.set(
            vertexI + 2,
            position: Vector2(b.x.toDouble(), b.y.toDouble()),
            normal: normal,
          );

          _pipeline!.vertex.set(
            vertexI + 3,
            position: Vector2(b.x.toDouble(), b.y.toDouble()),
            normal: -normal,
          );

          indices.addAll([vertexI, vertexI + 1, vertexI + 2, vertexI + 1, vertexI + 2, vertexI + 3]);
          vertexI += 4;
        }
      }
    }

    _pipeline!.vertex.allocateIndices(context, indices);
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

    final color = paint.lineColor.evaluate(evalContext);
    final opacity = paint.lineOpacity.evaluate(evalContext) * tileOpacity;
    final width = paint.lineWidth.evaluate(evalContext);

    _pipeline!.vertex.frameInfoUbo.set(
      mvp: camera,
      color: Vector4(
        color.r,
        color.g,
        color.b,
        color.a * opacity,
      ),
    );

    _pipeline!.vertex.lineInfoUbo.set(
      width: width.toDouble() * extent / evalContext.scaledTileSizePixels,
    );

    _pipeline!.bind(context, pass);
    pass.draw();
  }
}
