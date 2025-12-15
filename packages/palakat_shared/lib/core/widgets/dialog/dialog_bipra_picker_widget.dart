import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../constants/enums.dart';
import '../card/card_bipra.dart';
import 'dialog_custom_widget.dart';

/// Shows a dialog for selecting a BIPRA (activity type).
///
/// Returns the selected [Bipra] or null if cancelled.
Future<Bipra?> showDialogBipraPickerWidget({
  required BuildContext context,
  required String title,
  VoidCallback? onPopBottomSheet,
  Widget? closeIcon,
}) {
  return showDialogCustomWidget<Bipra?>(
    context: context,
    title: title,
    closeIcon: closeIcon,
    content: _DialogBipraPickerWidget(
      onPressedBipraCard: (Bipra bipra) {
        context.pop(bipra);
      },
    ),
  );
}

class _DialogBipraPickerWidget extends StatelessWidget {
  const _DialogBipraPickerWidget({required this.onPressedBipraCard});

  final void Function(Bipra bipra) onPressedBipraCard;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: Bipra.values.length,
      separatorBuilder: (BuildContext context, int index) =>
          Padding(padding: EdgeInsets.symmetric(vertical: BaseSize.h6)),
      itemBuilder: (BuildContext context, int index) {
        final e = Bipra.values[index];
        return CardBipra(bipra: e, onPressed: () => onPressedBipraCard(e));
      },
    );
  }
}
