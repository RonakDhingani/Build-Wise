import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_shadows.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/analytics.dart';
import '../../../../utils/date_formatter.dart';
import '../../data/report_data.dart';
import '../providers/report_providers.dart';

enum _TrendRange { d30, d90, m6, y1 }

extension _TrendRangeX on _TrendRange {
  String get label => switch (this) {
        _TrendRange.d30 => 'Last 30 Days',
        _TrendRange.d90 => 'Last 90 Days',
        _TrendRange.m6 => 'Last 6 Months',
        _TrendRange.y1 => 'Last Year',
      };

  int get months => switch (this) {
        _TrendRange.d30 => 2,
        _TrendRange.d90 => 3,
        _TrendRange.m6 => 6,
        _TrendRange.y1 => 12,
      };
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reportDataProvider(projectId));

    return AppScaffold(
      appBar: const AppBarWidget(title: 'Reports', showBackButton: false),
      body: async.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorState(
          message: 'Failed to load report data.',
          onRetry: () => ref.invalidate(reportDataProvider(projectId)),
        ),
        data: (data) => _Body(projectId: projectId, data: data),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.projectId, required this.data});

  final int projectId;
  final ReportData data;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  _TrendRange _range = _TrendRange.m6;

  // Memoized — budget/stage/material depend only on data (fixed for this
  // widget); only the trend recomputes when the range filter changes.
  List<ChartSlice> _budget = const [];
  List<ChartSlice> _stages = const [];
  List<ChartSlice> _materials = const [];
  Object? _dataKey;

  void _ensure() {
    if (identical(_dataKey, widget.data)) return;
    _dataKey = widget.data;
    _budget =
        Analytics.expensesByCategory(widget.data.expenses, widget.data.categories);
    _stages = Analytics.stageProgress(widget.data.stages);
    _materials = Analytics.topMaterials(widget.data.materials, limit: 8);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    _ensure();

    final budget = _budget;
    final trend =
        Analytics.monthlyExpenseTrend(data.expenses, months: _range.months);
    final stages = _stages;
    final materials = _materials;

    final stageHeight = (120 + stages.length * 34).clamp(200, 460).toDouble();
    final matHeight = (120 + materials.length * 34).clamp(200, 460).toDouble();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.pageVertical,
            ),
            children: [
              _DateRangeCard(
                start: data.project.startDate,
                end: data.generatedAt,
              ),
              const SizedBox(height: AppSpacing.lg),

              const SectionHeader(title: 'Reports', padding: EdgeInsets.zero),
              const SizedBox(height: AppSpacing.md),
              _ReportRow(
                icon: Icons.receipt_long_outlined,
                color: LightThemeColors.primary,
                title: 'Budget Report',
                subtitle: 'Overview of budget, spent and remaining',
                onTap: () => _openPdf(context),
              ),
              _ReportRow(
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFF8B5CF6),
                title: 'Expense Report',
                subtitle: 'Detailed list of all expenses',
                onTap: () => _openPdf(context),
              ),
              _ReportRow(
                icon: Icons.layers_outlined,
                color: AppColors.gold400,
                title: 'Material Report',
                subtitle: 'Summary of all materials used',
                onTap: () => _openPdf(context),
              ),
              _ReportRow(
                icon: Icons.insights_rounded,
                color: AppColors.success500,
                title: 'Progress Report',
                subtitle: 'Project progress and stage wise report',
                onTap: () => _openPdf(context),
              ),
              const SizedBox(height: AppSpacing.xl),

              const SectionHeader(title: 'Analytics', padding: EdgeInsets.zero),
              const SizedBox(height: AppSpacing.md),

              ChartCard(
                key: const ValueKey('chart:Budget Allocation'),
                title: 'Budget Allocation',
                subtitle: 'Spending distribution by category',
                isEmpty: budget.isEmpty,
                height: 360,
                child: AppDonutChart(slices: budget),
              ),
              const SizedBox(height: AppSpacing.lg),

              ChartCard(
                key: const ValueKey('chart:Expense Trend'),
                title: 'Expense Trend',
                subtitle: 'Spending over time',
                isEmpty: trend.every((p) => p.value == 0),
                height: 260,
                trailing: _RangeChip(
                  range: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
                child: AppLineChart(points: trend),
              ),
              const SizedBox(height: AppSpacing.lg),

              ChartCard(
                key: const ValueKey('chart:Stage Completion'),
                title: 'Stage Completion',
                subtitle: 'Progress of each stage',
                isEmpty: stages.isEmpty,
                height: stageHeight,
                child: AppHorizontalBarChart(bars: stages, isPercent: true),
              ),
              const SizedBox(height: AppSpacing.lg),

              ChartCard(
                key: const ValueKey('chart:Material Cost'),
                title: 'Material Cost',
                subtitle: 'Most expensive materials',
                isEmpty: materials.isEmpty,
                height: matHeight,
                child: AppHorizontalBarChart(bars: materials),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        AppBottomButton(
          label: 'Export Report (PDF)',
          onPressed: () => _openPdf(context),
        ),
      ],
    );
  }

  void _openPdf(BuildContext context) {
    context.pushNamed(
      AppRouteNames.pdfViewer,
      pathParameters: {'id': widget.projectId.toString()},
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: LightThemeColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(icon, color: color, size: AppDimensions.iconSm),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: LightThemeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: LightThemeColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: LightThemeColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: AppDimensions.iconSm, color: LightThemeColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '${DateFormatter.formatFull(start)}  –  ${DateFormatter.formatFull(end)}',
              style: AppTextStyles.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.range, required this.onChanged});

  final _TrendRange range;
  final ValueChanged<_TrendRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_TrendRange>(
      initialValue: range,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      itemBuilder: (_) => [
        for (final r in _TrendRange.values)
          PopupMenuItem(value: r, child: Text(r.label)),
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
              range.label,
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
