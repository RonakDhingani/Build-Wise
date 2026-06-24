import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../settings/presentation/widgets/settings_group.dart';
import '../../../settings/presentation/widgets/settings_tile.dart';
import '../../data/models/backup_result.dart';
import '../../domain/backup_format.dart';
import '../providers/backup_providers.dart';

/// Settings → Data Management. Offline export, import and restore. Everything
/// here works without a backend, cloud service or internet connection.
class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key, required this.projectId});

  final int projectId;

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  bool _busy = false;
  String _busyLabel = '';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(title: 'Data Management'),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.xxxl,
              ),
              children: [
                _OfflineBanner(),
                const SizedBox(height: AppSpacing.xl),
                SettingsGroup(
                  title: 'Backup',
                  children: [
                    SettingsTile(
                      icon: Icons.archive_outlined,
                      iconColor: AppColors.navy400,
                      title: 'Export Current Project',
                      subtitle: 'Back up the selected project and its data',
                      onTap: () => _showExportSheet(BackupScope.currentProject),
                    ),
                    SettingsTile(
                      icon: Icons.dns_outlined,
                      iconColor: AppColors.violet,
                      title: 'Export All Projects',
                      subtitle: 'Back up every project in BuildWise',
                      onTap: () => _showExportSheet(BackupScope.allProjects),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                SettingsGroup(
                  title: 'Restore',
                  children: [
                    SettingsTile(
                      icon: Icons.download_outlined,
                      iconColor: AppColors.success500,
                      title: 'Import Data',
                      subtitle: 'Restore from a BuildWise backup file (.zip)',
                      onTap: _pickAndPreview,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_busy) _LoadingOverlay(label: _busyLabel),
        ],
      ),
    );
  }

  // ---- Export --------------------------------------------------------------

  Future<void> _showExportSheet(BackupScope scope) async {
    final isAll = scope == BackupScope.allProjects;
    await AppBottomSheet.show<void>(
      context,
      title: isAll ? 'Export All Projects' : 'Export Current Project',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Includes:', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.md),
            ...const [
              'Project Details',
              'Expenses',
              'Materials',
              'Stages',
              'Photos',
              'Categories',
            ].map(_IncludeRow.new),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: 'Export',
              icon: Icons.archive_outlined,
              onPressed: () {
                Navigator.of(context).pop();
                _runExport(scope);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runExport(BackupScope scope) async {
    _setBusy('Creating backup…');
    try {
      final result = await ref.read(backupExportServiceProvider).export(
            scope: scope,
            projectId: scope == BackupScope.currentProject
                ? widget.projectId
                : null,
          );
      if (!mounted) return;
      _clearBusy();
      await _showExportResult(result);
    } on BackupException catch (e) {
      _clearBusy();
      _showError(e.message);
    } catch (e) {
      _clearBusy();
      _showError('Export failed. Please try again.');
    }
  }

  Future<void> _showExportResult(BackupResult result) async {
    await AppBottomSheet.show<void>(
      context,
      title: 'Backup Created Successfully',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle,
                    color: AppColors.success500, size: AppDimensions.iconLg),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    result.fileName,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${_formatBytes(result.sizeBytes)} • '
              '${result.manifest.counts.projects} project(s)',
              style: AppTextStyles.bodySmall
                  .copyWith(color: LightThemeColors.textSecondary),
            ),
            if (result.skippedPhotos > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${result.skippedPhotos} photo(s) were skipped (file missing).',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.gold400),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SettingsTile(
              icon: Icons.ios_share,
              iconColor: AppColors.navy400,
              title: 'Share File',
              subtitle: 'Send the backup to another device or app',
              onTap: () {
                Navigator.of(context).pop();
                _shareFile(result.filePath);
              },
            ),
            SettingsTile(
              icon: Icons.save_alt,
              iconColor: AppColors.success500,
              title: 'Save File',
              subtitle: 'Choose a folder to store the backup',
              onTap: () {
                Navigator.of(context).pop();
                _saveFile(result);
              },
            ),
            SettingsTile(
              icon: Icons.folder_open_outlined,
              iconColor: AppColors.gold400,
              title: 'Open File Location',
              subtitle: 'Show where the backup is stored',
              onTap: () {
                Navigator.of(context).pop();
                _showLocation(result.filePath);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareFile(String path) async {
    try {
      await Share.shareXFiles([XFile(path)], subject: 'BuildWise Backup');
    } catch (_) {
      _showError('Could not share the backup file.');
    }
  }

  Future<void> _saveFile(BackupResult result) async {
    try {
      final bytes = await File(result.filePath).readAsBytes();
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Save BuildWise Backup',
        fileName: result.fileName,
        bytes: bytes,
      );
      if (!mounted) return;
      if (saved != null) {
        _toast('Backup saved.');
      }
    } catch (_) {
      _showError('Could not save the backup file.');
    }
  }

  void _showLocation(String path) {
    final dir = path.substring(0, path.lastIndexOf('/'));
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Backup Location', style: AppTextStyles.titleLarge),
        content: Text(
          dir,
          style: AppTextStyles.bodySmall
              .copyWith(color: LightThemeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ---- Import --------------------------------------------------------------

  Future<void> _pickAndPreview() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: false,
      );
      final path = result?.files.single.path;
      if (path == null) return; // cancelled
      if (!mounted) return;
      context.pushNamed(
        AppRouteNames.importPreview,
        pathParameters: {'id': widget.projectId.toString()},
        extra: path,
      );
    } catch (_) {
      _showError('Could not open the file picker.');
    }
  }

  // ---- Helpers -------------------------------------------------------------

  void _setBusy(String label) {
    setState(() {
      _busy = true;
      _busyLabel = label;
    });
  }
  void _clearBusy() {
    if (mounted) setState(() => _busy = false);
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Something went wrong', style: AppTextStyles.titleLarge),
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

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.info500.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.info500.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined,
              color: AppColors.info500, size: AppDimensions.iconMd),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Backups are fully offline. Move the file to another device to '
              'transfer your projects.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: LightThemeColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncludeRow extends StatelessWidget {
  const _IncludeRow(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.check_rounded,
              color: AppColors.success500, size: AppDimensions.iconSm),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
