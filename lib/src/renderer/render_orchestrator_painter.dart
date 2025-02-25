import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gpu_vector_tile_renderer/_renderer.dart';

class RenderOrchestratorPainter extends CustomPainter {
  RenderOrchestratorPainter({
    required this.camera,
    required this.pixelRatio,
    required this.tileDimension,
    required this.orchestrator,
  }) : super(repaint: orchestrator);

  final MapCamera camera;
  final double pixelRatio;
  final int tileDimension;
  final VectorTileLayerRenderOrchestrator orchestrator;

  @override
  void paint(Canvas canvas, Size size) {
    final image = orchestrator.draw(camera: camera, pixelRatio: pixelRatio, size: size, tileDimension: tileDimension);
    if (image == null) return;

    canvas.scale(1 / pixelRatio);
    canvas.drawImage(image, Offset.zero, Paint());
    canvas.scale(pixelRatio);
  }

  @override
  bool shouldRepaint(RenderOrchestratorPainter oldDelegate) => true;
}
