import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    return null;
  }

  static String? positiveAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    if (amount == null) return AppStrings.invalidAmount;
    if (amount <= 0) return AppStrings.positiveAmount;
    return null;
  }

  static String? nonNegativeAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    if (amount == null) return AppStrings.invalidAmount;
    if (amount < 0) return AppStrings.invalidAmount;
    return null;
  }

  static String? optionalPositiveAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return positiveAmount(value);
  }

  static String? positiveInt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final n = int.tryParse(value);
    if (n == null || n <= 0) return AppStrings.invalidAmount;
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final v in validators) {
      final result = v(value);
      if (result != null) return result;
    }
    return null;
  }
}
