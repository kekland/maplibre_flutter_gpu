import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:gpu_vector_tile_renderer/_controller.dart';
import 'package:gpu_vector_tile_renderer/_renderer.dart';
import 'package:gpu_vector_tile_renderer/_spec.dart' as spec;
import 'package:gpu_vector_tile_renderer/_vector_tile.dart' as vt;
import 'package:gpu_vector_tile_renderer/src/isolates/isolates.dart';
import 'package:gpu_vector_tile_renderer/src/utils/flutter_map/tile_scale_calculator.dart';
import 'package:vector_math/vector_math.dart' as vm32;

typedef CreateSingleTileLayerRendererFn =
    SingleTileLayerRenderer? Function(
      gpu.ShaderLibrary shaderLibrary,
      fm.TileCoordinates coordinates,
      TileContainer container,
      spec.Layer specLayer,
      vt.Layer vtLayer,
    );

class VectorTileLayerRenderOrchestrator with ChangeNotifier {
  VectorTileLayerRenderOrchestrator({
    required this.controller,
    required this.shaderLibrary,
    required CreateSingleTileLayerRendererFn createSingleTileLayerRenderer,
  }) : _createSingleTileLayerRenderer = createSingleTileLayerRenderer {
    Isolates.instance.spawn();

    controller.setRenderOrchestrator(this);
    controller.addListener(_onControllerChanged);
    controller.addTileUpdateListener(_onTilesChanged);
  }

  /// The controller that this renderer is attached to.
  final VectorTileLayerController controller;

  /// Shader library to use
  final gpu.ShaderLibrary shaderLibrary;

  /// The function that creates a single tile layer renderer. Should be created by `compile_style.dart` executable.
  final CreateSingleTileLayerRendererFn _createSingleTileLayerRenderer;

  SingleTileLayerRenderer? createSingleTileLayerRenderer(
    fm.TileCoordinates coordinates,
    TileContainer container,
    spec.Layer specLayer,
    vt.Layer vtLayer,
  ) {
    return _createSingleTileLayerRenderer(shaderLibrary, coordinates, container, specLayer, vtLayer);
  }

  List<LayerRenderer>? _layers;

  void _onControllerChanged() {
    if (_layers != null) return;

    // Convert the style layers to layer renderers.
    _layers = createLayerRenderers(this, controller.style);

    for (final layer in _layers!) {
      layer.prepare(PrepareContext(eval: spec.EvaluationContext.empty()));
    }
  }

  void onReassemble() {
    if (_layers == null) return;

    for (final layer in _layers!) {
      final result = layer.prepare(PrepareContext(eval: spec.EvaluationContext.empty()));

      if (result is Future) {
        result.then((_) => notifyListeners());
      }
    }
  }

  void _onTilesChanged() {
    notifyListeners();
  }

  fm.MapCamera? _lastCamera;
  int? _lastTileDimension;
  TileScaleCalculator? _tileScaleCalculator;

  void onCameraChanged(fm.MapCamera camera, int tileDimension) {
    if (_tileScaleCalculator == null || tileDimension != _lastTileDimension) {
      _tileScaleCalculator = TileScaleCalculator(crs: camera.crs, tileDimension: tileDimension);
    }

    _lastCamera = camera;
    _lastTileDimension = tileDimension;
    _tileScaleCalculator!.clearCacheUnlessZoomMatches(camera.zoom);
  }

  gpu.Texture? _texture;
  gpu.Texture? _resolveTexture;

  void _setupTextures(ui.Size size, double pixelRatio) {
    final width = (size.width * pixelRatio).ceil();
    final height = (size.height * pixelRatio).ceil();

    if (_texture != null && _texture!.width == width && _texture!.height == height) return;

    if (gpu.gpuContext.doesSupportOffscreenMSAA) {
      _texture = gpu.gpuContext.createTexture(
        gpu.StorageMode.hostVisible,
        width,
        height,
        sampleCount: 4,
        format: gpu.PixelFormat.r8g8b8a8UNormIntSRGB,
      );

      _resolveTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.hostVisible,
        width,
        height,
        sampleCount: 1,
        format: gpu.PixelFormat.r8g8b8a8UNormIntSRGB,
      );
    } else {
      _texture = gpu.gpuContext.createTexture(
        gpu.StorageMode.hostVisible,
        width,
        height,
        format: gpu.PixelFormat.r8g8b8a8UNormIntSRGB,
      );
      _resolveTexture = null;
    }
  }

  ui.Image? draw({
    required ui.Size size,
    required double pixelRatio,
    required fm.MapCamera camera,
    required int tileDimension,
  }) {
    if (_layers == null) return null;
    _setupTextures(size, pixelRatio);

    final commandBuffer = gpu.gpuContext.createCommandBuffer();

    final renderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(
        texture: _texture!,
        resolveTexture: _resolveTexture,
        clearValue: vm32.Vector4(0, 0, 0, 0),
        storeAction: _resolveTexture != null ? gpu.StoreAction.storeAndMultisampleResolve : gpu.StoreAction.store,
        loadAction: gpu.LoadAction.clear,
      ),
    );

    final pass = commandBuffer.createRenderPass(renderTarget);
    pass.setColorBlendEnable(true);
    pass.setColorBlendEquation(
      gpu.ColorBlendEquation(
        colorBlendOperation: gpu.BlendOperation.add,
        sourceColorBlendFactor: gpu.BlendFactor.one,
        destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
        alphaBlendOperation: gpu.BlendOperation.add,
        sourceAlphaBlendFactor: gpu.BlendFactor.one,
        destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
      ),
    );

    pass.setCullMode(gpu.CullMode.none);

    final renderContext = RenderContext(
      pass: pass,
      size: size,
      pixelRatio: pixelRatio,
      camera: camera,
      tileScaleCalculator: _tileScaleCalculator!,
      eval: spec.EvaluationContext(geometryType: '', zoom: camera.zoom, locale: spec.Locale(languageCode: 'en')),
    );

    final zoom = camera.zoom;
    for (final layer in _layers!) {
      final specLayer = layer.specLayer;

      if (specLayer.minzoom != null && zoom < specLayer.minzoom!) continue;
      if (specLayer.maxzoom != null && zoom > specLayer.maxzoom!) continue;

      layer.draw(renderContext);
    }

    commandBuffer.submit();
    return (_resolveTexture ?? _texture)!.asImage();
  }
}
