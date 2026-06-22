import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Active date pattern — updated from app settings (Settings → Date Format)
  /// at startup and whenever the user changes it. Call sites that pass an
  /// explicit [pattern] override this.
  static String pattern = 'dd/MM/yyyy';

  static String format(DateTime date, {String? pattern}) {
    return DateFormat(pattern ?? DateFormatter.pattern).format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  static DateTime? tryParse(String text, {String? pattern}) {
    try {
      return DateFormat(pattern ?? DateFormatter.pattern).parseStrict(text);
    } catch (_) {
      return null;
    }
  }
}
