import '../../../../core/result/result.dart';
import '../entities/project_entity.dart';

abstract class ProjectRepository {
  Future<Result<ProjectEntity>> createProject(ProjectEntity entity);
  Future<Result<ProjectEntity>> updateProject(ProjectEntity entity);
  Future<Result<void>> deleteProject(int id);
  Future<Result<void>> archiveProject(int id);
  Future<Result<List<ProjectEntity>>> getProjects({ProjectStatus? status});
  Future<Result<ProjectEntity>> getProjectById(int id);
}
