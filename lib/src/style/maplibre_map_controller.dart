import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:maplibre_flutter_gpu/src/style/source.dart';
import 'package:maplibre_flutter_gpu/src/style/sprite.dart';
import 'package:maplibre_flutter_gpu/src/style/style_source.dart';
import 'package:maplibre_flutter_gpu/src/style/tile.dart';
import 'package:maplibre_flutter_gpu/src/utils/extensions.dart';
import 'package:maplibre_flutter_gpu/src/widgets/layers/background_layer.dart';
import 'package:maplibre_flutter_gpu/src/widgets/layers/fill_layer.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

const _supportedSources = {
  spec.SourceVector,
};

const _supportedLayers = {
  spec.Layer$Type.background,
  spec.Layer$Type.fill,
};

class MapLibreMapController with ChangeNotifier {
  MapLibreMapController({
    required this.styleSource,
    this.spriteSourceResolver = defaultSpriteSourceResolver,
    this.sourceResolver = defaultSourceResolver,
    this.tileResolver = defaultTileResolver,
    this.isHighDpi = false,
    this.tileSize = 256.0,
  });

  final double tileSize;
  final StyleSourceFunction styleSource;
  final SpriteSourceResolver spriteSourceResolver;
  final SourceResolver sourceResolver;
  final TileResolver tileResolver;
  final bool isHighDpi;

  /// Whether the style has been loaded and is ready to be used.
  bool get isLoaded => _isLoaded;
  var _isLoaded = false;

  /// Whether the style is currently being loaded.
  bool get isLoading => _isLoading;
  var _isLoading = false;

  /// The error that occurred while loading the style, if any.
  Object? get error => _error;
  Object? _error;

  /// Returns the style object.
  ///
  /// This must not be called before the style has been loaded.
  spec.Style get style {
    assert(_style != null, 'Style is not loaded yet');
    return _style!;
  }

  spec.Style? _style;

  /// A list of resolved sprite sources for this style.
  final resolvedSpriteSources = <ResolvedSpriteSource>[];

  /// A list of resolved sources for this style.
  final resolvedSources = <Object, spec.Source>{};
  final _resolvedTiledSources = <Object, TiledSource>{};

  /// Loads the style.
  ///
  /// If the style is currently being loaded, this method does nothing.
  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _isLoaded = false;
    _error = null;
    notifyListeners();

    try {
      await _load();
      _isLoaded = true;
    } catch (e) {
      _error = e;
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _load() async {
    // Load and parse the style
    _style = await styleSource();

    await Future.wait([
      if (style.sprite != null) _loadSprite(style.sprite!),
      _loadSources(),
    ]);
  }

  Future<void> _loadSprite(spec.Sprite sprite) async {
    await Future.wait(sprite.sources.map((source) async {
      resolvedSpriteSources.add(await spriteSourceResolver(source, isHighDpi: isHighDpi));
    }));
  }

  Future<void> _loadSources() {
    return Future.wait(
      style.sources.entries.where((entry) => _supportedSources.contains(entry.value.runtimeType)).map((entry) async {
        final source = await sourceResolver(entry.value);
        resolvedSources[entry.key] = source;

        if (source.isTiled) {
          final tiledSource = source.createTiledSource(tileResolver);

          tiledSource.addListener(notifyListeners);
          _resolvedTiledSources[entry.key] = tiledSource;
        }

        notifyListeners();
      }),
    );
  }

  @override
  void dispose() {
    for (final context in resolvedSpriteSources) {
      context.dispose();
    }

    for (final source in _resolvedTiledSources.values) {
      source.dispose();
    }

    super.dispose();
  }

  Iterable<Widget> buildLayers(BuildContext context) {
    final layers = style.layers.where((l) => _supportedLayers.contains(l.type));

    return layers.map((layer) {
      return switch (layer.type) {
        spec.Layer$Type.background => BackgroundLayer(
            layer: spec.LayerBackground(layer),
          ),
        spec.Layer$Type.fill => FillLayer(
            layer: spec.LayerFill(layer),
            tiledSource: _resolvedTiledSources[layer.source] as VectorTiledSource?,
            source: resolvedSources[layer.source]! as spec.SourceVector,
          ),
        _ => throw UnimplementedError('Unsupported layer type: ${layer.type}'),
      };
    });
  }
}
