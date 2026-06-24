import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../expense/presentation/providers/expense_providers.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../../settings/presentation/widgets/settings_tile.dart';
import '../../data/models/backup_bundle.dart';
import '../../domain/backup_format.dart';
import '../providers/backup_providers.dart';

/// Shows a validated backup's contents, then lets the user restore it as a new
/// project or replace an existing one.
class ImportPreviewScreen extends ConsumerStatefulWidget {
  const ImportPreviewScreen({
    super.key,
    required this.projectId,
    required this.zipPath,
  });

  final int projectId;
  final String zipPath;

  @override
  ConsumerState<ImportPreviewScreen> createState() =>
      _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends ConsumerState<ImportPreviewScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(backupBundleProvider(widget.zipPath));

    return AppScaffold(
      appBar: const AppBarWidget(title: 'Import Backup'),
      body: Stack(
        children: [
          async.when(
            loading: () => const AppLoadingWidget(),
            error: (e, _) => AppErrorState(
              message: e is BackupException
                  ? e.message
                  : 'This backup file could not be read.',
            ),
            data: (bundle) => _Content(
              bundle: bundle,
              onCreateNew: () => _import(bundle, ImportMode.createNew),
              onReplace: () => _pickReplaceTarget(bundle),
            ),
          ),
          if (_busy) _busyOverlay(),
        ],
      ),
    );
  }

  // ---- Replace target selection -------------------------------------------

  Future<void> _pickReplaceTarget(BackupBundle bundle) async {
    final state = ref.read(projectsNotifierProvider).valueOrNull;
    final projects = state?.projects ?? const <ProjectEntity>[];
    if (projects.isEmpty) {
      _showError('There are no existing projects to replace.');
      return;
    }

    final target = await AppBottomSheet.show<ProjectEntity>(
      context,
      title: 'Replace which project?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in projects)
            SettingsTile(
              icon: Icons.folder_outlined,
              iconColor: AppColors.navy400,
              title: p.name,
              subtitle: p.location,
              onTap: () => Navigator.of(context).pop(p),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
    if (target == null || !mounted) return;

    AppConfirmationDialog.show(
      context,
      title: 'Replace "${target.name}"?',
      message: 'The existing project, including all its expenses, materials, '
          'stages and photos, will be permanently deleted and replaced with '
          'the imported project.\n\nThis action cannot be undone.',
      confirmLabel: 'Replace',
      isDangerous: true,
      onConfirm: () => _import(
        bundle,
        ImportMode.replaceExisting,
        targetProjectId: target.id,
      ),
    );
  }

  // ---- Run import ----------------------------------------------------------

  Future<void> _import(
    BackupBundle bundle,
    ImportMode mode, {
    int? targetProjectId,
  }) async {
    setState(() => _busy = true);
    try {
      final summary = await ref.read(backupImportServiceProvider).performImport(
            bundle,
            mode: mode,
            targetProjectId: targetProjectId,
          );
      if (!mounted) return;

      // Refresh anything that depends on projects / categories.
      ref.invalidate(projectsNotifierProvider);
      ref.invalidate(categoriesNotifierProvider);
      ref.invalidate(expenseCategoriesProvider);

      setState(() => _busy = false);

      final restored = summary.replacedProjectName != null
          ? 'Replaced "${summary.replacedProjectName}".'
          : '${summary.projectsCreated} project(s) added.';
      final photoNote = summary.photosMissing > 0
          ? ' ${summary.photosMissing} photo(s) could not be restored.'
          : '';

      await AppSuccessDialog.show(
        context,
        title: 'Restore Complete',
        message: '$restored$photoNote',
      );
      if (!mounted) return;
      // Back to the project list so the user can open the restored project.
      context.goNamed(AppRouteNames.projects);
    } on BackupException catch (e) {
      setState(() => _busy = false);
      _showError(e.message);
    } catch (_) {
      setState(() => _busy = false);
      _showError('Import failed. Please try again.');
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Import failed', style: AppTextStyles.titleLarge),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium
              .copyWith(color: LightThemeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _busyOverlay() {
    return const Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.bundle,
    required this.onCreateNew,
    required this.onReplace,
  });

  final BackupBundle bundle;
  final VoidCallback onCreateNew;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final m = bundle.manifest;
    final counts = m.counts;
    final created = DateFormat('d MMMM yyyy').format(m.createdAt);
    final scopeLabel = m.scope == BackupScope.allProjects
        ? 'All projects'
        : 'Single project';

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: LightThemeColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: LightThemeColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        color: LightThemeColors.primary,
                        size: AppDimensions.iconMd),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Backup Found', style: AppTextStyles.titleMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _Stat('Projects', counts.projects),
                _Stat('Expenses', counts.expenses),
                _Stat('Materials', counts.materials),
                _Stat('Stages', counts.stages),
                _Stat('Photos', counts.photos),
                _Stat('Categories', counts.categories),
                Divider(height: AppSpacing.xl, color: LightThemeColors.border),
                _MetaRow('Scope', scopeLabel),
                _MetaRow('Created', created),
                _MetaRow('App version', m.appVersion),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Choose how to import', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSpacing.md),
          _ModeCard(
            icon: Icons.add_circle_outline,
            iconColor: AppColors.success500,
            title: 'Create New Project',
            badge: 'Recommended',
            subtitle: bundle.isSingleProject
                ? 'Add the backup as a brand-new project. Nothing existing is '
                    'changed.'
                : 'Add all ${counts.projects} backed-up projects as new '
                    'projects. Nothing existing is changed.',
            onTap: onCreateNew,
          ),
          const SizedBox(height: AppSpacing.md),
          _ModeCard(
            icon: Icons.swap_horiz_rounded,
            iconColor: AppColors.error500,
            title: 'Replace Existing Project',
            subtitle: bundle.isSingleProject
                ? 'Delete a chosen project and restore this backup in its '
                    'place. This cannot be undone.'
                : 'Only available for single-project backups.',
            onTap: bundle.isSingleProject ? onReplace : null,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: LightThemeColors.textSecondary)),
          Text('$value',
              style: AppTextStyles.titleSmall
                  .copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: LightThemeColors.textTertiary)),
          Text(value, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: LightThemeColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: LightThemeColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppDimensions.avatarSm + AppSpacing.xs,
                  height: AppDimensions.avatarSm + AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(icon,
                      color: iconColor, size: AppDimensions.iconSm),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(title,
                                style: AppTextStyles.titleSmall),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success500
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm),
                              ),
                              child: Text(
                                badge!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.success500,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: LightThemeColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
