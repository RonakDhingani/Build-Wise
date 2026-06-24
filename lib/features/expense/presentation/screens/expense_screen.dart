import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_shadows.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/currency_formatter.dart';
import '../../../../utils/analytics.dart';
import '../../../../utils/date_formatter.dart';
import '../../../../utils/trend_stats.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../onboarding/presentation/walkthrough_controller.dart';
import '../../../onboarding/presentation/walkthrough_keys.dart';
import '../../../onboarding/presentation/walkthrough_step.dart';
import '../../domain/entities/expense_entity.dart';
import '../notifiers/expense_notifier.dart';
import '../providers/expense_providers.dart';

class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(expensesNotifierProvider(projectId));

    // Onboarding: spotlight the add-expense button when its step is active.
    final walkStep = ref.watch(walkthroughControllerProvider);
    if (walkStep == WalkStep.addExpense) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(walkthroughControllerProvider.notifier).maybeShowCoach(
              context,
              WalkStep.addExpense,
              key: WalkthroughKeys.addExpense,
              align: ContentAlign.top,
            );
      });
    }

    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Expenses',
        showBackButton: false,
        actions: [
          if (async.valueOrNull != null) ...[
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search',
              onPressed: () => _showSearch(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Sort',
              onPressed: () =>
                  _showSortSheet(context, ref, async.value!.sortOrder),
            ),
          ],
        ],
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

  void _showSearch(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.pageHorizontal,
          right: AppSpacing.pageHorizontal,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Search Expenses', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            AppSearchField(
              hint: 'Category, vendor, note...',
              onChanged: (q) => ref
                  .read(expensesNotifierProvider(projectId).notifier)
                  .updateSearch(q),
            ),
          ],
        ),
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

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.projectId, required this.state});

  final int projectId;
  final ExpenseState state;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  TrendPeriod _period = TrendPeriod.thisMonth;
  PaymentMethod? _payFilter;

  static const _tabs = [
    (label: 'All', method: null),
    (label: 'Cash', method: PaymentMethod.cash),
    (label: 'Cheque', method: PaymentMethod.cheque),
    (label: 'UPI', method: PaymentMethod.upi),
    (label: 'Bank Transfer', method: PaymentMethod.bankTransfer),
    (label: 'Credit', method: PaymentMethod.credit),
    (label: 'Other', method: PaymentMethod.other),
  ];

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final expenses = state.expenses;

    final periodTotal = TrendStats.totalForPeriod<ExpenseEntity>(
      expenses,
      (e) => e.date,
      (e) => e.amount,
      _period,
    );
    final thisMonth = TrendStats.totalForPeriod<ExpenseEntity>(
      expenses,
      (e) => e.date,
      (e) => e.amount,
      TrendPeriod.thisMonth,
    );
    final lastMonth = TrendStats.totalForPeriod<ExpenseEntity>(
      expenses,
      (e) => e.date,
      (e) => e.amount,
      TrendPeriod.lastMonth,
    );
    final bars = TrendStats.monthlyTotals<ExpenseEntity>(
      expenses,
      (e) => e.date,
      (e) => e.amount,
    );

    // Payment filter applied on top of the notifier's category/search/sort.
    var filtered = state.filtered;
    if (_payFilter != null) {
      filtered = filtered.where((e) => e.paymentMethod == _payFilter).toList();
    }
    filtered = [...filtered]..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.pageVertical,
            AppSpacing.pageHorizontal,
            0,
          ),
          child: AppTrendCard(
            title: 'Total Expenses',
            total: CurrencyFormatter.format(periodTotal),
            period: _period,
            onPeriodChanged: (p) => setState(() => _period = p),
            thisMonthValue: CurrencyFormatter.format(thisMonth),
            lastMonthValue: CurrencyFormatter.format(lastMonth),
            barValues: bars,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFilterTabs(
          tabs: _tabs.map((t) => t.label).toList(),
          selectedIndex: _tabs.indexWhere((t) => t.method == _payFilter),
          onSelected: (i) => setState(() => _payFilter = _tabs[i].method),
        ),
        const SizedBox(height: AppSpacing.lg),
        Divider(
          height: 1,
          color: LightThemeColors.border,
          indent: AppSpacing.pageHorizontal,
          endIndent: AppSpacing.pageHorizontal,
        ),
        Expanded(
          child: filtered.isEmpty
              ? AppEmptyState(
                  title: 'No expenses',
                  subtitle: _payFilter != null
                      ? 'No ${_payFilter!.label} expenses yet.'
                      : 'Tap Add Expense to record your first one.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    AppSpacing.lg,
                  ),
                  children: [
                    const SectionHeader(
                        title: 'Transactions', padding: EdgeInsets.zero),
                    const SizedBox(height: AppSpacing.md),
                    ..._buildGroupedRows(context, state, filtered),
                    const SizedBox(height: AppSpacing.xl),
                    ..._analyticsSection(state),
                  ],
                ),
        ),
        KeyedSubtree(
          key: WalkthroughKeys.addExpense,
          child: AppBottomButton(
            label: '+  Add Expense',
            onPressed: () => context.pushNamed(
              AppRouteNames.addExpense,
              pathParameters: {'id': widget.projectId.toString()},
            ),
          ),
        ),
      ],
    );
  }

  // Memoized analytics — recomputed only when the expense list changes, so
  // toggling payment tabs / scrolling never recomputes or re-animates charts.
  List<ExpenseEntity>? _aSrc;
  List<ChartSlice> _aBreakdown = const [];
  List<TrendPoint> _aTrend = const [];
  List<ChartSlice> _aTop = const [];

  void _ensureAnalytics() {
    if (identical(_aSrc, widget.state.expenses)) return;
    _aSrc = widget.state.expenses;
    _aBreakdown =
        Analytics.expensesByCategory(widget.state.expenses, widget.state.categories);
    _aTrend = Analytics.monthlyExpenseTrend(widget.state.expenses);
    _aTop = Analytics.topExpenseCategories(
        widget.state.expenses, widget.state.categories);
  }

  List<Widget> _analyticsSection(ExpenseState state) {
    _ensureAnalytics();
    final breakdown = _aBreakdown;
    final trend = _aTrend;
    final top = _aTop;
    final topHeight = (120 + top.length * 34).clamp(180, 360).toDouble();

    return [
      const SectionHeader(title: 'Analytics', padding: EdgeInsets.zero),
      const SizedBox(height: AppSpacing.md),
      ChartCard(
        key: const ValueKey('chart:Category Breakdown'),
        title: 'Category Breakdown',
        subtitle: 'Distribution by category',
        isEmpty: breakdown.isEmpty,
        height: 360,
        child: AppDonutChart(slices: breakdown),
      ),
      const SizedBox(height: AppSpacing.lg),
      ChartCard(
        key: const ValueKey('chart:Monthly Trend'),
        title: 'Monthly Trend',
        subtitle: 'Last 6 months',
        isEmpty: trend.every((p) => p.value == 0),
        height: 230,
        child: AppLineChart(points: trend),
      ),
      const SizedBox(height: AppSpacing.lg),
      ChartCard(
        key: const ValueKey('chart:Top Categories'),
        title: 'Top Categories',
        subtitle: 'Highest spending',
        isEmpty: top.isEmpty,
        height: topHeight,
        child: AppHorizontalBarChart(bars: top),
      ),
    ];
  }

  List<Widget> _buildGroupedRows(
    BuildContext context,
    ExpenseState state,
    List<ExpenseEntity> items,
  ) {
    final rows = <Widget>[];
    String? lastLabel;
    for (final e in items) {
      final label = _dayLabel(e.date);
      if (label != lastLabel) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(
              top: lastLabel == null ? 0 : AppSpacing.lg,
              bottom: AppSpacing.md,
            ),
            child: Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: LightThemeColors.textSecondary,
              ),
            ),
          ),
        );
        lastLabel = label;
      }
      final cat = state.categoryOf(e.categoryId);
      rows.add(
        _ExpenseRow(
          color: cat?.color ?? LightThemeColors.primary,
          category: cat?.name ?? 'Uncategorized',
          description: e.description,
          amount: CurrencyFormatter.format(e.amount),
          payment: e.paymentMethod.label,
          onTap: () => context.pushNamed(
            AppRouteNames.expenseDetail,
            pathParameters: {
              'id': widget.projectId.toString(),
              'expenseId': e.id.toString(),
            },
          ),
        ),
      );
    }
    return rows;
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormatter.formatFull(d);
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.color,
    required this.category,
    required this.description,
    required this.amount,
    required this.payment,
    required this.onTap,
  });

  final Color color;
  final String category;
  final String? description;
  final String amount;
  final String payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category, style: AppTextStyles.titleMedium),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: LightThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: LightThemeColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _PaymentPill(label: payment),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentPill extends StatelessWidget {
  const _PaymentPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: LightThemeColors.textSecondary,
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
            (opt) => ListTile(
              title: Text(opt.label, style: AppTextStyles.bodyMedium),
              trailing: current == opt.order
                  ? Icon(Icons.check_rounded, color: LightThemeColors.primary)
                  : null,
              onTap: () => onSelected(opt.order),
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
