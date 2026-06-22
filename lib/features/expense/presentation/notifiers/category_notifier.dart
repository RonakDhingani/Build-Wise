import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expense_providers.dart';

/// Manages the global expense-category master list (Settings → Expense
/// Categories). Mutating methods return an error message on failure, or
/// `null` on success, so callers can surface validation errors (e.g. a
/// category still in use cannot be deleted).
class CategoriesNotifier extends AsyncNotifier<List<ExpenseCategoryEntity>> {
  @override
  Future<List<ExpenseCategoryEntity>> build() async {
    return _load();
  }

  Future<List<ExpenseCategoryEntity>> _load() async {
    final useCase = ref.read(getCategoriesUseCaseProvider);
    final result = await useCase.execute();
    return result.when(
      success: (data) => data,
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<String?> add(String name) async {
    final useCase = ref.read(createCategoryUseCaseProvider);
    final result = await useCase.execute(name);
    return result.when(
      success: (created) {
        state.whenData((list) {
          final updated = [...list, created]
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          state = AsyncData(updated);
        });
        return null;
      },
      failure: (f) => f.message,
    );
  }

  Future<String?> edit(ExpenseCategoryEntity entity) async {
    final useCase = ref.read(updateCategoryUseCaseProvider);
    final result = await useCase.execute(entity);
    return result.when(
      success: (updated) {
        state.whenData((list) {
          final next = list
              .map((c) => c.id == updated.id ? updated : c)
              .toList()
            ..sort((a, b) =>
                a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          state = AsyncData(next);
        });
        return null;
      },
      failure: (f) => f.message,
    );
  }

  Future<String?> remove(int id) async {
    final useCase = ref.read(deleteCategoryUseCaseProvider);
    final result = await useCase.execute(id);
    return result.when(
      success: (_) {
        state.whenData((list) {
          state = AsyncData(list.where((c) => c.id != id).toList());
        });
        return null;
      },
      failure: (f) => f.message,
    );
  }
}
