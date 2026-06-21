import '../../../../core/result/result.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<List<ExpenseCategoryEntity>>> execute() {
    return _repository.getCategories();
  }
}
