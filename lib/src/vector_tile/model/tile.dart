import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/model/_model.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/proto/_proto.dart' as pb;

class Tile {
  Tile({
    required this.layers,
  });

  factory Tile.parse(pb.Tile tile) {
    return Tile(
      layers: tile.layers.map((l) => Layer.parse(l)).toList(),
    );
  }

  final List<Layer> layers;
}
