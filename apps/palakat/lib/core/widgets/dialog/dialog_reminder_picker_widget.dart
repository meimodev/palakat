import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

Future<Reminder?> showDialogReminderPickerWidget({
  required BuildContext context,
  VoidCallback? onPopBottomSheet,
}) {
  return showDialogCustomWidget<Reminder?>(
    context: context,
    title: "Select Reminder",
    content: _DialogReminderPickerWidget(
      onPressedReminderCard: (Reminder reminder) {
        context.pop(reminder);
      },
    ),
  );
}

class _DialogReminderPickerWidget extends StatelessWidget {
  const _DialogReminderPickerWidget({
    required this.onPressedReminderCard,
  });

  final void Function(Reminder reminder) onPressedReminderCard;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: Reminder.values.length,
      separatorBuilder: (BuildContext context, int index) => Padding(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.h6,
        ),
      ),
      itemBuilder: (BuildContext context, int index) {
        final e = Reminder.values[index];
        return CardReminder(
          reminder: e,
          onPressed: () => onPressedReminderCard(e),
        );
      },
    );
  }
}
