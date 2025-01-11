import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/components/isolate/isolates.dart';
import 'package:maplibre_flutter_gpu/src/components/model/source_resolver_function.dart';
import 'package:maplibre_flutter_gpu/src/components/model/style_source_function.dart';
import 'package:maplibre_flutter_gpu/src/controller/style_controller.dart';
import 'package:maplibre_flutter_gpu/src/renderer/renderer_widget.dart';

class GpuVectorTileLayer extends StatefulWidget {
  const GpuVectorTileLayer({
    super.key,
    required this.styleSource,
    this.sourceResolver = defaultSourceResolver,
    this.tileSize = 256.0,
  });

  final StyleSourceFunction styleSource;
  final SourceResolverFunction sourceResolver;
  final double tileSize;

  @override
  State<GpuVectorTileLayer> createState() => GpuVectorTileLayerState();
}

class GpuVectorTileLayerState extends State<GpuVectorTileLayer> {
  late final StyleController controller;

  @override
  void initState() {
    super.initState();

    Isolates.instance.spawn();

    controller = StyleController(
      styleSource: widget.styleSource,
      sourceResolver: widget.sourceResolver,
      tileSize: widget.tileSize,
    );

    controller.addListener(onControllerChanged);
    controller.load();
  }

  void onControllerChanged() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final camera = MapCamera.of(context);
    controller.onCameraChanged(camera);
  }

  @override
  Widget build(BuildContext context) {
    return RenderOrchestratorWidget(
      orchestrator: controller.orchestrator,
      tileSize: widget.tileSize,
    );
  }
}
