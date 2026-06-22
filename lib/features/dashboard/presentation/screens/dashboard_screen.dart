import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_constants.dart';
import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_shadows.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/analytics.dart';
import '../../../../utils/currency_formatter.dart';
import '../../../../utils/date_formatter.dart';
import '../../../expense/domain/entities/expense_entity.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider(projectId));

    return async.when(
      skipLoadingOnReload: true,
      loading: () => const AppScaffold(appBar: null, body: AppLoadingWidget()),
      error: (e, _) => AppScaffold(
        appBar: AppBarWidget(title: 'Dashboard', showBackButton: false),
        body: AppErrorState(
          message: 'Failed to load dashboard.',
          onRetry: () => ref.invalidate(dashboardProvider(projectId)),
        ),
      ),
      data: (data) => _DashboardBody(projectId: projectId, data: data),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.projectId, required this.data});

  final int projectId;
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final project = data.project;
    final budgetHealth = project.spentPercent;
    final healthColor = budgetHealth >= AppConstants.budgetCriticalThreshold
        ? LightThemeColors.budgetCritical
        : budgetHealth >= AppConstants.budgetWarningThreshold
        ? LightThemeColors.budgetWarning
        : LightThemeColors.budgetHealthy;

    final expenseSlices = Analytics.expensesByCategory(
      data.expenses,
      data.categories,
    );
    final monthly = Analytics.monthlyExpenseTrend(data.expenses);
    final stageSlices = [
      for (final s in data.stages)
        ChartSlice(
          label: s.name,
          value: s.progressPercent.toDouble(),
          color: s.isCompleted
              ? AppColors.success500
              : s.isInProgress
              ? AppColors.navy500
              : AppColors.neutral400,
        ),
    ];
    final stageChartHeight = (120 + data.stages.length * 34)
        .clamp(180, 420)
        .toDouble();

    return AppScaffold(
      appBar: AppBarWidget(
        title: project.name,
        subtitle: project.location,
        showBackButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.pageVertical,
        ),
        children: [
          // Greeting
          const _Greeting(),
          const SizedBox(height: AppSpacing.lg),

          // Budget card
          _BudgetCard(
            budget: project.budget,
            spent: project.totalSpent,
            remaining: project.remaining,
            spentPercent: project.spentPercent,
            healthColor: healthColor,
          ),

          const SizedBox(height: AppSpacing.md),

          // Overall progress
          _CompletionCard(percent: project.completionPercentage),

          const SizedBox(height: AppSpacing.xl),

          // Quick actions
          _QuickActions(projectId: projectId),

          const SizedBox(height: AppSpacing.xl),

          // Recent expenses
          if (data.recentExpenses.isNotEmpty) ...[
            SectionHeader(
              title: 'Recent Expenses',
              action: TextButton(
                onPressed: () => context.goNamed(
                  AppRouteNames.expenses,
                  pathParameters: {'id': projectId.toString()},
                ),
                child: Text(
                  'See all',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: LightThemeColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...data.recentExpenses.map((expense) {
              final cat = data.categories
                  .where((c) => c.id == expense.categoryId)
                  .firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                child: AppExpenseCard(
                  categoryName: cat?.name ?? 'Uncategorized',
                  categoryColor: cat?.color ?? LightThemeColors.primary,
                  amount: expense.amount,
                  formattedAmount: CurrencyFormatter.format(expense.amount),
                  description: expense.description,
                  vendorName: expense.vendorName,
                  formattedDate: DateFormatter.formatShort(expense.date),
                  paymentTypeLabel: expense.paymentMethod.label,
                  onTap: () => context.pushNamed(
                    AppRouteNames.expenseDetail,
                    pathParameters: {
                      'id': projectId.toString(),
                      'expenseId': expense.id.toString(),
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Charts (bottom)
          ChartCard(
            key: const ValueKey('chart:Expense Breakdown'),
            title: 'Expense Breakdown',
            subtitle: 'Where your money is spent',
            isEmpty: expenseSlices.isEmpty,
            height: 360,
            child: AppDonutChart(slices: expenseSlices),
          ),
          const SizedBox(height: AppSpacing.lg),
          ChartCard(
            key: const ValueKey('chart:Stage Progress'),
            title: 'Stage Progress',
            subtitle: 'Tap a stage to update its progress',
            isEmpty: stageSlices.isEmpty,
            height: stageChartHeight,
            child: AppHorizontalBarChart(
              bars: stageSlices,
              isPercent: true,
              onBarTap: (index) {
                if (index < 0 || index >= data.stages.length) return;
                context.pushNamed(
                  AppRouteNames.stageDetail,
                  pathParameters: {
                    'id': projectId.toString(),
                    'stageId': data.stages[index].id.toString(),
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ChartCard(
            key: const ValueKey('chart:Monthly Spending'),
            title: 'Monthly Spending',
            subtitle: 'Last 6 months',
            isEmpty: monthly.every((p) => p.value == 0),
            height: 230,
            child: AppLineChart(points: monthly),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final pct = percent.clamp(0.0, 100.0);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LightThemeColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Progress',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: LightThemeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: AppDimensions.progressBarHeight,
                    backgroundColor: AppColors.neutral200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      LightThemeColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            '${pct.toStringAsFixed(0)}%',
            style: AppTextStyles.headlineSmall.copyWith(
              color: LightThemeColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final part = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$part 👋', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Here's what's happening with your project.",
          style: AppTextStyles.bodyMedium.copyWith(
            color: LightThemeColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.spentPercent,
    required this.healthColor,
  });

  final double budget;
  final double spent;
  final double remaining;
  final double spentPercent;
  final Color healthColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LightThemeColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Overview',
            style: AppTextStyles.labelMedium.copyWith(
              color: LightThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _BudgetStat(
                label: 'Budget',
                value: CurrencyFormatter.formatCompact(budget),
                color: LightThemeColors.textPrimary,
              ),
              _BudgetStat(
                label: 'Spent',
                value: CurrencyFormatter.formatCompact(spent),
                color: healthColor,
              ),
              _BudgetStat(
                label: 'Left',
                value: CurrencyFormatter.formatCompact(remaining),
                color: remaining >= 0
                    ? LightThemeColors.textPrimary
                    : AppColors.error500,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: spentPercent,
              minHeight: AppDimensions.progressBarHeight,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${(spentPercent * 100).toStringAsFixed(1)}% of budget used',
            style: AppTextStyles.bodySmall.copyWith(
              color: LightThemeColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: LightThemeColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.monoMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.receipt_long_outlined,
            label: '+ Expense',
            onTap: () => context.pushNamed(
              AppRouteNames.addExpense,
              pathParameters: {'id': projectId.toString()},
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionButton(
            icon: Icons.inventory_2_outlined,
            label: '+ Material',
            onTap: () => context.pushNamed(
              AppRouteNames.addMaterial,
              pathParameters: {'id': projectId.toString()},
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionButton(
            icon: Icons.layers_outlined,
            label: 'Stages',
            onTap: () => context.pushNamed(
              AppRouteNames.stages,
              pathParameters: {'id': projectId.toString()},
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: LightThemeColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: LightThemeColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: LightThemeColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconSm,
                color: LightThemeColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: LightThemeColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
