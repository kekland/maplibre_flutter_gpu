import 'package:flutter/material.dart';

bool debugMapShowTileBoundaries = false;
bool debugMapShowRenderStats = false;

class RenderDebugOptionsSection extends StatelessWidget {
  const RenderDebugOptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          value: debugMapShowTileBoundaries,
          onChanged: (value) {
            debugMapShowTileBoundaries = value!;
            WidgetsBinding.instance.reassembleApplication();
          },
          title: const Text('Show tile boundaries'),
        ),
        CheckboxListTile(
          value: debugMapShowRenderStats,
          onChanged: (value) {
            debugMapShowRenderStats = value!;
            WidgetsBinding.instance.reassembleApplication();
          },
          title: const Text('Show render stats'),
        ),
      ],
    );
  }
}
