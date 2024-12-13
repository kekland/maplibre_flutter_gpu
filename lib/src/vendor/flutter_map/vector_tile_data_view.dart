import 'dart:collection';

import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_range.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/vector_tile_data.dart';

/// The [VectorTileDataView] stores all loaded [VectorTileData]s with their
/// [TileCoordinates].
final class VectorTileDataView {
  final Map<TileCoordinates, VectorTileData> _tiles;
  final DiscreteTileRange _visibleRange;
  final DiscreteTileRange _keepRange;

  /// Create a new [VectorTileDataView] instance.
  const VectorTileDataView({
    required Map<TileCoordinates, VectorTileData> tiles,
    required DiscreteTileRange visibleRange,
    required DiscreteTileRange keepRange,
  })  : _tiles = tiles,
        _visibleRange = visibleRange,
        _keepRange = keepRange;

  /// Get a list with all tiles that have an error and are outside of the
  /// margin that should get kept.
  List<VectorTileData> errorTilesOutsideOfKeepMargin() =>
      _tiles.values.where((tile) => tile.loadError && !_keepRange.contains(tile.coordinates)).toList();

  /// Get a list with all tiles that are not visible on the current map
  /// viewport.
  List<VectorTileData> errorTilesNotVisible() =>
      _tiles.values.where((tile) => tile.loadError && !_visibleRange.contains(tile.coordinates)).toList();

  /// Get a list of [VectorTileData] that are stale and can get for pruned.
  Iterable<VectorTileData> get staleTiles {
    final stale = HashSet<VectorTileData>();
    final retain = HashSet<VectorTileData>();

    for (final tile in _tiles.values) {
      final c = tile.coordinates;
      if (!_keepRange.contains(c)) {
        stale.add(tile);
        continue;
      }

      final retainedAncestor = _retainAncestor(retain, c.x, c.y, c.z, c.z - 5);
      if (!retainedAncestor) {
        _retainChildren(retain, c.x, c.y, c.z, c.z + 2);
      }
    }

    return stale.where((tile) => !retain.contains(tile));
  }

  /// Get a list of [VectorTileData] that need to get rendered on screen.
  Iterable<VectorTileData> get renderTiles {
    final retain = HashSet<VectorTileData>();

    for (final tile in _tiles.values) {
      final c = tile.coordinates;
      if (!_visibleRange.contains(c)) {
        continue;
      }

      retain.add(tile);

      if (!tile.readyToDisplay) {
        final retainedAncestor = _retainAncestor(retain, c.x, c.y, c.z, c.z - 5);
        if (!retainedAncestor) {
          _retainChildren(retain, c.x, c.y, c.z, c.z + 2);
        }
      }
    }
    return retain;
  }

  /// Recurse through the ancestors of the Tile at the given coordinates adding
  /// them to [retain] if they are ready to display or loaded. Returns true if
  /// any of the ancestor tiles were ready to display.
  bool _retainAncestor(
    Set<VectorTileData> retain,
    int x,
    int y,
    int z,
    int minZoom,
  ) {
    final x2 = (x / 2).floor();
    final y2 = (y / 2).floor();
    final z2 = z - 1;
    final coords2 = TileCoordinates(x2, y2, z2);

    final tile = _tiles[coords2];
    if (tile != null) {
      if (tile.readyToDisplay) {
        retain.add(tile);
        return true;
      } else if (tile.loadFinishedAt != null) {
        retain.add(tile);
      }
    }

    if (z2 > minZoom) {
      return _retainAncestor(retain, x2, y2, z2, minZoom);
    }

    return false;
  }

  /// Recurse through the descendants of the Tile at the given coordinates
  /// adding them to [retain] if they are ready to display or loaded.
  void _retainChildren(
    Set<VectorTileData> retain,
    int x,
    int y,
    int z,
    int maxZoom,
  ) {
    for (final (i, j) in const [(0, 0), (0, 1), (1, 0), (1, 1)]) {
      final coords = TileCoordinates(2 * x + i, 2 * y + j, z + 1);

      final tile = _tiles[coords];
      if (tile != null) {
        if (tile.readyToDisplay || tile.loadFinishedAt != null) {
          retain.add(tile);

          // If have the child, we do not recurse. We don't need the child's children.
          continue;
        }
      }

      if (z + 1 < maxZoom) {
        _retainChildren(retain, i, j, z + 1, maxZoom);
      }
    }
  }
}
