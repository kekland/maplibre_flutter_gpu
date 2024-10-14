import 'dart:math';

import 'package:flutter_gpu/gpu.dart' as gpu;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/drawable/drawable.dart';
import 'package:maplibre_flutter_gpu/src/flutter_map_internals/tile_bounds.dart';
import 'package:maplibre_flutter_gpu/src/flutter_map_internals/tile_range_calculator.dart';
import 'package:maplibre_flutter_gpu/src/flutter_map_internals/tile_scale_calculator.dart';
import 'package:maplibre_flutter_gpu/src/style/tile.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:vector_math/vector_math.dart' show Vector4;

class VectorTiledLayerWidget extends StatefulWidget {
  const VectorTiledLayerWidget({
    super.key,
    required this.source,
    required this.drawableResolver,
    this.tileSize = 256.0,
  });

  final VectorTiledSource source;
  final Drawable? Function(TileCoordinates coordinates) drawableResolver;
  final double tileSize;

  @override
  State<VectorTiledLayerWidget> createState() => _VectorTiledLayerWidgetState();
}

class _VectorTiledLayerWidgetState extends State<VectorTiledLayerWidget> {
  late TileScaleCalculator _tileScaleCalculator;
  late TileRangeCalculator _tileRangeCalculator;
  late TileBounds _tileBounds;
  late Set<TileCoordinates> _tileCoordinates;

  @override
  void initState() {
    super.initState();

    _createTileCalculatorObjects();
    widget.source.addListener(_onSourceChanged);
  }

  void _onSourceChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.source.removeListener(_onSourceChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VectorTiledLayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tileSize != widget.tileSize) {
      _createTileCalculatorObjects();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final camera = MapCamera.of(context);

    _tileScaleCalculator.clearCacheUnlessZoomMatches(camera.zoom);

    final tileZoom = _clampToNativeZoom(camera.zoom);
    final bounds = _tileBounds.atZoom(tileZoom);
    final tileRange = _tileRangeCalculator.calculate(camera: camera, tileZoom: tileZoom);
    final validTileRange = bounds.validCoordinatesIn(tileRange);

    _tileCoordinates = validTileRange.map((v) => TileCoordinates.key(v)).toSet();

    widget.source.onVisibleTilesChanged(_tileCoordinates);
  }

  void _createTileCalculatorObjects() {
    _tileRangeCalculator = TileRangeCalculator(tileSize: widget.tileSize);
    _tileScaleCalculator = TileScaleCalculator(crs: const Epsg3857(), tileSize: widget.tileSize);
    _tileBounds = TileBounds(crs: const Epsg3857(), tileSize: widget.tileSize);
  }

  int _clampToNativeZoom(double zoom) => zoom.round().clamp(0, 19);

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);

    final pixelWorldBounds = camera.getPixelWorldBounds(null);

    final tileZoom = _clampToNativeZoom(camera.zoom);
    final scaledTileSize = _tileScaleCalculator.scaledTileSize(camera.zoom, tileZoom);

    final drawables = _tileCoordinates.map(widget.drawableResolver).nonNulls.toList();

    return CustomPaint(
      isComplex: true,
      willChange: true,
      painter: TiledLayerPainter(
        repaint: widget.source,
        drawables: drawables,
        tileCoordinates: _tileCoordinates,
        scaledTileSize: scaledTileSize,
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
        cameraPixelOrigin: camera.pixelOrigin,
        cameraWorldBounds: pixelWorldBounds!,
        zoom: camera.zoom,
      ),
      child: SizedBox.expand(),
    );
  }
}

class TiledLayerPainter extends CustomPainter {
  const TiledLayerPainter({
    super.repaint,
    required this.drawables,
    required this.tileCoordinates,
    required this.scaledTileSize,
    required this.pixelRatio,
    required this.cameraPixelOrigin,
    required this.cameraWorldBounds,
    required this.zoom,
  });

