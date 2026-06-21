import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/currency_formatter.dart';
import '../../domain/entities/material_entity.dart';
import '../notifiers/material_notifier.dart';
import '../providers/material_providers.dart';

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
          if (async.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Sort',
              onPressed: () =>
                  _showSortSheet(context, ref, async.value!.sortOrder),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(
          AppRouteNames.addMaterial,
          pathParameters: {'id': projectId.toString()},
        ),
        child: const Icon(Icons.add),
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

class _Body extends ConsumerWidget {
  const _Body({required this.projectId, required this.state});

  final int projectId;
  final MaterialsState state;

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
                  title: 'Total Cost',
                  value: state.totalCost > 0
                      ? CurrencyFormatter.formatCompact(state.totalCost)
                      : '—',
                  icon: Icons.inventory_2_outlined,
                  iconColor: LightThemeColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppSummaryCard(
                  title: 'Low Stock',
                  value: '${state.lowStockCount}',
                  icon: Icons.warning_amber_outlined,
                  iconColor: state.lowStockCount > 0
                      ? AppColors.warning500
                      : LightThemeColors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            0,
          ),
          child: AppSearchField(
            hint: 'Search materials...',
            onChanged: (q) => ref
                .read(materialsNotifierProvider(projectId).notifier)
                .updateSearch(q),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),
        Divider(height: 1, color: LightThemeColors.border),

        // List
        Expanded(
          child: filtered.isEmpty
              ? AppEmptyState(
                  title: 'No materials yet',
                  subtitle: state.searchQuery.isNotEmpty
                      ? 'No materials match "${state.searchQuery}".'
                      : 'Tap + to add your first material.',
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
                    final material = filtered[i];
                    return AppMaterialCard(
                      name: material.name,
                      unitLabel: material.unit.label,
                      quantityPurchased: material.quantityPurchased,
                      quantityUsed: material.quantityUsed,
                      totalCost:
                          material.totalCost > 0 ? material.totalCost : null,
                      formattedCost: material.totalCost > 0
                          ? CurrencyFormatter.format(material.totalCost)
                          : null,
                      onTap: () => context.pushNamed(
                        AppRouteNames.materialDetail,
                        pathParameters: {
                          'id': projectId.toString(),
                          'materialId': material.id.toString(),
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
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
                AppSpacing.sm),
            child: Text('Sort by', style: AppTextStyles.titleMedium),
          ),
          ..._options.map((opt) => ListTile(
                title: Text(opt.label, style: AppTextStyles.bodyMedium),
                leading: Radio<MaterialSortOrder>(
                  value: opt.order,
                  groupValue: current,
                  onChanged: (v) {
                    if (v != null) onSelected(v);
                  },
                  activeColor: LightThemeColors.primary,
                ),
                onTap: () => onSelected(opt.order),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
              )),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
