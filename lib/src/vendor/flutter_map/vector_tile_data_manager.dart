import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/components/model/source_resolver_function.dart';
import 'package:maplibre_flutter_gpu/src/components/model/style_source_function.dart';
import 'package:maplibre_flutter_gpu/src/components/model/tiled_source.dart';
import 'package:maplibre_flutter_gpu/src/model/vector_tile_provider.dart';
import 'package:maplibre_flutter_gpu/src/utils/extensions.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/gpu_vector_tile_layer.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_bounds/tile_bounds.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_bounds/tile_bounds_at_zoom.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_range.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/vector_tile_data.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/vector_tile_data_view.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

/// The [VectorTileDataManager] orchestrates the loading and pruning of tiles.
class VectorTileDataManager {
  VectorTileDataManager({
    required this.styleSource,
    required this.sourceResolver,
    required this.tileResolver,
    required this.onStyleLoaded,
    this.zoomOffset = 0,
  }) {
    load();
  }

  final StyleSourceFunction styleSource;
  final SourceResolverFunction sourceResolver;
  final TileResolverFunction tileResolver;
  final VoidCallback onStyleLoaded;
  final double zoomOffset;

  spec.Style? style;
  List<TiledSource>? tiledSources;
  final Map<TileCoordinates, VectorTileData> _tiles = HashMap<TileCoordinates, VectorTileData>();

  /// Check if the [VectorTileDataManager] has the tile for a given tile cooridantes.
  bool containsTileAt(TileCoordinates coordinates) => _tiles.containsKey(coordinates);

  /// Check if all tile images are loaded
  bool get allLoaded => _tiles.values.none((tile) => tile.loadFinishedAt == null);

  bool _isStyleLoaded = false;
  Future<void> load() async {
    _isStyleLoaded = false;
    removeAll(EvictErrorTileStrategy.dispose);

    style = await styleSource();
    await _loadSources();

    _isStyleLoaded = true;
    onStyleLoaded();
  }

  Future<void> _loadSources() async {
    final resolvedSources = <Object, spec.Source>{};

    await Future.wait(
      style!.sources.entries.map((entry) async {
        final source = await sourceResolver(entry.value);
        resolvedSources[entry.key] = source;

        if (source.isTiled) {
          final tiledSource = source.createTiledSource(entry.key, tileResolver);

          tiledSources ??= [];
          tiledSources!.add(tiledSource);
        }
      }),
    );

    style = style!.copyWith(sources: resolvedSources);
  }

  /// Filter tiles to only tiles that would be visible on screen. Specifically:
  ///   1. Tiles in the visible range at the target zoom level.
  ///   2. Tiles at non-target zoom level that would cover up holes that would
  ///      be left by tiles in #1, which are not ready yet.
  Iterable<VectorTileData> getTilesToRender({
    required DiscreteTileRange visibleRange,
  }) =>
      VectorTileDataView(
        tiles: _tiles,
        visibleRange: visibleRange,
        // `keepRange` is irrelevant here since we're not using the output for
        // pruning storage but rather to decide on what to put on screen.
        keepRange: visibleRange,
      ).renderTiles;

  /// Check if all loaded tiles are within the [minZoom] and [maxZoom] level.
  bool allWithinZoom(double minZoom, double maxZoom) =>
      _tiles.values.map((e) => e.coordinates).every((coord) => coord.z > maxZoom || coord.z < minZoom);

  /// Creates missing [VectorTileData]s within the provided tile range. Returns a
  /// list of [VectorTileData]s which haven't started loading yet.
  List<VectorTileData> createMissingTiles(
    DiscreteTileRange tileRange,
    TileBoundsAtZoom tileBoundsAtZoom,
    VectorTileData Function(
      TileCoordinates coordinates,
      VectorTileProvider provider,
    ) createTile,
  ) {
    if (!_isStyleLoaded) return [];

    final notLoaded = <VectorTileData>[];

    for (final coordinates in tileBoundsAtZoom.validCoordinatesIn(tileRange)) {
      final provider = VectorTileProvider(
        coordinates: coordinates,
        zoomOffset: zoomOffset,
        style: style!,
        sources: tiledSources!.whereType<VectorTiledSource>().where((v) => v.containsCoordinates(coordinates)).toList(),
      );

      final tile = _tiles[coordinates] ??= createTile(coordinates, provider);
      if (tile.loadStarted == null) {
        notLoaded.add(tile);
      }
    }

    return notLoaded;
  }

