import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:maplibre_flutter_gpu/src/components/model/source_resolver_function.dart';
import 'package:maplibre_flutter_gpu/src/components/model/sprite_source_resolver_function.dart';
import 'package:maplibre_flutter_gpu/src/components/model/style_source_function.dart';
import 'package:maplibre_flutter_gpu/src/components/model/tiled_source.dart';
import 'package:maplibre_flutter_gpu/src/controller/source.dart';
import 'package:maplibre_flutter_gpu/src/controller/texture_atlas.dart';
import 'package:maplibre_flutter_gpu/src/renderer/renderer.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_bounds/tile_bounds.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_range_calculator.dart';
import 'package:maplibre_flutter_gpu/src/vendor/flutter_map/tile_scale_calculator.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:maplibre_flutter_gpu/src/vector_tile/_vector_tile.dart' as vt;

final _logger = Logger('StyleController');

class StyleController extends ChangeNotifier {
  StyleController({
    required this.styleSource,
    this.sourceResolver = defaultSourceResolver,
    this.spriteSourceResolver = defaultSpriteSourceResolver,
    this.tileSize = 256.0,
  });

  final StyleSourceFunction styleSource;
  final SourceResolverFunction sourceResolver;
  final SpriteSourceResolverFunction spriteSourceResolver;
  final double tileSize;

  final orchestrator = RenderOrchestrator();

  spec.Style? _style;
  Map<Object, Source>? _sources;

  bool _isStyleLoaded = false;
  Future<void> load() async {
    _isStyleLoaded = false;
    _logger.finest('Loading style');

    _style = await styleSource();
    await _loadSources();

    orchestrator.initializeFromStyle(_style!, _sources!);
    await _loadSprites();

    _isStyleLoaded = true;
    _logger.finest('Style loaded: ${_sources!.length} sources');

    if (_lastCamera != null) {
      onCameraChanged(_lastCamera!);
    }

    notifyListeners();
  }

  Future<void> _loadSources() async {
    final resolvedSources = <Object, spec.Source>{};
    _sources = {};

    await Future.wait(
      _style!.sources.entries.map((entry) async {
        final source = await sourceResolver(entry.value);
        resolvedSources[entry.key] = source;

        if (source is spec.SourceVector && source.tiles != null) {
          _sources![entry.key] = VectorTiledSource(
            key: entry.key,
            specSource: source,
          );
        }
      }),
    );

    _style = _style!.copyWith(sources: resolvedSources);
  }

  Future<void> _loadSprites() async {
    final sprite = _style!.sprite;
    if (sprite == null) return;

    final resolvedSprites = await Future.wait(sprite.sources.map(spriteSourceResolver));

    for (final resolved in resolvedSprites) {
      final atlas = SpriteTextureAtlas();
      await atlas.initializeFromIndex(resolved.index, resolved.image);

      orchestrator.spriteAtlases[resolved.id] = atlas;
    }
  }

  fm.MapCamera? _lastCamera;
  void onCameraChanged(fm.MapCamera camera) {
    _lastCamera = camera;

    if (!_isStyleLoaded) return;

    for (final source in _sources!.values) {
      if (source is TiledSource) {
        source.onCameraChanged(camera, tileSize);
      }
    }
  }

  @override
  void dispose() {
    orchestrator.dispose();

    for (final source in _sources!.values) {
      source.dispose();
    }

    super.dispose();
  }
}
