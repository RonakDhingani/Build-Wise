import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/currency_formatter.dart';
import '../providers/report_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reportDataProvider(projectId));

    return AppScaffold(
      appBar: const AppBarWidget(
        title: 'Reports',
        showBackButton: false,
      ),
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

class _Body extends StatelessWidget {
  const _Body({required this.projectId, required this.data});

  final int projectId;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final project = data.project;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.pageVertical,
      ),
      children: [
        // Project name header
        Text(project.name, style: AppTextStyles.titleLarge),
        Text(
          project.location,
          style: AppTextStyles.bodyMedium.copyWith(
            color: LightThemeColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Summary cards
        Row(
          children: [
            Expanded(
              child: AppSummaryCard(
                title: 'Budget Used',
                value: CurrencyFormatter.formatCompact(project.totalSpent),
                icon: Icons.account_balance_wallet_outlined,
                iconColor: _budgetColor(project.spentPercent),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppSummaryCard(
                title: 'Remaining',
                value: CurrencyFormatter.formatCompact(project.remaining),
                icon: Icons.savings_outlined,
                iconColor: project.remaining >= 0
                    ? AppColors.success500
                    : AppColors.error500,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: AppSummaryCard(
                title: 'Stages Done',
                value:
                    '${data.completedStages}/${data.stages.length}',
                icon: Icons.layers_outlined,
                iconColor: AppColors.success500,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppSummaryCard(
                title: 'Expenses',
                value: '${data.expenses.length}',
                icon: Icons.receipt_long_outlined,
                iconColor: LightThemeColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Report cards
        _ReportCard(
          icon: Icons.pie_chart_outline_rounded,
          title: 'Budget Report',
          description:
              'Total budget, spending breakdown, remaining balance.',
          color: LightThemeColors.primary,
        ),

        const SizedBox(height: AppSpacing.md),

        _ReportCard(
          icon: Icons.receipt_long_outlined,
          title: 'Expense Report',
          description:
              'All expenses grouped by category with payment methods.',
          color: LightThemeColors.secondary,
        ),

        const SizedBox(height: AppSpacing.md),

        _ReportCard(
          icon: Icons.layers_outlined,
          title: 'Progress Report',
          description:
              'Stage-by-stage completion percentage and status.',
          color: AppColors.success500,
        ),

        const SizedBox(height: AppSpacing.md),

        _ReportCard(
          icon: Icons.inventory_2_outlined,
          title: 'Material Report',
          description:
              'Inventory levels, quantities used, and material costs.',
          color: AppColors.warning500,
        ),

        const SizedBox(height: AppSpacing.xxl),

        AppPrimaryButton(
          label: 'Generate Full PDF Report',
          icon: Icons.picture_as_pdf_outlined,
          onPressed: () => context.pushNamed(
            AppRouteNames.pdfViewer,
            pathParameters: {'id': projectId.toString()},
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Color _budgetColor(double spentPct) {
    if (spentPct >= 0.9) return AppColors.error500;
    if (spentPct >= 0.75) return AppColors.warning500;
    return AppColors.success500;
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LightThemeColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: LightThemeColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: color, size: AppDimensions.iconMd),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: LightThemeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
