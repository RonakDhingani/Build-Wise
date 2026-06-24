import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../expense/data/models/expense_category_isar_model.dart';
import '../../../expense/data/models/expense_isar_model.dart';
import '../../../material/data/models/material_isar_model.dart';
import '../../../photo/data/models/photo_isar_model.dart';
import '../../../project/data/models/project_isar_model.dart';
import '../../../stage/data/models/stage_isar_model.dart';
import '../../domain/backup_format.dart';
import '../models/backup_bundle.dart';
import '../models/backup_manifest.dart';
import 'backup_serializer.dart';

/// Validates and restores BuildWise `.zip` backups into the Isar database.
///
/// Two import modes only — Create New Project and Replace Existing Project.
/// Merge / partial imports are intentionally unsupported (they create
/// duplicate records and data inconsistency).
class BackupImportService {
  BackupImportService(this._isar);

  final Isar _isar;

  /// Opens and validates an archive, returning a [BackupBundle] for preview.
  /// Throws [BackupException] with a user-friendly message on any problem.
  Future<BackupBundle> open(String zipPath) async {
    final file = File(zipPath);
    if (!file.existsSync()) {
      throw const BackupException(
        BackupErrorType.invalidFile,
        'The backup file could not be found.',
      );
    }

    Archive archive;
    try {
      final bytes = await file.readAsBytes();
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const BackupException(
        BackupErrorType.corruptedArchive,
        'This file is not a valid ZIP archive or is corrupted.',
      );
    }

    final entries = <String, ArchiveFile>{
      for (final f in archive.files)
        if (f.isFile) f.name: f,
    };

    // Manifest is mandatory.
    final manifestJson = _readJsonObject(entries, BackupFormat.manifestFile);
    if (manifestJson == null) {
      throw const BackupException(
        BackupErrorType.invalidFile,
        'This is not a BuildWise backup (manifest is missing).',
      );
    }
    final manifest = BackupManifest.fromJson(manifestJson);

    if (!manifest.isValidMagic) {
      throw const BackupException(
        BackupErrorType.invalidFile,
        'This file is not a BuildWise backup.',
      );
    }
    if (!manifest.isFormatSupported) {
      throw const BackupException(
        BackupErrorType.versionMismatch,
        'This backup was made with a newer version of BuildWise. '
        'Please update the app to import it.',
      );
    }

    // Required data files.
    final projectsRaw = _readJson(entries, BackupFormat.projectFile);
    if (projectsRaw == null) {
      throw const BackupException(
        BackupErrorType.missingData,
        'The backup is incomplete (project data is missing).',
      );
    }
    final projects = _asMapList(
      projectsRaw is List ? projectsRaw : [projectsRaw],
    );
    if (projects.isEmpty) {
      throw const BackupException(
        BackupErrorType.missingData,
        'The backup does not contain any projects.',
      );
    }

    List<Map<String, dynamic>> requiredList(String name) {
      final raw = _readJson(entries, name);
      if (raw == null) {
        throw BackupException(
          BackupErrorType.missingData,
          'The backup is incomplete (${name.replaceAll('.json', '')} '
          'data is missing).',
        );
      }
      return _asMapList(raw as List);
    }

    final stages = requiredList(BackupFormat.stagesFile);
    final expenses = requiredList(BackupFormat.expensesFile);
    final materials = requiredList(BackupFormat.materialsFile);
    // Categories and photos may legitimately be empty; tolerate missing files.
    final categoriesRaw = _readJson(entries, BackupFormat.categoriesFile);
    final categories = categoriesRaw == null
        ? <Map<String, dynamic>>[]
        : _asMapList(categoriesRaw as List);
    final photosRaw = _readJson(entries, BackupFormat.photosFile);
    final photos = photosRaw == null
        ? <Map<String, dynamic>>[]
        : _asMapList(photosRaw as List);

    return BackupBundle(
      sourcePath: zipPath,
      manifest: manifest,
      projects: projects,
      stages: stages,
      expenses: expenses,
      materials: materials,
      categories: categories,
      photos: photos,
      files: entries,
    );
  }

