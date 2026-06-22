import 'package:isar/isar.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../mappers/expense_mapper.dart';
import '../models/expense_category_isar_model.dart';
import '../models/expense_isar_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._isar);
  final Isar _isar;

  @override
  Future<Result<ExpenseEntity>> createExpense(ExpenseEntity entity) async {
    try {
      final now = DateTime.now();
      final model = ExpenseMapper.toModel(entity.copyWith(
        createdAt: now,
        updatedAt: now,
      ));

      late int newId;
      await _isar.writeTxn(() async {
        newId = await _isar.expenseModels.put(model);
      });

      final saved = await _isar.expenseModels.get(newId);
      if (saved == null) return const Failure(DatabaseFailure());
      return Success(ExpenseMapper.toEntity(saved));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to create expense: $e'));
    }
  }

  @override
  Future<Result<ExpenseEntity>> updateExpense(ExpenseEntity entity) async {
    try {
      final existing = await _isar.expenseModels.get(entity.id);
      if (existing == null) return const Failure(NotFoundFailure());

      final model = ExpenseMapper.toModel(entity.copyWith(
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      ));
      model.id = entity.id;

      await _isar.writeTxn(() => _isar.expenseModels.put(model));
      final saved = await _isar.expenseModels.get(entity.id);
      if (saved == null) return const Failure(DatabaseFailure());
      return Success(ExpenseMapper.toEntity(saved));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to update expense: $e'));
    }
  }

  @override
  Future<Result<void>> deleteExpense(int id) async {
    try {
      await _isar.writeTxn(() => _isar.expenseModels.delete(id));
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to delete expense: $e'));
    }
  }

  @override
  Future<Result<List<ExpenseEntity>>> getExpensesByProject(int projectId) async {
    try {
      final models = await _isar.expenseModels
          .filter()
          .projectIdEqualTo(projectId)
          .sortByDateDesc()
          .findAll();
      return Success(models.map(ExpenseMapper.toEntity).toList());
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load expenses: $e'));
    }
  }

  @override
  Future<Result<ExpenseEntity>> getExpenseById(int id) async {
    try {
      final model = await _isar.expenseModels.get(id);
      if (model == null) return const Failure(NotFoundFailure());
      return Success(ExpenseMapper.toEntity(model));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load expense: $e'));
    }
  }

  @override
  Future<Result<List<ExpenseCategoryEntity>>> getCategories() async {
    try {
      final models = await _isar.expenseCategoryModels
          .where()
          .sortByName()
          .findAll();
      return Success(models.map(ExpenseCategoryMapper.toEntity).toList());
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load categories: $e'));
    }
  }

  @override
  Future<Result<ExpenseCategoryEntity>> createCategory(
    String name, {
    String? colorHex,
  }) async {
    try {
      final trimmed = name.trim();
      if (trimmed.isEmpty) {
        return const Failure(ValidationFailure('Category name is required.'));
      }
      final existing = await _isar.expenseCategoryModels
          .filter()
          .nameEqualTo(trimmed, caseSensitive: false)
          .findFirst();
      if (existing != null) {
        return const Failure(
          ValidationFailure('A category with this name already exists.'),
        );
      }
      final model = ExpenseCategoryModel()
        ..name = trimmed
        ..isDefault = false
        ..colorHex = colorHex
        ..createdAt = DateTime.now();
      final id = await _isar.writeTxn(() async {
        return _isar.expenseCategoryModels.put(model);
      });
      model.id = id;
      return Success(ExpenseCategoryMapper.toEntity(model));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to create category: $e'));
    }
  }

  @override
  Future<Result<ExpenseCategoryEntity>> updateCategory(
    ExpenseCategoryEntity entity,
  ) async {
    try {
      final trimmed = entity.name.trim();
      if (trimmed.isEmpty) {
        return const Failure(ValidationFailure('Category name is required.'));
      }
      final model = await _isar.expenseCategoryModels.get(entity.id);
      if (model == null) {
        return const Failure(NotFoundFailure('Category not found.'));
      }
      final clash = await _isar.expenseCategoryModels
          .filter()
          .nameEqualTo(trimmed, caseSensitive: false)
          .and()
          .not()
          .idEqualTo(entity.id)
          .findFirst();
      if (clash != null) {
        return const Failure(
          ValidationFailure('A category with this name already exists.'),
        );
      }
      model
        ..name = trimmed
        ..colorHex = entity.colorHex;
      await _isar.writeTxn(() async {
        await _isar.expenseCategoryModels.put(model);
      });
      return Success(ExpenseCategoryMapper.toEntity(model));
    } catch (e) {
      return Failure(DatabaseFailure('Failed to update category: $e'));
    }
  }

  @override
  Future<Result<void>> deleteCategory(int id) async {
    try {
      final inUse = await _isar.expenseModels
          .filter()
          .categoryIdEqualTo(id)
          .count();
      if (inUse > 0) {
        return Failure(ValidationFailure(
          'Cannot delete: $inUse expense(s) use this category.',
        ));
      }
      await _isar.writeTxn(() async {
        await _isar.expenseCategoryModels.delete(id);
      });
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to delete category: $e'));
    }
  }
}
