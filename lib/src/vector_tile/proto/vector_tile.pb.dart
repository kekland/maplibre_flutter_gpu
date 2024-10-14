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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'vector_tile.pbenum.dart';

export 'vector_tile.pbenum.dart';

/// Variant type encoding
/// The use of values is described in section 4.1 of the specification
class Tile_Value extends $pb.GeneratedMessage {
  factory Tile_Value({
    $core.String? stringValue,
    $core.double? floatValue,
    $core.double? doubleValue,
    $fixnum.Int64? intValue,
    $fixnum.Int64? uintValue,
    $fixnum.Int64? sintValue,
    $core.bool? boolValue,
  }) {
    final $result = create();
    if (stringValue != null) {
      $result.stringValue = stringValue;
    }
    if (floatValue != null) {
      $result.floatValue = floatValue;
    }
    if (doubleValue != null) {
      $result.doubleValue = doubleValue;
    }
    if (intValue != null) {
      $result.intValue = intValue;
    }
    if (uintValue != null) {
      $result.uintValue = uintValue;
    }
    if (sintValue != null) {
      $result.sintValue = sintValue;
    }
    if (boolValue != null) {
      $result.boolValue = boolValue;
    }
    return $result;
  }
  Tile_Value._() : super();
  factory Tile_Value.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Tile_Value.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Tile.Value', package: const $pb.PackageName(_omitMessageNames ? '' : 'vector_tile'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'stringValue')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'floatValue', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'doubleValue', $pb.PbFieldType.OD)
    ..aInt64(4, _omitFieldNames ? '' : 'intValue')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'uintValue', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'sintValue', $pb.PbFieldType.OS6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(7, _omitFieldNames ? '' : 'boolValue')
    ..hasExtensions = true
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Tile_Value clone() => Tile_Value()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Tile_Value copyWith(void Function(Tile_Value) updates) => super.copyWith((message) => updates(message as Tile_Value)) as Tile_Value;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tile_Value create() => Tile_Value._();
  Tile_Value createEmptyInstance() => create();
  static $pb.PbList<Tile_Value> createRepeated() => $pb.PbList<Tile_Value>();
  @$core.pragma('dart2js:noInline')
  static Tile_Value getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tile_Value>(create);
  static Tile_Value? _defaultInstance;

