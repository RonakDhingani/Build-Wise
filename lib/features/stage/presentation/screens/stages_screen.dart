import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/date_formatter.dart';
import '../../domain/entities/stage_entity.dart';
import '../notifiers/stage_notifier.dart';
import '../providers/stage_providers.dart';

class StagesScreen extends ConsumerWidget {
  const StagesScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stagesNotifierProvider(projectId));

    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Stages',
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
            onPressed: () => _showSearch(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(
          AppRouteNames.addStage,
          pathParameters: {'id': projectId.toString()},
        ),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorState(
          message: 'Failed to load stages.',
          onRetry: () =>
              ref.read(stagesNotifierProvider(projectId).notifier).refresh(),
        ),
        data: (state) => _Body(projectId: projectId, state: state),
      ),
    );
  }

  void _showSearch(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (_) => _SearchSheet(
        projectId: projectId,
        onChanged: (q) => ref
            .read(stagesNotifierProvider(projectId).notifier)
            .updateSearch(q),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.projectId, required this.state});

  final int projectId;
  final StageState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = state.filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.pageVertical,
            AppSpacing.pageHorizontal,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppSummaryCard(
                  title: 'Total Stages',
                  value: '${state.total}',
                  icon: Icons.layers_outlined,
                  iconColor: LightThemeColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppSummaryCard(
                  title: 'Completed',
                  value: '${state.completedCount}',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.success500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Status filter tabs
        AppFilterTabs(
          tabs: _statusTabs.map((t) => t.label).toList(),
          selectedIndex: _statusTabs.indexWhere(
            (t) => t.status == state.statusFilter,
          ),
          onSelected: (i) => ref
              .read(stagesNotifierProvider(projectId).notifier)
              .setStatusFilter(_statusTabs[i].status),
        ),

        const SizedBox(height: AppSpacing.lg),
        Divider(
          height: 1,
          color: LightThemeColors.border,
          indent: AppSpacing.pageHorizontal,
          endIndent: AppSpacing.pageHorizontal,
        ),

        // List
        Expanded(
          child: filtered.isEmpty
              ? AppEmptyState(
                  title: 'No stages yet',
                  subtitle: state.statusFilter != null
                      ? 'No stages with this status.'
                      : 'Tap + to add your first construction stage.',
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  itemCount: filtered.length,
                  onReorderItem: (oldIndex, newIndex) =>
                      _onReorder(ref, filtered, oldIndex, newIndex),
                  itemBuilder: (context, i) {
                    final stage = filtered[i];
                    return _StageItem(
                      key: ValueKey(stage.id),
                      stage: stage,
                      projectId: projectId,
                      onDelete: () =>
                          _confirmDelete(context, ref, stage.id, projectId),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _onReorder(
    WidgetRef ref,
    List<StageEntity> filtered,
    int oldIndex,
    int newIndex,
  ) async {
    final notifier = ref.read(stagesNotifierProvider(projectId).notifier);
    final reordered = List<StageEntity>.from(filtered);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);

    for (var i = 0; i < reordered.length; i++) {
      if (reordered[i].orderIndex != i) {
        await notifier.updateStage(reordered[i].copyWith(orderIndex: i));
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int stageId,
    int projectId,
  ) async {
    await AppDeleteDialog.show(
      context,
      itemName: 'stage',
      onDelete: () async {
        await ref
            .read(stagesNotifierProvider(projectId).notifier)
            .deleteStage(stageId);
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
}

class _StageItem extends ConsumerWidget {
  const _StageItem({
    super.key,
    required this.stage,
    required this.projectId,
    required this.onDelete,
  });

  final StageEntity stage;
  final int projectId;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      child: AppStageCard(
        orderIndex: stage.orderIndex,
        name: stage.name,
        status: _mapStatus(stage.status),
        progressPercent: stage.progressPercent,
        startDate: stage.startDate != null
            ? DateFormatter.formatShort(stage.startDate!)
            : null,
        endDate: stage.endDate != null
            ? DateFormatter.formatShort(stage.endDate!)
            : null,
        onTap: () => context.pushNamed(
          AppRouteNames.stageDetail,
          pathParameters: {
            'id': projectId.toString(),
            'stageId': stage.id.toString(),
          },
        ),
      ),
    );
  }

  StageCardStatus _mapStatus(StageStatus s) => switch (s) {
    StageStatus.notStarted => StageCardStatus.notStarted,
    StageStatus.inProgress => StageCardStatus.inProgress,
    StageStatus.completed => StageCardStatus.completed,
    StageStatus.onHold => StageCardStatus.onHold,
  };
}

const _statusTabs = [
  (label: 'All', status: null),
  (label: 'Not Started', status: StageStatus.notStarted),
  (label: 'In Progress', status: StageStatus.inProgress),
  (label: 'Completed', status: StageStatus.completed),
  (label: 'On Hold', status: StageStatus.onHold),
];

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({required this.projectId, required this.onChanged});

  final int projectId;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  @override
  void dispose() {
    widget.onChanged('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Search Stages', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),
          AppSearchField(hint: 'Stage name...', onChanged: widget.onChanged),
        ],
      ),
    );
  }
}
