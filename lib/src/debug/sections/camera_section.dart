import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class DebugCameraSection extends StatelessWidget {
  const DebugCameraSection({super.key, required this.mapController});

  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: mapController.mapEventStream,
      builder: (context, _) {
        final camera = mapController.camera;

        return Column(
          children: [
            ListTile(
              title: const Text('Camera'),
              subtitle: Text('Zoom: ${camera.zoom.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Center'),
              subtitle: Text('Lat: ${camera.center.latitude.toStringAsFixed(2)}, Lng: ${camera.center.longitude.toStringAsFixed(2)}'),
            ),
          ],
        );
      },
    );
  }
}
