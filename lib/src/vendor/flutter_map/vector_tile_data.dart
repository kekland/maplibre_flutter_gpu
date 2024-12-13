import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maplibre_flutter_gpu/src/components/rendering/drawable.dart';
import 'package:maplibre_flutter_gpu/src/model/vector_tile_provider.dart';
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;

class VectorTileData extends ChangeNotifier {
  bool _disposed = false;

  /// Controls fade-in opacity.
  AnimationController? _animationController;

  /// Whether the tile is displayable. See [readyToDisplay].
  bool _readyToDisplay = false;

  VectorTileProvider provider;

  /// Used by animationController. Still required if animation is disabled in
  /// case the tile display is changed at a later point.
  final TickerProvider vsync;

  /// The z of the coordinate is the TileImage's zoom level whilst the x and y
  /// indicate the position of the tile at that zoom level.
  final TileCoordinates coordinates;

  /// Callback fired when loading finishes with or withut an error. This
  /// callback is not triggered after this TileImage is disposed.
  final void Function(TileCoordinates coordinates) onLoadComplete;

  /// Callback fired when an error occurs whilst loading the tile image.
  /// [onLoadComplete] will be called immediately afterwards. This callback is
  /// not triggered after this TileImage is disposed.
  final void Function(VectorTileData tile, Object error, StackTrace? stackTrace) onLoadError;

  /// Options for how the tile image is displayed.
  TileDisplay _tileDisplay;

  /// Completer that is completed when this object is disposed
  ///
  /// Intended to allow [TileProvider]s to cancel unneccessary HTTP requests.
  final Completer<void> cancelLoading;

  /// True if an error occurred during loading.
  bool loadError = false;

  /// When loading started.
  DateTime? loadStarted;

  /// When loading finished.
  DateTime? loadFinishedAt;

  List<Drawable>? drawables;

  /// Create a new object for a tile image.
  VectorTileData({
    required this.provider,
    required this.vsync,
    required this.coordinates,
    required this.onLoadComplete,
    required this.onLoadError,
    required TileDisplay tileDisplay,
    required this.cancelLoading,
  })  : _tileDisplay = tileDisplay,
        _animationController = tileDisplay.when(
          instantaneous: (_) => null,
          fadeIn: (fadeIn) => AnimationController(
            vsync: vsync,
            duration: fadeIn.duration,
          ),
        );

  /// Get the current opacity value for the tile image.
  double get opacity => _tileDisplay.when(
        instantaneous: (instantaneous) => _readyToDisplay ? instantaneous.opacity : 0.0,
        fadeIn: (fadeIn) => _animationController!.value,
      )!;

  /// Getter for the tile [AnimationController]
  AnimationController? get animation => _animationController;

  /// Whether the tile is displayable. This means that either:
  ///   * Loading errored but an error image is configured.
  ///   * Loading succeeded and the fade animation has finished.
  ///   * Loading succeeded and there is no fade animation.
  ///
  /// Note that [opacity] can be less than 1 when this is true if instantaneous
  /// tile display is used with a maximum opacity less than 1.
  bool get readyToDisplay => _readyToDisplay;

  /// Change the tile display options.
  set tileDisplay(TileDisplay newTileDisplay) {
    final oldTileDisplay = _tileDisplay;
    _tileDisplay = newTileDisplay;

    // Handle disabling/enabling of animation controller if necessary
    oldTileDisplay.when(
      instantaneous: (instantaneous) {
        newTileDisplay.when(
          fadeIn: (fadeIn) {
            // Became animated.
            _animationController = AnimationController(
              duration: fadeIn.duration,
              vsync: vsync,
              value: _readyToDisplay ? 1.0 : 0.0,
            );
          },
        );
      },
      fadeIn: (fadeIn) {
        newTileDisplay.when(instantaneous: (instantaneous) {
          // No longer animated.
          _animationController!.dispose();
          _animationController = null;
        }, fadeIn: (fadeIn) {
          // Still animated with different fade.
          _animationController!.duration = fadeIn.duration;
        });
      },
    );

    if (!_disposed) notifyListeners();
  }

  /// Initiate loading of the tile.
  void load() async {
    if (cancelLoading.isCompleted) return;

    loadStarted = DateTime.now();

    try {
      drawables = await provider.load(cancelLoading);
      if (cancelLoading.isCompleted) return;

      _onTileLoadSuccess();
    } catch (e, s) {
      // Make sure all exceptions are handled - #444 / #536
      _onTileLoadError(e, s);
    }
  }

  void _onTileLoadSuccess() {
    loadError = false;

    if (!_disposed) {
      _display();
      onLoadComplete(coordinates);
    }
  }

  void _onTileLoadError(Object exception, StackTrace? stackTrace) {
    loadError = true;

    if (!_disposed) {
      onLoadError(this, exception, stackTrace);
      onLoadComplete(coordinates);
    }
  }

  // Initiates fading in and marks this TileImage as readyToDisplay when fading
  // finishes. If fading is disabled or a loading error occurred this TileImage
  // becomes readyToDisplay immediately.
  void _display() {
    final previouslyLoaded = loadFinishedAt != null;
    loadFinishedAt = DateTime.now();

    if (loadError) {
      _readyToDisplay = true;
      if (!_disposed) notifyListeners();
      return;
    }

    _tileDisplay.when(
      instantaneous: (_) {
        _readyToDisplay = true;
        if (!_disposed) notifyListeners();
      },
      fadeIn: (fadeIn) {
        final fadeStartOpacity = previouslyLoaded ? fadeIn.reloadStartOpacity : fadeIn.startOpacity;

        if (fadeStartOpacity == 1.0) {
          _readyToDisplay = true;
          if (!_disposed) notifyListeners();
        } else {
          _animationController!.reset();
          _animationController!.forward(from: fadeStartOpacity).then((_) {
            _readyToDisplay = true;
            if (!_disposed) notifyListeners();
          });
        }
      },
    );
  }

  @override
  void dispose({bool evictTileFromCache = false}) {
    assert(
      !_disposed,
      'The TileImage dispose() method was called multiple times',
    );
    _disposed = true;

    if (evictTileFromCache) {
      try {
        // TODO: Cache eviction
        // provider.evict();
      } catch (e) {
        // This may be never called because catchError will handle errors, however
        // we want to avoid random crashes like in #444 / #536
        debugPrint(e.toString());
      }
    }

    cancelLoading?.complete();

    _readyToDisplay = false;
    _animationController?.stop(canceled: false);
    _animationController?.value = 0.0;
    notifyListeners();

    _animationController?.dispose();
    super.dispose();
  }

  @override
  int get hashCode => coordinates.hashCode;

  @override
  bool operator ==(Object other) {
    return other is VectorTileData && coordinates == other.coordinates;
  }

  @override
  String toString() {
    return 'TileImage($coordinates, readyToDisplay: $_readyToDisplay)';
  }
}
