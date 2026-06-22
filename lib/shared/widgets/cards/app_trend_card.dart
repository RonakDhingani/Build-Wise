import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../charts/mini_bar_chart.dart';

enum TrendPeriod { thisMonth, lastMonth, allTime }

extension TrendPeriodX on TrendPeriod {
  String get label => switch (this) {
        TrendPeriod.thisMonth => 'This Month',
        TrendPeriod.lastMonth => 'Last Month',
        TrendPeriod.allTime => 'All Time',
      };
}

/// Headline summary card: big total for the selected [period], a period
/// dropdown, this-month vs last-month comparison, and a mini bar chart.
class AppTrendCard extends StatelessWidget {
  const AppTrendCard({
    super.key,
    required this.title,
    required this.total,
    required this.period,
    required this.onPeriodChanged,
    required this.thisMonthValue,
    required this.lastMonthValue,
    required this.barValues,
    this.accent = LightThemeColors.primary,
  });

  final String title;
  final String total;
  final TrendPeriod period;
  final ValueChanged<TrendPeriod> onPeriodChanged;
  final String thisMonthValue;
  final String lastMonthValue;
  final List<double> barValues;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: LightThemeColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: LightThemeColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(total, style: AppTextStyles.headlineMedium),
                  ],
                ),
              ),
              _PeriodChip(period: period, onChanged: onPeriodChanged),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: LightThemeColors.border),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Stat(label: 'This Month', value: thisMonthValue, accent: accent),
              const Spacer(),
              _Stat(label: 'Last Month', value: lastMonthValue),
              const Spacer(),
              Container(
                width: 1,
                height: 40,
                color: LightThemeColors.border,
              ),
              const SizedBox(width: AppSpacing.lg),
              MiniBarChart(values: barValues, color: accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: LightThemeColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(color: accent),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.period, required this.onChanged});

  final TrendPeriod period;
  final ValueChanged<TrendPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TrendPeriod>(
      initialValue: period,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      itemBuilder: (_) => [
        for (final p in TrendPeriod.values)
          PopupMenuItem(value: p, child: Text(p.label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              period.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: LightThemeColors.textSecondary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: AppDimensions.iconXs,
              color: LightThemeColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
