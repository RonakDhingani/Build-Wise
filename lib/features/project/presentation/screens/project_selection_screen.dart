import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../constants/app_strings.dart';
import '../../../../navigation/app_router.dart';
import '../../../../features/settings/presentation/providers/settings_providers.dart';
import '../../../../features/onboarding/presentation/walkthrough_controller.dart';
import '../../../../features/onboarding/presentation/walkthrough_keys.dart';
import '../../../../features/onboarding/presentation/walkthrough_step.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../domain/entities/project_entity.dart';
import '../notifiers/project_notifier.dart';
import '../providers/project_providers.dart';
import '../widgets/project_card.dart';

class ProjectSelectionScreen extends ConsumerWidget {
  const ProjectSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectsNotifierProvider);

    // Onboarding: auto-start on first run; show the create-project spotlight.
    final completed = ref.watch(walkthroughCompletedProvider);
    final walkStep = ref.watch(walkthroughControllerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(walkthroughControllerProvider.notifier);
      if (walkStep == WalkStep.idle && completed.valueOrNull == false) {
        notifier.beginFirstRun();
      } else if (walkStep == WalkStep.createProject) {
        notifier.maybeShowCoach(
          context,
          WalkStep.createProject,
          key: WalkthroughKeys.createProject,
          shape: ShapeLightFocus.RRect,
          align: ContentAlign.top,
        );
      }
    });

    return AppScaffold(
      appBar: AppBarWidget(
        title: 'BuildWise',
        showBackButton: false,
        actions: [
          state.whenOrNull(
            data: (s) => IconButton(
              icon: Icon(
                s.showArchived
                    ? Icons.inventory_2
                    : Icons.inventory_2_outlined,
                color: s.showArchived
                    ? LightThemeColors.primary
                    : LightThemeColors.textSecondary,
              ),
              tooltip: s.showArchived ? 'Hide archived' : 'Show archived',
              onPressed: () {
                ref.read(projectsNotifierProvider.notifier).toggleShowArchived();
              },
            ),
          ) ?? const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: WalkthroughKeys.createProject,
        onPressed: () => context.pushNamed(AppRouteNames.createProject),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
      body: state.when(
        loading: () => const AppLoadingWidget(message: 'Loading projects...'),
        error: (e, _) => AppErrorState(
          message: e.toString(),
          onRetry: () => ref.refresh(projectsNotifierProvider),
        ),
        data: (s) => _Body(state: s),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.state});
  final ProjectsState state;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  @override
  Widget build(BuildContext context) {
    final filtered = widget.state.filtered;

    return Column(
      children: [
        _SearchBar(
          onChanged: (q) =>
              ref.read(projectsNotifierProvider.notifier).updateSearch(q),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _empty(context, widget.state)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                    AppSpacing.pageHorizontal,
                    100,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, i) => _ProjectItem(project: filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context, ProjectsState state) {
    if (state.searchQuery.isNotEmpty) {
      return AppEmptyState(
        title: 'No results found',
        subtitle: 'No projects match "${state.searchQuery}".',
      );
    }
    if (state.showArchived && state.projects.every((p) => p.status == ProjectStatus.active)) {
      return const AppEmptyState(
        title: 'No archived projects',
        subtitle: 'Projects you archive will appear here.',
      );
    }
    return AppEmptyState(
      title: AppStrings.noProjects,
      subtitle: AppStrings.noProjectsSubtitle,
      action: AppPrimaryButton(
        label: AppStrings.createProject,
        icon: Icons.add,
        width: 200,
        onPressed: () => context.pushNamed(AppRouteNames.createProject),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        0,
      ),
      child: AppSearchField(
        hint: 'Search projects...',
        onChanged: onChanged,
      ),
    );
  }
}

class _ProjectItem extends ConsumerWidget {
  const _ProjectItem({required this.project});
  final ProjectEntity project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch currency so the card re-formats when the user changes it in
    // Settings. Pass the symbol explicitly to avoid relying on the global
    // static being updated before this rebuild.
    final currencySymbol = ref.watch(
      settingsNotifierProvider.select((s) => s.valueOrNull?.currencySymbol),
    );
    return ProjectCard(
      project: project,
      currencySymbol: currencySymbol,
      onTap: () => context.pushNamed(
        AppRouteNames.dashboard,
        pathParameters: {'id': project.id.toString()},
      ),
      onEdit: () => context.pushNamed(
        AppRouteNames.editProject,
        pathParameters: {'id': project.id.toString()},
      ),
      onArchive: () async {
        final notifier = ref.read(projectsNotifierProvider.notifier);
        final isArchiving = project.status == ProjectStatus.active;
        final confirm = await AppConfirmationDialog.show(
          context,
          title: isArchiving
              ? 'Archive ${project.name}?'
              : 'Unarchive ${project.name}?',
          message: isArchiving
              ? 'Project will be hidden from your active list.'
              : 'Project will be restored to your active list.',
          confirmLabel: isArchiving ? 'Archive' : 'Unarchive',
          onConfirm: () => notifier.archiveProject(project.id),
        );
        if (confirm == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArchiving
                    ? '${project.name} archived'
                    : '${project.name} unarchived',
              ),
            ),
          );
        }
      },
      onDelete: () => _confirmDelete(context, ref),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await AppDeleteDialog.show(
      context,
      itemName: project.name,
      onDelete: () {
        ref.read(projectsNotifierProvider.notifier).deleteProject(project.id);
      },
    );
    if (confirm == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${project.name} deleted'),
          backgroundColor: AppColors.error500,
        ),
      );
    }
  }
}
