import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_flutter_gpu/demo/fixtures/style.dart';
import 'package:maplibre_flutter_gpu/src/style/maplibre_map_controller.dart';
import 'package:maplibre_flutter_gpu/src/style/style_source.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapLibreMapController _style;

  @override
  void initState() {
    super.initState();

    _style = MapLibreMapController(
      styleSource: createJsonStyleSource(jsonDecode(maptilerStreetsStyle)),
    );

    _style.addListener(() {
      setState(() {});
    });

    _style.load();
  }

  @override
  void dispose() {
    _style.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all ^ InteractiveFlag.rotate,
          ),
          initialZoom: 13.0,
          initialCenter: LatLng(43.2380, 76.8829),
        ),
        children: [
          if (_style.isLoaded) ..._style.buildLayers(context),
          if (false)
            Opacity(
              opacity: 0.5,
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
