import '../shared/widgets/cards/app_trend_card.dart';

/// Helpers for the trend summary cards on the Expenses and Materials screens.
class TrendStats {
  TrendStats._();

  static bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static DateTime _monthsAgo(DateTime from, int months) {
    var y = from.year;
    var m = from.month - months;
    while (m <= 0) {
      m += 12;
      y -= 1;
    }
    return DateTime(y, m);
  }

  /// Total of [value] over items whose [date] falls in the given [period].
  static double totalForPeriod<T>(
    List<T> items,
    DateTime Function(T) date,
    double Function(T) value,
    TrendPeriod period,
  ) {
    final now = DateTime.now();
    final lastMonth = _monthsAgo(now, 1);
    var sum = 0.0;
    for (final it in items) {
      final d = date(it);
      switch (period) {
        case TrendPeriod.thisMonth:
          if (_sameMonth(d, now)) sum += value(it);
        case TrendPeriod.lastMonth:
          if (_sameMonth(d, lastMonth)) sum += value(it);
        case TrendPeriod.allTime:
          sum += value(it);
      }
    }
    return sum;
  }

  /// Monthly totals for the last [months] months, oldest first — feeds the
  /// mini bar chart.
  static List<double> monthlyTotals<T>(
    List<T> items,
    DateTime Function(T) date,
    double Function(T) value, {
    int months = 6,
  }) {
    final now = DateTime.now();
    final buckets = List<double>.filled(months, 0);
    for (final it in items) {
      final d = date(it);
      for (var i = 0; i < months; i++) {
        if (_sameMonth(d, _monthsAgo(now, months - 1 - i))) {
          buckets[i] += value(it);
          break;
        }
      }
    }
    return buckets;
  }
}
