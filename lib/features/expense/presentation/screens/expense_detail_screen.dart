import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/currency_formatter.dart';
import '../../../../utils/date_formatter.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expense_providers.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({
    super.key,
    required this.projectId,
    required this.expenseId,
  });

  final int projectId;
  final int expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(expensesNotifierProvider(projectId));

    return async.when(
      loading: () => const AppScaffold(
        appBar: null,
        body: AppLoadingWidget(),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBarWidget(title: 'Expense Detail'),
        body: AppErrorState(message: 'Failed to load expense.'),
      ),
      data: (state) {
        final expense =
            state.expenses.where((e) => e.id == expenseId).firstOrNull;

        if (expense == null) {
          return AppScaffold(
            appBar: AppBarWidget(title: 'Expense Detail'),
            body: const AppErrorState(message: 'Expense not found.'),
          );
        }

        final cat = state.categoryOf(expense.categoryId);

        return AppScaffold(
          appBar: AppBarWidget(
            title: 'Expense Detail',
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => context.pushNamed(
                  AppRouteNames.editExpense,
                  pathParameters: {
                    'id': projectId.toString(),
                    'expenseId': expenseId.toString(),
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                color: AppColors.error500,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.pageVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount hero
                Center(
                  child: Column(
                    children: [
                      if (cat != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            cat.name,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: cat.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      Text(
                        CurrencyFormatter.format(expense.amount),
                        style: AppTextStyles.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        DateFormatter.formatFull(expense.date),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: LightThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),
                Divider(color: LightThemeColors.border),
                const SizedBox(height: AppSpacing.lg),

                // Details
                _DetailRow(
                  icon: Icons.payment_outlined,
                  label: 'Payment',
                  value: expense.paymentMethod.label,
                ),
                if (expense.vendorName != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DetailRow(
                    icon: Icons.store_outlined,
                    label: 'Vendor',
                    value: expense.vendorName!,
                  ),
                ],
                if (expense.description != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DetailRow(
                    icon: Icons.notes_outlined,
                    label: 'Note',
                    value: expense.description!,
                  ),
                ],
                if (expense.stageId != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _StageRow(
                    projectId: projectId,
                    stageId: expense.stageId!,
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),
                Divider(color: LightThemeColors.border),
                const SizedBox(height: AppSpacing.md),

                Text(
                  'Added ${DateFormatter.formatRelative(expense.createdAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: LightThemeColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    await AppDeleteDialog.show(
      context,
      itemName: 'expense',
      onDelete: () async {
        await ref
            .read(expensesNotifierProvider(projectId).notifier)
            .deleteExpense(expenseId);
        if (context.mounted) context.pop();
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: LightThemeColors.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: LightThemeColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _StageRow extends ConsumerWidget {
  const _StageRow({required this.projectId, required this.stageId});

  final int projectId;
  final int stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stagesAsync = ref.watch(stagesByProjectProvider(projectId));
    return stagesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stages) {
        final stage = stages.where((s) => s.id == stageId).firstOrNull;
        if (stage == null) return const SizedBox.shrink();
        return _DetailRow(
          icon: Icons.layers_outlined,
          label: 'Stage',
          value: stage.name,
        );
      },
    );
  }
}
