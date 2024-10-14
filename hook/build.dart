// ignore_for_file: avoid_print

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:flutter_gpu_shaders/build.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (config, output) async {
    final logger = Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) => print(record.message));

    await buildShaderBundleJson(
      buildConfig: config,
      buildOutput: output,
      manifestFileName: 'shaders/TestLibrary.shaderbundle.json',
    );

    // final nativeBuilders = <Builder>[];

    // final packageName = config.packageName;
    // nativeBuilders.add(
    //   CBuilder.library(
    //     name: packageName,
    //     assetName: 'src/gen/c_bindings.dart',
    //     sources: [
    //       'src/tessellator.cpp',
    //     ],
    //     includes: [
    //       'src/vendor/mapbox/include',
    //     ],
    //     language: Language.cpp,
    //     flags: ['-std=c++11'],
    //   ),
    // );

    // for (final builder in nativeBuilders) {
    //   await builder.run(
    //     config: config,
    //     output: output,
    //     logger: logger,
    //   );
    // }
  });
}
