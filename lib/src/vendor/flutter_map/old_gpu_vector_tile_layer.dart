// import 'dart:async';
// import 'dart:math';

// import 'package:collection/collection.dart' show MapEquality;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart';
// import 'package:http/retry.dart';
// import 'package:flutter_gpu/gpu.dart' as gpu;
// import 'package:maplibre_flutter_gpu/src/components/isolate/isolates.dart';
// import 'package:maplibre_flutter_gpu/src/components/model/source_resolver_function.dart';
// import 'package:maplibre_flutter_gpu/src/components/model/style_source_function.dart';
// import 'package:maplibre_flutter_gpu/src/components/model/tiled_source.dart';
// import 'package:maplibre_flutter_gpu/src/model/vector_tile_provider.dart';
// import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_bounds/tile_bounds.dart';
// import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_bounds/tile_bounds_at_zoom.dart';
// import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_model.dart';
// import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_painter.dart';
// import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_range.dart';
// import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_range_calculator.dart';
// import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_scale_calculator.dart';
// import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/vector_tile_data.dart';
// import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/vector_tile_data_manager.dart';

// import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

// typedef VectorErrorTileCallBack = void Function(
//   VectorTileData tile,
//   Object error,
//   StackTrace? stackTrace,
// );

// @immutable
// class GpuVectorTileLayer extends StatefulWidget {
//   GpuVectorTileLayer({
//     super.key,
//     required this.styleSource,
//     this.sourceResolver = defaultSourceResolver,
//     this.tileResolver = defaultTileResolver,
//     this.tileSize = 256.0,
//     this.evictErrorTileStrategy = EvictErrorTileStrategy.none,
//     TileUpdateTransformer? tileUpdateTransformer,
//     this.reset,
//     this.tileBounds,
//     this.minZoom = 0.0,
//     this.maxZoom = double.infinity,
//     this.tileDisplay = const TileDisplay.fadeIn(),
//     this.keepBuffer = 2,
//     this.panBuffer = 1,
//     this.minNativeZoom = 0,
//     this.maxNativeZoom = 19,
//     this.errorTileCallback,
//     this.zoomOffset = 0.0,
//   }) : tileUpdateTransformer = tileUpdateTransformer ?? TileUpdateTransformers.ignoreTapEvents;

//   final StyleSourceFunction styleSource;
//   final SourceResolverFunction sourceResolver;
//   final TileResolverFunction tileResolver;
//   final double tileSize;
//   final EvictErrorTileStrategy evictErrorTileStrategy;
//   final TileUpdateTransformer tileUpdateTransformer;
//   final Stream<void>? reset;
//   final LatLngBounds? tileBounds;
//   final double minZoom;
//   final double maxZoom;
//   final int minNativeZoom;
//   final int maxNativeZoom;
//   final double zoomOffset;
//   final TileDisplay tileDisplay;
//   final int panBuffer;
//   final int keepBuffer;
//   final VectorErrorTileCallBack? errorTileCallback;

//   @override
//   State<StatefulWidget> createState() => GpuVectorTileLayerState();
// }

// class GpuVectorTileLayerState extends State<GpuVectorTileLayer> with TickerProviderStateMixin {
//   bool _initializedFromMapCamera = false;

//   late final VectorTileDataManager _vectorTileDataManager;
//   late TileBounds _tileBounds;
//   late var _tileRangeCalculator = TileRangeCalculator(tileSize: widget.tileSize);
//   late TileScaleCalculator _tileScaleCalculator;

//   // We have to hold on to the mapController hashCode to determine whether we
//   // need to reinitialize the listeners. didChangeDependencies is called on
//   // every map movement and if we unsubscribe and resubscribe every time we
//   // miss events.
//   int? _mapControllerHashCode;

//   StreamSubscription<TileUpdateEvent>? _tileUpdateSubscription;
//   Timer? _pruneLater;

//   gpu.Texture? renderTexture;
//   gpu.Texture? resolveTexture;

//   late final _resetSub = widget.reset?.listen((_) {
//     _vectorTileDataManager.removeAll(widget.evictErrorTileStrategy);
//     if (mounted) _loadAndPruneInVisibleBounds(MapCamera.of(context));
//   });

//   @override
//   void initState() {
//     super.initState();

//     // TODO
//     Isolates.instance.spawn();

//     _vectorTileDataManager = VectorTileDataManager(
//       styleSource: widget.styleSource,
//       sourceResolver: widget.sourceResolver,
//       tileResolver: widget.tileResolver,
//       onStyleLoaded: () {
//         if (mounted) _loadAndPruneInVisibleBounds(MapCamera.of(context));
//       },
//     );
//   }

