import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/debug/debug_panel.dart';
import 'package:maplibre_flutter_gpu/src/renderer/renderer.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_scale_calculator.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:vector_math/vector_math.dart' as vm32;

class RenderOrchestratorWidget extends StatefulWidget {
  const RenderOrchestratorWidget({
    super.key,
    required this.orchestrator,
    required this.tileSize,
  });

  final RenderOrchestrator orchestrator;
  final double tileSize;

  @override
  State<RenderOrchestratorWidget> createState() => _RenderOrchestratorWidgetState();
}

class _RenderOrchestratorWidgetState extends State<RenderOrchestratorWidget> {
  @override
  void initState() {
    super.initState();
    widget.orchestrator.addListener(_onOrchestratorChanged);
  }

  void _onOrchestratorChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.orchestrator.removeListener(_onOrchestratorChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final camera = MapCamera.of(context);

    return MobileLayerTransformer(
      child: CustomPaint(
        painter: _RenderOrchestratorPainter(
          orchestrator: widget.orchestrator,
          devicePixelRatio: devicePixelRatio,
          tileSize: widget.tileSize,
          camera: camera,
        ),
      ),
    );
  }
}

class _RenderOrchestratorPainter extends CustomPainter {
  _RenderOrchestratorPainter({
    required this.orchestrator,
    required this.devicePixelRatio,
    required this.tileSize,
    required this.camera,
  });

  final RenderOrchestrator orchestrator;
  final double devicePixelRatio;
  final double tileSize;
  final MapCamera camera;

  @override
  void paint(Canvas canvas, Size size) {
    final textureWidth = (size.width * devicePixelRatio).toInt();
    final textureHeight = (size.height * devicePixelRatio).toInt();

    final renderTexture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      textureWidth,
      textureHeight,
      sampleCount: 4,
    )!;

    final resolveTexture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      textureWidth,
      textureHeight,
      sampleCount: 1,
    )!;

    final commandBuffer = gpu.gpuContext.createCommandBuffer();

    // TODO: Optionally disable MSAA
    final renderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(
        texture: renderTexture,
        resolveTexture: resolveTexture,
        clearValue: vm32.Vector4(0.0, 0.0, 0.0, 0.0),
        storeAction: gpu.StoreAction.storeAndMultisampleResolve,
        loadAction: gpu.LoadAction.clear,
      ),
    );

    final pass = commandBuffer.createRenderPass(renderTarget);

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

    final tileScaleCalculator = TileScaleCalculator(crs: camera.crs, tileSize: tileSize);
    tileScaleCalculator.clearCacheUnlessZoomMatches(camera.zoom);

    final rendererContext = RendererDrawContext(
      canvas: canvas,
      size: size,
      camera: camera,
      devicePixelRatio: devicePixelRatio,
      gpuContext: gpu.gpuContext,
      pass: pass,
      evalContext: spec.EvaluationContext.empty()..copyWith(zoom: camera.zoom),
      tileSizeCalculator: (coordinates) => tileScaleCalculator.scaledTileSize(camera.zoom, coordinates.z),
    );

    orchestrator.draw(rendererContext);
    commandBuffer.submit();
    final image = resolveTexture.asImage();

    canvas.scale(1 / devicePixelRatio);
    canvas.drawImage(
      image,
      Offset.zero,
      Paint(),
    );
    canvas.scale(devicePixelRatio);

    orchestrator.postDraw(rendererContext);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
