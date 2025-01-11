import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/controller/style_controller.dart';
import 'package:maplibre_flutter_gpu/src/debug/sections/camera_section.dart';
import 'package:maplibre_flutter_gpu/src/debug/sections/render_debug_options_section.dart';
import 'package:maplibre_flutter_gpu/src/debug/sections/sprite_atlases_section.dart';
import 'package:maplibre_flutter_gpu/src/gpu_vector_tile_layer.dart';
import 'package:maplibre_flutter_gpu/src/renderer/renderer.dart';

class MapDebugPanel extends StatefulWidget {
  const MapDebugPanel({
    super.key,
    required this.layerKey,
    required this.mapController,
  });

  final GlobalKey<GpuVectorTileLayerState> layerKey;
  final MapController mapController;

  @override
  State<MapDebugPanel> createState() => _MapDebugPanelState();
}

class _MapDebugPanelState extends State<MapDebugPanel> {
  StyleController? _controller;

  @override
  void initState() {
    super.initState();

    // TODO: This is ugly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller = widget.layerKey.currentState?.controller;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      data: ListTileThemeData(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
      child: DividerTheme(
        data: const DividerThemeData(
          thickness: 1.0,
          space: 1.0,
        ),
        child: Drawer(
          child: Column(
            children: [
              PerformanceOverlay.allEnabled(),
              const SizedBox(height: 12.0),
              Divider(),
              Expanded(
                child: ListView(
                  children: [
                    DebugCameraSection(mapController: widget.mapController),
                    Divider(),
                    RenderDebugOptionsSection(),
                    Divider(),
                    if (_controller != null) ...[
                      SpriteAtlasesSection(orchestrator: _controller!.orchestrator),
                      Divider(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
