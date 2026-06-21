import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/entities/photo_entity.dart';
import '../notifiers/photo_notifier.dart';
import '../providers/photo_providers.dart';

class PhotosScreen extends ConsumerWidget {
  const PhotosScreen({
    super.key,
    required this.projectId,
    this.stageId,
  });

  final int projectId;
  final int? stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(photosNotifierProvider(projectId));

    // Apply stage filter if provided via route
    if (stageId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        async.whenData((s) {
          if (s.stageFilter != stageId) {
            ref
                .read(photosNotifierProvider(projectId).notifier)
                .setStageFilter(stageId);
          }
        });
      });
    }

    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Photos',
        actions: [
          if (async.valueOrNull != null &&
              async.value!.photos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: Text(
                  '${async.value!.count}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: LightThemeColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPickerSheet(context, ref),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: async.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorState(
          message: 'Failed to load photos.',
          onRetry: () =>
              ref.read(photosNotifierProvider(projectId).notifier).refresh(),
        ),
        data: (state) => _Body(projectId: projectId, state: state),
      ),
    );
  }

  void _showPickerSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (_) => _PickerSheet(projectId: projectId),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.projectId, required this.state});

  final int projectId;
  final PhotoState state;

  @override
  Widget build(BuildContext context) {
    final photos = state.filtered;

    if (photos.isEmpty) {
      return const AppEmptyState(
        title: 'No photos yet',
        subtitle: 'Tap the camera button to add site photos.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) {
        final photo = photos[i];
        return _PhotoTile(
          photo: photo,
          projectId: projectId,
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.projectId});

  final PhotoEntity photo;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final displayPath = photo.thumbnailPath ?? photo.filePath;
    final file = File(displayPath);

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRouteNames.photoDetail,
        pathParameters: {
          'id': projectId.toString(),
          'photoId': photo.id.toString(),
        },
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: file.existsSync()
            ? Image.file(file, fit: BoxFit.cover)
            : Container(
                color: AppColors.neutral200,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.neutral400,
                ),
              ),
      ),
    );
  }
}

class _PickerSheet extends ConsumerStatefulWidget {
  const _PickerSheet({required this.projectId});

  final int projectId;

  @override
  ConsumerState<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends ConsumerState<_PickerSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.pageHorizontal,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Photo', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            if (_isLoading)
              const Center(child: AppLoadingWidget())
            else ...[
              _PickerOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                onTap: () => _pick(fromCamera: true),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PickerOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                onTap: () => _pick(fromCamera: false),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _pick({required bool fromCamera}) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(photoPickerServiceProvider);
      final result = fromCamera
          ? await service.pickFromCamera(widget.projectId)
          : await service.pickFromGallery(widget.projectId);

      if (result == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final entity = PhotoEntity(
        id: 0,
        projectId: widget.projectId,
        filePath: result.filePath,
        thumbnailPath: result.thumbnailPath,
        takenAt: result.takenAt,
        createdAt: DateTime.now(),
      );

      await ref
          .read(photosNotifierProvider(widget.projectId).notifier)
          .addPhoto(entity);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
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
