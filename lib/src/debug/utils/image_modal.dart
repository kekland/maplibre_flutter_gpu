import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

Future<void> showGpuTextureModal(BuildContext context, gpu.Texture texture) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return _GpuTextureModal(texture: texture);
    },
  );
}

class _GpuTextureModal extends StatelessWidget {
  const _GpuTextureModal({required this.texture});

  final gpu.Texture texture;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: _GpuTexturePainter(texture),
        size: Size(texture.width.toDouble(), texture.height.toDouble()),
      ),
    );
  }
}

class _GpuTexturePainter extends CustomPainter {
  _GpuTexturePainter(this.texture);

  final gpu.Texture texture;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(
      texture.asImage(),
      Offset.zero,
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
