import 'package:flutter/material.dart';

Future<TimeOfDay?> showDialogTimePickerWidget({
  required BuildContext context,
  TimeOfDay? initialTime,
}) async {
  final time = await showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),
    initialEntryMode: TimePickerEntryMode.dialOnly,
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      );
    },
  );
  return time;
}
