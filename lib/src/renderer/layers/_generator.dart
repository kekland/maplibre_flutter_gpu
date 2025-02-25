/// A template method used by `style_precompiler.dart` for generating the [setFeatureVertices] code for a
/// [FillLayerRenderer].
List<String> fillLayerRendererSetFeatureVerticesGenerator(List<String> vertexEval, List<String> vertexSetters) {
  return [
    'int setFeatureVertices(spec.EvaluationContext eval, vt.PolygonFeature feature, int index) {',
    '  final paint = specLayer.paint;',
    ...vertexEval.map((v) => '      $v'),
    '',
    '  for (final polygon in feature.polygons) {',
    '    for (final vertex in polygon.vertices) {',
    '      pipeline.vertex.setVertex(',
    '        index,',
    '        position: vertex.vec2,',
    ...vertexSetters.map((v) => '        $v,'),
    '      );',
    '      index += 1;',
    '    }',
    '  }',
    '',
    '  return index;',
    '}',
  ];
}

/// A template method used by `style_precompiler.dart` for generating the `setUniforms` code.
List<String> setUniformsGenerator(List<String> uniformEval, List<String> uniformSetters) {
  return [
    'void setUniforms(',
    '  RenderContext context,',
    '  Matrix4 cameraWorldToGl,',
    '  double cameraZoom,',
    '  double pixelRatio,',
    '  Matrix4 tileLocalToWorld,',
    '  int tileDimension,',
    '  double tileExtent,',
    '  double tileOpacity,',
    ') {',
    '  final eval = context.eval;',
    ...uniformEval.map((v) => '  $v'),
    '',
    '  pipeline.setUbos(',
    '    cameraWorldToGl: cameraWorldToGl,',
    '    cameraZoom: cameraZoom,',
    '    cameraPixelRatio: pixelRatio,'
        '    tileLocalToWorld: tileLocalToWorld,',
    '    tileDimension: tileDimension,',
    '    tileExtent: tileExtent,',
    '    tileOpacity: tileOpacity,',
    ...uniformSetters.map((v) => '        $v,'),
    '  );',
    '}',
  ];
}

List<String> lineLayerRendererSetFeatureVerticesGenerator(List<String> vertexEval, List<String> vertexSetters) {
  return [
    'int setFeatureVertices(',
    '  spec.EvaluationContext eval,',
    '  vt.LineStringFeature feature,',
    '  int index,',
    '  List<(Vector2 position, Vector2 normal)> vertexData,',
    ') {',
    '  final paint = specLayer.paint;',
    ...vertexEval.map((v) => '      $v'),
    '',
    '  for (var i = 0; i < vertexData.length; i++) {',
    '    final vertex = vertexData[i];',
    '    pipeline.vertex.setVertex(',
    '      index + i,',
    '      position: vertex.\$1,',
    '      normal: vertex.\$2,',
    ...vertexSetters.map((v) => '      $v,'),
    '    );',
    '  }',
    '',
    '  return index + vertexData.length;',
    '}',
  ];
}
