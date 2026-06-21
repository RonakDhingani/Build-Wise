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
      loading: () => const AppScaffold(
        appBar: null,
        body: AppLoadingWidget(),
      ),
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
          // Budget card
          _BudgetCard(
            budget: project.budget,
            spent: project.totalSpent,
            remaining: project.remaining,
            spentPercent: project.spentPercent,
            healthColor: healthColor,
          ),

          const SizedBox(height: AppSpacing.md),

          // Completion card
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
                child: Text('See all',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: LightThemeColors.primary,
                    )),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...data.recentExpenses.map((expense) {
              final cat = data.categories
                  .where((c) => c.id == expense.categoryId)
                  .firstOrNull;
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSpacing.itemGap),
                child: AppExpenseCard(
                  categoryName: cat?.name ?? 'Uncategorized',
                  categoryColor:
                      cat?.color ?? LightThemeColors.primary,
                  amount: expense.amount,
                  formattedAmount:
                      CurrencyFormatter.format(expense.amount),
                  description: expense.description,
                  vendorName: expense.vendorName,
                  formattedDate:
                      DateFormatter.formatShort(expense.date),
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
            const SizedBox(height: AppSpacing.lg),
          ],

          // Stages overview
          if (data.stages.isNotEmpty) ...[
            const SectionHeader(title: 'Stage Progress'),
            const SizedBox(height: AppSpacing.md),
            ...data.stages.map(
              (stage) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _StageProgressTile(
                  stage: stage,
                  projectId: projectId,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
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
          Text('Budget Overview',
              style: AppTextStyles.labelMedium
                  .copyWith(color: LightThemeColors.textSecondary)),
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
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusFull),
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
            style: AppTextStyles.bodySmall
                .copyWith(color: LightThemeColors.textTertiary),
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
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: LightThemeColors.textTertiary)),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTextStyles.monoMedium.copyWith(color: color)),
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
                Text('Overall Progress',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: LightThemeColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: AppDimensions.progressBarHeight,
                    backgroundColor: AppColors.neutral200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        LightThemeColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            '${pct.toStringAsFixed(0)}%',
            style: AppTextStyles.headlineSmall
                .copyWith(color: LightThemeColors.primary),
          ),
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
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: LightThemeColors.primaryLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: AppDimensions.iconMd,
                color: LightThemeColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: LightThemeColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StageProgressTile extends StatelessWidget {
  const _StageProgressTile({
    required this.stage,
    required this.projectId,
  });
  final StageProgress stage;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final color = stage.isCompleted
        ? AppColors.success500
        : stage.isInProgress
            ? LightThemeColors.primary
            : LightThemeColors.textTertiary;

    return InkWell(
      onTap: () => context.pushNamed(
        AppRouteNames.stageDetail,
        pathParameters: {
          'id': projectId.toString(),
          'stageId': stage.id.toString(),
        },
      ),
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
        Icon(
          stage.isCompleted
              ? Icons.check_circle
              : stage.isInProgress
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
          size: AppDimensions.iconSm,
          color: color,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stage.name, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: stage.progressPercent / 100,
                  minHeight: AppDimensions.progressBarThin,
                  backgroundColor: AppColors.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '${stage.progressPercent}%',
          style: AppTextStyles.labelSmall
              .copyWith(color: LightThemeColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.xs),
        Icon(
          Icons.chevron_right,
          size: AppDimensions.iconSm,
          color: LightThemeColors.textTertiary,
        ),
      ],
        ),
      ),
    );
  }
}
