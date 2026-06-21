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
import '../../../../utils/date_formatter.dart';
import '../../../expense/presentation/providers/expense_providers.dart';
import '../../domain/entities/material_entity.dart';
import '../providers/material_providers.dart';

class MaterialDetailScreen extends ConsumerWidget {
  const MaterialDetailScreen({
    super.key,
    required this.projectId,
    required this.materialId,
  });

  final int projectId;
  final int materialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(materialsNotifierProvider(projectId));

    return async.when(
      loading: () => const AppScaffold(
        appBar: null,
        body: AppLoadingWidget(),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBarWidget(title: 'Material Detail'),
        body: const AppErrorState(message: 'Failed to load material.'),
      ),
      data: (state) {
        final material =
            state.materials.where((m) => m.id == materialId).firstOrNull;

        if (material == null) {
          return AppScaffold(
            appBar: AppBarWidget(title: 'Material Detail'),
            body: const AppErrorState(message: 'Material not found.'),
          );
        }

        return AppScaffold(
          appBar: AppBarWidget(
            title: 'Material Detail',
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => context.pushNamed(
                  AppRouteNames.editMaterial,
                  pathParameters: {
                    'id': projectId.toString(),
                    'materialId': materialId.toString(),
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
                // Header: name + unit chip
                Row(
                  children: [
                    Expanded(
                      child: Text(material.name,
                          style: AppTextStyles.headlineSmall),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: LightThemeColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(material.unit.label,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: LightThemeColors.primary)),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Quantity progress
                _QuantityCard(material: material),

                const SizedBox(height: AppSpacing.xl),
                Divider(color: LightThemeColors.border),
                const SizedBox(height: AppSpacing.lg),

                // Details
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Purchase Date',
                  value: DateFormatter.formatFull(material.purchaseDate),
                ),
                if (material.costPerUnit != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DetailRow(
                    icon: Icons.currency_rupee,
                    label: 'Cost / Unit',
                    value: CurrencyFormatter.format(material.costPerUnit!),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DetailRow(
                    icon: Icons.calculate_outlined,
                    label: 'Total Cost',
                    value: CurrencyFormatter.format(material.totalCost),
                  ),
                ],
                if (material.vendorName != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DetailRow(
                    icon: Icons.store_outlined,
                    label: 'Vendor',
                    value: material.vendorName!,
                  ),
                ],
                if (material.notes != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DetailRow(
                    icon: Icons.notes_outlined,
                    label: 'Notes',
                    value: material.notes!,
                  ),
                ],
                if (material.stageId != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _StageRow(
                      projectId: projectId, stageId: material.stageId!),
                ],

                const SizedBox(height: AppSpacing.xxl),
                Divider(color: LightThemeColors.border),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Added ${DateFormatter.formatRelative(material.createdAt)}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: LightThemeColors.textTertiary),
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
      itemName: 'material',
      onDelete: () async {
        await ref
            .read(materialsNotifierProvider(projectId).notifier)
            .deleteMaterial(materialId);
        if (context.mounted) context.pop();
      },
    );
  }
}

class _QuantityCard extends StatelessWidget {
  const _QuantityCard({required this.material});
  final MaterialEntity material;

  @override
  Widget build(BuildContext context) {
    final usedRatio = material.quantityPurchased > 0
        ? (material.quantityUsed / material.quantityPurchased).clamp(0.0, 1.0)
        : 0.0;

    final remaining = material.remaining;
    final statusColor = remaining <= 0
        ? AppColors.error500
        : material.isLowStock
            ? AppColors.warning500
            : AppColors.success500;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LightThemeColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _QtyItem(
                label: 'Purchased',
                value:
                    '${material.quantityPurchased.toStringAsFixed(1)} ${material.unit.label}',
              ),
              _QtyItem(
                label: 'Used',
                value:
                    '${material.quantityUsed.toStringAsFixed(1)} ${material.unit.label}',
              ),
              _QtyItem(
                label: 'Remaining',
                value:
                    '${remaining.toStringAsFixed(1)} ${material.unit.label}',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: usedRatio,
              minHeight: AppDimensions.progressBarHeight,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyItem extends StatelessWidget {
  const _QtyItem({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

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
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color ?? LightThemeColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
        Icon(icon,
            size: AppDimensions.iconSm,
            color: LightThemeColors.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: LightThemeColors.textSecondary)),
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