//   // This is called on every map movement so we should avoid expensive logic
//   // where possible, or filter as necessary
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final camera = MapCamera.of(context);
//     final mapController = MapController.of(context);

//     if (_mapControllerHashCode != mapController.hashCode) {
//       _tileUpdateSubscription?.cancel();

//       _mapControllerHashCode = mapController.hashCode;
//       _tileUpdateSubscription = mapController.mapEventStream
//           .map((mapEvent) => TileUpdateEvent(mapEvent: mapEvent))
//           .transform(widget.tileUpdateTransformer)
//           .listen(_onTileUpdateEvent);
//     }

//     var reloadTiles = false;
//     if (!_initializedFromMapCamera || _tileBounds.shouldReplace(camera.crs, widget.tileSize, widget.tileBounds)) {
//       reloadTiles = true;
//       _tileBounds = TileBounds(
//         crs: camera.crs,
//         tileSize: widget.tileSize,
//         latLngBounds: widget.tileBounds,
//       );
//     }

//     if (!_initializedFromMapCamera || _tileScaleCalculator.shouldReplace(camera.crs, widget.tileSize)) {
//       reloadTiles = true;
//       _tileScaleCalculator = TileScaleCalculator(
//         crs: camera.crs,
//         tileSize: widget.tileSize,
//       );
//     }

//     if (reloadTiles) _loadAndPruneInVisibleBounds(camera);

//     _initializedFromMapCamera = true;
//   }

//   @override
//   void didUpdateWidget(GpuVectorTileLayer oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     var reloadTiles = false;

//     // There is no caching in TileRangeCalculator so we can just replace it.
//     _tileRangeCalculator = TileRangeCalculator(tileSize: widget.tileSize);

//     if (_tileBounds.shouldReplace(_tileBounds.crs, widget.tileSize, widget.tileBounds)) {
//       _tileBounds = TileBounds(
//         crs: _tileBounds.crs,
//         tileSize: widget.tileSize,
//         latLngBounds: widget.tileBounds,
//       );
//       reloadTiles = true;
//     }

//     if (_tileScaleCalculator.shouldReplace(_tileScaleCalculator.crs, widget.tileSize)) {
//       _tileScaleCalculator = TileScaleCalculator(
//         crs: _tileScaleCalculator.crs,
//         tileSize: widget.tileSize,
//       );
//     }

//     if (oldWidget.minZoom != widget.minZoom || oldWidget.maxZoom != widget.maxZoom) {
//       reloadTiles |= !_vectorTileDataManager.allWithinZoom(widget.minZoom, widget.maxZoom);
//     }

//     if (!reloadTiles) {
//       // TODO: Reload style...
//       // final oldUrl = oldWidget.wmsOptions?._encodedBaseUrl ?? oldWidget.urlTemplate;
//       // final newUrl = widget.wmsOptions?._encodedBaseUrl ?? widget.urlTemplate;

//       // final oldOptions = oldWidget.additionalOptions;
//       // final newOptions = widget.additionalOptions;

//       // if (oldUrl != newUrl || !(const MapEquality<String, String>()).equals(oldOptions, newOptions)) {
//       //   _vectorTileDataManager.reloadTiles(widget, _tileBounds);
//       // }
//     }

//     if (reloadTiles) {
//       _vectorTileDataManager.removeAll(widget.evictErrorTileStrategy);
//       _loadAndPruneInVisibleBounds(MapCamera.maybeOf(context)!);
//     } else if (oldWidget.tileDisplay != widget.tileDisplay) {
//       _vectorTileDataManager.updateTileDisplay(widget.tileDisplay);
//     }
//   }

//   @override
//   void dispose() {
//     _tileUpdateSubscription?.cancel();
//     _vectorTileDataManager.removeAll(widget.evictErrorTileStrategy);
//     _resetSub?.cancel();
//     _pruneLater?.cancel();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final map = MapCamera.of(context);

//     if (_outsideZoomLimits(map.zoom.round())) return const SizedBox.shrink();

//     final tileZoom = _clampToNativeZoom(map.zoom);
//     final tileBoundsAtZoom = _tileBounds.atZoom(tileZoom);
//     final visibleTileRange = _tileRangeCalculator.calculate(
//       camera: map,
//       tileZoom: tileZoom,
//     );

//     // For a given map event both this rebuild method and the tile
//     // loading/pruning logic will be fired. Any TileImages which are not
//     // rendered in a corresponding Tile after this build will not become
//     // visible until the next build. Therefore, in case this build is executed
//     // before the loading/updating, we must pre-create the missing TileImages
//     // and add them to the widget tree so that when they are loaded they notify
//     // the Tile and become visible. We don't need to prune here as any new tiles
//     // will be pruned when the map event triggers tile loading.
//     _vectorTileDataManager.createMissingTiles(
//       visibleTileRange,
//       tileBoundsAtZoom,
//       (coordinates, provider) => _createTileData(
//         coordinates: coordinates,
//         provider: provider,
//         tileBoundsAtZoom: tileBoundsAtZoom,
//         pruneAfterLoad: false,
//       ),
//     );

