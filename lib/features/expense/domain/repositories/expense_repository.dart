import '../../../../core/result/result.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<Result<ExpenseEntity>> createExpense(ExpenseEntity entity);
  Future<Result<ExpenseEntity>> updateExpense(ExpenseEntity entity);
  Future<Result<void>> deleteExpense(int id);
  Future<Result<List<ExpenseEntity>>> getExpensesByProject(int projectId);
  Future<Result<ExpenseEntity>> getExpenseById(int id);
  Future<Result<List<ExpenseCategoryEntity>>> getCategories();
  Future<Result<ExpenseCategoryEntity>> createCategory(
    String name, {
    String? colorHex,
  });
  Future<Result<ExpenseCategoryEntity>> updateCategory(
    ExpenseCategoryEntity entity,
  );
  Future<Result<void>> deleteCategory(int id);
}
