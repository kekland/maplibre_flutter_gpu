import 'package:flutter/material.dart';
import 'package:maplibre_flutter_gpu/src/debug/utils/image_modal.dart';
import 'package:maplibre_flutter_gpu/src/renderer/renderer.dart';

class SpriteAtlasesSection extends StatelessWidget {
  const SpriteAtlasesSection({super.key, required this.orchestrator});

  final RenderOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...orchestrator.spriteAtlases.entries.map((entry) {
          final key = entry.key;
          final atlas = entry.value;

          return ListTile(
            onTap: () {
              showGpuTextureModal(context, atlas.texture!);
            },
            trailing: Icon(Icons.view_in_ar),
            title: Text('Sprite atlas: $key'),
            subtitle: Text('Size: ${atlas.texture?.width}x${atlas.texture?.height}'),
          );
        }),
      ],
    );
  }
}
