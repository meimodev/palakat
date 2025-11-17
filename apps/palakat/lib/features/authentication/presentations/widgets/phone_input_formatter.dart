import 'package:flutter/services.dart';

/// Text input formatter that automatically adds dashes every 4 digits
/// Format: XXXX-XXXX-XXXX or XXXX-XXXX-XXXXX
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Get only digits from the old and new text
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    final newDigits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit to 13 digits
    final limitedDigits = newDigits.length > 13
        ? newDigits.substring(0, 13)
        : newDigits;

    // Build formatted string with dashes every 4 digits
    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(limitedDigits[i]);
    }

    final formattedText = buffer.toString();

    // Calculate cursor position based on digit position
    // Count how many digits are before the cursor in the old value
    final oldCursorPosition = oldValue.selection.baseOffset;
    final digitsBeforeCursor = oldValue.text
        .substring(0, oldCursorPosition)
        .replaceAll(RegExp(r'\D'), '')
        .length;

    // Determine new cursor position based on digits
    // If we're adding digits, move cursor forward
    // If we're removing digits, move cursor backward
    int targetDigitPosition = digitsBeforeCursor;

    if (newDigits.length > oldDigits.length) {
      // Adding digit(s)
      targetDigitPosition =
          digitsBeforeCursor + (newDigits.length - oldDigits.length);
    } else if (newDigits.length < oldDigits.length) {
      // Removing digit(s)
      targetDigitPosition =
          digitsBeforeCursor - (oldDigits.length - newDigits.length);
    }

    // Clamp to valid range
    targetDigitPosition = targetDigitPosition.clamp(0, limitedDigits.length);

    // Convert digit position to character position (accounting for dashes)
    int newOffset = 0;
    int digitCount = 0;
    for (
      int i = 0;
      i < formattedText.length && digitCount < targetDigitPosition;
      i++
    ) {
      if (formattedText[i] != '-') {
        digitCount++;
      }
      newOffset = i + 1;
    }

    // Ensure cursor is within bounds
    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
