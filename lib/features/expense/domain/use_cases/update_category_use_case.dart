import '../../../../core/result/result.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class UpdateCategoryUseCase {
  const UpdateCategoryUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<ExpenseCategoryEntity>> execute(ExpenseCategoryEntity entity) {
    return _repository.updateCategory(entity);
  }
}
