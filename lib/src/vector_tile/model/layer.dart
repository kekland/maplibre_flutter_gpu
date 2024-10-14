import 'package:maplibre_flutter_gpu/src/vector_tile/proto/_proto.dart' as pb;
import 'package:maplibre_flutter_gpu/src/vector_tile/model/feature.dart';

Object _unwrapPbTileValue(pb.Tile_Value value) {
  if (value.hasStringValue()) return value.stringValue;
  if (value.hasFloatValue()) return value.floatValue;
  if (value.hasDoubleValue()) return value.doubleValue;
  if (value.hasIntValue()) return value.intValue;
  if (value.hasUintValue()) return value.uintValue;
  if (value.hasSintValue()) return value.sintValue;
  if (value.hasBoolValue()) return value.boolValue;

  throw UnimplementedError();
}

class Layer {
  const Layer({
    required this.version,
    required this.name,
    required this.extent,
    required this.features,
    required this.keys,
    required this.values,
  });

  factory Layer.parse(pb.Tile_Layer layer) {
    final extent = layer.extent;
    final features = <Feature>[];

    final _values = layer.values.map(_unwrapPbTileValue).toList();

    for (final feature in layer.features) {
      features.add(
        Feature.parse(feature, keys: layer.keys, values: _values),
      );
    }

    return Layer(
      version: layer.version,
      name: layer.name,
      extent: extent,
      features: features,
      keys: layer.keys,
      values: _values,
    );
  }

  final int version;
  final String name;
  final int extent;
  final List<Feature> features;
  final List<String> keys;
  final List<Object> values;
}
