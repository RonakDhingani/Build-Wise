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
import '../../../../utils/currency_formatter.dart';
import '../../../../utils/trend_stats.dart';
import '../../domain/entities/material_entity.dart';
import '../notifiers/material_notifier.dart';
import '../providers/material_providers.dart';

enum _Stock { inStock, lowStock, outStock }

_Stock _statusOf(MaterialEntity m) {
  if (m.quantityPurchased > 0 && m.remaining <= 0) return _Stock.outStock;
  if (m.isLowStock) return _Stock.lowStock;
  return _Stock.inStock;
}

class MaterialScreen extends ConsumerWidget {
  const MaterialScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(materialsNotifierProvider(projectId));

    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Materials',
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
          message: 'Failed to load materials.',
          onRetry: () =>
              ref.read(materialsNotifierProvider(projectId).notifier).refresh(),
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
            Text('Search Materials', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            AppSearchField(
              hint: 'Material or vendor...',
              onChanged: (q) => ref
                  .read(materialsNotifierProvider(projectId).notifier)
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
    MaterialSortOrder current,
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
              .read(materialsNotifierProvider(projectId).notifier)
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
  final MaterialsState state;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  TrendPeriod _period = TrendPeriod.thisMonth;
  _Stock? _stockFilter;

  static const _tabs = [
    (label: 'All', stock: null),
    (label: 'In Stock', stock: _Stock.inStock),
    (label: 'Low Stock', stock: _Stock.lowStock),
    (label: 'Out of Stock', stock: _Stock.outStock),
  ];

  // Memoized analytics — recomputed only when the material list changes, so
  // stock-tab switches / scrolling never recompute or re-animate charts.
  List<MaterialEntity>? _aSrc;
  List<ChartSlice> _aDist = const [];
  List<ChartSlice> _aTop = const [];
  List<TrendPoint> _aTrend = const [];

  List<Widget> _analyticsSection(List<MaterialEntity> materials) {
    if (!identical(_aSrc, materials)) {
      _aSrc = materials;
      _aDist = Analytics.materialCostDistribution(materials);
      _aTop = Analytics.topMaterials(materials);
      _aTrend = Analytics.monthlyMaterialTrend(materials);
    }
    final dist = _aDist;
    final top = _aTop;
    final trend = _aTrend;
    final topHeight = (120 + top.length * 34).clamp(180, 360).toDouble();

    return [
      const SectionHeader(title: 'Analytics', padding: EdgeInsets.zero),
      const SizedBox(height: AppSpacing.md),
      ChartCard(
        key: const ValueKey('chart:Cost Distribution'),
        title: 'Cost Distribution',
        subtitle: 'Budget share by material',
        isEmpty: dist.isEmpty,
        height: 360,
        child: AppDonutChart(slices: dist),
      ),
      const SizedBox(height: AppSpacing.lg),
      ChartCard(
        key: const ValueKey('chart:Top Cost Materials'),
        title: 'Top Cost Materials',
        subtitle: 'Most expensive',
        isEmpty: top.isEmpty,
        height: topHeight,
        child: AppHorizontalBarChart(bars: top),
      ),
      const SizedBox(height: AppSpacing.lg),
      ChartCard(
        key: const ValueKey('chart:Purchase Trend'),
        title: 'Purchase Trend',
        subtitle: 'Last 6 months',
        isEmpty: trend.every((p) => p.value == 0),
        height: 230,
        child: AppLineChart(points: trend, color: AppColors.success500),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final materials = state.materials;

    final periodTotal = TrendStats.totalForPeriod<MaterialEntity>(
      materials,
      (m) => m.purchaseDate,
      (m) => m.totalCost,
      _period,
    );
    final thisMonth = TrendStats.totalForPeriod<MaterialEntity>(
      materials,
      (m) => m.purchaseDate,
      (m) => m.totalCost,
      TrendPeriod.thisMonth,
    );
    final lastMonth = TrendStats.totalForPeriod<MaterialEntity>(
      materials,
      (m) => m.purchaseDate,
      (m) => m.totalCost,
      TrendPeriod.lastMonth,
    );
    final bars = TrendStats.monthlyTotals<MaterialEntity>(
      materials,
      (m) => m.purchaseDate,
      (m) => m.totalCost,
    );

    var filtered = state.filtered;
    if (_stockFilter != null) {
      filtered = filtered.where((m) => _statusOf(m) == _stockFilter).toList();
    }

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
            title: 'Total Materials',
            total: periodTotal > 0
                ? CurrencyFormatter.format(periodTotal)
                : '—',
            period: _period,
            onPeriodChanged: (p) => setState(() => _period = p),
            thisMonthValue: CurrencyFormatter.format(thisMonth),
            lastMonthValue: CurrencyFormatter.format(lastMonth),
            barValues: bars,
            accent: AppColors.success500,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFilterTabs(
          tabs: _tabs.map((t) => t.label).toList(),
          selectedIndex: _tabs.indexWhere((t) => t.stock == _stockFilter),
          onSelected: (i) => setState(() => _stockFilter = _tabs[i].stock),
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
                  title: 'No materials',
                  subtitle: _stockFilter != null
                      ? 'No materials in this state.'
                      : 'Tap Add Material to add your first one.',
                )
              : Builder(builder: (context) {
                  // Only the material rows are built lazily (unbounded, one
                  // per material) — the analytics charts below are few and
                  // fixed-size, built once and indexed into.
                  final analyticsWidgets = _analyticsSection(materials);
                  const headerCount = 2; // SectionHeader + spacer
                  final rowsEnd = headerCount + filtered.length;
                  final itemCount = rowsEnd + 1 + analyticsWidgets.length;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.xl,
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                    ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const SectionHeader(
                            title: 'Materials', padding: EdgeInsets.zero);
                      }
                      if (index == 1) {
                        return const SizedBox(height: AppSpacing.md);
                      }
                      if (index < rowsEnd) {
                        final m = filtered[index - headerCount];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _MaterialRow(
                            material: m,
                            status: _statusOf(m),
                            onTap: () => context.pushNamed(
                              AppRouteNames.materialDetail,
                              pathParameters: {
                                'id': widget.projectId.toString(),
                                'materialId': m.id.toString(),
                              },
                            ),
                          ),
                        );
                      }
                      if (index == rowsEnd) {
                        return const SizedBox(height: AppSpacing.xl);
                      }
                      return analyticsWidgets[index - rowsEnd - 1];
                    },
                  );
                }),
        ),
        AppBottomButton(
          label: '+  Add Material',
          onPressed: () => context.pushNamed(
            AppRouteNames.addMaterial,
            pathParameters: {'id': widget.projectId.toString()},
          ),
        ),
      ],
    );
  }
}

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

