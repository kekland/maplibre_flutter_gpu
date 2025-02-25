import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:gpu_vector_tile_renderer/_renderer.dart';
import 'package:gpu_vector_tile_renderer/_spec.dart' as spec;
import 'package:gpu_vector_tile_renderer/_utils.dart';
import 'package:gpu_vector_tile_renderer/_vector_tile.dart' as vt;
import 'package:gpu_vector_tile_renderer/src/shaders/bindings/shader_bindings.dart';
import 'package:vector_math/vector_math_64.dart';

const _kLineCapRoundSegments = 16;

abstract class LineLayerRenderer extends SingleTileLayerRenderer<spec.LayerLine> {
  LineLayerRenderer({
    required super.coordinates,
    required super.container,
    required super.specLayer,
    required super.vtLayer,
  });

  RenderPipelineBindings get pipeline;

  int setFeatureVertices(
    spec.EvaluationContext eval,
    vt.LineStringFeature feature,
    int index,
    List<(Vector2 position, Vector2 normal)> vertexData,
  );

  @override
  void prepare(PrepareContext context) {
    final features = filterFeatures<vt.LineStringFeature>(
      vtLayer,
      specLayer,
      context.eval,
      sortKey: specLayer.layout.lineSortKey,
    );

    if (features.isEmpty) return;

    final lineCap = specLayer.layout.lineCap.evaluate(context.eval);

    // TODO:
    // final lineJoin = specLayer.layout.lineJoin.evaluate(context.eval);
    // final miterLimit = specLayer.layout.lineMiterLimit.evaluate(context.eval);
    // final roundLimit = specLayer.layout.lineRoundLimit.evaluate(context.eval);

    // Contains the list of (position, normal) for each vertex, grouped by feature.
    // During vertex shader, position is extended by normal * 0.5 * width
    final vertexData = <List<(Vector2 position, Vector2 normal)>>[];
    final indices = <int>[];
    var vertexCount = 0;

    void _addRelativeIndices(List<int> idx) {
      indices.addAll(idx.map((i) => i + vertexCount));
    }

    // Add cap going from a to b.
    void _addCap(Vector2 a, Vector2 b) {
      if (lineCap == spec.LayoutLine$LineCap.butt) return;

      final t = (b - a)..normalize();
      final n = Vector2(t.y, -t.x);

      if (lineCap == spec.LayoutLine$LineCap.square) {
        _addRelativeIndices([0, 1, 2, 1, 2, 3]);

        vertexData.last.add((a, n));
        vertexData.last.add((a, -n));

        vertexData.last.add((a, t + n));
        vertexData.last.add((a, t - n));

        vertexCount += 4;
      } else if (lineCap == spec.LayoutLine$LineCap.round) {
        final center = a;
        final startAngle = math.atan2(-n.y, -n.x);

        vertexData.last.add((center, Vector2.zero()));
        final centerIndex = vertexCount;

        for (var i = 0; i <= _kLineCapRoundSegments; i++) {
          final angle = startAngle + i / _kLineCapRoundSegments * math.pi;
          final vec = Vector2(math.cos(angle), math.sin(angle));

          vertexData.last.add((center, vec));
        }

        for (var i = 0; i < _kLineCapRoundSegments; i++) {
          indices.addAll([centerIndex, centerIndex + i + 1, centerIndex + i + 2]);
        }

        vertexCount += _kLineCapRoundSegments + 2;
      }
    }

    // Add single line segment from a to b.
    void _addSegment(Vector2 a, Vector2 b) {
      final t = b - a;
      final n = Vector2(t.y, -t.x)..normalize();

      _addRelativeIndices([0, 1, 2, 1, 2, 3]);

      vertexData.last.add((a, n));
      vertexData.last.add((a, -n));

      vertexData.last.add((b, n));
      vertexData.last.add((b, -n));

      vertexCount += 4;
    }

    // Add join at c, from a to b.
    void _addJoin(Vector2 c, Vector2 a, Vector2 b) {
      final ac = c - a;
      final cb = b - c;

      var na = Vector2(ac.y, -ac.x)..normalize();
      var nb = Vector2(cb.y, -cb.x)..normalize();

      // check direction
      final cross = ac.x * cb.y - ac.y * cb.x;
      final direction = cross < 0 ? -1.0 : 1.0;

      na *= direction;
      nb *= direction;

      // TODO: Miter, round joins
      _addRelativeIndices([0, 1, 2]);

      vertexData.last.add((c, Vector2.zero()));
      vertexData.last.add((c, na));
      vertexData.last.add((c, nb));

      vertexCount += 3;
    }

    for (final feature in features) {
      vertexData.add([]);

      // Line consists of:
      // Cap - Segment - Join - Segment - Join - ... - Segment - Cap
      for (final line in feature.lines) {
        if (line.points.length < 2) continue;

        _addCap(line.points[0].vec2, line.points[1].vec2);

        for (var i = 0; i < line.points.length - 1; i++) {
          _addSegment(line.points[i].vec2, line.points[i + 1].vec2);

          if (i != 0) {
            _addJoin(line.points[i].vec2, line.points[i - 1].vec2, line.points[i + 1].vec2);
          }
        }

        _addCap(line.points[line.points.length - 1].vec2, line.points[line.points.length - 2].vec2);
      }
    }

    pipeline.vertex.allocateVertices(gpu.gpuContext, vertexCount);
    pipeline.vertex.allocateIndices(gpu.gpuContext, indices);

    var vertexIndex = 0;
    for (var i = 0; i < vertexData.length; i++) {
      final feature = features[i];
      final featureEval = context.eval.forFeature(feature);

      setFeatureVertices(featureEval, feature, vertexIndex, vertexData[i]);
      vertexIndex += vertexData[i].length;
    }

    pipeline.upload(gpu.gpuContext);
  }

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
  void draw(RenderContext context) {
    if (!pipeline.isReady) return;

    final tileDimension = context.getScaledTileDimension(coordinates);
    final origin = ui.Offset(coordinates.x * tileDimension, coordinates.y * tileDimension);
    final tileLocalToWorld = Matrix4.identity()..translate(origin.dx, origin.dy);

    setUniforms(
      context,
      context.worldToGl,
      context.camera.zoom,
      context.pixelRatio,
      tileLocalToWorld,
      tileDimension,
      vtLayer.extent.toDouble(),
      container.opacityAnimation.value,
    );

    context.setTileScissor(context.pass, coordinates);
    pipeline.bind(gpu.gpuContext, context.pass);

    context.pass.draw();
    context.pass.clearBindings();
  }
}
