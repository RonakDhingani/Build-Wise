import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../expense/domain/entities/expense_entity.dart';
import '../../../expense/presentation/providers/expense_providers.dart';
import '../../../material/domain/entities/material_entity.dart';
import '../../../material/presentation/providers/material_providers.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../../stage/domain/entities/stage_entity.dart';
import '../../../stage/presentation/providers/stage_providers.dart';
import '../../data/report_data.dart';

final reportDataProvider =
    FutureProvider.family<ReportData, int>((ref, projectId) async {
  // React to any mutation in expenses, materials, or stages
  ref.watch(expensesNotifierProvider(projectId));
  ref.watch(materialsNotifierProvider(projectId));
  ref.watch(stagesNotifierProvider(projectId));

  final projectResult = await ref
      .read(getProjectByIdUseCaseProvider)
      .execute(projectId);
  final expensesResult = await ref
      .read(getExpensesUseCaseProvider)
      .execute(projectId);
  final categoriesResult = await ref
      .read(getCategoriesUseCaseProvider)
      .execute();
  final stagesResult = await ref
      .read(getStagesUseCaseProvider)
      .execute(projectId);
  final materialsResult = await ref
      .read(getMaterialsUseCaseProvider)
      .execute(projectId);

  final project = projectResult.when(
    success: (p) => p,
    failure: (f) => throw Exception(f.message),
  );
  final expenses = expensesResult.when(
    success: (e) => e,
    failure: (_) => <ExpenseEntity>[],
  );
  final categories = categoriesResult.when(
    success: (c) => c,
    failure: (_) => <ExpenseCategoryEntity>[],
  );
  final stages = stagesResult.when(
    success: (s) => s,
    failure: (_) => <StageEntity>[],
  );
  final materials = materialsResult.when(
    success: (m) => m,
    failure: (_) => <MaterialEntity>[],
  );

  return ReportData(
    project: project,
    expenses: expenses,
    categories: categories,
    stages: stages,
    materials: materials,
    generatedAt: DateTime.now(),
  );
});
