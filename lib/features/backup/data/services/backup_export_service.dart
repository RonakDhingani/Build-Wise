import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../constants/app_constants.dart';
import '../../../expense/data/models/expense_category_isar_model.dart';
import '../../../expense/data/models/expense_isar_model.dart';
import '../../../material/data/models/material_isar_model.dart';
import '../../../photo/data/models/photo_isar_model.dart';
import '../../../project/data/models/project_isar_model.dart';
import '../../../stage/data/models/stage_isar_model.dart';
import '../../domain/backup_format.dart';
import '../models/backup_manifest.dart';
import '../models/backup_result.dart';
import 'backup_serializer.dart';

/// Reads the Isar database and writes an offline `.zip` backup. No network,
/// cloud or backend involved — purely local file handling.
class BackupExportService {
  const BackupExportService(this._isar);

  final Isar _isar;

  /// Builds a backup archive for [scope].
  ///
  /// For [BackupScope.currentProject], [projectId] must be supplied.
  Future<BackupResult> export({
    required BackupScope scope,
    int? projectId,
  }) async {
    // 1. Resolve which projects are included.
    final List<ProjectModel> projects;
    if (scope == BackupScope.currentProject) {
      if (projectId == null) {
        throw const BackupException(
          BackupErrorType.unknown,
          'No project selected to export.',
        );
      }
      final project = await _isar.projectModels.get(projectId);
      if (project == null) {
        throw const BackupException(
          BackupErrorType.missingData,
          'The selected project could not be found.',
        );
      }
      projects = [project];
    } else {
      projects = await _isar.projectModels.where().findAll();
      if (projects.isEmpty) {
        throw const BackupException(
          BackupErrorType.noProjects,
          'There are no projects to export yet.',
        );
      }
    }

    final projectIds = projects.map((p) => p.id).toSet();

    // 2. Load related data scoped to those projects.
    final stages = await _filterByProject(
        _isar.stageModels.where().findAll(), projectIds, (m) => m.projectId);
    final expenses = await _filterByProject(
        _isar.expenseModels.where().findAll(), projectIds, (m) => m.projectId);
    final materials = await _filterByProject(
        _isar.materialModels.where().findAll(), projectIds, (m) => m.projectId);
    final photos = await _filterByProject(
        _isar.photoModels.where().findAll(), projectIds, (m) => m.projectId);

    // Categories are global master data — exported in full so expense
    // references resolve on import regardless of scope.
    final categories = await _isar.expenseCategoryModels.where().findAll();

    // 3. Assemble the archive.
    final archive = Archive();
    var skippedPhotos = 0;

    // Projects (+ cover images).
    final projectMaps = projects.map((p) {
      final map = BackupSerializer.projectToMap(p);
      map['coverImagePath'] =
          _archiveFile(archive, p.id, BackupFormat.subCover, p.coverImagePath);
      return map;
    }).toList();

    // Stages.
    final stageMaps = stages.map(BackupSerializer.stageToMap).toList();

    // Expenses (+ bill images).
    final expenseMaps = expenses.map((e) {
      final map = BackupSerializer.expenseToMap(e);
      map['billImagePath'] = _archiveFile(
          archive, e.projectId, BackupFormat.subBills, e.billImagePath);
      return map;
    }).toList();

    // Materials.
    final materialMaps = materials.map(BackupSerializer.materialToMap).toList();

    // Photos (+ photo and thumbnail files). Skip any whose main file is gone.
    final photoMaps = <Map<String, dynamic>>[];
    for (final photo in photos) {
      if (!File(photo.filePath).existsSync()) {
        skippedPhotos++;
        continue;
      }
      final map = BackupSerializer.photoToMap(photo);
      map['filePath'] = _archiveFile(
          archive, photo.projectId, BackupFormat.subPhotos, photo.filePath);
      map['thumbnailPath'] = _archiveFile(
          archive, photo.projectId, BackupFormat.subThumbs, photo.thumbnailPath);
      photoMaps.add(map);
    }

    // Categories.
    final categoryMaps = categories.map(BackupSerializer.categoryToMap).toList();

    // 4. Manifest.
    final counts = BackupCounts(
      projects: projectMaps.length,
      stages: stageMaps.length,
      expenses: expenseMaps.length,
      materials: materialMaps.length,
      categories: categoryMaps.length,
      photos: photoMaps.length,
    );
    final manifest = BackupManifest(
      magic: BackupFormat.magic,
      formatVersion: BackupFormat.formatVersion,
      appVersion: AppConstants.appVersion,
      createdAt: DateTime.now(),
      scope: scope,
      counts: counts,
    );

    // 5. Write JSON entries.
    _addJson(archive, BackupFormat.manifestFile, manifest.toJson());
    _addJson(
      archive,
      BackupFormat.projectFile,
      // Single object for current-project, list for all-projects.
      scope == BackupScope.currentProject ? projectMaps.first : projectMaps,
    );
    _addJson(archive, BackupFormat.stagesFile, stageMaps);
    _addJson(archive, BackupFormat.expensesFile, expenseMaps);
    _addJson(archive, BackupFormat.materialsFile, materialMaps);
    _addJson(archive, BackupFormat.categoriesFile, categoryMaps);
    _addJson(archive, BackupFormat.photosFile, photoMaps);

    // 6. Encode and persist to the app's backups folder.
    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw const BackupException(
        BackupErrorType.unknown,
        'Failed to create the backup archive.',
      );
    }

    final fileName = _buildFileName(scope, projects);
    final dir = await _backupsDir();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(encoded, flush: true);

    return BackupResult(
      filePath: filePath,
      fileName: fileName,
      sizeBytes: encoded.length,
      manifest: manifest,
      skippedPhotos: skippedPhotos,
    );
  }

  // ---- Helpers -------------------------------------------------------------

  Future<List<T>> _filterByProject<T>(
    Future<List<T>> all,
    Set<int> ids,
    int Function(T) projectIdOf,
  ) async {
    final list = await all;
    return list.where((m) => ids.contains(projectIdOf(m))).toList();
  }

  /// Copies [path]'s bytes into the archive under
  /// `files/<projectId>/<sub>/<basename>` and returns that key. Returns null
  /// when [path] is null or the file is missing (caller keeps the field null).
  String? _archiveFile(
    Archive archive,
    int projectId,
    String sub,
    String? path,
  ) {
    if (path == null) return null;
    final file = File(path);
    if (!file.existsSync()) return null;

    final bytes = file.readAsBytesSync();
    final base = path.split('/').last;
    final key = '${BackupFormat.filesDir}/$projectId/$sub/$base';
    archive.addFile(ArchiveFile(key, bytes.length, bytes));
    return key;
  }

  void _addJson(Archive archive, String name, Object json) {
    final bytes = utf8.encode(jsonEncode(json));
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  Future<Directory> _backupsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/build_wise/backups');
    await dir.create(recursive: true);
    return dir;
  }

  String _buildFileName(BackupScope scope, List<ProjectModel> projects) {
    final now = DateTime.now();
    final stamp = '${now.year}${_pad2(now.month)}${_pad2(now.day)}'
        '_${_pad2(now.hour)}${_pad2(now.minute)}${_pad2(now.second)}';
    if (scope == BackupScope.allProjects) {
      return 'buildwise_all_projects_$stamp.zip';
    }
    final slug = _slug(projects.first.name);
    return 'buildwise_${slug}_$stamp.zip';
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');

  String _slug(String name) {
    final s = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return s.isEmpty ? 'project' : s;
  }
}
