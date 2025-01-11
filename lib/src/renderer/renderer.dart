import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_map/flutter_map.dart';
import 'package:logging/logging.dart';
import 'package:maplibre_flutter_gpu/src/controller/source.dart';
import 'package:maplibre_flutter_gpu/src/controller/texture_atlas.dart';
import 'package:maplibre_flutter_gpu/src/controller/tile_bucket.dart';
import 'package:maplibre_flutter_gpu/src/renderer/implementations/background_layer_renderer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/implementations/fill_layer_renderer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/implementations/line_layer_renderer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/implementations/symbol_layer_renderer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/implementations/tile_stats_layer_renderer.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;
import 'package:vector_math/vector_math.dart' as vm32;
import 'package:vector_math/vector_math_64.dart' as vm64;

final _logger = Logger('RenderOrchestrator');

/// An orchestrator for rendering and hit testing.
///
/// Internally contains a list of [Renderer]s that are drawn in order.
class RenderOrchestrator with ChangeNotifier {
  RenderOrchestrator();

  /// List of renderers that will be drawn in order.
  final renderers = <Renderer>[];
  final postRenderers = <Renderer>[];

  final spriteAtlases = <String?, SpriteTextureAtlas>{};

  void initializeFromStyle(spec.Style style, Map<Object, Source> sources) {
    _logger.fine('Initializing renderers from style');

    // Initialize renderers from layers in the style.
    for (final layer in style.layers) {
      final source = layer.source != null ? sources[layer.source!] : null;

      final renderer = switch (layer.type) {
        spec.Layer$Type.background => MapBackgroundLayerRenderer(
            specLayer: layer as spec.LayerBackground,
          ),
        spec.Layer$Type.line => MapLineLayerRenderer(
            specLayer: layer as spec.LayerLine,
            tileBucket: (source as VectorTiledSource).visibleTileBucket,
          ),
        spec.Layer$Type.fill => MapFillLayerRenderer(
            specLayer: layer as spec.LayerFill,
            tileBucket: (source as VectorTiledSource).visibleTileBucket,
          ),
        spec.Layer$Type.symbol => MapSymbolLayerRenderer(
            specLayer: layer as spec.LayerSymbol,
            tileBucket: (source as VectorTiledSource).visibleTileBucket,
          ),
        _ => null,
      };

      if (renderer != null) {
        _logger.fine('Adding renderer for layer ${layer.id}');

        renderers.add(renderer);
        renderer.addListener(notifyListeners);
      }
    }

    postRenderers.add(DebugMapTileStatsLayerRenderer(orchestrator: this));
  }

  void draw(RendererDrawContext context) {
    for (final renderer in renderers) {
      renderer.prepare(context.prepareContext);
    }

    for (final renderer in renderers) {
      renderer.draw(context);
    }
  }

  void postDraw(RendererDrawContext context) {
    for (final renderer in postRenderers) {
      renderer.draw(context);
    }
  }

  @override
  void dispose() {
    for (final renderer in renderers) {
      renderer.dispose();
    }

    for (final renderer in postRenderers) {
      renderer.dispose();
    }

    super.dispose();
  }
}

class RendererPrepareContext {
  const RendererPrepareContext({
    required this.gpuContext,
    required this.evalContext,
  });

  final gpu.GpuContext gpuContext;
  final spec.EvaluationContext evalContext;
}

/// A context provided to renderers during [draw] operations.
class RendererDrawContext {
  const RendererDrawContext({
    required this.canvas,
    required this.size,
    required this.devicePixelRatio,
    required this.camera,
    required this.gpuContext,
    required this.pass,
    required this.evalContext,
    required this.tileSizeCalculator,
  });

  final ui.Canvas canvas;
  final ui.Size size;
  final double devicePixelRatio;
  final MapCamera camera;
  final gpu.GpuContext gpuContext;
  final gpu.RenderPass pass;
  final spec.EvaluationContext evalContext;
  final double Function(TileCoordinates) tileSizeCalculator;

  vm64.Matrix4 get cameraMvpCanvas {
    return vm64.Matrix4.identity()..translate(-camera.pixelOrigin.x, -camera.pixelOrigin.y, 0.0);
  }

