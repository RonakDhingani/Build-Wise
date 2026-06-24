import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_shadows.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/currency_formatter.dart';
import '../../../../utils/date_formatter.dart';
import '../../domain/entities/project_entity.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.currencySymbol,
    this.onEdit,
    this.onArchive,
    this.onDelete,
  });

  final ProjectEntity project;
  final String? currencySymbol;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  Color get _budgetColor {
    final pct = project.spentPercent;
    if (pct < 0.75) return AppColors.success500;
    if (pct < 0.90) return AppColors.warning500;
    return AppColors.error500;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: (onEdit != null || onArchive != null || onDelete != null)
          ? () => _showContextMenu(context)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: LightThemeColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image or gradient header
            _Header(project: project),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: AppTextStyles.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: AppColors.neutral400,
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    project.location,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: LightThemeColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (project.status == ProjectStatus.archived)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            'Archived',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: LightThemeColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Budget row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Budget', style: AppTextStyles.labelSmall.copyWith(
                            color: LightThemeColors.textTertiary,
                          )),
                          Text(
                            CurrencyFormatter.formatCompact(
                              project.budget,
                              symbol: currencySymbol,
                            ),
                            style: AppTextStyles.titleSmall,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Spent', style: AppTextStyles.labelSmall.copyWith(
                            color: LightThemeColors.textTertiary,
                          )),
                          Text(
                            CurrencyFormatter.formatCompact(
                              project.totalSpent,
                              symbol: currencySymbol,
                            ),
                            style: AppTextStyles.titleSmall.copyWith(
                              color: _budgetColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Budget progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    child: LinearProgressIndicator(
                      value: project.spentPercent,
                      minHeight: AppDimensions.progressBarThin,
                      backgroundColor: AppColors.neutral200,
                      valueColor: AlwaysStoppedAnimation<Color>(_budgetColor),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Footer: completion + date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${project.completionPercentage.toInt()}% complete',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: LightThemeColors.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormatter.format(project.startDate),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: LightThemeColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
        child: Material(
          color: LightThemeColors.surface,
          child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(project.name, style: AppTextStyles.titleMedium),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (onEdit != null)
                _ContextMenuItem(
                  icon: Icons.edit_outlined,
                  label: 'Edit Project',
                  onTap: () {
                    Navigator.pop(context);
                    onEdit!();
                  },
                ),
              if (onArchive != null)
                _ContextMenuItem(
                  icon: project.status == ProjectStatus.active
                      ? Icons.archive_outlined
                      : Icons.unarchive_outlined,
                  label: project.status == ProjectStatus.active
                      ? 'Archive Project'
                      : 'Unarchive Project',
                  onTap: () {
                    Navigator.pop(context);
                    onArchive!();
                  },
                ),
              if (onDelete != null)
                _ContextMenuItem(
                  icon: Icons.delete_outline,
                  label: 'Delete Project',
                  color: AppColors.error500,
                  onTap: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.project});
  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusMd),
      ),
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              LightThemeColors.primary,
              LightThemeColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: AppColors.white,
                  size: AppDimensions.iconSm,
                ),
              ),
              const Spacer(),
              Text(
                '${project.completionPercentage.toInt()}%',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LightThemeColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: c)),
      onTap: onTap,
    );
  }
}
