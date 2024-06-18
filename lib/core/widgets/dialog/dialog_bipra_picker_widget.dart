import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/constants/constants.dart';

Future<Bipra?> showDialogBipraPickerWidget({
  required BuildContext context,
  VoidCallback? onPopBottomSheet,
}) {
  return showDialogCustomWidget<Bipra?>(
    context: context,
    title: "Select BIPRA",
    content: _DialogBipraPickerWidget(
      onPressedBipraCard: (Bipra bipra) {
        context.pop(bipra);
      },
    ),
  );
}

class _DialogBipraPickerWidget extends StatelessWidget {
  const _DialogBipraPickerWidget({
    required this.onPressedBipraCard,
  });

  final void Function(Bipra bipra) onPressedBipraCard;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: Bipra.values.length,
      separatorBuilder: (BuildContext context, int index) => Padding(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.h6,
        ),
      ),
      itemBuilder: (BuildContext context, int index) {
        final e = Bipra.values[index];
        return CardBipra(
          bipra: e,
          onPressed: () => onPressedBipraCard(e),
        );
      },
    );
  }
}
