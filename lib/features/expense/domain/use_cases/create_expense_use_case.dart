import '../../../../core/result/result.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class CreateExpenseUseCase {
  const CreateExpenseUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<ExpenseEntity>> execute(ExpenseEntity entity) {
    return _repository.createExpense(entity);
  }
}
