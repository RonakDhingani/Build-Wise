import '../../../expense/data/models/expense_category_isar_model.dart';
import '../../../expense/data/models/expense_isar_model.dart';
import '../../../material/data/models/material_isar_model.dart';
import '../../../photo/data/models/photo_isar_model.dart';
import '../../../project/data/models/project_isar_model.dart';
import '../../../stage/data/models/stage_isar_model.dart';

/// Converts Isar models to/from plain JSON maps for the backup archive.
///
/// Conventions:
/// * `DateTime` is stored as `millisecondsSinceEpoch` (int) — stable across
///   devices and locales, preserving original dates exactly.
/// * Enums are stored by `name` (matching `@Enumerated(EnumType.name)`).
/// * `id` and all foreign keys (`projectId`, `stageId`, `categoryId`) are kept
///   verbatim so the importer can remap them.
/// * Image path fields (`filePath`, `thumbnailPath`, `billImagePath`,
///   `coverImagePath`) are written/read as-is here; the export and import
///   services rewrite them to/from in-archive keys around this layer.
abstract class BackupSerializer {
  static int _ms(DateTime d) => d.millisecondsSinceEpoch;
  static DateTime _dt(dynamic v) =>
      DateTime.fromMillisecondsSinceEpoch((v as num).toInt());

  static T _enumByName<T>(List<T> values, dynamic name, T fallback) {
    for (final v in values) {
      if ((v as Enum).name == name) return v;
    }
    return fallback;
  }

  // ---- Project -------------------------------------------------------------

  static Map<String, dynamic> projectToMap(ProjectModel m) => {
        'id': m.id,
        'name': m.name,
        'location': m.location,
        'plotSize': m.plotSize,
        'builtUpArea': m.builtUpArea,
        'numberOfFloors': m.numberOfFloors,
        'budget': m.budget,
        'startDate': _ms(m.startDate),
        'expectedCompletionDate': m.expectedCompletionDate == null
            ? null
            : _ms(m.expectedCompletionDate!),
        'notes': m.notes,
        'coverImagePath': m.coverImagePath,
        'status': m.status.name,
        'createdAt': _ms(m.createdAt),
        'updatedAt': _ms(m.updatedAt),
      };

  static ProjectModel projectFromMap(Map<String, dynamic> j) => ProjectModel()
    ..name = j['name'] as String
    ..location = j['location'] as String
    ..plotSize = j['plotSize'] as String?
    ..builtUpArea = j['builtUpArea'] as String?
    ..numberOfFloors = (j['numberOfFloors'] as num?)?.toInt()
    ..budget = (j['budget'] as num).toDouble()
    ..startDate = _dt(j['startDate'])
    ..expectedCompletionDate = j['expectedCompletionDate'] == null
        ? null
        : _dt(j['expectedCompletionDate'])
    ..notes = j['notes'] as String?
    ..coverImagePath = j['coverImagePath'] as String?
    ..status = _enumByName(
        ProjectModelStatus.values, j['status'], ProjectModelStatus.active)
    ..createdAt = _dt(j['createdAt'])
    ..updatedAt = _dt(j['updatedAt']);

  // ---- Stage ---------------------------------------------------------------

  static Map<String, dynamic> stageToMap(StageModel m) => {
        'id': m.id,
        'projectId': m.projectId,
        'name': m.name,
        'orderIndex': m.orderIndex,
        'status': m.status.name,
        'startDate': m.startDate == null ? null : _ms(m.startDate!),
        'endDate': m.endDate == null ? null : _ms(m.endDate!),
        'progressPercent': m.progressPercent,
        'notes': m.notes,
        'isDefault': m.isDefault,
        'createdAt': _ms(m.createdAt),
        'updatedAt': _ms(m.updatedAt),
      };

  static StageModel stageFromMap(Map<String, dynamic> j) => StageModel()
    ..name = j['name'] as String
    ..orderIndex = (j['orderIndex'] as num).toInt()
    ..status = _enumByName(
        StageModelStatus.values, j['status'], StageModelStatus.notStarted)
    ..startDate = j['startDate'] == null ? null : _dt(j['startDate'])
    ..endDate = j['endDate'] == null ? null : _dt(j['endDate'])
    ..progressPercent = (j['progressPercent'] as num).toInt()
    ..notes = j['notes'] as String?
    ..isDefault = j['isDefault'] as bool? ?? false
    ..createdAt = _dt(j['createdAt'])
    ..updatedAt = _dt(j['updatedAt']);

