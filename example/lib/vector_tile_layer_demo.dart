import 'dart:convert';

import 'package:example/compiled_style/layer_renderers.gen.dart';
import 'package:example/fixtures/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gpu_vector_tile_renderer/gpu_vector_tile_renderer.dart';
import 'package:latlong2/latlong.dart';

class VectorTileLayerDemo extends StatefulWidget {
  const VectorTileLayerDemo({super.key});

  @override
  State<VectorTileLayerDemo> createState() => _DemoPageState();
}

class _DemoPageState extends State<VectorTileLayerDemo> {
  var _showRasterLayer = false;
  var _showVectorLayer = true;
  var _isDebug = false;
  late final _controller = MapController();

  final _locations = {
    'Zero': LatLng(0.0, 0.0),
    'London': LatLng(51.5074, -0.1278),
    'Almaty': LatLng(43.2389498, 76.8897094),
    'Milano': LatLng(45.4642, 9.1900),
    'Zurich': LatLng(47.3769, 8.5417),
    'New York': LatLng(40.7128, -74.0060),
    'Tokyo': LatLng(35.6895, 139.6917),
    'Sydney': LatLng(-33.8688, 151.2093),
    'Santiago': LatLng(-33.4489, -70.6693),
    'Rio de Janeiro': LatLng(-22.9068, -43.1729),
    'Reykjavik': LatLng(64.1466, -21.9426),
    'Barcelona': LatLng(41.3851, 2.1734),
  };

  void _showJumpToLocation() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => ListView(
            shrinkWrap: true,
            children:
                _locations.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(
                      '${entry.value.latitude}, ${entry.value.longitude}',
                    ),
                    trailing: Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      final location = _locations[entry.key]!;
                      _controller.move(location, 13.0);

                      Navigator.pop(context);
                    },
                  );
                }).toList(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Demo')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              backgroundColor: theme.colorScheme.surface,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all ^ InteractiveFlag.rotate,
              ),
              initialZoom: 0.0,
              initialCenter: const LatLng(0.0, 0.0),
            ),
            children: [
              FlutterGpuVectorTileLayer(
                enableRender: _showVectorLayer,
                debug: _isDebug,
                styleProvider: jsonStyleProvider(
                  jsonDecode(maptilerStreetsStyle),
                ),
                createSingleTileLayerRenderer: createSingleTileLayerRenderer,
                shaderLibrary:
                    ShaderLibrary.fromAsset(
                      'build/shaderbundles/Streets.shaderbundle',
                    )!,
              ),
              if (_showRasterLayer)
                Opacity(
                  opacity: 0.35,
                  child: TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                    maxNativeZoom: 19,
                    tileBuilder: (context, child, image) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.0),
                        ),
                        child: child,
                      );
                    },
                  ),
                ),
            ],
          ),

          Positioned(
            top: 120,
            left: 16,
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16.0),
              clipBehavior: Clip.antiAlias,
              child: ToggleButtons(
                isSelected: [_showRasterLayer, _showVectorLayer, _isDebug, false],
                direction: Axis.vertical,
                onPressed: (index) {
                  if (index == 0) _showRasterLayer = !_showRasterLayer;
                  if (index == 1) _showVectorLayer = !_showVectorLayer;
                  if (index == 2) _isDebug = !_isDebug;
                  if (index == 3) _showJumpToLocation();
                  setState(() {});
                },
                children: [
                  Icon(Icons.image_rounded),
                  Icon(Icons.map_rounded),
                  Icon(Icons.bug_report_rounded),
                  Icon(Icons.location_city_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