  /// Applies [bundle] to the database.
  ///
  /// * [ImportMode.createNew] — every project in the bundle is inserted as a
  ///   brand-new project. No existing data is modified.
  /// * [ImportMode.replaceExisting] — only valid for single-project bundles;
  ///   [targetProjectId] is deleted (cascade) and the imported project takes
  ///   its place.
  Future<ImportSummary> performImport(
    BackupBundle bundle, {
    required ImportMode mode,
    int? targetProjectId,
  }) async {
    String? replacedName;

    if (mode == ImportMode.replaceExisting) {
      if (!bundle.isSingleProject || targetProjectId == null) {
        throw const BackupException(
          BackupErrorType.unknown,
          'Replace mode requires a single-project backup and a target project.',
        );
      }
      final target = await _isar.projectModels.get(targetProjectId);
      replacedName = target?.name;
      await _deleteProjectCascade(targetProjectId);
    }

    // Categories are global — resolve them once for the whole import.
    final categoryMap = await _resolveCategories(bundle.categories);

    var projectsCreated = 0;
    var stagesCount = 0;
    var expensesCount = 0;
    var materialsCount = 0;
    var photosRestored = 0;
    var photosMissing = 0;

    for (final projectMap in bundle.projects) {
      final oldProjectId = (projectMap['id'] as num).toInt();

      final stages = bundle.stages
          .where((s) => (s['projectId'] as num).toInt() == oldProjectId)
          .toList();
      final expenses = bundle.expenses
          .where((e) => (e['projectId'] as num).toInt() == oldProjectId)
          .toList();
      final materials = bundle.materials
          .where((m) => (m['projectId'] as num).toInt() == oldProjectId)
          .toList();

      final result = await _importOneProject(
        bundle: bundle,
        projectMap: projectMap,
        stages: stages,
        expenses: expenses,
        materials: materials,
        categoryMap: categoryMap,
      );

      projectsCreated++;
      stagesCount += result.stages;
      expensesCount += result.expenses;
      materialsCount += result.materials;
      photosRestored += result.photosRestored;
      photosMissing += result.photosMissing;
    }

    return ImportSummary(
      projectsCreated: projectsCreated,
      stages: stagesCount,
      expenses: expensesCount,
      materials: materialsCount,
      photosRestored: photosRestored,
      photosMissing: photosMissing,
      replacedProjectName: replacedName,
    );
  }

  // ---- Per-project import --------------------------------------------------

  Future<_ProjectImportResult> _importOneProject({
    required BackupBundle bundle,
    required Map<String, dynamic> projectMap,
    required List<Map<String, dynamic>> stages,
    required List<Map<String, dynamic>> expenses,
    required List<Map<String, dynamic>> materials,
    required Map<int, int> categoryMap,
  }) async {
    final oldProjectId = (projectMap['id'] as num).toInt();

    // 1. Insert the project (without auto-seeding default stages).
    final project = BackupSerializer.projectFromMap(projectMap);
    late int newProjectId;
    await _isar.writeTxn(() async {
      newProjectId = await _isar.projectModels.put(project);
    });

    final appDir = await getApplicationDocumentsDirectory();
    final baseDir = '${appDir.path}/build_wise/$newProjectId';

    // 2. Restore the cover image and patch the project record.
    final coverKey = projectMap['coverImagePath'] as String?;
    final newCover = _writeArchiveFile(bundle.files, baseDir, coverKey);
    if (newCover != null) {
      await _isar.writeTxn(() async {
        final p = await _isar.projectModels.get(newProjectId);
        if (p != null) {
          p.coverImagePath = newCover;
          await _isar.projectModels.put(p);
        }
      });
    }

    // 3. Stages — build old->new id map.
    final stageIdMap = <int, int>{};
    final stageModels = stages.map(BackupSerializer.stageFromMap).toList();
    await _isar.writeTxn(() async {
      for (var i = 0; i < stageModels.length; i++) {
        final model = stageModels[i]..projectId = newProjectId;
        final newId = await _isar.stageModels.put(model);
        stageIdMap[(stages[i]['id'] as num).toInt()] = newId;
      }
    });

    int? remapStage(Map<String, dynamic> j) {
      final old = (j['stageId'] as num?)?.toInt();
      return old == null ? null : stageIdMap[old];
    }

    // 4. Expenses (+ bill images, category + stage remap).
    final expenseModels = <ExpenseModel>[];
    for (final e in expenses) {
      final model = BackupSerializer.expenseFromMap(e)
        ..projectId = newProjectId
        ..stageId = remapStage(e)
        ..categoryId =
            categoryMap[(e['categoryId'] as num).toInt()] ?? _fallbackCategoryId;
      model.billImagePath =
          _writeArchiveFile(bundle.files, baseDir, e['billImagePath'] as String?);
      expenseModels.add(model);
    }
    await _isar.writeTxn(() async {
      await _isar.expenseModels.putAll(expenseModels);
    });

    // 5. Materials (+ stage remap).
    final materialModels = materials.map((m) {
      return BackupSerializer.materialFromMap(m)
        ..projectId = newProjectId
        ..stageId = remapStage(m);
    }).toList();
    await _isar.writeTxn(() async {
      await _isar.materialModels.putAll(materialModels);
    });

    // 6. Photos (+ image + thumbnail files, stage remap). Skip ones whose
    //    image payload is missing from the archive.
    final photos = bundle.photosForProject(oldProjectId);
    var photosRestored = 0;
    var photosMissing = 0;
    final photoModels = <PhotoModel>[];
    for (final ph in photos) {
      final newPath =
          _writeArchiveFile(bundle.files, baseDir, ph['filePath'] as String?);
      if (newPath == null) {
        photosMissing++;
        continue;
      }
      final newThumb = _writeArchiveFile(
          bundle.files, baseDir, ph['thumbnailPath'] as String?);
      photoModels.add(
        BackupSerializer.photoFromMap(ph)
          ..projectId = newProjectId
          ..stageId = remapStage(ph)
          ..filePath = newPath
          ..thumbnailPath = newThumb,
      );
      photosRestored++;
    }
    if (photoModels.isNotEmpty) {
      await _isar.writeTxn(() async {
        await _isar.photoModels.putAll(photoModels);
      });
    }

    return _ProjectImportResult(
      stages: stageModels.length,
      expenses: expenseModels.length,
      materials: materialModels.length,
      photosRestored: photosRestored,
      photosMissing: photosMissing,
    );
  }

