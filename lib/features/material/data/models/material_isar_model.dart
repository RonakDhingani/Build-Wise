import 'package:isar/isar.dart';

part 'material_isar_model.g.dart';

@Collection()
class MaterialModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int projectId;

  int? stageId;

  late String name;

  @Enumerated(EnumType.name)
  late MaterialUnit unit;

  late double quantityPurchased;
  late double quantityUsed;

  double? costPerUnit;

  String? vendorName;
  late DateTime purchaseDate;
  String? notes;

  late bool isDefault;
  late DateTime createdAt;
  late DateTime updatedAt;
}

enum MaterialUnit { bags, kg, tons, pieces, sqft, sqm, liters, meters, rolls, other }
