import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/analytics.dart';

/// Spline line chart with markers + gradient fill for monthly trends.
class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.points,
    this.color = AppColors.navy500,
  });

  final List<TrendPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: AxisLine(width: 1, color: AppColors.neutral200),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: AppTextStyles.labelSmall,
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(width: 1, color: AppColors.neutral200),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        numberFormat: NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹'),
        labelStyle: AppTextStyles.labelSmall,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<TrendPoint, String>>[
        SplineAreaSeries<TrendPoint, String>(
          dataSource: points,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          animationDuration: 0,
          borderWidth: 2.5,
          borderColor: color,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.02),
            ],
          ),
          markerSettings: MarkerSettings(
            isVisible: true,
            color: color,
            borderColor: AppColors.white,
            borderWidth: 2,
          ),
        ),
      ],
    );
  }
}
