import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../features/expense/domain/entities/expense_entity.dart';
import '../features/material/domain/entities/material_entity.dart';
import '../features/stage/domain/entities/stage_entity.dart';
import '../theme/app_colors.dart';

/// One slice/bar with an explicit color (donut, top-N bars).
class ChartSlice {
  const ChartSlice({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;
}

/// One point on a trend line (month bucket).
class TrendPoint {
  const TrendPoint({required this.label, required this.value});
  final String label;
  final double value;
}

/// Consistent chart palette derived from the Build Wise design system —
/// no random colors. Used for series that have no intrinsic color.
const List<Color> kChartPalette = [
  AppColors.navy500,
  AppColors.gold400,
  AppColors.success500,
  AppColors.info500,
  AppColors.violet,
  AppColors.teal,
  AppColors.error500,
  AppColors.pink,
  AppColors.brown,
  AppColors.navy300,
];

Color paletteColor(int i) => kChartPalette[i % kChartPalette.length];

/// Pure, cheap analytics transforms. Caller memoizes by passing stable lists.
class Analytics {
  Analytics._();

  // ---- Expenses ----

  static List<ChartSlice> expensesByCategory(
    List<ExpenseEntity> expenses,
    List<ExpenseCategoryEntity> categories,
  ) {
    final byId = <int, double>{};
    for (final e in expenses) {
      byId[e.categoryId] = (byId[e.categoryId] ?? 0) + e.amount;
    }
    final catById = {for (final c in categories) c.id: c};
    final slices = byId.entries.map((e) {
      final cat = catById[e.key];
      return ChartSlice(
        label: cat?.name ?? 'Uncategorized',
        value: e.value,
        color: cat?.color ?? AppColors.navy500,
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return slices;
  }

  static List<ChartSlice> topExpenseCategories(
    List<ExpenseEntity> expenses,
    List<ExpenseCategoryEntity> categories, {
    int limit = 5,
  }) {
    final all = expensesByCategory(expenses, categories);
    return all.take(limit).toList();
  }

  static List<TrendPoint> monthlyExpenseTrend(
    List<ExpenseEntity> expenses, {
    int months = 6,
  }) =>
      _monthlyTrend(expenses, (e) => e.date, (e) => e.amount, months);

  // ---- Materials ----

  static List<ChartSlice> materialCostDistribution(
    List<MaterialEntity> materials,
  ) {
    final byName = <String, double>{};
    for (final m in materials) {
      if (m.totalCost <= 0) continue;
      byName[m.name] = (byName[m.name] ?? 0) + m.totalCost;
    }
    final entries = byName.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (var i = 0; i < entries.length; i++)
        ChartSlice(
          label: entries[i].key,
          value: entries[i].value,
          color: paletteColor(i),
        ),
    ];
  }

  static List<ChartSlice> topMaterials(
    List<MaterialEntity> materials, {
    int limit = 5,
  }) =>
      materialCostDistribution(materials).take(limit).toList();

  static List<TrendPoint> monthlyMaterialTrend(
    List<MaterialEntity> materials, {
    int months = 6,
  }) =>
      _monthlyTrend(materials, (m) => m.purchaseDate, (m) => m.totalCost, months);

  // ---- Stages ----

  static List<ChartSlice> stageProgress(List<StageEntity> stages) {
    final sorted = [...stages]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return [
      for (var i = 0; i < sorted.length; i++)
        ChartSlice(
          label: sorted[i].name,
          value: sorted[i].progressPercent.toDouble(),
          color: sorted[i].progressPercent >= 100
              ? AppColors.success500
              : sorted[i].progressPercent > 0
                  ? AppColors.navy500
                  : AppColors.neutral400,
        ),
    ];
  }

  // ---- shared ----

  static List<TrendPoint> _monthlyTrend<T>(
    List<T> items,
    DateTime Function(T) date,
    double Function(T) value,
    int months,
  ) {
    final now = DateTime.now();
    final labels = <String>[];
    final keys = <String>[];
    final fmt = DateFormat('MMM');
    for (var i = months - 1; i >= 0; i--) {
      var y = now.year;
      var m = now.month - i;
      while (m <= 0) {
        m += 12;
        y -= 1;
      }
      keys.add('$y-$m');
      labels.add(fmt.format(DateTime(y, m)));
    }
    final sums = {for (final k in keys) k: 0.0};
    for (final it in items) {
      final d = date(it);
      final k = '${d.year}-${d.month}';
      if (sums.containsKey(k)) sums[k] = sums[k]! + value(it);
    }
    return [
      for (var i = 0; i < keys.length; i++)
        TrendPoint(label: labels[i], value: sums[keys[i]]!),
    ];
  }
}
