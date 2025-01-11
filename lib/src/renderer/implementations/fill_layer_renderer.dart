import 'package:collection/collection.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/_shaders.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/gen/fill_fragment.gen.dart';
import 'package:maplibre_flutter_gpu/src/components/shaders/gen/fill_vertex.gen.dart';
import 'package:maplibre_flutter_gpu/src/renderer/implementations/tile_stats_layer_renderer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/renderer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/utils.dart';
import 'package:maplibre_flutter_gpu/src/utils/extensions.dart';
import 'package:maplibre_flutter_gpu/src/utils/tessellator.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:vector_math/vector_math.dart' as vm32;

class MapFillLayerRenderer extends MapVectorTiledLayerRenderer<spec.LayerFill> {
  MapFillLayerRenderer({required super.specLayer, required super.tileBucket});

  @override
  TileRenderer<spec.LayerFill, vt.Tile>? createTileRenderer(TileCoordinates coordinates, vt.Tile tile) {
    final vtLayer = tile.layers.firstWhereOrNull((l) => l.name == specLayer.sourceLayer);
    if (vtLayer == null) return null;

    return TileFillLayerRenderer(
      coordinates: coordinates,
      specLayer: specLayer,
      vtLayer: vtLayer,
      data: tile,
    );
  }

  @override
  void drawImpl(RendererDrawContext context) {
    for (final renderer in tileRenderers.values) {
      renderer.draw(context);
    }
  }
}

class _FillLayerShaderPipeline extends ShaderPipeline<FillVertexShader, FillFragmentShader> {
  _FillLayerShaderPipeline() : super(FillVertexShader(), FillFragmentShader());
}

class TileFillLayerRenderer extends VectorTileLayerRenderer<spec.LayerFill> {
  TileFillLayerRenderer({
    required super.coordinates,
    required super.specLayer,
    required super.vtLayer,
    required super.data,
  });

  @override
  bool get needsAsyncPreparation => true;

  _FillLayerShaderPipeline? _pipeline;

  @override
  DebugRenderStats? get debugRenderStats =>
      _pipeline?.vertex.vertexCount != null ? DebugRenderStats(vertices: _pipeline!.vertex.vertexCount!) : null;

  @override
  Future<void> prepareImpl(RendererPrepareContext context) async {
    _pipeline = _FillLayerShaderPipeline();

    // Filter features
    final features = filterFeatures<vt.MultiPolygonFeature>(coordinates, vtLayer, specLayer, context.evalContext);
    if (features.isEmpty) return;

    // Extract polygons
    final polygons = features.map((f) => f.polygons).expand((p) => p).toList();
    final indicesList = <int>[];

    // Allocate vertices
    _pipeline!.vertex.allocateVertices(context.gpuContext, polygons.vertexCount);
    var vertexIndex = 0;

    // Tessellate polygons
    for (final polygon in polygons) {
      final indices = Tessellator.tessellatePolygon(polygon);
      indicesList.addAll(indices.map((index) => index + vertexIndex));

      // While we're at it, set the vertices in the buffer
      for (final vertex in polygon.vertices) {
        _pipeline!.vertex.set(
          vertexIndex,
          position: vm32.Vector2(vertex.x.toDouble(), vertex.y.toDouble()),
        );

        vertexIndex++;
      }
    }

    // Allocate index buffer and upload
    _pipeline!.vertex.allocateIndices(context.gpuContext, indicesList);
    _pipeline!.upload(context.gpuContext);
  }

  @override
  void drawImpl(RendererDrawContext context) {
    if (_pipeline == null || !_pipeline!.isUploaded) return;

    final evalContext = context.evalContext;
    final paint = specLayer.paint;

    final tileOpacity = (evalContext.opacity ?? 1.0);
    final color = paint.fillColor.evaluate(evalContext);
    final opacity = paint.fillOpacity.evaluate(evalContext) * tileOpacity;

    _pipeline!.vertex.frameInfoUbo.set(
      mvp: context.getMvpForTileGpu(coordinates, vtLayer.extent),
      color: vm32.Vector4(
        color.r,
        color.g,
        color.b,
        color.a * opacity,
      ),
    );

    context.pass.setScissor(context.getScissorForTile(coordinates));
    _pipeline!.bind(context.gpuContext, context.pass);
    context.pass.draw();
  }
}
