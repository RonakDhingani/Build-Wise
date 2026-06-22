import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_spacing.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_option_tile.dart';

class DefaultProjectScreen extends ConsumerWidget {
  const DefaultProjectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final defaultId = settings.valueOrNull?.defaultProjectId;

    return AppScaffold(
      appBar: const AppBarWidget(title: 'Default Project'),
      body: projectsAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (_, _) => AppErrorState(
          message: 'Failed to load projects.',
          onRetry: () => ref.read(projectsNotifierProvider.notifier).refresh(),
        ),
        data: (state) {
          final projects = state.projects
              .where((p) => p.status == ProjectStatus.active)
              .toList();

          if (projects.isEmpty) {
            return const AppEmptyState(
              title: 'No projects yet',
              subtitle: 'Create a project first to set a default.',
            );
          }

          final notifier = ref.read(settingsNotifierProvider.notifier);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            children: [
              SettingsCard(
                children: [
                  SettingsOptionTile(
                    title: 'None',
                    subtitle: 'Always open the project list on launch',
                    selected: defaultId == null,
                    onTap: () => notifier.setDefaultProject(null),
                  ),
                  for (final p in projects)
                    SettingsOptionTile(
                      title: p.name,
                      subtitle: p.location,
                      selected: defaultId == p.id,
                      onTap: () => notifier.setDefaultProject(p.id),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
