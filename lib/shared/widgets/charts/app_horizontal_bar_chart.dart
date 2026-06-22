import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/analytics.dart';

/// Horizontal bar chart (syncfusion [BarSeries]). Set [isPercent] for a
/// fixed 0–100 axis (stage progress); otherwise shows compact currency.
class AppHorizontalBarChart extends StatelessWidget {
  const AppHorizontalBarChart({
    super.key,
    required this.bars,
    this.isPercent = false,
    this.onBarTap,
  });

  final List<ChartSlice> bars;
  final bool isPercent;

  /// Called with the tapped bar's index. When set, bars are tappable.
  final ValueChanged<int>? onBarTap;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: AppTextStyles.labelSmall,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: isPercent ? 100 : null,
        interval: isPercent ? 25 : null,
        majorGridLines: MajorGridLines(
          width: 1,
          color: AppColors.neutral200,
        ),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        numberFormat: isPercent
            ? NumberFormat.decimalPattern()
            : NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹'),
        labelStyle: AppTextStyles.labelSmall,
      ),
      // Tap navigates; long-press reveals the value tooltip on the bar.
      tooltipBehavior: TooltipBehavior(
        enable: true,
        activationMode: ActivationMode.longPress,
        format: 'point.x : point.y',
      ),
      series: <CartesianSeries<ChartSlice, String>>[
        BarSeries<ChartSlice, String>(
          dataSource: bars,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          pointColorMapper: (d, _) => d.color,
          // Tap: navigate (when a handler is provided).
          onPointTap: onBarTap == null
              ? null
              : (ChartPointDetails d) {
                  if (d.pointIndex != null) onBarTap!(d.pointIndex!);
                },
          animationDuration: 0,
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: AppTextStyles.labelSmall,
            labelAlignment: ChartDataLabelAlignment.outer,
          ),
          dataLabelMapper: (d, _) =>
              isPercent ? '${d.value.toStringAsFixed(0)}%' : null,
        ),
      ],
    );
  }
}
