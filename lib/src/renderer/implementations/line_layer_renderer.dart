import 'package:collection/collection.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_coordinates.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/_shaders.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/gen/line_fragment.gen.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/gen/line_vertex.gen.dart';
import 'package:maplibre_flutter_gpu/src/renderer/implementations/tile_stats_layer_renderer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/renderer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/utils.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/model/tile.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;
import 'package:vector_math/vector_math.dart' as vm32;

class MapLineLayerRenderer extends MapVectorTiledLayerRenderer<spec.LayerLine> {
  MapLineLayerRenderer({required super.specLayer, required super.tileBucket});

  @override
  TileRenderer<spec.LayerLine, vt.Tile>? createTileRenderer(TileCoordinates coordinates, vt.Tile tile) {
    final vtLayer = tile.layers.firstWhereOrNull((l) => l.name == specLayer.sourceLayer);
    if (vtLayer == null) return null;

    return TileLineLayerRenderer(
      coordinates: coordinates,
      specLayer: specLayer,
      vtLayer: vtLayer,
      data: tile,
    );
  }
}

class _LineLayerShaderPipeline extends ShaderPipeline<LineVertexShader, LineFragmentShader> {
  _LineLayerShaderPipeline() : super(LineVertexShader(), LineFragmentShader());
}

class TileLineLayerRenderer extends VectorTileLayerRenderer<spec.LayerLine> {
  TileLineLayerRenderer({
    required super.coordinates,
    required super.data,
    required super.specLayer,
    required super.vtLayer,
  });

  @override
  bool get needsAsyncPreparation => true;

  _LineLayerShaderPipeline? _pipeline;

  @override
  DebugRenderStats? get debugRenderStats =>
      _pipeline?.vertex.vertexCount != null ? DebugRenderStats(vertices: _pipeline!.vertex.vertexCount!) : null;

  @override
  Future<void> prepareImpl(RendererPrepareContext context) async {
    final evalContext = context.evalContext;
    final features = filterFeatures<vt.MultiLineStringFeature>(coordinates, vtLayer, specLayer, evalContext);
    if (features.isEmpty) return;

    // TODO
    final lineCap = specLayer.layout.lineCap.evaluate(evalContext);
    final lineJoin = specLayer.layout.lineJoin.evaluate(evalContext);
    final miterLimit = specLayer.layout.lineMiterLimit.evaluate(evalContext);
    final roundLimit = specLayer.layout.lineRoundLimit.evaluate(evalContext);

    _pipeline = _LineLayerShaderPipeline();

    var totalVertices = 0;

    for (final feature in features) {
      for (final line in feature.lines) {
        final points = line.points;
        if (points.length < 2) continue;
        totalVertices += (points.length - 1) * 4;
      }
    }

    final indices = <int>[];
    _pipeline!.vertex.allocateVertices(context.gpuContext, totalVertices);
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

          final normal = vm32.Vector2(dy.toDouble(), -dx.toDouble()).normalized();

          _pipeline!.vertex.set(
            vertexI,
            position: vm32.Vector2(a.x.toDouble(), a.y.toDouble()),
            normal: normal,
          );

          _pipeline!.vertex.set(
            vertexI + 1,
            position: vm32.Vector2(a.x.toDouble(), a.y.toDouble()),
            normal: -normal,
          );

          _pipeline!.vertex.set(
            vertexI + 2,
            position: vm32.Vector2(b.x.toDouble(), b.y.toDouble()),
            normal: normal,
          );

          _pipeline!.vertex.set(
            vertexI + 3,
            position: vm32.Vector2(b.x.toDouble(), b.y.toDouble()),
            normal: -normal,
          );

          indices.addAll([vertexI, vertexI + 1, vertexI + 2, vertexI + 1, vertexI + 2, vertexI + 3]);
          vertexI += 4;
        }
      }
    }

    _pipeline!.vertex.allocateIndices(context.gpuContext, indices);
    _pipeline!.upload(context.gpuContext);
  }

  @override
  void drawImpl(RendererDrawContext context) {
    if (_pipeline == null || !_pipeline!.isUploaded) return;

    final evalContext = context.evalContext;
    final paint = specLayer.paint;

    final tileOpacity = (evalContext.opacity ?? 1.0);

    final color = paint.lineColor.evaluate(evalContext);
    final opacity = paint.lineOpacity.evaluate(evalContext) * tileOpacity;
    final width = paint.lineWidth.evaluate(evalContext);

    _pipeline!.vertex.frameInfoUbo.set(
      mvp: context.getMvpForTileGpu(coordinates, vtLayer.extent),
      color: vm32.Vector4(
        color.r,
        color.g,
        color.b,
        color.a * opacity,
      ),
    );

    _pipeline!.vertex.lineInfoUbo.set(
      width: width.toDouble() * vtLayer.extent / context.tileSizeCalculator(coordinates),
    );

    context.pass.setScissor(context.getScissorForTile(coordinates));
    _pipeline!.bind(context.gpuContext, context.pass);
    context.pass.draw();
  }
}