  /// Set the new [TileDisplay] for all [_tiles].
  void updateTileDisplay(TileDisplay tileDisplay) {
    for (final tile in _tiles.values) {
      tile.tileDisplay = tileDisplay;
    }
  }

  /// All removals should be performed by calling this method to ensure that
  /// disposal is performed correctly.
  void _remove(
    TileCoordinates key, {
    required bool Function(VectorTileData tileImage) evictImageFromCache,
  }) {
    final removed = _tiles.remove(key);

    if (removed != null) {
      removed.dispose(evictTileFromCache: evictImageFromCache(removed));
    }
  }

  void _removeWithEvictionStrategy(
    TileCoordinates key,
    EvictErrorTileStrategy strategy,
  ) {
    _remove(
      key,
      evictImageFromCache: (tileImage) => tileImage.loadError && strategy != EvictErrorTileStrategy.none,
    );
  }

  /// Remove all tiles with a given [EvictErrorTileStrategy].
  void removeAll(EvictErrorTileStrategy evictStrategy) {
    final keysToRemove = List<TileCoordinates>.from(_tiles.keys);

    for (final key in keysToRemove) {
      _removeWithEvictionStrategy(key, evictStrategy);
    }
  }

  /// Reload all tile images of a [TileLayer] for a given tile bounds.
  void reloadTiles(
    GpuVectorTileLayer layer,
    TileBounds tileBounds,
  ) {
    // If a VectorTileData's imageInfo is already available when load() is called it
    // will call its onLoadComplete callback synchronously which can trigger
    // pruning. Since pruning may cause removals from _tiles we must not
    // iterate _tiles directly otherwise a concurrent modification error may
    // occur. To avoid this we create a copy of the collection of tiles to
    // reload and iterate over that instead.
    final tilesToReload = List<VectorTileData>.from(_tiles.values);

    for (final tile in tilesToReload) {
      // TODO
      final provider = VectorTileProvider(
        coordinates: tile.coordinates,
        zoomOffset: zoomOffset,
        style: style!,
        sources:
            tiledSources!.whereType<VectorTiledSource>().where((v) => v.containsCoordinates(tile.coordinates)).toList(),
      );

      tile.provider = provider;
      tile.load();
    }
  }

  /// evict tiles that have an error and prune tiles that are no longer needed.
  void evictAndPrune({
    required DiscreteTileRange visibleRange,
    required int pruneBuffer,
    required EvictErrorTileStrategy evictStrategy,
  }) {
    final pruningState = VectorTileDataView(
      tiles: _tiles,
      visibleRange: visibleRange,
      keepRange: visibleRange.expand(pruneBuffer),
    );

    _evictErrorTiles(pruningState, evictStrategy);
    _prune(pruningState, evictStrategy);
  }

  void _evictErrorTiles(
    VectorTileDataView tileRemovalState,
    EvictErrorTileStrategy evictStrategy,
  ) {
    switch (evictStrategy) {
      case EvictErrorTileStrategy.notVisibleRespectMargin:
        for (final tileImage in tileRemovalState.errorTilesOutsideOfKeepMargin()) {
          _remove(tileImage.coordinates, evictImageFromCache: (_) => true);
        }
      case EvictErrorTileStrategy.notVisible:
        for (final tileImage in tileRemovalState.errorTilesNotVisible()) {
          _remove(tileImage.coordinates, evictImageFromCache: (_) => true);
        }
      case EvictErrorTileStrategy.dispose:
      case EvictErrorTileStrategy.none:
        return;
    }
  }

  /// Prune tiles from the [VectorTileDataManager].
  void prune({
    required DiscreteTileRange visibleRange,
    required int pruneBuffer,
    required EvictErrorTileStrategy evictStrategy,
  }) {
    _prune(
      VectorTileDataView(
        tiles: _tiles,
        visibleRange: visibleRange,
        keepRange: visibleRange.expand(pruneBuffer),
      ),
      evictStrategy,
    );
  }

  /// Prune tiles from the [VectorTileDataManager].
  void _prune(
    VectorTileDataView tileRemovalState,
    EvictErrorTileStrategy evictStrategy,
  ) {
    for (final tileImage in tileRemovalState.staleTiles) {
      _removeWithEvictionStrategy(tileImage.coordinates, evictStrategy);
    }
  }
}
