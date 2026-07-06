import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/date_formatter.dart';
import '../../../stage/presentation/providers/stage_providers.dart';
import '../../domain/entities/photo_entity.dart';
import '../providers/photo_providers.dart';
import '../widgets/add_photo_sheet.dart';

enum _ViewMode { grid, timeline }

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key, required this.projectId, this.stageId});

  final int projectId;
  final int? stageId;

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  _ViewMode _mode = _ViewMode.grid;
  bool _selecting = false;
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(photosNotifierProvider(widget.projectId));

    // Build stageId -> name lookup from stages (used for tile labels + timeline).
    final stages =
        ref
            .watch(stagesNotifierProvider(widget.projectId))
            .valueOrNull
            ?.stages ??
        const [];
    final stageNames = {for (final s in stages) s.id: s.name};
    final stageOrder = {
      for (var i = 0; i < stages.length; i++) stages[i].id: i,
    };

    // Sync filter to the route's stageId (null clears it). Without this the
    // keep-alive notifier keeps a stale filter from a previous stage-scoped
    // open, so a later unfiltered open would show only that stage's photos.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      async.whenData((s) {
        if (s.stageFilter != widget.stageId) {
          ref
              .read(photosNotifierProvider(widget.projectId).notifier)
              .setStageFilter(widget.stageId);
        }
      });
    });

    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selecting) _exitSelection();
      },
      child: AppScaffold(
        appBar: _selecting ? _buildSelectionBar() : _buildNormalBar(),
        floatingActionButton: _selecting
            ? null
            : FloatingActionButton(
                onPressed: () => showAddPhotoSheet(
                  context,
                  projectId: widget.projectId,
                  presetStageId: widget.stageId,
                ),
                child: const Icon(Icons.add_a_photo_outlined),
              ),
        body: async.when(
          loading: () => const AppLoadingWidget(),
          error: (e, _) => AppErrorState(
            message: 'Failed to load photos.',
            onRetry: () => ref
                .read(photosNotifierProvider(widget.projectId).notifier)
                .refresh(),
          ),
          data: (state) {
            final photos = state.filtered;
            if (photos.isEmpty) {
              return const AppEmptyState(
                title: 'No photos yet',
                subtitle: 'Tap the camera button to add site photos.',
              );
            }
            return _mode == _ViewMode.grid
                ? _GridView(
                    photos: photos,
                    stageNames: stageNames,
                    selecting: _selecting,
                    selected: _selected,
                    onTap: _onTap,
                    onLongPress: _onLongPress,
                  )
                : _TimelineView(
                    photos: photos,
                    stageNames: stageNames,
                    stageOrder: stageOrder,
                    selecting: _selecting,
                    selected: _selected,
                    onTap: _onTap,
                    onLongPress: _onLongPress,
                  );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildNormalBar() {
    return AppBarWidget(
      title: 'Photos',
      actions: [
        IconButton(
          tooltip: _mode == _ViewMode.grid ? 'Timeline view' : 'Grid view',
          icon: Icon(
            _mode == _ViewMode.grid
                ? Icons.timeline_rounded
                : Icons.grid_view_rounded,
          ),
          onPressed: () => setState(() {
            _mode = _mode == _ViewMode.grid
                ? _ViewMode.timeline
                : _ViewMode.grid;
          }),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: 'Cancel',
        onPressed: _exitSelection,
      ),
      title: Text('${_selected.length} selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppColors.error500,
          tooltip: 'Delete',
          onPressed: _selected.isEmpty ? null : _confirmDeleteSelected,
        ),
      ],
    );
  }

  void _onTap(PhotoEntity photo) {
    if (_selecting) {
      _toggle(photo.id);
    } else {
      context.pushNamed(
        AppRouteNames.photoDetail,
        pathParameters: {
          'id': widget.projectId.toString(),
          'photoId': photo.id.toString(),
        },
      );
    }
  }

  void _onLongPress(PhotoEntity photo) {
    if (_selecting) return;
    setState(() {
      _selecting = true;
      _selected.add(photo.id);
    });
  }

  void _toggle(int id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
      if (_selected.isEmpty) _selecting = false; // auto-exit when none left
    });
  }

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  Future<void> _confirmDeleteSelected() async {
    final count = _selected.length;
    await AppDeleteDialog.show(
      context,
      itemName: count == 1 ? 'photo' : '$count photos',
      onDelete: () async {
        final notifier = ref.read(
          photosNotifierProvider(widget.projectId).notifier,
        );
        for (final id in _selected.toList()) {
          await notifier.deletePhoto(id);
        }
        if (mounted) _exitSelection();
      },
    );
  }
}

