import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Tiny sparkline-style bar chart used inside summary cards. The last bar is
/// drawn in the solid [color]; earlier bars are muted.
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    this.color = LightThemeColors.primary,
    this.width = 64,
    this.height = 40,
  });

  final List<double> values;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _MiniBarPainter(values: values, color: color),
      ),
    );
  }
}

class _MiniBarPainter extends CustomPainter {
  _MiniBarPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal <= 0 ? 1.0 : maxVal;

    const gap = 3.0;
    final barWidth = (size.width - gap * (values.length - 1)) / values.length;
    final radius = Radius.circular(barWidth / 2);

    for (var i = 0; i < values.length; i++) {
      final isLast = i == values.length - 1;
      final norm = (values[i] / safeMax).clamp(0.06, 1.0);
      final barHeight = size.height * norm;
      final left = i * (barWidth + gap);
      final rect = Rect.fromLTWH(
        left,
        size.height - barHeight,
        barWidth,
        barHeight,
      );
      final paint = Paint()
        ..color = isLast ? color : color.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect, topLeft: radius, topRight: radius),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniBarPainter old) =>
      old.values != values || old.color != color;
}
