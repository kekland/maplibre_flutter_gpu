import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_flutter_gpu/demo/fixtures/style.dart';
import 'package:maplibre_flutter_gpu/src/components/model/style_source_function.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/gpu_vector_tile_layer.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    TileLayer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      // backgroundColor: Colors.pink,
      body: FlutterMap(
        options: MapOptions(
          // backgroundColor: Colors.pink,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all ^ InteractiveFlag.rotate,
          ),
          // initialZoom: 0.0on,
          // initialCenter: cst LatLng(0.0, 0.0),
          // London
          // initialZoom: 10.0,
          // initialCenter: const LatLng(51.5074, -0.1278),
          // Minden
          // initialZoom: 15.0,
          // initialCenter: const LatLng(52.2909650444652, 8.87692979746907),
          // Almaty
          initialZoom: 13.0,
          initialCenter: const LatLng(43.2389498, 76.8897094),
          // Milano
          // initialZoom: 13.0,
          // initialCenter: const LatLng(45.4642, 9.1900),
          // Zurich
          // initialZoom: 13.0,
          // initialCenter: const LatLng(47.3769, 8.5417),
          // New York
          // initialZoom: 13.0,
          // initialCenter: const LatLng(40.7128, -74.0060),
        ),
        children: [
          GpuVectorTileLayer(
            styleSource: createJsonStyleSource(jsonDecode(maptilerBasicStyle)),
            tileSize: 256.0,
          ),
          if (false)
            Opacity(
              opacity: 1.0,
              child: TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                maxNativeZoom: 19,
                tileBuilder: (context, child, image) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 0.0,
                      ),
                    ),
                    child: child,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
