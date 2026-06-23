import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/date_formatter.dart';
import '../../../stage/presentation/providers/stage_providers.dart';
import '../providers/photo_providers.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  const PhotoDetailScreen({
    super.key,
    required this.projectId,
    required this.photoId,
    this.stageId,
  });

  final int projectId;
  final int photoId;

  /// When set, the viewer swipes only this stage's photos (stage detail
  /// strip). Otherwise it follows the gallery's current filtered list.
  final int? stageId;

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  PageController? _controller;
  int _index = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(photosNotifierProvider(widget.projectId));

    return async.when(
      loading: () => const AppScaffold(appBar: null, body: AppLoadingWidget()),
      error: (_, __) => AppScaffold(
        appBar: AppBarWidget(title: 'Photo'),
        body: const AppErrorState(message: 'Failed to load photo.'),
      ),
      data: (state) {
        // Scoped to one stage when stageId given (stage detail strip);
        // otherwise the gallery's current filtered list.
        final photos = widget.stageId != null
            ? state.photos.where((p) => p.stageId == widget.stageId).toList()
            : state.filtered;
        if (photos.isEmpty) {
          return AppScaffold(
            appBar: AppBarWidget(title: 'Photo'),
            body: const AppErrorState(message: 'Photo not found.'),
          );
        }

        // First build: position PageView on the tapped photo.
        if (_controller == null) {
          final initial = photos.indexWhere((p) => p.id == widget.photoId);
          _index = initial < 0 ? 0 : initial;
          _controller = PageController(initialPage: _index);
        }

        // Keep index valid after deletions.
        if (_index >= photos.length) _index = photos.length - 1;

        final current = photos[_index];
        final stageName = current.stageId == null
            ? null
            : ref
                .watch(stagesNotifierProvider(widget.projectId))
                .valueOrNull
                ?.stages
                .where((s) => s.id == current.stageId)
                .firstOrNull
                ?.name;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              '${_index + 1} / ${photos.length}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
                tooltip: 'Share',
                onPressed: () => _share(current.filePath, current.caption),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error500),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, current.id),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: photos.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final file = File(photos[i].filePath);
                    return InteractiveViewer(
                      minScale: 1,
                      maxScale: 5,
                      child: Center(
                        child: file.existsSync()
                            ? Image.file(
                                file,
                                fit: BoxFit.contain,
                                gaplessPlayback: true,
                                filterQuality: FilterQuality.medium,
                              )
                            : const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white54,
                                size: 64,
                              ),
                      ),
                    );
                  },
                ),
              ),
              _InfoStrip(
                stageName: stageName,
                caption: current.caption,
                takenAt: current.takenAt,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _share(String filePath, String? caption) async {
    final file = File(filePath);
    if (!file.existsSync()) return;
    await Share.shareXFiles([XFile(filePath)], text: caption);
  }

  Future<void> _confirmDelete(BuildContext context, int photoId) async {
    await AppDeleteDialog.show(
      context,
      itemName: 'photo',
      onDelete: () async {
        final state =
            ref.read(photosNotifierProvider(widget.projectId)).valueOrNull;
        final remaining = state == null
            ? 0
            : (widget.stageId != null
                    ? state.photos.where((p) => p.stageId == widget.stageId)
                    : state.filtered)
                .length;
        await ref
            .read(photosNotifierProvider(widget.projectId).notifier)
            .deletePhoto(photoId);
        // Last photo deleted -> leave the viewer.
        if (remaining <= 1 && context.mounted) context.pop();
      },
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.stageName,
    required this.caption,
    required this.takenAt,
  });

  final String? stageName;
  final String? caption;
  final DateTime takenAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          if (stageName != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.layers_outlined,
                    color: Colors.white70, size: 14),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  stageName!,
                  style:
                      AppTextStyles.labelMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (caption != null && caption!.isNotEmpty) ...[
            Text(
              caption!,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            DateFormatter.formatFull(takenAt),
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
