import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/date_formatter.dart';
import '../providers/photo_providers.dart';

class PhotoDetailScreen extends ConsumerWidget {
  const PhotoDetailScreen({
    super.key,
    required this.projectId,
    required this.photoId,
  });

  final int projectId;
  final int photoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(photosNotifierProvider(projectId));

    return async.when(
      loading: () => const AppScaffold(
        appBar: null,
        body: AppLoadingWidget(),
      ),
      error: (_, __) => AppScaffold(
        appBar: AppBarWidget(title: 'Photo'),
        body: const AppErrorState(message: 'Failed to load photo.'),
      ),
      data: (state) {
        final photo =
            state.photos.where((p) => p.id == photoId).firstOrNull;

        if (photo == null) {
          return AppScaffold(
            appBar: AppBarWidget(title: 'Photo'),
            body: const AppErrorState(message: 'Photo not found.'),
          );
        }

        final file = File(photo.filePath);

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error500),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  child: Center(
                    child: file.existsSync()
                        ? Image.file(file, fit: BoxFit.contain)
                        : const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                  ),
                ),
              ),
              // Info strip
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (photo.caption != null && photo.caption!.isNotEmpty) ...[
                      Text(
                        photo.caption!,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    Text(
                      DateFormatter.formatFull(photo.takenAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    await AppDeleteDialog.show(
      context,
      itemName: 'photo',
      onDelete: () async {
        await ref
            .read(photosNotifierProvider(projectId).notifier)
            .deletePhoto(photoId);
        if (context.mounted) context.pop();
      },
    );
  }
}
