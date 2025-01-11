//
//  Generated code. Do not modify.
//  source: glyphs.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use glyphDescriptor instead')
const glyph$json = {
  '1': 'glyph',
  '2': [
    {'1': 'id', '3': 1, '4': 2, '5': 13, '10': 'id'},
    {'1': 'bitmap', '3': 2, '4': 1, '5': 12, '10': 'bitmap'},
    {'1': 'width', '3': 3, '4': 2, '5': 13, '10': 'width'},
    {'1': 'height', '3': 4, '4': 2, '5': 13, '10': 'height'},
    {'1': 'left', '3': 5, '4': 2, '5': 17, '10': 'left'},
    {'1': 'top', '3': 6, '4': 2, '5': 17, '10': 'top'},
    {'1': 'advance', '3': 7, '4': 2, '5': 13, '10': 'advance'},
  ],
};

/// Descriptor for `glyph`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List glyphDescriptor = $convert.base64Decode(
    'CgVnbHlwaBIOCgJpZBgBIAIoDVICaWQSFgoGYml0bWFwGAIgASgMUgZiaXRtYXASFAoFd2lkdG'
    'gYAyACKA1SBXdpZHRoEhYKBmhlaWdodBgEIAIoDVIGaGVpZ2h0EhIKBGxlZnQYBSACKBFSBGxl'
    'ZnQSEAoDdG9wGAYgAigRUgN0b3ASGAoHYWR2YW5jZRgHIAIoDVIHYWR2YW5jZQ==');

@$core.Deprecated('Use fontstackDescriptor instead')
const fontstack$json = {
  '1': 'fontstack',
  '2': [
    {'1': 'name', '3': 1, '4': 2, '5': 9, '10': 'name'},
    {'1': 'range', '3': 2, '4': 2, '5': 9, '10': 'range'},
    {'1': 'glyphs', '3': 3, '4': 3, '5': 11, '6': '.mapboxgl.glyphs.glyph', '10': 'glyphs'},
  ],
};

/// Descriptor for `fontstack`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fontstackDescriptor = $convert.base64Decode(
    'Cglmb250c3RhY2sSEgoEbmFtZRgBIAIoCVIEbmFtZRIUCgVyYW5nZRgCIAIoCVIFcmFuZ2USLg'
    'oGZ2x5cGhzGAMgAygLMhYubWFwYm94Z2wuZ2x5cGhzLmdseXBoUgZnbHlwaHM=');

@$core.Deprecated('Use glyphsDescriptor instead')
const glyphs$json = {
  '1': 'glyphs',
  '2': [
    {'1': 'stacks', '3': 1, '4': 3, '5': 11, '6': '.mapboxgl.glyphs.fontstack', '10': 'stacks'},
  ],
  '5': [
    {'1': 16, '2': 8192},
  ],
};

/// Descriptor for `glyphs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List glyphsDescriptor = $convert.base64Decode(
    'CgZnbHlwaHMSMgoGc3RhY2tzGAEgAygLMhoubWFwYm94Z2wuZ2x5cGhzLmZvbnRzdGFja1IGc3'
    'RhY2tzKgUIEBCAQA==');

