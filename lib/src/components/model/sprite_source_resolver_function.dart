// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui' as ui;
// import 'package:maplibre_flutter_gpu/src/components/utils/zoned_http_client.dart';
// import 'package:maplibre_flutter_gpu/src/utils/image_utils.dart';
// import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

// /// A function that provides a way to load a style object.
// ///
// /// For a default (network) implementation, see [defaultSpriteSourceResolver].
// typedef SpriteSourceResolverFunction = Future<ResolvedSpriteSource> Function(
//   spec.SpriteSource source, {
//   bool isHighDpi,
// });

// /// Uses `dart:http` to load a sprite source.
// Future<ResolvedSpriteSource> defaultSpriteSourceResolver(
//   spec.SpriteSource source, {
//   bool isHighDpi = false,
// }) async {
//   final [indexResponse, imageResponse] = await [
//     zonedHttpGet(source.getIndexUri(isHighDpi: isHighDpi)),
//     zonedHttpGet(source.getImageUri(isHighDpi: isHighDpi)),
//   ].wait;

//   final index = spec.SpriteIndex.fromJson(jsonDecode(indexResponse.body));
//   final image = await decodeImageFromListAsync(imageResponse.bodyBytes);

//   return ResolvedSpriteSource(
//     id: source.id,
//     index: index,
//     image: image,
//   );
// }

// class ResolvedSpriteSource {
//   const ResolvedSpriteSource({
//     this.id,
//     required this.index,
//     required this.image,
//   });

//   final String? id;
//   final spec.SpriteIndex index;
//   final ui.Image image;

//   void dispose() {
//     image.dispose();
//   }
// }
