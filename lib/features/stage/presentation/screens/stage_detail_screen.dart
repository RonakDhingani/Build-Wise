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
import '../../../photo/presentation/providers/photo_providers.dart';
import '../../../photo/presentation/widgets/add_photo_sheet.dart';
import '../../domain/entities/stage_entity.dart';
import '../providers/stage_providers.dart';

class StageDetailScreen extends ConsumerWidget {
  const StageDetailScreen({
    super.key,
    required this.projectId,
    required this.stageId,
  });

  final int projectId;
  final int stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stagesNotifierProvider(projectId));

    return async.when(
      loading: () => const AppScaffold(
        appBar: null,
        body: AppLoadingWidget(),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBarWidget(title: 'Stage Detail'),
        body: const AppErrorState(message: 'Failed to load stage.'),
      ),
      data: (state) {
        final stage =
            state.stages.where((s) => s.id == stageId).firstOrNull;

        if (stage == null) {
          return AppScaffold(
            appBar: AppBarWidget(title: 'Stage Detail'),
            body: const AppErrorState(message: 'Stage not found.'),
          );
        }

        return AppScaffold(
          appBar: AppBarWidget(
            title: stage.name,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => context.pushNamed(
                  AppRouteNames.editStage,
                  pathParameters: {
                    'id': projectId.toString(),
                    'stageId': stageId.toString(),
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Delete',
                color: AppColors.error500,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: _DetailBody(
            stage: stage,
            projectId: projectId,
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    await AppDeleteDialog.show(
      context,
      itemName: 'stage',
      onDelete: () async {
        await ref
            .read(stagesNotifierProvider(projectId).notifier)
            .deleteStage(stageId);
        if (context.mounted) context.pop();
      },
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.stage, required this.projectId});

  final StageEntity stage;
  final int projectId;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  late int _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.stage.progressPercent;
  }

  @override
  void didUpdateWidget(_DetailBody old) {
    super.didUpdateWidget(old);
    if (old.stage.progressPercent != widget.stage.progressPercent) {
      _progress = widget.stage.progressPercent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;
    final statusColor = _statusColor(stage.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.pageVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _statusLabel(stage.status),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (stage.isDefault) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    'Default',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: LightThemeColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Progress section
          _SectionCard(
            title: 'Progress',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_progress%',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: statusColor,
                      ),
                    ),
                    Text(
                      'Drag to update',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: LightThemeColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: _progress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: statusColor,
                    inactiveColor: AppColors.neutral200,
                    onChanged: (v) => setState(() => _progress = v.round()),
                    onChangeEnd: (v) => ref
                        .read(stagesNotifierProvider(widget.projectId).notifier)
                        .updateProgress(stage.id, v.round()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Dates
          if (stage.startDate != null || stage.endDate != null)
            _SectionCard(
              title: 'Timeline',
              child: Row(
                children: [
                  if (stage.startDate != null)
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.play_circle_outline_rounded,
                        label: 'Start',
                        value: DateFormatter.format(stage.startDate!),
                      ),
                    ),
                  if (stage.startDate != null && stage.endDate != null)
                    const SizedBox(width: AppSpacing.md),
                  if (stage.endDate != null)
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.flag_outlined,
                        label: 'End',
                        value: DateFormatter.format(stage.endDate!),
                      ),
                    ),
                ],
              ),
            ),

          if (stage.startDate != null || stage.endDate != null)
            const SizedBox(height: AppSpacing.lg),

          // Notes
          if (stage.notes != null && stage.notes!.isNotEmpty)
            _SectionCard(
              title: 'Notes',
              child: Text(
                stage.notes!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: LightThemeColors.textSecondary,
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Progress photos
          _StagePhotosSection(
            projectId: widget.projectId,
            stageId: stage.id,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _QuickStatusButton(
                  label: 'Mark In Progress',
                  icon: Icons.play_arrow_rounded,
                  color: AppColors.navy500,
                  enabled: stage.status != StageStatus.inProgress,
                  onTap: () => _updateStatus(StageStatus.inProgress),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickStatusButton(
                  label: 'Mark Complete',
                  icon: Icons.check_rounded,
                  color: AppColors.success500,
                  enabled: stage.status != StageStatus.completed,
                  onTap: () => _updateStatus(StageStatus.completed),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Created / updated
          Text(
            'Created ${DateFormatter.formatFull(stage.createdAt)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: LightThemeColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(StageStatus status) async {
    final updated = widget.stage.copyWith(status: status);
    await ref
        .read(stagesNotifierProvider(widget.projectId).notifier)
        .updateStage(updated);
  }

  Color _statusColor(StageStatus s) => switch (s) {
        StageStatus.notStarted => AppColors.neutral400,
        StageStatus.inProgress => AppColors.navy500,
        StageStatus.completed => AppColors.success500,
        StageStatus.onHold => AppColors.warning500,
      };

  String _statusLabel(StageStatus s) => switch (s) {
        StageStatus.notStarted => 'Not Started',
        StageStatus.inProgress => 'In Progress',
        StageStatus.completed => 'Completed',
        StageStatus.onHold => 'On Hold',
      };
}

class _StagePhotosSection extends ConsumerWidget {
  const _StagePhotosSection({
    required this.projectId,
    required this.stageId,
  });

  final int projectId;
  final int stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref
            .watch(photosNotifierProvider(projectId))
            .valueOrNull
            ?.photos
            .where((p) => p.stageId == stageId)
            .toList() ??
        const [];

    return _SectionCard(
      title: 'Progress Photos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photos.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'No photos for this stage yet.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: LightThemeColors.textTertiary,
                ),
              ),
            )
          else ...[
            // Only shown once at least one photo exists.
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.pushNamed(
                  AppRouteNames.photos,
                  pathParameters: {'id': projectId.toString()},
                ),
                icon: const Icon(Icons.collections_outlined, size: 18),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, i) {
                  final photo = photos[i];
                  final file = File(photo.thumbnailPath ?? photo.filePath);
                  return GestureDetector(
                    onTap: () => context.pushNamed(
                      AppRouteNames.photoDetail,
                      pathParameters: {
                        'id': projectId.toString(),
                        'photoId': photo.id.toString(),
                      },
                      queryParameters: {'stageId': stageId.toString()},
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSm),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: file.existsSync()
                            ? Image.file(file, fit: BoxFit.cover)
                            : Container(color: AppColors.neutral200),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          AppOutlineButton(
            label: 'Add Progress Photo',
            icon: Icons.add_a_photo_outlined,
            onPressed: () => showAddPhotoSheet(
              context,
              projectId: projectId,
              presetStageId: stageId,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LightThemeColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: LightThemeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium.copyWith(
            color: LightThemeColors.textTertiary,
          )),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
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
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: LightThemeColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: LightThemeColors.textTertiary,
                )),
            Text(value, style: AppTextStyles.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _QuickStatusButton extends StatelessWidget {
  const _QuickStatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
