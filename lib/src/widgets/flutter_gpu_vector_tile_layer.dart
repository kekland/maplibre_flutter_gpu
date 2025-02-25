import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gpu_vector_tile_renderer/_controller.dart';
import 'package:gpu_vector_tile_renderer/_renderer.dart';
import 'package:gpu_vector_tile_renderer/src/debug/debug_painter.dart';

class FlutterGpuVectorTileLayer extends StatefulWidget {
  const FlutterGpuVectorTileLayer({
    super.key,
    required this.styleProvider,
    this.tileDimension = 256,
    required this.shaderLibrary,
    required this.createSingleTileLayerRenderer,
    this.enableRender = true,
    this.debug = false,
  });

  final StyleProviderFn styleProvider;
  final ShaderLibrary shaderLibrary;
  final CreateSingleTileLayerRendererFn createSingleTileLayerRenderer;
  final int tileDimension;
  final bool enableRender; // Temporary!
  final bool debug; // Temporary!

  @override
  State<FlutterGpuVectorTileLayer> createState() => FlutterGpuVectorTileLayerState();
}

class FlutterGpuVectorTileLayerState extends State<FlutterGpuVectorTileLayer> with TickerProviderStateMixin {
  late final VectorTileLayerController _controller;
  late final VectorTileLayerRenderOrchestrator _orchestrator;

  @override
  void initState() {
    super.initState();

    _controller = VectorTileLayerController(styleProvider: widget.styleProvider, tickerProvider: this);
    _controller.load();

    _orchestrator = VectorTileLayerRenderOrchestrator(
      controller: _controller,
      shaderLibrary: widget.shaderLibrary,
      createSingleTileLayerRenderer: widget.createSingleTileLayerRenderer,
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _orchestrator.onReassemble();
  }

  @override
  void dispose() {
    _controller.dispose();
    _orchestrator.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final camera = MapCamera.of(context);
    _controller.onCameraChanged(camera, widget.tileDimension);
    _orchestrator.onCameraChanged(camera, widget.tileDimension);
  }

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.enableRender)
            CustomPaint(
              painter: RenderOrchestratorPainter(
                camera: camera,
                pixelRatio: pixelRatio,
                tileDimension: widget.tileDimension,
                orchestrator: _orchestrator,
              ),
            ),
          if (widget.debug)
            CustomPaint(
              painter: MapDebugPainter(camera: camera, controller: _controller, tileDimension: widget.tileDimension),
            ),
        ],
      ),
    );
  }
}
