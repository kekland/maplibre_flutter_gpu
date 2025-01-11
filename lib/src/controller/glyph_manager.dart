import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;
import 'package:maplibre_flutter_gpu/src/glyphs/glyphs.pb.dart' as pb;

class GlyphManager {
  const GlyphManager({required this.style});

  final spec.Style style;

  LoadedGlyph? loadGlyph(String fontStack, String codePoint) {
    codePoint.codeUnits;
  }
}

class LoadedGlyph {
  LoadedGlyph({required this.glyph});

  final pb.glyph glyph;
}
