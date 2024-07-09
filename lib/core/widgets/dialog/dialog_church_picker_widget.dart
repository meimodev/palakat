import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/models/models.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/constants/constants.dart';

Future<Church?> showDialogChurchPickerWidget({
  required BuildContext context,
  VoidCallback? onPopBottomSheet,
}) {
  return showDialogCustomWidget<Church?>(
    context: context,
    title: "Select Church",
    scrollControlled: false,
    content: Expanded(
      child: _DialogChurchPickerWidget(
        onPressedCard: (Church c) {
          context.pop<Church>(c);
        },
      ),
    ),
  );
}

class _DialogChurchPickerWidget extends StatelessWidget {
  const _DialogChurchPickerWidget({
    required this.onPressedCard,
  });

  final void Function(Church) onPressedCard;

  @override
  Widget build(BuildContext context) {
    final List<Church> churches = List<Church>.generate(
      15,
      (index) => Church(
        serial: "index $index",
        name: "c $index",
        location: Location(
          latitude: 1,
          longitude: 1,
          name: "name $index",
        ),
      ),
    );

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: churches.length,
      separatorBuilder: (BuildContext context, int index) => Padding(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.h6,
        ),
      ),
      itemBuilder: (BuildContext context, int index) {
        final c = churches[index];
        return CardChurch(
          church: c,
          onPressed: () => onPressedCard(c),
        );
      },
    );

    // return Column(
    //   children: [
    //     ...churches.map(
    //       (c) {
    //         // final c = churches[index];
    //         return CardChurch(
    //           church: c,
    //           onPressed: () {},
    //         );
    //       },
    //     ),
    //   ],
    // );
  }
}
