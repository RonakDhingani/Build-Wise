import '../../../../core/result/result.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class CreateCategoryUseCase {
  const CreateCategoryUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<ExpenseCategoryEntity>> execute(
    String name, {
    String? colorHex,
  }) {
    return _repository.createCategory(name, colorHex: colorHex);
  }
}