class _GridView extends StatelessWidget {
  const _GridView({
    required this.photos,
    required this.stageNames,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final List<PhotoEntity> photos;
  final Map<int, String> stageNames;
  final bool selecting;
  final Set<int> selected;
  final void Function(PhotoEntity) onTap;
  final void Function(PhotoEntity) onLongPress;

  @override
  Widget build(BuildContext context) {
    // Cache decode size to the on-screen tile width for smooth scrolling
    // even with many photos.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final tilePx = (MediaQuery.of(context).size.width / 3 * dpr).round();

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
          stageName: photo.stageId == null ? null : stageNames[photo.stageId],
          selecting: selecting,
          selected: selected.contains(photo.id),
          cacheSize: tilePx,
          onTap: () => onTap(photo),
          onLongPress: () => onLongPress(photo),
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.stageName,
    required this.selecting,
    required this.selected,
    required this.cacheSize,
    required this.onTap,
    required this.onLongPress,
  });

  final PhotoEntity photo;
  final String? stageName;
  final bool selecting;
  final bool selected;
  final int cacheSize;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final displayPath = photo.thumbnailPath ?? photo.filePath;
    final file = File(displayPath);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: selected
              ? Border.all(color: LightThemeColors.primary, width: 3)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Stack(
            fit: StackFit.expand,
            children: [
              file.existsSync()
                  ? Image.file(
                      file,
                      fit: BoxFit.cover,
                      cacheWidth: cacheSize,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.low,
                    )
                  : Container(
                      color: AppColors.neutral200,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.neutral400,
                      ),
                    ),
              // Bottom gradient + stage name + date.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.black.withValues(alpha: 0.7),
                        AppColors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (stageName != null)
                        Text(
                          stageName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        DateFormatter.formatShort(photo.takenAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Selection overlay + indicator.
              if (selecting) ...[
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: selected ? 1 : 0,
                  child: Container(
                    color: LightThemeColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 22,
                    color: LightThemeColors.cardBg,
                    shadows: [
                      Shadow(
                        color: AppColors.black.withValues(alpha: 0.54),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Construction Journey Timeline: photos grouped by stage, in stage order,
/// each group showing its photo count.
class _TimelineView extends StatelessWidget {
  const _TimelineView({
    required this.photos,
    required this.stageNames,
    required this.stageOrder,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final List<PhotoEntity> photos;
  final Map<int, String> stageNames;
  final Map<int, int> stageOrder;
  final bool selecting;
  final Set<int> selected;
  final void Function(PhotoEntity) onTap;
  final void Function(PhotoEntity) onLongPress;

  @override
  Widget build(BuildContext context) {
    // Group by stageId (null = "Unassigned").
    final groups = <int?, List<PhotoEntity>>{};
    for (final p in photos) {
      groups.putIfAbsent(p.stageId, () => []).add(p);
    }

    // Order: stage order index, unassigned last.
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return (stageOrder[a] ?? 1 << 30).compareTo(stageOrder[b] ?? 1 << 30);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.pageVertical,
      ),
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final key = keys[i];
        final items = groups[key]!;
        final name = key == null
            ? 'Unassigned'
            : (stageNames[key] ?? 'Stage $key');
        return _TimelineGroup(
          stageName: name,
          photos: items,
          isLast: i == keys.length - 1,
          selecting: selecting,
          selected: selected,
          onTap: onTap,
          onLongPress: onLongPress,
        );
      },
    );
  }
}

class _TimelineGroup extends StatelessWidget {
  const _TimelineGroup({
    required this.stageName,
    required this.photos,
    required this.isLast,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final String stageName;
  final List<PhotoEntity> photos;
  final bool isLast;
  final bool selecting;
  final Set<int> selected;
  final void Function(PhotoEntity) onTap;
  final void Function(PhotoEntity) onLongPress;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail: dot + connector line.
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: LightThemeColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: LightThemeColors.border),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Group content.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(stageName, style: AppTextStyles.titleSmall),
                      ),
                      Text(
                        '${photos.length} '
                        '${photos.length == 1 ? 'photo' : 'photos'}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: LightThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (context, i) {
                        final photo = photos[i];
                        final path = photo.thumbnailPath ?? photo.filePath;
                        final file = File(path);
                        final isSelected = selected.contains(photo.id);
                        return GestureDetector(
                          onTap: () => onTap(photo),
                          onLongPress: () => onLongPress(photo),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                              border: isSelected
                                  ? Border.all(
                                      color: LightThemeColors.primary,
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSm,
                              ),
                              child: SizedBox(
                                width: 84,
                                height: 84,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    file.existsSync()
                                        ? Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                            cacheWidth: 252,
                                            gaplessPlayback: true,
                                          )
                                        : Container(
                                            color: AppColors.neutral200,
                                          ),
                                    if (selecting) ...[
                                      AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        opacity: isSelected ? 1 : 0,
                                        child: Container(
                                          color: LightThemeColors.primary
                                              .withValues(alpha: 0.25),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons
                                                    .radio_button_unchecked_rounded,
                                          size: 20,
                                          color: LightThemeColors.cardBg,
                                          shadows: [
                                            Shadow(
                                              color: AppColors.black.withValues(
                                                alpha: 0.54,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