  // Default category id used when an expense references a category that was not
  // in the backup — should not happen, but keeps imports non-fatal.
  int get _fallbackCategoryId => _resolvedFallbackCategoryId ?? 0;
  int? _resolvedFallbackCategoryId;

  /// Maps each backup category id to a database category id, reusing existing
  /// categories by their unique name and creating any that are missing.
  Future<Map<int, int>> _resolveCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    final map = <int, int>{};
    final existing = await _isar.expenseCategoryModels.where().findAll();
    final byName = {for (final c in existing) c.name: c.id};

    for (final cat in categories) {
      final oldId = (cat['id'] as num).toInt();
      final name = cat['name'] as String;
      final existingId = byName[name];
      if (existingId != null) {
        map[oldId] = existingId;
        continue;
      }
      final model = BackupSerializer.categoryFromMap(cat);
      late int newId;
      await _isar.writeTxn(() async {
        newId = await _isar.expenseCategoryModels.put(model);
      });
      byName[name] = newId;
      map[oldId] = newId;
    }

    // Pick any category as the fallback target for orphaned expenses.
    _resolvedFallbackCategoryId =
        map.values.isNotEmpty ? map.values.first : byName.values.firstOrNull;
    return map;
  }

  // ---- File + delete helpers ----------------------------------------------

  /// Extracts an archive entry to `<baseDir>/<sub>/<basename>` and returns the
  /// new absolute path, or null if the key is null / not present in the archive.
  String? _writeArchiveFile(
    Map<String, ArchiveFile> files,
    String baseDir,
    String? key,
  ) {
    if (key == null) return null;
    final entry = files[key];
    if (entry == null) return null;

    // key shape: files/<projectId>/<sub>/<basename>
    final parts = key.split('/');
    final sub = parts.length >= 4 ? parts[2] : 'misc';
    final base = parts.last;

    final destDir = Directory('$baseDir/$sub');
    destDir.createSync(recursive: true);
    final dest = '${destDir.path}/$base';
    File(dest).writeAsBytesSync(entry.content as List<int>);
    return dest;
  }

  Future<void> _deleteProjectCascade(int id) async {
    // Remove image files for the project first.
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/build_wise/$id');
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    } catch (_) {}

    await _isar.writeTxn(() async {
      await _isar.projectModels.delete(id);
      await _isar.stageModels
          .filter()
          .projectIdEqualTo(id)
          .deleteAll();
      await _isar.expenseModels
          .filter()
          .projectIdEqualTo(id)
          .deleteAll();
      await _isar.materialModels
          .filter()
          .projectIdEqualTo(id)
          .deleteAll();
      await _isar.photoModels
          .filter()
          .projectIdEqualTo(id)
          .deleteAll();
    });
  }

  // ---- JSON helpers --------------------------------------------------------

  Object? _readJson(Map<String, ArchiveFile> entries, String name) {
    final entry = entries[name];
    if (entry == null) return null;
    try {
      return jsonDecode(utf8.decode(entry.content as List<int>));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _readJsonObject(
    Map<String, ArchiveFile> entries,
    String name,
  ) {
    final raw = _readJson(entries, name);
    return raw is Map ? raw.cast<String, dynamic>() : null;
  }

  List<Map<String, dynamic>> _asMapList(List raw) =>
      raw.map((e) => (e as Map).cast<String, dynamic>()).toList();
}

class _ProjectImportResult {
  const _ProjectImportResult({
    required this.stages,
    required this.expenses,
    required this.materials,
    required this.photosRestored,
    required this.photosMissing,
  });

  final int stages;
  final int expenses;
  final int materials;
  final int photosRestored;
  final int photosMissing;
}

extension on Iterable<int> {
  int? get firstOrNull => isEmpty ? null : first;
}
