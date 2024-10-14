//
//  Generated code. Do not modify.
//  source: lib/src/proto/vector_tile.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// GeomType is described in section 4.3.4 of the specification
class Tile_GeomType extends $pb.ProtobufEnum {
  static const Tile_GeomType UNKNOWN = Tile_GeomType._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const Tile_GeomType POINT = Tile_GeomType._(1, _omitEnumNames ? '' : 'POINT');
  static const Tile_GeomType LINESTRING = Tile_GeomType._(2, _omitEnumNames ? '' : 'LINESTRING');
  static const Tile_GeomType POLYGON = Tile_GeomType._(3, _omitEnumNames ? '' : 'POLYGON');

  static const $core.List<Tile_GeomType> values = <Tile_GeomType> [
    UNKNOWN,
    POINT,
    LINESTRING,
    POLYGON,
  ];

  static final $core.Map<$core.int, Tile_GeomType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Tile_GeomType? valueOf($core.int value) => _byValue[value];

  const Tile_GeomType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
