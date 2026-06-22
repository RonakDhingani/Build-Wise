import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../theme/app_text_styles.dart';
import '../../../utils/analytics.dart';

/// Doughnut chart with bottom legend, percentage data labels, and tooltips.
class AppDonutChart extends StatelessWidget {
  const AppDonutChart({super.key, required this.slices});

  final List<ChartSlice> slices;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (s, e) => s + e.value);

    return SfCircularChart(
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x : point.y',
      ),
      margin: const EdgeInsets.symmetric(vertical: 18),
      series: <CircularSeries<ChartSlice, String>>[
        DoughnutSeries<ChartSlice, String>(
          dataSource: slices,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          pointColorMapper: (d, _) => d.color,
          innerRadius: '58%',
          radius: '72%',
          animationDuration: 0,
          dataLabelMapper: (d, _) => total <= 0
              ? ''
              : '${(d.value / total * 100).toStringAsFixed(0)}%',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: AppTextStyles.labelSmall,
            connectorLineSettings: const ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '12%',
            ),
          ),
        ),
      ],
    );
  }
}
