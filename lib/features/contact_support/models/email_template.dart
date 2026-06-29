import '../../../constants/app_constants.dart';
import 'support_request.dart';

/// Single source for the email subject/body used by the support cards AND the
/// form. Keep this identical to the website's mailto templates for parity.
abstract class SupportEmailTemplate {
  /// Subject line per request type, e.g. "BuildWise — Bug Report".
  static String subject(SupportRequestType type) => 'BuildWise — ${type.wire}';

  /// Body when tapping a type card (no form details yet).
  static String quickBody(SupportRequestType type) =>
      'Hi BuildWise team,\n\n[${type.wire}] ';

  /// Body for the filled form.
  static String formBody({
    required String name,
    required String email,
    required String message,
  }) =>
      'Name: $name\nEmail: $email\n\n$message';

  /// Build a complete `mailto:` URI.
  static Uri mailto(
    SupportRequestType type, {
    String? body,
  }) {
    return Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      query: _encodeQuery({
        'subject': subject(type),
        'body': body ?? quickBody(type),
      }),
    );
  }

  // Uri(query:) must be manually encoded (Uri encodes the whole string once).
  static String _encodeQuery(Map<String, String> params) => params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
