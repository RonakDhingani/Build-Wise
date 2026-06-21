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
import '../notifiers/expense_notifier.dart';
import '../providers/expense_providers.dart';

class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(expensesNotifierProvider(projectId));

    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Expenses',
        showBackButton: false,
        actions: [
          async.whenData((s) => s).valueOrNull != null
              ? IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  tooltip: 'Sort',
                  onPressed: () =>
                      _showSortSheet(context, ref, async.value!.sortOrder),
                )
              : const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(
          AppRouteNames.addExpense,
          pathParameters: {'id': projectId.toString()},
        ),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorState(
          message: 'Failed to load expenses.',
          onRetry: () =>
              ref.read(expensesNotifierProvider(projectId).notifier).refresh(),
        ),
        data: (state) => _Body(projectId: projectId, state: state),
      ),
    );
  }

  void _showSortSheet(
    BuildContext context,
    WidgetRef ref,
    ExpenseSortOrder current,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (_) => _SortSheet(
        current: current,
        onSelected: (order) {
          ref
              .read(expensesNotifierProvider(projectId).notifier)
              .setSortOrder(order);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.projectId, required this.state});

  final int projectId;
  final ExpenseState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = state.filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.pageVertical,
            AppSpacing.pageHorizontal,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppSummaryCard(
                  title: 'Total Spent',
                  value: CurrencyFormatter.formatCompact(state.totalAmount),
                  icon: Icons.receipt_long_outlined,
                  iconColor: LightThemeColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppSummaryCard(
                  title: 'Transactions',
                  value: '${state.count}',
                  icon: Icons.list_alt_outlined,
                  iconColor: LightThemeColors.secondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Category filter chips
        if (state.categories.isNotEmpty)
          _CategoryChips(state: state, projectId: projectId),

        const SizedBox(height: AppSpacing.sm),
        Divider(height: 1, color: LightThemeColors.border),

        // Expense list
        Expanded(
          child: filtered.isEmpty
              ? AppEmptyState(
                  title: 'No expenses yet',
                  subtitle: state.selectedCategoryId != null
                      ? 'No expenses in this category.'
                      : 'Tap + to record your first expense.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.itemGap),
                  itemBuilder: (context, i) {
                    final expense = filtered[i];
                    final cat = state.categoryOf(expense.categoryId);
                    return AppExpenseCard(
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
                      onDelete: () =>
                          _confirmDelete(context, ref, expense.id, projectId),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int expenseId,
    int projectId,
  ) async {
    await AppDeleteDialog.show(
      context,
      itemName: 'expense',
      onDelete: () async {
        await ref
            .read(expensesNotifierProvider(projectId).notifier)
            .deleteExpense(expenseId);
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.state, required this.projectId});

  final ExpenseState state;
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usedIds = state.expenses.map((e) => e.categoryId).toSet();
    final visible = state.categories
        .where((c) => usedIds.contains(c.id))
        .toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
        ),
        children: [
          _Chip(
            label: 'All',
            selected: state.selectedCategoryId == null,
            color: LightThemeColors.primary,
            onTap: () => ref
                .read(expensesNotifierProvider(projectId).notifier)
                .setCategory(null),
          ),
          ...visible.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: _Chip(
                label: cat.name,
                selected: state.selectedCategoryId == cat.id,
                color: cat.color,
                onTap: () => ref
                    .read(expensesNotifierProvider(projectId).notifier)
                    .setCategory(cat.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: selected ? color : AppColors.neutral300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : LightThemeColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.onSelected});

  final ExpenseSortOrder current;
  final ValueChanged<ExpenseSortOrder> onSelected;

  static const _options = [
    (label: 'Newest first', order: ExpenseSortOrder.dateDesc),
    (label: 'Oldest first', order: ExpenseSortOrder.dateAsc),
    (label: 'Highest amount', order: ExpenseSortOrder.amountDesc),
    (label: 'Lowest amount', order: ExpenseSortOrder.amountAsc),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.lg,
              AppSpacing.pageHorizontal,
              AppSpacing.sm,
            ),
            child: Text('Sort by', style: AppTextStyles.titleMedium),
          ),
          ..._options.map(
            (opt) => RadioListTile<ExpenseSortOrder>(
              title: Text(opt.label, style: AppTextStyles.bodyMedium),
              value: opt.order,
              groupValue: current,
              onChanged: (v) {
                if (v != null) onSelected(v);
              },
              activeColor: LightThemeColors.primary,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