  // ---- Expense -------------------------------------------------------------

  static Map<String, dynamic> expenseToMap(ExpenseModel m) => {
        'id': m.id,
        'projectId': m.projectId,
        'stageId': m.stageId,
        'categoryId': m.categoryId,
        'amount': m.amount,
        'date': _ms(m.date),
        'description': m.description,
        'vendorName': m.vendorName,
        'paymentType': m.paymentType.name,
        'billImagePath': m.billImagePath,
        'createdAt': _ms(m.createdAt),
        'updatedAt': _ms(m.updatedAt),
      };

  static ExpenseModel expenseFromMap(Map<String, dynamic> j) => ExpenseModel()
    ..amount = (j['amount'] as num).toDouble()
    ..date = _dt(j['date'])
    ..description = j['description'] as String?
    ..vendorName = j['vendorName'] as String?
    ..paymentType =
        _enumByName(PaymentType.values, j['paymentType'], PaymentType.cash)
    ..billImagePath = j['billImagePath'] as String?
    ..createdAt = _dt(j['createdAt'])
    ..updatedAt = _dt(j['updatedAt']);
  // projectId / stageId / categoryId are assigned by the importer after remap.

  // ---- Material ------------------------------------------------------------

  static Map<String, dynamic> materialToMap(MaterialModel m) => {
        'id': m.id,
        'projectId': m.projectId,
        'stageId': m.stageId,
        'name': m.name,
        'unit': m.unit.name,
        'quantityPurchased': m.quantityPurchased,
        'quantityUsed': m.quantityUsed,
        'costPerUnit': m.costPerUnit,
        'vendorName': m.vendorName,
        'purchaseDate': _ms(m.purchaseDate),
        'notes': m.notes,
        'isDefault': m.isDefault,
        'createdAt': _ms(m.createdAt),
        'updatedAt': _ms(m.updatedAt),
      };

  static MaterialModel materialFromMap(Map<String, dynamic> j) => MaterialModel()
    ..name = j['name'] as String
    ..unit = _enumByName(MaterialUnit.values, j['unit'], MaterialUnit.other)
    ..quantityPurchased = (j['quantityPurchased'] as num).toDouble()
    ..quantityUsed = (j['quantityUsed'] as num).toDouble()
    ..costPerUnit = (j['costPerUnit'] as num?)?.toDouble()
    ..vendorName = j['vendorName'] as String?
    ..purchaseDate = _dt(j['purchaseDate'])
    ..notes = j['notes'] as String?
    ..isDefault = j['isDefault'] as bool? ?? false
    ..createdAt = _dt(j['createdAt'])
    ..updatedAt = _dt(j['updatedAt']);

  // ---- Expense Category (global master data) -------------------------------

  static Map<String, dynamic> categoryToMap(ExpenseCategoryModel m) => {
        'id': m.id,
        'name': m.name,
        'isDefault': m.isDefault,
        'colorHex': m.colorHex,
        'iconName': m.iconName,
        'createdAt': _ms(m.createdAt),
      };

  static ExpenseCategoryModel categoryFromMap(Map<String, dynamic> j) =>
      ExpenseCategoryModel()
        ..name = j['name'] as String
        ..isDefault = j['isDefault'] as bool? ?? false
        ..colorHex = j['colorHex'] as String?
        ..iconName = j['iconName'] as String?
        ..createdAt = _dt(j['createdAt']);

  // ---- Photo ---------------------------------------------------------------

  static Map<String, dynamic> photoToMap(PhotoModel m) => {
        'id': m.id,
        'projectId': m.projectId,
        'stageId': m.stageId,
        'filePath': m.filePath,
        'thumbnailPath': m.thumbnailPath,
        'caption': m.caption,
        'takenAt': _ms(m.takenAt),
        'createdAt': _ms(m.createdAt),
      };

  static PhotoModel photoFromMap(Map<String, dynamic> j) => PhotoModel()
    ..filePath = j['filePath'] as String
    ..thumbnailPath = j['thumbnailPath'] as String?
    ..caption = j['caption'] as String?
    ..takenAt = _dt(j['takenAt'])
    ..createdAt = _dt(j['createdAt']);
  // projectId / stageId assigned by the importer after remap.
}