//     _tileScaleCalculator.clearCacheUnlessZoomMatches(map.zoom);

//     // Note: `renderTiles` filters out all tiles that are either off-screen or
//     // tiles at non-target zoom levels that are would be completely covered by
//     // tiles that are *ready* and at the target zoom level.
//     // We're happy to do a bit of diligent work here, since tiles not rendered are
//     // cycles saved later on in the render pipeline.
//     final tiles = _vectorTileDataManager
//         .getTilesToRender(visibleRange: visibleTileRange)
//         .map(
//           (tile) => VectorTileModel(
//             scaledTileSize: _tileScaleCalculator.scaledTileSize(
//               map.zoom,
//               tile.coordinates.z,
//             ),
//             zoom: map.zoom,
//             currentPixelOrigin: map.pixelOrigin,
//             tile: tile,
//           ),
//         )
//         .toList();

//     /// Sort in render order. In reverse:
//     ///   1. Tiles at the current zoom.
//     ///   2. Tiles at the current zoom +/- 1.
//     ///   3. Tiles at the current zoom +/- 2.
//     ///   4. ...etc
//     int renderOrder(VectorTileModel a, VectorTileModel b) {
//       final (za, zb) = (a.tile.coordinates.z, b.tile.coordinates.z);
//       final cmp = (zb - tileZoom).abs().compareTo((za - tileZoom).abs());
//       if (cmp == 0) {
//         // When compare parent/child tiles of equal distance, prefer higher res images.
//         return za.compareTo(zb);
//       }
//       return cmp;
//     }

//     final pixelRatio = MediaQuery.devicePixelRatioOf(context);
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final textureWidth = (constraints.maxWidth * pixelRatio).ceil() * 2;
//         final textureHeight = (constraints.maxHeight * pixelRatio).ceil() * 2;

//         if (renderTexture == null || renderTexture?.width != textureWidth || renderTexture?.height != textureHeight) {
//           renderTexture = gpu.gpuContext.createTexture(
//             gpu.StorageMode.devicePrivate,
//             textureWidth,
//             textureHeight,
//             sampleCount: 4,
//           )!;

//           resolveTexture = gpu.gpuContext.createTexture(
//             gpu.StorageMode.devicePrivate,
//             textureWidth,
//             textureHeight,
//             sampleCount: 1,
//           )!;
//         }

//         return MobileLayerTransformer(
//           child: CustomPaint(
//             size: Size.infinite,
//             willChange: true,
//             painter: GpuVectorTilePainter(
//               pixelRatio: pixelRatio,
//               renderTexture: renderTexture!,
//               resolveTexture: resolveTexture,
//               tiles: tiles..sort(renderOrder),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   VectorTileData _createTileData({
//     required TileCoordinates coordinates,
//     required VectorTileProvider provider,
//     required TileBoundsAtZoom tileBoundsAtZoom,
//     required bool pruneAfterLoad,
//   }) {
//     final cancelLoading = Completer<void>();

//     return VectorTileData(
//       vsync: this,
//       coordinates: coordinates,
//       provider: provider,
//       onLoadError: _onTileLoadError,
//       onLoadComplete: (coordinates) {
//         if (pruneAfterLoad) _pruneIfAllTilesLoaded(coordinates);
//       },
//       tileDisplay: widget.tileDisplay,
//       cancelLoading: cancelLoading,
//     );
//   }

//   /// Load and/or prune tiles according to the visible bounds of the [event]
//   /// center/zoom, or the current center/zoom if not specified.
//   void _onTileUpdateEvent(TileUpdateEvent event) {
//     final tileZoom = _clampToNativeZoom(event.zoom);
//     final visibleTileRange = _tileRangeCalculator.calculate(
//       camera: event.camera,
//       tileZoom: tileZoom,
//       center: event.center,
//       viewingZoom: event.zoom,
//     );

//     if (event.load && !_outsideZoomLimits(tileZoom)) {
//       _loadTiles(visibleTileRange, pruneAfterLoad: event.prune);
//     }

//     if (event.prune) {
//       _vectorTileDataManager.evictAndPrune(
//         visibleRange: visibleTileRange,
//         pruneBuffer: widget.panBuffer + widget.keepBuffer,
//         evictStrategy: widget.evictErrorTileStrategy,
//       );
//     }
//   }