  vm32.Matrix4 get cameraMvpGpu {
    return vm32.Matrix4.identity()
      ..translate(-1.0, 1.0, 0.0)
      ..scale(1.0, -1.0, 0.0)
      ..scale(
        1 / (size.width / devicePixelRatio),
        1 / (size.height / devicePixelRatio),
      )
      ..translate(-camera.pixelOrigin.x, -camera.pixelOrigin.y, 0.0);
  }

  vm64.Matrix4 getMvpForTileCanvas(TileCoordinates coordinates, int extent) {
    final scaledTileSize = tileSizeCalculator(coordinates);

    final origin = ui.Offset(
      coordinates.x * scaledTileSize,
      coordinates.y * scaledTileSize,
    );

    final scale = scaledTileSize / extent;
    return cameraMvpCanvas * vm64.Matrix4.identity()
      ..translate(origin.dx, origin.dy)
      ..scale(scale, scale);
  }

  vm32.Matrix4 getMvpForTileGpu(TileCoordinates coordinates, int extent) {
    final scaledTileSize = tileSizeCalculator(coordinates);

    final origin = ui.Offset(
      coordinates.x * scaledTileSize,
      coordinates.y * scaledTileSize,
    );

    final scale = scaledTileSize / extent;
    return cameraMvpGpu * vm32.Matrix4.identity()
      ..translate(origin.dx, origin.dy)
      ..scale(scale, scale);
  }

  gpu.Scissor getScissorForTile(TileCoordinates coordinates) {
    final scaledTileSize = tileSizeCalculator(coordinates);

    final origin = ui.Offset(
      coordinates.x * scaledTileSize - camera.pixelOrigin.x,
      coordinates.y * scaledTileSize - camera.pixelOrigin.y,
    );

    var _x = (origin.dx * devicePixelRatio).ceil();
    var _y = (origin.dy * devicePixelRatio).ceil();
    var _width = (scaledTileSize * devicePixelRatio).ceil();
    var _height = (scaledTileSize * devicePixelRatio).ceil();

    if (_x < 0) {
      _width += _x;
      _width = _width.clamp(0, size.width * devicePixelRatio).ceil();
      _x = 0;
    }

    if (_y < 0) {
      _height += _y;
      _height = _height.clamp(0, size.height * devicePixelRatio).ceil();
      _y = 0;
    }

    return gpu.Scissor(x: _x, y: _y, width: _width, height: _height);
  }

  RendererPrepareContext get prepareContext => RendererPrepareContext(
        gpuContext: gpuContext,
        evalContext: evalContext,
      );
}

/// An abstract class that can render something on the screen.
abstract class Renderer with ChangeNotifier {
  Renderer();

  /// Whether the renderer needs to perform some asynchronous preparation before it can be drawn.
  ///
  /// If this returns true, [prepare] will be called sometime during the idle time before the next frame, using the
  /// [SchedulerBinding.scheduleTask] method.
  bool get needsAsyncPreparation => false;

  bool _needsPreparation = true;
  bool _isPrepared = false;
  bool _prepareScheduled = false;
  bool _isDisposed = false;

  bool checkNeedsPreparation(RendererPrepareContext oldContext, RendererPrepareContext newContext) {
    return false;
  }

  RendererPrepareContext? _lastPrepareContext;

  /// Prepare the renderer for drawing.
  ///
  /// Usually this involves loading textures, performing tessellation, etc. If the operation is lightweight, it can be
  /// done synchronously. Otherwise, it should be done asynchronously.
  ///
  /// Internally this method will call [prepareImpl], which should be overridden by subclasses.
  Future<void> prepare(RendererPrepareContext context) async {
    // If we don't need preparation, don't do anything.
    if (!needsAsyncPreparation) return;

    // If we've already prepared before, check if we need to prepare again.
    if (_lastPrepareContext != null) _needsPreparation = checkNeedsPreparation(_lastPrepareContext!, context);
    if (!_needsPreparation) return;
    if (_prepareScheduled) return;

    _prepareScheduled = true;

    // await SchedulerBinding.instance.scheduleTask(
    //   () {
    //     if (_isDisposed) return;
    //     prepareImpl(context);
    //   },
    //   Priority.animation,
    // );
    await prepareImpl(context);

    if (_isDisposed) return;
    _isPrepared = true;
    _needsPreparation = false;
    _prepareScheduled = false;

    _lastPrepareContext = context;

    notifyListeners();
  }

