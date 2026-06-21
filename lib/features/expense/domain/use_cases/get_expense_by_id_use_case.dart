import '../../../../core/result/result.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpenseByIdUseCase {
  const GetExpenseByIdUseCase(this._repository);
  final ExpenseRepository _repository;

  Future<Result<ExpenseEntity>> execute(int id) {
    return _repository.getExpenseById(id);
  }
}
