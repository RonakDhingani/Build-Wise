import '../../../../core/result/result.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  const GetExpensesUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<List<ExpenseEntity>>> execute(int projectId) {
    return _repository.getExpensesByProject(projectId);
  }
}
