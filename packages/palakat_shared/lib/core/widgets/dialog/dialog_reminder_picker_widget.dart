import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../constants/enums.dart';
import '../card/card_reminder.dart';
import 'dialog_custom_widget.dart';

/// Shows a dialog for selecting a reminder option.
///
/// Returns the selected [Reminder] or null if cancelled.
Future<Reminder?> showDialogReminderPickerWidget({
  required BuildContext context,
  VoidCallback? onPopBottomSheet,
  Widget? closeIcon,
}) {
  return showDialogCustomWidget<Reminder?>(
    context: context,
    title: "Select Reminder",
    closeIcon: closeIcon,
    content: _DialogReminderPickerWidget(
      onPressedReminderCard: (Reminder reminder) {
        context.pop(reminder);
      },
    ),
  );
}

class _DialogReminderPickerWidget extends StatelessWidget {
  const _DialogReminderPickerWidget({required this.onPressedReminderCard});

  final void Function(Reminder reminder) onPressedReminderCard;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: Reminder.values.length,
      separatorBuilder: (BuildContext context, int index) =>
          Padding(padding: EdgeInsets.symmetric(vertical: BaseSize.h6)),
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