  /// Internal implementation of the preparation method. Override this method to prepare the renderer.
  ///
  /// This method will only be called by [prepare], which handles state management.
  Future<void> prepareImpl(RendererPrepareContext context) async {
    // No-op by default.
  }

  /// Draw the renderer on the screen.
  ///
  /// Internally this method will call [drawImpl], which should be overridden by subclasses.
  void draw(RendererDrawContext context) {
    // Don't draw if the renderer needs async preparation and hasn't been prepared yet.
    if (needsAsyncPreparation && !_isPrepared) return;

    drawImpl(context);
    context.pass.clearBindings();
  }

  /// Internal implementation of the drawing method. Override this method to draw the renderer.
  void drawImpl(RendererDrawContext context);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

/// A renderer for a map layer.
abstract class MapLayerRenderer<TLayer extends spec.Layer> extends Renderer {
  MapLayerRenderer({required this.specLayer, this.specSource});

  final TLayer specLayer;
  final spec.Source? specSource;
}

/// A renderer for a map layer that consists of tiles.
abstract class MapTiledLayerRenderer<TLayer extends spec.Layer, TTile> extends MapLayerRenderer<TLayer>
    with TileBucketListener<TTile> {
  MapTiledLayerRenderer({
    required super.specLayer,
    required this.tileBucket,
    super.specSource,
  }) {
    tileBucket.addListener(this);
  }

  final TileBucket<TTile> tileBucket;
  final tileRenderers = <TileCoordinates, TileRenderer<TLayer, TTile>>{};

  /// Create a renderer for a single tile.
  TileRenderer<TLayer, TTile>? createTileRenderer(TileCoordinates coordinates, TTile tile);

  @override
  void onTileAdded(TileCoordinates coordinates, TTile tile) {
    if (tileRenderers.containsKey(coordinates)) return;

    final renderer = createTileRenderer(coordinates, tile);

    if (renderer == null) return;

    renderer.addListener(notifyListeners);
    tileRenderers[coordinates] = renderer;
    notifyListeners();
  }

  @override
  void onTileRemoved(TileCoordinates coordinates) {
    final renderer = tileRenderers.remove(coordinates);
    renderer?.dispose();
    notifyListeners();
  }

  @override
  Future<void> prepare(RendererPrepareContext context) async {
    await Future.wait(tileRenderers.values.map((r) => r.prepare(context)));
  }

  @override
  void drawImpl(RendererDrawContext context) {
    for (final renderer in tileRenderers.values) {
      renderer.draw(context);
    }
  }

  @override
  void dispose() {
    for (final renderer in tileRenderers.values) {
      renderer.dispose();
    }

    tileBucket.removeListener(this);
    super.dispose();
  }
}

abstract class MapVectorTiledLayerRenderer<TLayer extends spec.Layer> extends MapTiledLayerRenderer<TLayer, vt.Tile> {
  MapVectorTiledLayerRenderer({
    required super.specLayer,
    required super.tileBucket,
    super.specSource,
  });
}

abstract class TileRenderer<TLayer extends spec.Layer, TTile> extends Renderer {
  TileRenderer({required this.coordinates, required this.data, required this.specLayer});

  final TileCoordinates coordinates;
  final TLayer specLayer;
  final TTile data;

  DebugRenderStats? get debugRenderStats => null;
}

/// A renderer for a single vector tile's layer.
abstract class VectorTileLayerRenderer<TLayer extends spec.Layer> extends TileRenderer<TLayer, vt.Tile> {
  VectorTileLayerRenderer({
    required super.coordinates,
    required super.data,
    required super.specLayer,
    required this.vtLayer,
  });

  final vt.Layer vtLayer;

  @override
  bool checkNeedsPreparation(RendererPrepareContext oldContext, RendererPrepareContext newContext) {
    return oldContext.evalContext.zoom.floor() != newContext.evalContext.zoom.floor();
  }
}
