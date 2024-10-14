import 'package:flutter/material.dart';
import 'package:maplibre_flutter_gpu/demo/map_page.dart';

void main() {
  runApp(
    MaterialApp(
      showPerformanceOverlay: true,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: MapPage(),
    ),
  );
}
