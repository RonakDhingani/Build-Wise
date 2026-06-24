import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/result/result.dart';
import '../../../stage/data/models/stage_isar_model.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/use_cases/create_category_use_case.dart';
import '../../domain/use_cases/create_expense_use_case.dart';
import '../../domain/use_cases/delete_category_use_case.dart';
import '../../domain/use_cases/delete_expense_use_case.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import '../../domain/use_cases/get_expense_by_id_use_case.dart';
import '../../domain/use_cases/get_expenses_use_case.dart';
import '../../domain/use_cases/update_category_use_case.dart';
import '../../domain/use_cases/update_expense_use_case.dart';
import '../notifiers/category_notifier.dart';
import '../notifiers/expense_notifier.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.read(isarProvider));
});

final createExpenseUseCaseProvider = Provider<CreateExpenseUseCase>((ref) {
  return CreateExpenseUseCase(ref.read(expenseRepositoryProvider));
});

final updateExpenseUseCaseProvider = Provider<UpdateExpenseUseCase>((ref) {
  return UpdateExpenseUseCase(ref.read(expenseRepositoryProvider));
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  return DeleteExpenseUseCase(ref.read(expenseRepositoryProvider));
});

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  return GetExpensesUseCase(ref.read(expenseRepositoryProvider));
});

final getExpenseByIdUseCaseProvider = Provider<GetExpenseByIdUseCase>((ref) {
  return GetExpenseByIdUseCase(ref.read(expenseRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.read(expenseRepositoryProvider));
});

final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  return CreateCategoryUseCase(ref.read(expenseRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.read(expenseRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.read(expenseRepositoryProvider));
});

final categoriesNotifierProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<ExpenseCategoryEntity>>(
  CategoriesNotifier.new,
);

final expensesNotifierProvider =
    AsyncNotifierProvider.family<ExpensesNotifier, ExpenseState, int>(
  ExpensesNotifier.new,
);

// Standalone categories provider for forms that load independently
// Derives from categoriesNotifierProvider (single source of truth) so any
// add/edit/delete — from Settings or quick-add — reflects in the dropdown
// immediately, without a separate fetch that can drift out of sync.
final expenseCategoriesProvider =
    FutureProvider<List<ExpenseCategoryEntity>>((ref) {
  return ref.watch(categoriesNotifierProvider.future);
});

// Minimal stage info for the stage-link dropdown in the expense form
class StageInfo {
  const StageInfo({required this.id, required this.name});
  final int id;
  final String name;
}

final stagesByProjectProvider =
    FutureProvider.family<List<StageInfo>, int>((ref, projectId) async {
  final isar = ref.read(isarProvider);
  final models = await isar.stageModels
      .where()
      .projectIdEqualTo(projectId)
      .findAll();
  models.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  return models.map((m) => StageInfo(id: m.id, name: m.name)).toList();
});
