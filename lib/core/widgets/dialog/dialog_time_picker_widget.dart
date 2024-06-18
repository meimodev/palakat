import 'package:flutter/material.dart';

Future<DateTime?> showDialogTimePickerWidget({
  required BuildContext context,
}) async {
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    initialEntryMode: TimePickerEntryMode.dialOnly,
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
  );
  DateTime? res;
  if (time != null) {
    res = DateTime.now().copyWith(
      hour: time.hour,
      minute: time.minute,
      microsecond: 0,
      millisecond: 0,
    );
  }
  return res;
}
