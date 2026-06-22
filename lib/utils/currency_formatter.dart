import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Active currency symbol — updated from app settings (Settings → Currency)
  /// at startup and whenever the user changes it. Call sites that pass an
  /// explicit [symbol] override this.
  static String symbol = '₹';

  static String format(
    double amount, {
    String? symbol,
    String locale = 'en_IN',
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol ?? CurrencyFormatter.symbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatCompact(
    double amount, {
    String? symbol,
  }) {
    final s = symbol ?? CurrencyFormatter.symbol;
    if (amount >= 10000000) {
      return '$s${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '$s${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '$s${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, symbol: s);
  }

  static double? tryParse(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned);
  }
}
