import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:logging/logging.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;

final _logger = Logger('TileBucket');

/// A bucket for tiles for a single source.
abstract class TileBucket<T> {
  TileBucket({
    required this.key,
    required this.source,
  });

  final Object key;
  final spec.Source source;
  final _tiles = <fm.TileCoordinates, T>{};
  final _listeners = <TileBucketListener<T>>{};

  void addListener(TileBucketListener<T> listener) {
    _listeners.add(listener);
  }

  void removeListener(TileBucketListener<T> listener) {
    _listeners.remove(listener);
  }

  void addTile(fm.TileCoordinates coordinates, T tile) {
    _logger.fine('Adding tile $coordinates');
    _tiles[coordinates] = tile;

    for (final listener in _listeners) {
      listener.onTileAdded(coordinates, tile);
    }
  }

  void removeTile(fm.TileCoordinates coordinates) {
    _logger.fine('Removing tile $coordinates');
    _tiles.remove(coordinates);

    for (final listener in _listeners) {
      listener.onTileRemoved(coordinates);
    }
  }

  /// Keep only tiles that are in the visible range.
  ///
  /// Returns the coordinates of the tiles that are missing and should be loaded.
  Iterable<fm.TileCoordinates> keepVisibleRange(Iterable<fm.TileCoordinates> coordinates) {
    final visibleSet = coordinates.toSet();
    final currentSet = _tiles.keys.toSet();

    final missing = currentSet.difference(visibleSet);
    final extra = visibleSet.difference(currentSet);

    for (final coordinates in missing) {
      removeTile(coordinates);
    }

    return extra;
  }

  void dispose() {
    _tiles.clear();
    _listeners.clear();
  }
}

class VectorTileBucket extends TileBucket<vt.Tile> {
  VectorTileBucket({required super.key, required super.source});
}

/// A listener for tile bucket events.
mixin TileBucketListener<T> {
  void onTileAdded(fm.TileCoordinates coordinates, T tile);
  void onTileRemoved(fm.TileCoordinates coordinates);
}
