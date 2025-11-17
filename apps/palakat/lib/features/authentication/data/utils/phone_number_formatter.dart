/// Utility class for formatting and manipulating phone numbers
class PhoneNumberFormatter {
  PhoneNumberFormatter._();

  /// Formats a phone number for display with dashes every 4 digits
  ///
  /// Example:
  /// - Input: "081234567890"
  /// - Output: "0812-3456-7890"
  ///
  /// Parameters:
  /// - [phone]: The phone number to format
  /// - [convertPlusToZero]: If true, converts +62 prefix to 0 (default: false)
  ///
  /// Examples with convertPlusToZero:
  /// - Input: "+6281234567890", convertPlusToZero: true
  /// - Output: "0812-3456-7890"
  static String format(String phone, {bool convertPlusToZero = false}) {
    String processedPhone = phone;

    // Convert +62 to 0 if requested
    if (convertPlusToZero && phone.startsWith('+62')) {
      processedPhone = '0${phone.substring(3)}';
    }

    // Remove all non-digit characters
    final cleanPhone = processedPhone.replaceAll(RegExp(r'\D'), '');

    if (cleanPhone.isEmpty) {
      return '';
    }

    // Format with dashes every 4 digits
    final buffer = StringBuffer();
    for (int i = 0; i < cleanPhone.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(cleanPhone[i]);
    }

    return buffer.toString();
  }

  /// Converts a phone number to E.164 format for Firebase
  ///
  /// E.164 format: +62[phone number without leading 0]
  /// Example: "081234567890" -> "+6281234567890"
  ///
  /// Parameters:
  /// - [phone]: The phone number (can include spaces, dashes, etc.)
  ///
  /// Returns: Phone number in E.164 format
  static String toE164(String phone) {
    // Remove all non-digit characters from phone
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    if (cleanPhone.isEmpty) {
      return '+62';
    }

    // Remove leading zero if present
    final phoneWithoutLeadingZero = cleanPhone.startsWith('0')
        ? cleanPhone.substring(1)
        : cleanPhone;

    return '+62$phoneWithoutLeadingZero';
  }

  /// Masks the middle digits of a phone number for privacy
  ///
  /// Example:
  /// - Input: "0812-3456-7890"
  /// - Output: "0812-****-7890"
  ///
  /// Parameters:
  /// - [fullPhoneNumber]: The phone number to mask
  /// - [convertPlusToZero]: If true, converts +62 prefix to 0 before masking (default: false)
  ///
  /// Shows first 4 and last 4 digits
  static String mask(String fullPhoneNumber, {bool convertPlusToZero = false}) {
    String processedPhone = fullPhoneNumber;

    // Convert +62 to 0 if requested
    if (convertPlusToZero && fullPhoneNumber.startsWith('+62')) {
      processedPhone = '0${fullPhoneNumber.substring(3)}';
    }

    // Remove all non-digit characters
    final cleaned = processedPhone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length <= 8) {
      // If phone is too short, mask middle part
      if (cleaned.length <= 4) {
        return cleaned.replaceAll(RegExp(r'.'), '*');
      }
      final first = cleaned.substring(0, 2);
      final last = cleaned.substring(cleaned.length - 2);
      final masked = '*' * (cleaned.length - 4);
      return format('$first$masked$last');
    }

    // Standard masking: show first 4 and last 4 digits
    final first = cleaned.substring(0, 4);
    final last = cleaned.substring(cleaned.length - 4);
    final masked = '*' * (cleaned.length - 8);

    return format('$first$masked$last');
  }
}
