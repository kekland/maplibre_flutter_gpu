import 'package:flutter/widgets.dart';
import 'package:maplibre_flutter_gpu/src/utils/extensions.dart';
import 'package:maplibre_style_spec/maplibre_style_spec.dart' as spec;

class BackgroundLayer extends StatelessWidget {
  const BackgroundLayer({super.key, required this.layer});

  final spec.LayerBackground layer;

  @override
  Widget build(BuildContext context) {
    final context = spec.EvaluationContext.empty();

    final layout = layer.layout;

    if (layout.visibility.evaluate(context) == spec.Visibility.none) {
      return const SizedBox.shrink();
    }

    final paint = layer.paint;

    final backgroundColor = paint.backgroundColor.evaluate(context);
    final backgroundPattern = paint.backgroundPattern?.evaluate(context);
    final backgroundOpacity = paint.backgroundOpacity.evaluate(context);

    return Opacity(
      opacity: backgroundOpacity.toDouble(),
      child: Container(
        color: backgroundColor.asUiColor,
        child: const SizedBox.expand(),
      ),
    );
  }
}
