import '../../../../core/result/result.dart';
import '../repositories/expense_repository.dart';

class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<void>> execute(int id) {
    return _repository.deleteCategory(id);
  }
}
