import 'package:flutter/material.dart';
import 'package:maplibre_flutter_gpu/src/components/_components.dart';
import 'package:maplibre_flutter_gpu/src/debug/debug_paint_tile.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_model.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart' as vm32;

/// Draws [TileModel]s onto a canvas at the correct position
class GpuVectorTilePainter extends CustomPainter {
  GpuVectorTilePainter({
    required this.tiles,
    required this.renderTexture,
    required this.pixelRatio,
    this.resolveTexture,
  }) : super(
          repaint: Listenable.merge(
            tiles.map<Listenable?>((t) => t.tile.animation).followedBy(tiles.map((t) => t.tile)),
          ),
        );

  final List<VectorTileModel> tiles;
  final gpu.Texture renderTexture;
  final gpu.Texture? resolveTexture;
  final double pixelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final width = (size.width * pixelRatio).ceil();
    final height = (size.height * pixelRatio).ceil();

    final commandBuffer = gpu.gpuContext.createCommandBuffer();

    final renderTarget = resolveTexture != null
        ? gpu.RenderTarget.singleColor(
            gpu.ColorAttachment(
              texture: renderTexture,
              resolveTexture: resolveTexture,
              clearValue: vm32.Vector4(0.0, 0.0, 0.0, 0.0),
              storeAction: gpu.StoreAction.storeAndMultisampleResolve,
              loadAction: gpu.LoadAction.clear,
            ),
          )
        : gpu.RenderTarget.singleColor(
            gpu.ColorAttachment(
              texture: renderTexture,
              clearValue: vm32.Vector4(0.0, 0.0, 0.0, 0.0),
              storeAction: gpu.StoreAction.store,
              loadAction: gpu.LoadAction.clear,
            ),
          );

    final pass = commandBuffer.createRenderPass(renderTarget);

    // pass.setDepthWriteEnable(true);
    // pass.setStencilConfig(
    //   gpu.StencilConfig(
    //     compareFunction: gpu.CompareFunction.always,
    //     stencilFailureOperation: gpu.StencilOperation.invert,
    //     depthStencilPassOperation: gpu.StencilOperation.keep,
    //     depthFailureOperation: gpu.StencilOperation.invert,
    //   ),
    // );

    pass.setColorBlendEnable(true);
    pass.setColorBlendEquation(
      gpu.ColorBlendEquation(
        colorBlendOperation: gpu.BlendOperation.add,
        sourceColorBlendFactor: gpu.BlendFactor.sourceAlpha,
        destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
        alphaBlendOperation: gpu.BlendOperation.add,
        sourceAlphaBlendFactor: gpu.BlendFactor.one,
        destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
      ),
    );

    for (final tile in tiles) {
      final _tile = tile.tile;

      if (_tile.drawables != null) {
        final origin = Offset(
          _tile.coordinates.x * tile.scaledTileSize - tile.currentPixelOrigin.x,
          _tile.coordinates.y * tile.scaledTileSize - tile.currentPixelOrigin.y,
        );

        for (final drawable in _tile.drawables!.whereType<TileDrawable>()) {
          final scale = tile.scaledTileSize / drawable.extent;
          final mvp = vm32.Matrix4.identity()
            ..translate(-1.0, 1.0, 0.0)
            ..scale(1.0, -1.0, 0.0)
            ..scale(
              1 / (width / 2.0),
              1 / (height / 2.0),
            )
            ..translate(origin.dx, origin.dy)
            ..scale(scale, scale);

          var _x = (origin.dx * pixelRatio).round();
          var _y = (origin.dy * pixelRatio).round();
          var _width = (tile.scaledTileSize * pixelRatio).round();
          var _height = (tile.scaledTileSize * pixelRatio).round();

          if (_x < 0) {
            _width += _x;
            _x = 0;
          }

          if (_y < 0) {
            _height += _y;
            _y = 0;
          }

          pass.setScissor(gpu.Scissor(x: _x, y: _y, width: _width, height: _height));
          drawable.draw(
            canvas,
            gpu.gpuContext,
            spec.EvaluationContext.empty().copyWith(
              zoom: tile.zoom,
              scaledTileSizePixels: tile.scaledTileSize,
              opacity: tile.tile.opacity,
            ),
            mvp,
            pass,
          );

          pass.clearBindings();
        }
      }
    }

    commandBuffer.submit();
    final image = (resolveTexture ?? renderTexture).asImage();

    canvas.scale(0.5);
    canvas.drawImage(
      image,
      Offset.zero,
      Paint(),
    );
    canvas.scale(2.0);

    for (final tile in tiles) {
      if (tile.tile.provider.debugVt != null) {
        final _tile = tile.tile;
        final debugVt = _tile.provider.debugVt!;

        final origin = Offset(
          _tile.coordinates.x * tile.scaledTileSize - tile.currentPixelOrigin.x,
          _tile.coordinates.y * tile.scaledTileSize - tile.currentPixelOrigin.y,
        );

        final mvp = Matrix4.identity()
          ..translate(origin.dx, origin.dy)
          ..scale(
            tile.scaledTileSize / debugVt.layers.first.extent,
            tile.scaledTileSize / debugVt.layers.first.extent,
          );

        canvas.drawRect(
          Rect.fromLTWH(
            origin.dx,
            origin.dy,
            tile.scaledTileSize,
            tile.scaledTileSize,
          ),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.2)
            ..style = PaintingStyle.stroke,
        );

        canvas.save();
        canvas.transform(mvp.storage);
        debugPaintTile(canvas, size, debugVt);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant GpuVectorTilePainter oldDelegate) => true;
}
