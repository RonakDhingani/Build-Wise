import '../../domain/entities/expense_entity.dart';
import '../models/expense_category_isar_model.dart';
import '../models/expense_isar_model.dart';

class ExpenseMapper {
  ExpenseMapper._();

  static ExpenseEntity toEntity(ExpenseModel model) {
    return ExpenseEntity(
      id: model.id,
      projectId: model.projectId,
      stageId: model.stageId,
      categoryId: model.categoryId,
      amount: model.amount,
      date: model.date,
      description: model.description,
      vendorName: model.vendorName,
      paymentMethod: _toPaymentMethod(model.paymentType),
      billImagePath: model.billImagePath,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static ExpenseModel toModel(ExpenseEntity entity) {
    final model = ExpenseModel()
      ..projectId = entity.projectId
      ..stageId = entity.stageId
      ..categoryId = entity.categoryId
      ..amount = entity.amount
      ..date = entity.date
      ..description = entity.description
      ..vendorName = entity.vendorName
      ..paymentType = _toPaymentType(entity.paymentMethod)
      ..billImagePath = entity.billImagePath
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;

    if (entity.id != 0) model.id = entity.id;
    return model;
  }

  static PaymentMethod _toPaymentMethod(PaymentType t) => switch (t) {
        PaymentType.cash => PaymentMethod.cash,
        PaymentType.cheque => PaymentMethod.cheque,
        PaymentType.upi => PaymentMethod.upi,
        PaymentType.bankTransfer => PaymentMethod.bankTransfer,
        PaymentType.credit => PaymentMethod.credit,
        PaymentType.other => PaymentMethod.other,
      };

  static PaymentType _toPaymentType(PaymentMethod m) => switch (m) {
        PaymentMethod.cash => PaymentType.cash,
        PaymentMethod.cheque => PaymentType.cheque,
        PaymentMethod.upi => PaymentType.upi,
        PaymentMethod.bankTransfer => PaymentType.bankTransfer,
        PaymentMethod.credit => PaymentType.credit,
        PaymentMethod.other => PaymentType.other,
      };
}

class ExpenseCategoryMapper {
  ExpenseCategoryMapper._();

  static ExpenseCategoryEntity toEntity(ExpenseCategoryModel model) {
    return ExpenseCategoryEntity(
      id: model.id,
      name: model.name,
      isDefault: model.isDefault,
      colorHex: model.colorHex,
      createdAt: model.createdAt,
    );
  }
}
