import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'dart:ui' as ui;
import 'package:maplibre_flutter_gpu/src/glyphs/glyphs.pb.dart' as pb;

/// A class to manage a texture atlas.
///
/// - [TKey] refers to the key type used to index elements in the atlas.
/// - [TMetrics] refers to the metrics type used to store the metrics of an element in the atlas.
///
/// By default, this class provides no implementation for the actual texture atlas. See:
/// - [SpriteTextureAtlas] for an implementation that is used to manage sprite atlases.
/// - [GlyphTextureAtlas] for an implementation that is used to manage glyph atlases.
abstract class TextureAtlas<TKey, TMetrics> {
  final _metrics = <TKey, TMetrics>{};

  gpu.Texture? texture;

  TMetrics? get(TKey key) {
    return _metrics[key];
  }
}

class SpriteTextureAtlas extends TextureAtlas<String, spec.SpriteData> {
  Future<void> initializeFromIndex(
    spec.SpriteIndex index,
    ui.Image pngAtlas,
  ) async {
    final atlasByteData = await pngAtlas.toByteData();

    texture = gpu.gpuContext.createTexture(
      gpu.StorageMode.hostVisible,
      pngAtlas.width,
      pngAtlas.height,
      format: gpu.PixelFormat.r8g8b8a8UNormInt,
      coordinateSystem: gpu.TextureCoordinateSystem.uploadFromHost,
    );

    texture!.overwrite(atlasByteData!);

    for (final entry in index.sprites.entries) {
      final key = entry.key;
      final sprite = entry.value;

      _metrics[key] = sprite;
    }
  }
}

class GlyphTextureAtlas extends TextureAtlas<int, pb.glyph> {
  GlyphTextureAtlas({int baseTextureSize = 1024}) {
    texture = gpu.gpuContext.createTexture(
      gpu.StorageMode.hostVisible,
      baseTextureSize,
      baseTextureSize,
      format: gpu.PixelFormat.r8UNormInt,
      coordinateSystem: gpu.TextureCoordinateSystem.uploadFromHost,
    );
  }

  final _byteData = ByteData(1024 * 1024);

  int _cursorX = 0;
  int _cursorY = 0;
  int _currentRowHeight = 0;

  void addGlyph(pb.glyph glyph) {
    final key = glyph.id;
    final metrics = glyph;

    _metrics[key] = metrics;

    final width = metrics.width;
    final height = metrics.height;

    if (_cursorX + width > texture!.width) {
      _cursorX = 0;
      _cursorY += _currentRowHeight;
      _currentRowHeight = 0;
    }

    // TODO: Expand texture if needed
    if (_cursorY + height > texture!.height) {
      throw Exception('Texture atlas overflow');
    }

    final glyphData = glyph.bitmap;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final index = (_cursorY + y) * texture!.width + _cursorX + x;
        final value = glyphData[y * width + x];

        _byteData.setUint8(index, value);
      }
    }

    _cursorX += width;
    _currentRowHeight = max(_currentRowHeight, height);
  }

  void flush() {
    texture!.overwrite(_byteData);
  }
}
