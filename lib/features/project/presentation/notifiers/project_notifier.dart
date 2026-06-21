import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/project_entity.dart';
import '../providers/project_providers.dart';

class ProjectsState {
  const ProjectsState({
    required this.projects,
    this.searchQuery = '',
    this.showArchived = false,
  });

  final List<ProjectEntity> projects;
  final String searchQuery;
  final bool showArchived;

  List<ProjectEntity> get filtered {
    var list = showArchived
        ? projects
        : projects.where((p) => p.status == ProjectStatus.active).toList();

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  ProjectsState copyWith({
    List<ProjectEntity>? projects,
    String? searchQuery,
    bool? showArchived,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      searchQuery: searchQuery ?? this.searchQuery,
      showArchived: showArchived ?? this.showArchived,
    );
  }
}

class ProjectsNotifier extends AsyncNotifier<ProjectsState> {
  @override
  Future<ProjectsState> build() async {
    return _load();
  }

  Future<ProjectsState> _load() async {
    final useCase = ref.read(getProjectsUseCaseProvider);
    final result = await useCase.execute();
    return result.when(
      success: (data) => ProjectsState(projects: data),
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    state = AsyncData(await _load().then(
      (s) => s.copyWith(
        searchQuery: current?.searchQuery ?? '',
        showArchived: current?.showArchived ?? false,
      ),
    ));
  }

  void updateSearch(String query) {
    state.whenData((s) {
      state = AsyncData(s.copyWith(searchQuery: query));
    });
  }

  void toggleShowArchived() {
    state.whenData((s) {
      state = AsyncData(s.copyWith(showArchived: !s.showArchived));
    });
  }

  Future<ProjectEntity?> createProject(ProjectEntity entity) async {
    final useCase = ref.read(createProjectUseCaseProvider);
    final result = await useCase.execute(entity);
    return result.when(
      success: (created) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            projects: [created, ...s.projects],
          ));
        });
        return created;
      },
      failure: (f) {
        throw Exception(f.message);
      },
    );
  }

  Future<void> updateProject(ProjectEntity entity) async {
    final useCase = ref.read(updateProjectUseCaseProvider);
    final result = await useCase.execute(entity);
    result.when(
      success: (updated) {
        state.whenData((s) {
          final idx = s.projects.indexWhere((p) => p.id == updated.id);
          if (idx >= 0) {
            final updated2 = List<ProjectEntity>.from(s.projects);
            updated2[idx] = updated;
            state = AsyncData(s.copyWith(projects: updated2));
          }
        });
      },
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> deleteProject(int id) async {
    final useCase = ref.read(deleteProjectUseCaseProvider);
    final result = await useCase.execute(id);
    result.when(
      success: (_) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            projects: s.projects.where((p) => p.id != id).toList(),
          ));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> archiveProject(int id) async {
    final useCase = ref.read(archiveProjectUseCaseProvider);
    final result = await useCase.execute(id);
    result.when(
      success: (_) {},
      failure: (f) => throw Exception(f.message),
    );
    await refresh();
    // Auto-hide archived toggle if no archived projects remain
    state.whenData((s) {
      if (s.showArchived &&
          s.projects.every((p) => p.status == ProjectStatus.active)) {
        state = AsyncData(s.copyWith(showArchived: false));
      }
    });
  }
}