  final Set<TileCoordinates> tileCoordinates;
  final List<Drawable> drawables;
  final double scaledTileSize;
  final double pixelRatio;
  final Point<double> cameraPixelOrigin;
  final Bounds<num> cameraWorldBounds;
  final double zoom;

  void _paintGpu(Canvas canvas, Size size) {
    final width = (size.width * pixelRatio).ceil();
    final height = (size.height * pixelRatio).ceil();

    final renderTexture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      width,
      height,
      sampleCount: 1,
    )!;

    final commandBuffer = gpu.gpuContext.createCommandBuffer();

    final renderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(
        texture: renderTexture,
        clearValue: Vector4(0.0, 0.0, 0.0, 0.0),
        storeAction: gpu.StoreAction.store,
        loadAction: gpu.LoadAction.clear,
      ),
    );

    final pass = commandBuffer.createRenderPass(renderTarget);

    pass.setColorBlendEnable(true, colorAttachmentIndex: 0);
    pass.setColorBlendEquation(
      gpu.ColorBlendEquation(
        colorBlendOperation: gpu.BlendOperation.add,
        sourceColorBlendFactor: gpu.BlendFactor.sourceAlpha, // Changed from 'one' to 'sourceAlpha'
        destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
        alphaBlendOperation: gpu.BlendOperation.add,
        sourceAlphaBlendFactor: gpu.BlendFactor.one,
        destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
      ),
    );

    for (final drawable in drawables) {
      if (drawable is TileDrawable) {
        // Create MVP matrix for this tile
        final tileOrigin = Point<double>(
          drawable.coordinates.x * scaledTileSize - cameraPixelOrigin.x,
          drawable.coordinates.y * scaledTileSize - cameraPixelOrigin.y,
        );

        final mvp = Matrix4.identity()
          ..translate(-1.0, 1.0, 0.0)
          ..scale(1.0, -1.0, 0.0)
          ..scale(
            1 / (width / 2.0),
            1 / (height / 2.0),
          )
          ..translate(tileOrigin.x, tileOrigin.y)
          ..scale(
            scaledTileSize / drawable.extent,
            scaledTileSize / drawable.extent,
          );

        final evalContext = spec.EvaluationContext.empty().copyWith(zoom: zoom);
        drawable.draw(
          gpu.gpuContext,
          pass,
          mvp,
          evalContext,
        );
      }
    }

    commandBuffer.submit();
    final image = renderTexture.asImage();

    canvas.drawImage(
      image,
      Offset.zero,
      Paint(),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintGpu(canvas, size);
    return;

    // Debug painters
    canvas.translate(-cameraPixelOrigin.x, -cameraPixelOrigin.y);

    // for (final drawable in drawables) {
    //   if (drawable is FillLayerDrawable) {
    //     canvas.save();
    //     canvas.translate(drawable.coordinates.x * scaledTileSize, drawable.coordinates.y * scaledTileSize);
    //     canvas.scale(scaledTileSize / drawable.extent);

    //     debugPaintLayer(canvas, size, drawable.vectorTileLayer);

    //     canvas.restore();
    //   }
    // }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final coordinates in tileCoordinates) {
      final rect = Rect.fromLTWH(
        coordinates.x * scaledTileSize,
        coordinates.y * scaledTileSize,
        scaledTileSize,
        scaledTileSize,
      );

      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.red,
      );

      textPainter.text = TextSpan(
        text: '${coordinates.z} > (${coordinates.x}, ${coordinates.y})',
        style: const TextStyle(color: Colors.black),
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top));
    }

    textPainter.dispose();
  }

  @override
  bool shouldRepaint(TiledLayerPainter oldDelegate) =>
      !setEquals(tileCoordinates, oldDelegate.tileCoordinates) ||
      !listEquals(drawables, oldDelegate.drawables) ||
      oldDelegate.scaledTileSize != scaledTileSize ||
      oldDelegate.pixelRatio != pixelRatio ||
      oldDelegate.cameraPixelOrigin != cameraPixelOrigin ||
      oldDelegate.cameraWorldBounds != cameraWorldBounds;
}
