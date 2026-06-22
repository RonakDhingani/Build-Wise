import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

/// Card wrapper for an analytics chart: title, optional subtitle, and either
/// the chart [child] or a "No data available" placeholder when [isEmpty].
///
/// Keeps itself alive in lazy lists ([AutomaticKeepAliveClientMixin]) so the
/// chart isn't rebuilt — and its entry animation isn't replayed — every time
/// it scrolls in and out of the viewport.
class ChartCard extends StatefulWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.isEmpty,
    required this.child,
    this.subtitle,
    this.height = 240,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool isEmpty;
  final Widget child;
  final double height;
  final Widget? trailing;

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final title = widget.title;
    final subtitle = widget.subtitle;
    final trailing = widget.trailing;
    final isEmpty = widget.isEmpty;
    final height = widget.height;
    final child = widget.child;

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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: LightThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: height,
            width: double.infinity,
            child: isEmpty
                ? const _NoData()
                : KeyedSubtree(key: ValueKey('chart:$title'), child: child),
          ),
        ],
      ),
    );
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bar_chart_rounded,
          size: AppDimensions.iconXl,
          color: AppColors.neutral300,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'No data available',
          style: AppTextStyles.bodyMedium.copyWith(
            color: LightThemeColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
