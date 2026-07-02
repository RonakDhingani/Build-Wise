import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../project/presentation/actions/project_actions.dart';
import '../../../project/presentation/providers/project_providers.dart';

enum _ProjectAction { edit, archive, delete }

class ManageProjectsScreen extends ConsumerWidget {
  const ManageProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(projectsNotifierProvider);

    return AppScaffold(
      appBar: const AppBarWidget(title: 'Manage Projects'),
      body: async.when(
        loading: () => const AppLoadingWidget(),
        error: (_, _) => AppErrorState(
          message: 'Failed to load projects.',
          onRetry: () => ref.read(projectsNotifierProvider.notifier).refresh(),
        ),
        data: (state) {
          final projects = state.projects;
          if (projects.isEmpty) {
            return const AppEmptyState(
              title: 'No projects yet',
              subtitle: 'Create your first project to manage it here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            itemCount: projects.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.itemGap),
            itemBuilder: (context, i) => _ProjectRow(project: projects[i]),
          );
        },
      ),
    );
  }
}

class _ProjectRow extends ConsumerWidget {
  const _ProjectRow({required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArchived = project.status == ProjectStatus.archived;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: LightThemeColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: LightThemeColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        project.name,
                        style: AppTextStyles.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isArchived) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _Badge(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  project.location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: LightThemeColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<_ProjectAction>(
            icon: Icon(Icons.more_vert, color: LightThemeColors.textSecondary),
            onSelected: (action) => _onAction(context, ref, action),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _ProjectAction.edit,
                child: Text('Edit'),
              ),
              if (!isArchived)
                const PopupMenuItem(
                  value: _ProjectAction.archive,
                  child: Text('Archive'),
                ),
              const PopupMenuItem(
                value: _ProjectAction.delete,
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onAction(
    BuildContext context,
    WidgetRef ref,
    _ProjectAction action,
  ) {
    switch (action) {
      case _ProjectAction.edit:
        ProjectActions.edit(context, project);
      case _ProjectAction.archive:
        ProjectActions.archive(context, ref, project);
      case _ProjectAction.delete:
        // Manage Projects lives under the project you came from (`:id`). If that
        // project is the one being deleted, ProjectActions leaves its context
        // and returns to the Project Listing (Case 2); deleting any other
        // project just stays here (Case 1).
        final activeId = int.tryParse(
          GoRouterState.of(context).pathParameters['id'] ?? '',
        );
        ProjectActions.delete(context, project, activeProjectId: activeId);
    }
  }
}

class _Badge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        'Archived',
        style: AppTextStyles.labelSmall.copyWith(
          color: LightThemeColors.textSecondary,
        ),
      ),
    );
  }
}
