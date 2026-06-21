import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expense_providers.dart';

enum ExpenseSortOrder { dateDesc, dateAsc, amountDesc, amountAsc }

class ExpenseState {
  const ExpenseState({
    required this.expenses,
    required this.categories,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.sortOrder = ExpenseSortOrder.dateDesc,
  });

  final List<ExpenseEntity> expenses;
  final List<ExpenseCategoryEntity> categories;
  final String searchQuery;
  final int? selectedCategoryId;
  final ExpenseSortOrder sortOrder;

  double get totalAmount => expenses.fold(0.0, (s, e) => s + e.amount);
  int get count => expenses.length;

  List<ExpenseEntity> get filtered {
    var list = [...expenses];

    if (selectedCategoryId != null) {
      list = list.where((e) => e.categoryId == selectedCategoryId).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((e) {
        final catName = categoryOf(e.categoryId)?.name.toLowerCase() ?? '';
        return (e.description?.toLowerCase().contains(q) ?? false) ||
            (e.vendorName?.toLowerCase().contains(q) ?? false) ||
            catName.contains(q);
      }).toList();
    }

    switch (sortOrder) {
      case ExpenseSortOrder.dateDesc:
        list.sort((a, b) => b.date.compareTo(a.date));
      case ExpenseSortOrder.dateAsc:
        list.sort((a, b) => a.date.compareTo(b.date));
      case ExpenseSortOrder.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case ExpenseSortOrder.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
    }

    return list;
  }

  ExpenseCategoryEntity? categoryOf(int categoryId) {
    for (final c in categories) {
      if (c.id == categoryId) return c;
    }
    return null;
  }

  ExpenseState copyWith({
    List<ExpenseEntity>? expenses,
    List<ExpenseCategoryEntity>? categories,
    String? searchQuery,
    int? selectedCategoryId,
    bool clearCategoryFilter = false,
    ExpenseSortOrder? sortOrder,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId:
          clearCategoryFilter ? null : (selectedCategoryId ?? this.selectedCategoryId),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class ExpensesNotifier extends FamilyAsyncNotifier<ExpenseState, int> {
  @override
  Future<ExpenseState> build(int arg) async {
    return _load(arg);
  }

  Future<ExpenseState> _load(int projectId) async {
    final expUseCase = ref.read(getExpensesUseCaseProvider);
    final catUseCase = ref.read(getCategoriesUseCaseProvider);

    final expFuture = expUseCase.execute(projectId);
    final catFuture = catUseCase.execute();

    final expResult = await expFuture;
    final catResult = await catFuture;

    final expenses = expResult.when(
      success: (data) => data,
      failure: (f) => throw Exception(f.message),
    );
    final categories = catResult.when(
      success: (data) => data,
      failure: (_) => <ExpenseCategoryEntity>[],
    );

    return ExpenseState(expenses: expenses, categories: categories);
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    final newState = await _load(arg);
    state = AsyncData(newState.copyWith(
      searchQuery: current?.searchQuery ?? '',
      selectedCategoryId: current?.selectedCategoryId,
      clearCategoryFilter: current?.selectedCategoryId == null,
      sortOrder: current?.sortOrder ?? ExpenseSortOrder.dateDesc,
    ));
  }

  Future<void> addExpense(ExpenseEntity entity) async {
    final useCase = ref.read(createExpenseUseCaseProvider);
    final result = await useCase.execute(entity);
    result.when(
      success: (created) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            expenses: [created, ...s.expenses],
          ));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
    ref.read(projectsNotifierProvider.notifier).refresh();
  }

  Future<void> updateExpense(ExpenseEntity entity) async {
    final useCase = ref.read(updateExpenseUseCaseProvider);
    final result = await useCase.execute(entity);
    result.when(
      success: (updated) {
        state.whenData((s) {
          final list = List<ExpenseEntity>.from(s.expenses);
          final idx = list.indexWhere((e) => e.id == updated.id);
          if (idx >= 0) list[idx] = updated;
          state = AsyncData(s.copyWith(expenses: list));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
    ref.read(projectsNotifierProvider.notifier).refresh();
  }

  Future<void> deleteExpense(int id) async {
    final useCase = ref.read(deleteExpenseUseCaseProvider);
    final result = await useCase.execute(id);
    result.when(
      success: (_) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            expenses: s.expenses.where((e) => e.id != id).toList(),
          ));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
    ref.read(projectsNotifierProvider.notifier).refresh();
  }

  void updateSearch(String query) {
    state.whenData((s) => state = AsyncData(s.copyWith(searchQuery: query)));
  }

  void setCategory(int? categoryId) {
    state.whenData((s) => state = AsyncData(s.copyWith(
          selectedCategoryId: categoryId,
          clearCategoryFilter: categoryId == null,
        )));
  }

  void setSortOrder(ExpenseSortOrder order) {
    state.whenData((s) => state = AsyncData(s.copyWith(sortOrder: order)));
  }
}
