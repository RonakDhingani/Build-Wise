import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/use_cases/archive_project_use_case.dart';
import '../../domain/use_cases/create_project_use_case.dart';
import '../../domain/use_cases/delete_project_use_case.dart';
import '../../domain/use_cases/get_project_by_id_use_case.dart';
import '../../domain/use_cases/get_projects_use_case.dart';
import '../../domain/use_cases/update_project_use_case.dart';
import '../notifiers/project_notifier.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(ref.read(isarProvider));
});

final createProjectUseCaseProvider = Provider<CreateProjectUseCase>((ref) {
  return CreateProjectUseCase(ref.read(projectRepositoryProvider));
});

final updateProjectUseCaseProvider = Provider<UpdateProjectUseCase>((ref) {
  return UpdateProjectUseCase(ref.read(projectRepositoryProvider));
});

final deleteProjectUseCaseProvider = Provider<DeleteProjectUseCase>((ref) {
  return DeleteProjectUseCase(ref.read(projectRepositoryProvider));
});

final archiveProjectUseCaseProvider = Provider<ArchiveProjectUseCase>((ref) {
  return ArchiveProjectUseCase(ref.read(projectRepositoryProvider));
});

final getProjectsUseCaseProvider = Provider<GetProjectsUseCase>((ref) {
  return GetProjectsUseCase(ref.read(projectRepositoryProvider));
});

final getProjectByIdUseCaseProvider = Provider<GetProjectByIdUseCase>((ref) {
  return GetProjectByIdUseCase(ref.read(projectRepositoryProvider));
});

final projectsNotifierProvider =
    AsyncNotifierProvider<ProjectsNotifier, ProjectsState>(
  ProjectsNotifier.new,
);

final showArchivedProvider = StateProvider<bool>((ref) => false);
