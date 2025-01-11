//
//  Generated code. Do not modify.
//  source: glyphs.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Stores a glyph with metrics and optional SDF bitmap information.
class glyph extends $pb.GeneratedMessage {
  factory glyph({
    $core.int? id,
    $core.List<$core.int>? bitmap,
    $core.int? width,
    $core.int? height,
    $core.int? left,
    $core.int? top,
    $core.int? advance,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (bitmap != null) {
      $result.bitmap = bitmap;
    }
    if (width != null) {
      $result.width = width;
    }
    if (height != null) {
      $result.height = height;
    }
    if (left != null) {
      $result.left = left;
    }
    if (top != null) {
      $result.top = top;
    }
    if (advance != null) {
      $result.advance = advance;
    }
    return $result;
  }
  glyph._() : super();
  factory glyph.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory glyph.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'glyph', package: const $pb.PackageName(_omitMessageNames ? '' : 'mapboxgl.glyphs'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.QU3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'bitmap', $pb.PbFieldType.OY)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'width', $pb.PbFieldType.QU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'height', $pb.PbFieldType.QU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'left', $pb.PbFieldType.QS3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'top', $pb.PbFieldType.QS3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'advance', $pb.PbFieldType.QU3)
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  glyph clone() => glyph()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  glyph copyWith(void Function(glyph) updates) => super.copyWith((message) => updates(message as glyph)) as glyph;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static glyph create() => glyph._();
  glyph createEmptyInstance() => create();
  static $pb.PbList<glyph> createRepeated() => $pb.PbList<glyph>();
  @$core.pragma('dart2js:noInline')
  static glyph getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<glyph>(create);
  static glyph? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// A signed distance field of the glyph with a border of 3 pixels.
  @$pb.TagNumber(2)
  $core.List<$core.int> get bitmap => $_getN(1);
  @$pb.TagNumber(2)
  set bitmap($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBitmap() => $_has(1);
  @$pb.TagNumber(2)
  void clearBitmap() => clearField(2);

  /// Glyph metrics.
  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get left => $_getIZ(4);
  @$pb.TagNumber(5)
  set left($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLeft() => $_has(4);
  @$pb.TagNumber(5)
  void clearLeft() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get top => $_getIZ(5);
  @$pb.TagNumber(6)
  set top($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTop() => $_has(5);
  @$pb.TagNumber(6)
  void clearTop() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get advance => $_getIZ(6);
  @$pb.TagNumber(7)
  set advance($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAdvance() => $_has(6);
  @$pb.TagNumber(7)
  void clearAdvance() => clearField(7);
}

/// Stores fontstack information and a list of faces.
class fontstack extends $pb.GeneratedMessage {
  factory fontstack({
    $core.String? name,
    $core.String? range,
    $core.Iterable<glyph>? glyphs,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (range != null) {
      $result.range = range;
    }
    if (glyphs != null) {
      $result.glyphs.addAll(glyphs);
    }
    return $result;
  }
  fontstack._() : super();
  factory fontstack.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory fontstack.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'fontstack', package: const $pb.PackageName(_omitMessageNames ? '' : 'mapboxgl.glyphs'), createEmptyInstance: create)
    ..aQS(1, _omitFieldNames ? '' : 'name')
    ..aQS(2, _omitFieldNames ? '' : 'range')
    ..pc<glyph>(3, _omitFieldNames ? '' : 'glyphs', $pb.PbFieldType.PM, subBuilder: glyph.create)
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  fontstack clone() => fontstack()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  fontstack copyWith(void Function(fontstack) updates) => super.copyWith((message) => updates(message as fontstack)) as fontstack;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static fontstack create() => fontstack._();
  fontstack createEmptyInstance() => create();
  static $pb.PbList<fontstack> createRepeated() => $pb.PbList<fontstack>();
  @$core.pragma('dart2js:noInline')
  static fontstack getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<fontstack>(create);
  static fontstack? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get range => $_getSZ(1);
  @$pb.TagNumber(2)
  set range($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRange() => $_has(1);
  @$pb.TagNumber(2)
  void clearRange() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<glyph> get glyphs => $_getList(2);
}

class glyphs extends $pb.GeneratedMessage {
  factory glyphs({
    $core.Iterable<fontstack>? stacks,
  }) {
    final $result = create();
    if (stacks != null) {
      $result.stacks.addAll(stacks);
    }
    return $result;
  }
  glyphs._() : super();
  factory glyphs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory glyphs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'glyphs', package: const $pb.PackageName(_omitMessageNames ? '' : 'mapboxgl.glyphs'), createEmptyInstance: create)
    ..pc<fontstack>(1, _omitFieldNames ? '' : 'stacks', $pb.PbFieldType.PM, subBuilder: fontstack.create)
    ..hasExtensions = true
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  glyphs clone() => glyphs()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  glyphs copyWith(void Function(glyphs) updates) => super.copyWith((message) => updates(message as glyphs)) as glyphs;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static glyphs create() => glyphs._();
  glyphs createEmptyInstance() => create();
  static $pb.PbList<glyphs> createRepeated() => $pb.PbList<glyphs>();
  @$core.pragma('dart2js:noInline')
  static glyphs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<glyphs>(create);
  static glyphs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<fontstack> get stacks => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
