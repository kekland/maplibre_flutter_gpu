import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/vector_tile_data.dart';

/// Model for tiles displayed by [TileLayer] and [TilePainter]
class VectorTileModel {
  /// [VectorTileData] is the model class that contains meta data for the Tile image.
  final VectorTileData tile;

  /// The tile size for the given scale of the map.
  final double scaledTileSize;

  /// Current camera zoom level.
  final double zoom;

  /// Reference to the offset of the top-left corner of the bounding rectangle
  /// of the [MapCamera]. The origin will not equal the offset of the top-left
  /// visible pixel when the map is rotated.
  final Point<double> currentPixelOrigin;

  /// Creates a new instance of TileModel.
  const VectorTileModel({
    required this.scaledTileSize,
    required this.currentPixelOrigin,
    required this.tile,
    required this.zoom,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VectorTileModel &&
          tile == other.tile &&
          scaledTileSize == other.scaledTileSize &&
          currentPixelOrigin == other.currentPixelOrigin);

  @override
  int get hashCode => Object.hash(tile, scaledTileSize, currentPixelOrigin);
}
