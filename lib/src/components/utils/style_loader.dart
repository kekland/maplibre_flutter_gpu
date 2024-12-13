// import 'package:maplibre_flutter_gpu/src/components/model/loaded_style.dart';
// import 'package:maplibre_flutter_gpu/src/components/model/source_resolver_function.dart';
// import 'package:maplibre_flutter_gpu/src/components/model/sprite_source_resolver_function.dart';
// import 'package:maplibre_flutter_gpu/src/components/model/style_source_function.dart';
// import 'package:maplibre_flutter_gpu/src/components/model/tiled_source.dart';
// import 'package:maplibre_flutter_gpu/src/utils/extensions.dart';
// import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

// Future<LoadedStyle> loadStyle({
//   required StyleSourceFunction styleSource,
//   required SourceResolverFunction sourceResolver,
//   required TileResolverFunction tileResolver,
//   required Set<Type> supportedSources,
// }) async {
//   final style = await styleSource();
//   final sources = await _loadSources(
//     sourceResolver,
//     style.sources,
//     tileResolver,
//     supportedSources,
//   );

//   return LoadedStyle(
//     style: style,
//     resolvedTiledSources: sources,
//   );
// }

// Future<Map<Object, TiledSource>> _loadSources(
//   SourceResolverFunction resolver,
//   Map<Object, spec.Source> sources,
//   TileResolverFunction tileResolver,
//   Set<Type> supportedSources,
// ) async {
//   final resolvedSources = <Object, TiledSource>{};

//   await Future.wait(
//     sources.entries.where((entry) => supportedSources.contains(entry.value.runtimeType)).map((entry) async {
//       final source = await resolver(entry.value);

//       if (source.isTiled) {
//         final tiledSource = source.createTiledSource(tileResolver);
//         resolvedSources[entry.key] = tiledSource;
//       }
//     }),
//   );

//   return resolvedSources;
// }