  /// Exactly one of these values must be present in a valid message
  @$pb.TagNumber(1)
  $core.String get stringValue => $_getSZ(0);
  @$pb.TagNumber(1)
  set stringValue($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStringValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearStringValue() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get floatValue => $_getN(1);
  @$pb.TagNumber(2)
  set floatValue($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFloatValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearFloatValue() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get doubleValue => $_getN(2);
  @$pb.TagNumber(3)
  set doubleValue($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDoubleValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearDoubleValue() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get intValue => $_getI64(3);
  @$pb.TagNumber(4)
  set intValue($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIntValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearIntValue() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get uintValue => $_getI64(4);
  @$pb.TagNumber(5)
  set uintValue($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUintValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearUintValue() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get sintValue => $_getI64(5);
  @$pb.TagNumber(6)
  set sintValue($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSintValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearSintValue() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get boolValue => $_getBF(6);
  @$pb.TagNumber(7)
  set boolValue($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasBoolValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearBoolValue() => clearField(7);
}

/// Features are described in section 4.2 of the specification
class Tile_Feature extends $pb.GeneratedMessage {
  factory Tile_Feature({
    $fixnum.Int64? id,
    $core.Iterable<$core.int>? tags,
    Tile_GeomType? type,
    $core.Iterable<$core.int>? geometry,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    if (type != null) {
      $result.type = type;
    }
    if (geometry != null) {
      $result.geometry.addAll(geometry);
    }
    return $result;
  }
  Tile_Feature._() : super();
  factory Tile_Feature.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Tile_Feature.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Tile.Feature', package: const $pb.PackageName(_omitMessageNames ? '' : 'vector_tile'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..p<$core.int>(2, _omitFieldNames ? '' : 'tags', $pb.PbFieldType.KU3)
    ..e<Tile_GeomType>(3, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: Tile_GeomType.UNKNOWN, valueOf: Tile_GeomType.valueOf, enumValues: Tile_GeomType.values)
    ..p<$core.int>(4, _omitFieldNames ? '' : 'geometry', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Tile_Feature clone() => Tile_Feature()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Tile_Feature copyWith(void Function(Tile_Feature) updates) => super.copyWith((message) => updates(message as Tile_Feature)) as Tile_Feature;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tile_Feature create() => Tile_Feature._();
  Tile_Feature createEmptyInstance() => create();
  static $pb.PbList<Tile_Feature> createRepeated() => $pb.PbList<Tile_Feature>();
  @$core.pragma('dart2js:noInline')
  static Tile_Feature getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tile_Feature>(create);
  static Tile_Feature? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// Tags of this feature are encoded as repeated pairs of
  /// integers.
  /// A detailed description of tags is located in sections
  /// 4.2 and 4.4 of the specification
  @$pb.TagNumber(2)
  $core.List<$core.int> get tags => $_getList(1);

  /// The type of geometry stored in this feature.
  @$pb.TagNumber(3)
  Tile_GeomType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(Tile_GeomType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => clearField(3);

  /// Contains a stream of commands and parameters (vertices).
  /// A detailed description on geometry encoding is located in
  /// section 4.3 of the specification.
  @$pb.TagNumber(4)
  $core.List<$core.int> get geometry => $_getList(3);
}

/// Layers are described in section 4.1 of the specification
class Tile_Layer extends $pb.GeneratedMessage {
  factory Tile_Layer({
    $core.String? name,
    $core.Iterable<Tile_Feature>? features,
    $core.Iterable<$core.String>? keys,
    $core.Iterable<Tile_Value>? values,
    $core.int? extent,
    $core.int? version,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (features != null) {
      $result.features.addAll(features);
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    if (values != null) {
      $result.values.addAll(values);
    }
    if (extent != null) {
      $result.extent = extent;
    }
    if (version != null) {
      $result.version = version;
    }
    return $result;
  }
  Tile_Layer._() : super();
  factory Tile_Layer.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Tile_Layer.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Tile.Layer', package: const $pb.PackageName(_omitMessageNames ? '' : 'vector_tile'), createEmptyInstance: create)
    ..aQS(1, _omitFieldNames ? '' : 'name')
    ..pc<Tile_Feature>(2, _omitFieldNames ? '' : 'features', $pb.PbFieldType.PM, subBuilder: Tile_Feature.create)
    ..pPS(3, _omitFieldNames ? '' : 'keys')
    ..pc<Tile_Value>(4, _omitFieldNames ? '' : 'values', $pb.PbFieldType.PM, subBuilder: Tile_Value.create)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'extent', $pb.PbFieldType.OU3, defaultOrMaker: 4096)
    ..a<$core.int>(15, _omitFieldNames ? '' : 'version', $pb.PbFieldType.QU3, defaultOrMaker: 1)
    ..hasExtensions = true
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Tile_Layer clone() => Tile_Layer()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Tile_Layer copyWith(void Function(Tile_Layer) updates) => super.copyWith((message) => updates(message as Tile_Layer)) as Tile_Layer;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tile_Layer create() => Tile_Layer._();
  Tile_Layer createEmptyInstance() => create();
  static $pb.PbList<Tile_Layer> createRepeated() => $pb.PbList<Tile_Layer>();
  @$core.pragma('dart2js:noInline')
  static Tile_Layer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tile_Layer>(create);
  static Tile_Layer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  /// The actual features in this tile.
  @$pb.TagNumber(2)
  $core.List<Tile_Feature> get features => $_getList(1);

  /// Dictionary encoding for keys
  @$pb.TagNumber(3)
  $core.List<$core.String> get keys => $_getList(2);

  /// Dictionary encoding for values
  @$pb.TagNumber(4)
  $core.List<Tile_Value> get values => $_getList(3);

  /// Although this is an "optional" field it is required by the specification.
  /// See https://github.com/mapbox/vector-tile-spec/issues/47
  @$pb.TagNumber(5)
  $core.int get extent => $_getI(4, 4096);
  @$pb.TagNumber(5)
  set extent($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExtent() => $_has(4);
  @$pb.TagNumber(5)
  void clearExtent() => clearField(5);

  /// Any compliant implementation must first read the version
  /// number encoded in this message and choose the correct
  /// implementation for this version number before proceeding to
  /// decode other parts of this message.
  @$pb.TagNumber(15)
  $core.int get version => $_getI(5, 1);
  @$pb.TagNumber(15)
  set version($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(15)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(15)
  void clearVersion() => clearField(15);
}

class Tile extends $pb.GeneratedMessage {
  factory Tile({
    $core.Iterable<Tile_Layer>? layers,
  }) {
    final $result = create();
    if (layers != null) {
      $result.layers.addAll(layers);
    }
    return $result;
  }
  Tile._() : super();
  factory Tile.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Tile.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Tile', package: const $pb.PackageName(_omitMessageNames ? '' : 'vector_tile'), createEmptyInstance: create)
    ..pc<Tile_Layer>(3, _omitFieldNames ? '' : 'layers', $pb.PbFieldType.PM, subBuilder: Tile_Layer.create)
    ..hasExtensions = true
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Tile clone() => Tile()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Tile copyWith(void Function(Tile) updates) => super.copyWith((message) => updates(message as Tile)) as Tile;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tile create() => Tile._();
  Tile createEmptyInstance() => create();
  static $pb.PbList<Tile> createRepeated() => $pb.PbList<Tile>();
  @$core.pragma('dart2js:noInline')
  static Tile getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tile>(create);
  static Tile? _defaultInstance;

  @$pb.TagNumber(3)
  $core.List<Tile_Layer> get layers => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
