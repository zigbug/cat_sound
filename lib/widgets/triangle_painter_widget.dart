import 'package:flutter/material.dart';

/// Виджет треугольника для отображения точек останова на слайдере
class TrianglePainterWidget extends StatelessWidget {
  final Color strokeColor;
  final double strokeWidth;

  const TrianglePainterWidget({
    super.key,
    required this.strokeColor,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 20,
      child: CustomPaint(
        painter: _TrianglePainter(
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;

  _TrianglePainter({required this.strokeColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height - 20);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
