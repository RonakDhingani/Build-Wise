import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../expense/domain/entities/expense_entity.dart';
import '../../../expense/presentation/providers/expense_providers.dart';
import '../widgets/settings_card.dart';

class ExpenseCategoriesScreen extends ConsumerWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoriesNotifierProvider);

    return AppScaffold(
      appBar: const AppBarWidget(title: 'Expense Categories'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const AppLoadingWidget(),
        error: (_, _) => AppErrorState(
          message: 'Failed to load categories.',
          onRetry: () =>
              ref.read(categoriesNotifierProvider.notifier).refresh(),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const AppEmptyState(
              title: 'No categories',
              subtitle: 'Tap + to add an expense category.',
            );
          }
          return ListView(
            // Extra bottom padding so the last row's delete button is not
            // covered by the FAB.
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.xxxl + AppDimensions.buttonHeightLg,
            ),
            children: [
              SettingsCard(
                children: [
                  for (final c in categories)
                    _CategoryRow(
                      category: c,
                      onEdit: () => _showEditor(context, ref, existing: c),
                      onDelete: () => _confirmDelete(context, ref, c),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    ExpenseCategoryEntity? existing,
  }) async {
    final controller = TextEditingController(text: existing?.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing == null ? 'Add Category' : 'Edit Category',
          style: AppTextStyles.titleLarge,
        ),
        content: AppTextField(
          label: 'Category Name',
          controller: controller,
          autofocus: true,
          onSubmitted: (_) => Navigator.of(ctx).pop(controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) return;

    final notifier = ref.read(categoriesNotifierProvider.notifier);
    final error = existing == null
        ? await notifier.add(name)
        : await notifier.edit(existing.copyWith(name: name));

    if (error != null && context.mounted) _snack(context, error);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ExpenseCategoryEntity category,
  ) async {
    await AppDeleteDialog.show(
      context,
      itemName: 'category',
      onDelete: () async {
        final error =
            await ref.read(categoriesNotifierProvider.notifier).remove(category.id);
        if (error != null && context.mounted) _snack(context, error);
      },
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseCategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: AppDimensions.iconMd,
              height: AppDimensions.iconMd,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(category.name, style: AppTextStyles.titleSmall),
            ),
            if (category.isDefault)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    'Default',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: LightThemeColors.textSecondary,
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error500,
                size: AppDimensions.iconSm,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