//   /// Load new tiles in the visible bounds and prune those outside.
//   void _loadAndPruneInVisibleBounds(MapCamera camera) {
//     final tileZoom = _clampToNativeZoom(camera.zoom);
//     final visibleTileRange = _tileRangeCalculator.calculate(
//       camera: camera,
//       tileZoom: tileZoom,
//     );

//     if (!_outsideZoomLimits(tileZoom)) {
//       _loadTiles(
//         visibleTileRange,
//         pruneAfterLoad: true,
//       );
//     }

//     _vectorTileDataManager.evictAndPrune(
//       visibleRange: visibleTileRange,
//       pruneBuffer: max(widget.panBuffer, widget.keepBuffer),
//       evictStrategy: widget.evictErrorTileStrategy,
//     );
//   }

//   // For all valid TileCoordinates in the [tileLoadRange], expanded by the
//   // [TileLayer.panBuffer], this method will do the following depending on
//   // whether a matching TileImage already exists or not:
//   //   * Exists: Mark it as current and initiate image loading if it has not
//   //     already been initiated.
//   //   * Does not exist: Creates the TileImage (they are current when created)
//   //     and initiates loading.
//   //
//   // Additionally, any current TileImages outside of the [tileLoadRange],
//   // expanded by the [TileLayer.panBuffer] + [TileLayer.keepBuffer], are marked
//   // as not current.
//   void _loadTiles(
//     DiscreteTileRange tileLoadRange, {
//     required bool pruneAfterLoad,
//   }) {
//     final tileZoom = tileLoadRange.zoom;
//     final expandedTileLoadRange = tileLoadRange.expand(widget.panBuffer);

//     // Build the queue of tiles to load. Marks all tiles with valid coordinates
//     // in the tileLoadRange as current.
//     final tileBoundsAtZoom = _tileBounds.atZoom(tileZoom);
//     final tilesToLoad = _vectorTileDataManager.createMissingTiles(
//       expandedTileLoadRange,
//       tileBoundsAtZoom,
//       (coordinates, provider) => _createTileData(
//         coordinates: coordinates,
//         provider: provider,
//         tileBoundsAtZoom: tileBoundsAtZoom,
//         pruneAfterLoad: pruneAfterLoad,
//       ),
//     );

//     // Re-order the tiles by their distance to the center of the range.
//     final tileCenter = expandedTileLoadRange.center;
//     tilesToLoad.sort(
//       (a, b) => _distanceSq(a.coordinates, tileCenter).compareTo(_distanceSq(b.coordinates, tileCenter)),
//     );

//     // Create the new Tiles.
//     for (final tile in tilesToLoad) {
//       tile.load();
//     }
//   }

//   /// Rounds the zoom to the nearest int and clamps it to the native zoom limits
//   /// if there are any.
//   int _clampToNativeZoom(double zoom) => zoom.round().clamp(widget.minNativeZoom, widget.maxNativeZoom);

//   void _onTileLoadError(VectorTileData tile, Object error, StackTrace? stackTrace) {
//     debugPrint(error.toString());
//     widget.errorTileCallback?.call(tile, error, stackTrace);
//   }

//   void _pruneIfAllTilesLoaded(TileCoordinates coordinates) {
//     if (!_vectorTileDataManager.containsTileAt(coordinates) || !_vectorTileDataManager.allLoaded) {
//       return;
//     }

//     widget.tileDisplay.when(instantaneous: (_) {
//       _pruneWithCurrentCamera();
//     }, fadeIn: (fadeIn) {
//       // Wait a bit more than tileFadeInDuration to trigger a pruning so that
//       // we don't see tile removal under a fading tile.
//       _pruneLater?.cancel();
//       _pruneLater = Timer(
//         fadeIn.duration + const Duration(milliseconds: 50),
//         _pruneWithCurrentCamera,
//       );
//     });
//   }

//   void _pruneWithCurrentCamera() {
//     final camera = MapCamera.of(context);
//     final visibleTileRange = _tileRangeCalculator.calculate(
//       camera: camera,
//       tileZoom: _clampToNativeZoom(camera.zoom),
//       center: camera.center,
//       viewingZoom: camera.zoom,
//     );
//     _vectorTileDataManager.prune(
//       visibleRange: visibleTileRange,
//       pruneBuffer: max(widget.panBuffer, widget.keepBuffer),
//       evictStrategy: widget.evictErrorTileStrategy,
//     );
//   }

//   bool _outsideZoomLimits(num zoom) => zoom < widget.minZoom || zoom > widget.maxZoom;
// }

// double _distanceSq(TileCoordinates coord, Point<double> center) {
//   final dx = center.x - coord.x;
//   final dy = center.y - coord.y;
//   return dx * dx + dy * dy;
// }
