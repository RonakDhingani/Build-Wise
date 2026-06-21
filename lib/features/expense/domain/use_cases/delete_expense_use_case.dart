import '../../../../core/result/result.dart';
import '../repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  const DeleteExpenseUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<void>> execute(int id) {
    return _repository.deleteExpense(id);
  }
}