const _brown = AppColors.brown;
const _indigo = AppColors.indigo;
const _teal = AppColors.teal;
const _purple = AppColors.violet;

/// Maps a material name to a representative icon + tint color.
({IconData icon, Color color}) _materialVisual(String name) {
  final n = name.toLowerCase();
  bool has(String s) => n.contains(s);

  if (has('cement')) {
    return (icon: Icons.inventory_2_outlined, color: AppColors.navy400);
  }
  if (has('steel') || has('rod') || has('tmt')) {
    return (icon: Icons.layers_outlined, color: AppColors.neutral600);
  }
  if (has('sand')) {
    return (icon: Icons.warning_amber_rounded, color: AppColors.gold400);
  }
  if (has('aggregate') || has('gravel')) {
    return (icon: Icons.grain_rounded, color: _brown);
  }
  if (has('brick')) {
    return (icon: Icons.view_module_outlined, color: AppColors.error500);
  }
  if (has('block')) {
    return (icon: Icons.dashboard_outlined, color: _brown);
  }
  if (has('tile')) {
    return (icon: Icons.window_outlined, color: _indigo);
  }
  if (has('paint')) {
    return (icon: Icons.format_paint_outlined, color: AppColors.gold400);
  }
  if (has('putty')) {
    return (icon: Icons.layers_outlined, color: _teal);
  }
  if (has('pipe')) {
    return (icon: Icons.plumbing_outlined, color: AppColors.navy400);
  }
  if (has('wire') || has('cable')) {
    return (icon: Icons.cable_outlined, color: AppColors.gold400);
  }
  if (has('switch')) {
    return (icon: Icons.toggle_on_outlined, color: _purple);
  }
  if (has('door')) {
    return (icon: Icons.door_front_door_outlined, color: _brown);
  }
  if (has('window')) {
    return (icon: Icons.window_outlined, color: AppColors.navy400);
  }
  if (has('granite') || has('marble') || has('stone')) {
    return (icon: Icons.texture_rounded, color: AppColors.neutral500);
  }
  if (has('waterproof')) {
    return (icon: Icons.water_drop_outlined, color: AppColors.info500);
  }
  if (has('water') || has('tank')) {
    return (icon: Icons.water_outlined, color: AppColors.info500);
  }
  if (has('plywood') || has('wood') || has('ply')) {
    return (icon: Icons.dashboard_outlined, color: _brown);
  }
  return (icon: Icons.inventory_2_outlined, color: LightThemeColors.primary);
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({
    required this.material,
    required this.status,
    required this.onTap,
  });

  final MaterialEntity material;
  final _Stock status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = material;
    final visual = _materialVisual(m.name);
    return InkWell(
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
                color: visual.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(
                visual.icon,
                color: visual.color,
                size: AppDimensions.iconSm,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${_qty(m.quantityPurchased)} ${m.unit.label}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: LightThemeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _StockBadge(status: status),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  m.totalCost > 0 ? CurrencyFormatter.format(m.totalCost) : '—',
                  style: AppTextStyles.titleSmall,
                ),
                if (m.costPerUnit != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${CurrencyFormatter.format(m.costPerUnit!)} / ${m.unit.label}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: LightThemeColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.status});

  final _Stock status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      _Stock.inStock => (
        'In Stock',
        AppColors.success500,
        AppColors.success100,
      ),
      _Stock.lowStock => (
        'Low Stock',
        AppColors.warning500,
        AppColors.warning100,
      ),
      _Stock.outStock => (
        'Out of Stock',
        AppColors.error500,
        AppColors.error100,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.onSelected});

  final MaterialSortOrder current;
  final ValueChanged<MaterialSortOrder> onSelected;

  static const _options = [
    (label: 'Recent first', order: MaterialSortOrder.purchaseDateDesc),
    (label: 'Oldest first', order: MaterialSortOrder.purchaseDateAsc),
    (label: 'Name A–Z', order: MaterialSortOrder.nameAsc),
    (label: 'Name Z–A', order: MaterialSortOrder.nameDesc),
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
