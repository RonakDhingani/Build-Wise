import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/permissions/permission_service.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../stage/presentation/providers/stage_providers.dart';
import '../../domain/entities/photo_entity.dart';
import '../providers/photo_providers.dart';
import '../services/photo_picker_service.dart';

/// Opens the add-photo flow: pick a source, then choose stage + optional note
/// before saving. [presetStageId] pre-selects a stage (used from a stage
/// screen). Returns once the sheet is dismissed.
Future<void> showAddPhotoSheet(
  BuildContext context, {
  required int projectId,
  int? presetStageId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLg),
      ),
    ),
    builder: (_) => _AddPhotoSheet(
      projectId: projectId,
      presetStageId: presetStageId,
    ),
  );
}

class _AddPhotoSheet extends ConsumerStatefulWidget {
  const _AddPhotoSheet({required this.projectId, this.presetStageId});

  final int projectId;
  final int? presetStageId;

  @override
  ConsumerState<_AddPhotoSheet> createState() => _AddPhotoSheetState();
}

class _AddPhotoSheetState extends ConsumerState<_AddPhotoSheet> {
  PhotoPickResult? _pick;
  int? _stageId;
  final _noteController = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _stageId = widget.presetStageId;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _pick == null ? 'Add Progress Photo' : 'Photo Details',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: AppLoadingWidget()),
                )
              else if (_pick == null)
                ..._buildSourceOptions()
              else
                ..._buildDetailForm(),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSourceOptions() {
    return [
      _SourceOption(
        icon: Icons.camera_alt_outlined,
        label: 'Take Photo',
        onTap: () => _pickFrom(fromCamera: true),
      ),
      const SizedBox(height: AppSpacing.sm),
      _SourceOption(
        icon: Icons.photo_library_outlined,
        label: 'Choose from Gallery',
        onTap: () => _pickFrom(fromCamera: false),
      ),
    ];
  }

  List<Widget> _buildDetailForm() {
    final stages = ref
            .read(stagesNotifierProvider(widget.projectId))
            .valueOrNull
            ?.stages ??
        const [];
    final file = File(_pick!.thumbnailPath ?? _pick!.filePath);

    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: file.existsSync()
              ? Image.file(file, fit: BoxFit.cover)
              : Container(color: AppColors.neutral200),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      AppDropdownField<int?>(
        label: 'Stage',
        hint: 'Select a stage',
        value: _stageId,
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('No stage'),
          ),
          for (final s in stages)
            DropdownMenuItem<int?>(value: s.id, child: Text(s.name)),
        ],
        onChanged: (v) => setState(() => _stageId = v),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Note (optional)',
        hint: 'e.g. Slab casting completed',
        controller: _noteController,
        maxLines: 2,
        maxLength: 200,
      ),
      const SizedBox(height: AppSpacing.md),
      AppPrimaryButton(
        label: 'Save Photo',
        icon: Icons.check_rounded,
        isLoading: _busy,
        onPressed: _save,
      ),
    ];
  }

  Future<void> _pickFrom({required bool fromCamera}) async {
    // Just-in-time permission: check/request before opening camera or gallery.
    final permissions = ref.read(permissionServiceProvider);
    final allowed = fromCamera
        ? await permissions.ensureCamera(context)
        : await permissions.ensureGallery(context);
    if (!mounted) return;
    // Denied / sent to Settings → close this sheet so the user returns to a
    // clean, interactive screen (no stuck modal) instead of a frozen sheet.
    if (!allowed) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      return;
    }

    setState(() => _busy = true);
    try {
      final service = ref.read(photoPickerServiceProvider);
      final result = fromCamera
          ? await service.pickFromCamera(widget.projectId)
          : await service.pickFromGallery(widget.projectId);

      if (!mounted) return;
      if (result == null) {
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        _pick = result;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick photo: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (_pick == null) return;
    setState(() => _busy = true);
    try {
      final note = _noteController.text.trim();
      final entity = PhotoEntity(
        id: 0,
        projectId: widget.projectId,
        stageId: _stageId,
        filePath: _pick!.filePath,
        thumbnailPath: _pick!.thumbnailPath,
        caption: note.isEmpty ? null : note,
        takenAt: _pick!.takenAt,
        createdAt: DateTime.now(),
      );

      await ref
          .read(photosNotifierProvider(widget.projectId).notifier)
          .addPhoto(entity);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save photo: $e')),
      );
    }
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: LightThemeColors.primaryLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Icon(icon, color: LightThemeColors.primary),
      ),
      title: Text(label, style: AppTextStyles.bodyMedium),
      contentPadding: EdgeInsets.zero,
    );
  }
}
