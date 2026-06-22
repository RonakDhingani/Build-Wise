import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class DonutSegment {
  const DonutSegment({required this.value, required this.color});
  final double value;
  final Color color;
}

/// Ring/donut chart with an optional centered label. Pure CustomPaint, no
/// external chart dependency.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 120,
    this.strokeWidth = 18,
    this.centerLabel,
    this.centerSubLabel,
  });

  final List<DonutSegment> segments;
  final double size;
  final double strokeWidth;
  final String? centerLabel;
  final String? centerSubLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(segments: segments, strokeWidth: strokeWidth),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (centerLabel != null)
                Text(
                  centerLabel!,
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
              if (centerSubLabel != null)
                Text(
                  centerSubLabel!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: LightThemeColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.strokeWidth});

  final List<DonutSegment> segments;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final track = Paint()
      ..color = AppColors.neutral200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    if (total <= 0) return;

    var start = -math.pi / 2;
    const gap = 0.04;
    for (final seg in segments) {
      if (seg.value <= 0) continue;
      final sweep = (seg.value / total) * (2 * math.pi) - gap;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, start + gap / 2, sweep, false, paint);
      start += (seg.value / total) * (2 * math.pi);
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.segments != segments || old.strokeWidth != strokeWidth;
}
