extension DoubleExtension on double {
  double clamp01() => clamp(0.0, 1.0).toDouble();

  double get asPercent => this * 100;

  bool get isPositive => this > 0;
  bool get isZero => this == 0.0;

  double roundToDecimalPlaces(int places) {
    final factor = _pow10(places);
    return (this * factor).round() / factor;
  }

  double _pow10(int n) {
    double result = 1;
    for (int i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }
}

extension NullableDoubleExtension on double? {
  double get orZero => this ?? 0.0;
}
