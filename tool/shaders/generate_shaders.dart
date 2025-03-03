#!/usr/bin/env fvm dart

import 'dart:io';

void main() => generateShaders();

// TODO: Rewrite this to be more concise

void generateShaders() {
  final scriptPath = Platform.script.path;
  final rootDirectory = File(scriptPath).parent.parent.parent;
  final shadersDirectory = Directory('${rootDirectory.path}/lib/src/shaders');
  final outputFile = File('${rootDirectory.path}/lib/src/shaders/gen/shader_templates.gen.dart');

  final files = shadersDirectory.listSync().whereType<File>().toList();
  final preludeShadersFiles =
      files.where((file) => file.path.split('/').last.startsWith('_prelude') && file.path.endsWith('.glsl')).toList();

  final vertexShadersFiles = files.where((file) => file.path.endsWith('.vert')).toList();
  final fragmentShadersFiles = files.where((file) => file.path.endsWith('.frag')).toList();

  final preludeShaders = <String, String>{};
  final vertexShaders = <String, String>{};
  final fragmentShaders = <String, String>{};

  for (final preludeShader in preludeShadersFiles) {
    final preludeName = preludeShader.path.split('/').last.split('.').first.substring('_prelude_'.length);
    preludeShaders[preludeName] = preludeShader.readAsStringSync();
  }

  for (final vertexShader in vertexShadersFiles) {
    final vertexName = vertexShader.path.split('/').last.split('.').first;
    vertexShaders[vertexName] = vertexShader.readAsStringSync();
  }

  for (final fragmentShader in fragmentShadersFiles) {
    final fragmentName = fragmentShader.path.split('/').last.split('.').first;
    fragmentShaders[fragmentName] = fragmentShader.readAsStringSync();
  }

  final code = StringBuffer();

  code.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  code.writeln('// Generated by tool/shaders/generate_shaders.dart');
  code.writeln();

  code.writeln('const preludeShaders = <String, String>{');

  for (final entry in preludeShaders.entries) {
    code.writeln('\'${entry.key}\': \'\'\'');
    code.write(entry.value.replaceAll('\\', '\\\\'));
    code.writeln('\'\'\',');
  }

  code.writeln('};');
  code.writeln('');

  code.writeln('const vertexShaderTemplates = <String, String>{');

  for (final entry in vertexShaders.entries) {
    code.writeln('\'${entry.key}\': \'\'\'');
    code.write(entry.value.replaceAll('\\', '\\\\'));
    code.writeln('\'\'\',');
  }

  code.writeln('};');
  code.writeln('');

  code.writeln('const fragmentShaderTemplates = <String, String>{');

  for (final entry in fragmentShaders.entries) {
    code.writeln('\'${entry.key}\': \'\'\'');
    code.write(entry.value.replaceAll('\\', '\\\\'));
    code.writeln('\'\'\',');
  }

  code.writeln('};');
  code.writeln('');

  outputFile.writeAsStringSync(code.toString());
}
