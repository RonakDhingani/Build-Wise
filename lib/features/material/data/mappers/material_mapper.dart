import '../../domain/entities/material_entity.dart' as domain;
import '../models/material_isar_model.dart';

class MaterialMapper {
  MaterialMapper._();

  static domain.MaterialEntity toEntity(MaterialModel model) {
    return domain.MaterialEntity(
      id: model.id,
      projectId: model.projectId,
      stageId: model.stageId,
      name: model.name,
      unit: _toUnit(model.unit),
      quantityPurchased: model.quantityPurchased,
      quantityUsed: model.quantityUsed,
      costPerUnit: model.costPerUnit,
      vendorName: model.vendorName,
      purchaseDate: model.purchaseDate,
      notes: model.notes,
      isDefault: model.isDefault,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static MaterialModel toModel(domain.MaterialEntity entity) {
    final model = MaterialModel()
      ..projectId = entity.projectId
      ..stageId = entity.stageId
      ..name = entity.name
      ..unit = _toModelUnit(entity.unit)
      ..quantityPurchased = entity.quantityPurchased
      ..quantityUsed = entity.quantityUsed
      ..costPerUnit = entity.costPerUnit
      ..vendorName = entity.vendorName
      ..purchaseDate = entity.purchaseDate
      ..notes = entity.notes
      ..isDefault = entity.isDefault
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;

    if (entity.id != 0) model.id = entity.id;
    return model;
  }

  static domain.MaterialUnit _toUnit(MaterialUnit u) => switch (u) {
        MaterialUnit.bags => domain.MaterialUnit.bags,
        MaterialUnit.kg => domain.MaterialUnit.kg,
        MaterialUnit.tons => domain.MaterialUnit.tons,
        MaterialUnit.pieces => domain.MaterialUnit.pieces,
        MaterialUnit.sqft => domain.MaterialUnit.sqft,
        MaterialUnit.sqm => domain.MaterialUnit.sqm,
        MaterialUnit.liters => domain.MaterialUnit.liters,
        MaterialUnit.meters => domain.MaterialUnit.meters,
        MaterialUnit.rolls => domain.MaterialUnit.rolls,
        MaterialUnit.other => domain.MaterialUnit.other,
      };

  static MaterialUnit _toModelUnit(domain.MaterialUnit u) => switch (u) {
        domain.MaterialUnit.bags => MaterialUnit.bags,
        domain.MaterialUnit.kg => MaterialUnit.kg,
        domain.MaterialUnit.tons => MaterialUnit.tons,
        domain.MaterialUnit.pieces => MaterialUnit.pieces,
        domain.MaterialUnit.sqft => MaterialUnit.sqft,
        domain.MaterialUnit.sqm => MaterialUnit.sqm,
        domain.MaterialUnit.liters => MaterialUnit.liters,
        domain.MaterialUnit.meters => MaterialUnit.meters,
        domain.MaterialUnit.rolls => MaterialUnit.rolls,
        domain.MaterialUnit.other => MaterialUnit.other,
      };
}
