import 'package:flutter/material.dart';

/// Shows a date picker dialog with customizable options.
///
/// Returns the selected [DateTime] or null if cancelled.
Future<DateTime?> showDialogDatePickerWidget({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? lastDate,
  DatePickerMode? initialDatePickerMode,
  DateTime? firstDate,
}) {
  return showDatePicker(
    context: context,
    firstDate: firstDate ?? DateTime(1900),
    lastDate: lastDate ?? DateTime.now(),
    initialDatePickerMode: initialDatePickerMode ?? DatePickerMode.year,
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    initialDate: initialDate ?? DateTime(1990),
  );
}
