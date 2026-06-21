import '../../../../constants/app_constants.dart';

enum MaterialUnit { bags, kg, tons, pieces, sqft, sqm, liters, meters, rolls, other }

extension MaterialUnitX on MaterialUnit {
  String get label => switch (this) {
        MaterialUnit.bags => 'Bags',
        MaterialUnit.kg => 'Kg',
        MaterialUnit.tons => 'Tons',
        MaterialUnit.pieces => 'Pieces',
        MaterialUnit.sqft => 'Sq.ft',
        MaterialUnit.sqm => 'Sq.m',
        MaterialUnit.liters => 'Liters',
        MaterialUnit.meters => 'Meters',
        MaterialUnit.rolls => 'Rolls',
        MaterialUnit.other => 'Other',
      };
}

class MaterialEntity {
  const MaterialEntity({
    required this.id,
    required this.projectId,
    this.stageId,
    required this.name,
    required this.unit,
    required this.quantityPurchased,
    required this.quantityUsed,
    this.costPerUnit,
    this.vendorName,
    required this.purchaseDate,
    this.notes,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int projectId;
  final int? stageId;
  final String name;
  final MaterialUnit unit;
  final double quantityPurchased;
  final double quantityUsed;
  final double? costPerUnit;
  final String? vendorName;
  final DateTime purchaseDate;
  final String? notes;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get remaining => (quantityPurchased - quantityUsed).clamp(0.0, double.infinity);
  double get totalCost => costPerUnit != null ? quantityPurchased * costPerUnit! : 0.0;
  bool get isLowStock {
    if (quantityPurchased <= 0) return false;
    return remaining / quantityPurchased <= AppConstants.lowStockThreshold;
  }

  MaterialEntity copyWith({
    int? id,
    int? projectId,
    int? stageId,
    bool clearStageId = false,
    String? name,
    MaterialUnit? unit,
    double? quantityPurchased,
    double? quantityUsed,
    double? costPerUnit,
    bool clearCostPerUnit = false,
    String? vendorName,
    DateTime? purchaseDate,
    String? notes,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      stageId: clearStageId ? null : (stageId ?? this.stageId),
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantityPurchased: quantityPurchased ?? this.quantityPurchased,
      quantityUsed: quantityUsed ?? this.quantityUsed,
      costPerUnit: clearCostPerUnit ? null : (costPerUnit ?? this.costPerUnit),
      vendorName: vendorName ?? this.vendorName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
