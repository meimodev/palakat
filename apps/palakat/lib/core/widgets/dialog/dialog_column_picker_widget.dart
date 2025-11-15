import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/models/column.dart' as model;

Future<model.Column?> showDialogColumnPickerWidget({
  required BuildContext context,
  VoidCallback? onPopBottomSheet,
}) {
  return showDialogCustomWidget<model.Column?>(
    context: context,
    title: "Select Column",
    scrollControlled: false,
    content: Expanded(
      child: _DialogColumnPickerWidget(
        onPressedCard: (model.Column c) {
          context.pop<model.Column>(c);
        },
      ),
    ),
  );
}

class _DialogColumnPickerWidget extends StatelessWidget {
  const _DialogColumnPickerWidget({required this.onPressedCard});

  final void Function(model.Column) onPressedCard;

  @override
  Widget build(BuildContext context) {
    final List<model.Column> columns = List<model.Column>.generate(
      15,
      (index) => model.Column(id: index, name: "$index", churchId: index),
    );

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: columns.length,
      separatorBuilder: (BuildContext context, int index) =>
          Padding(padding: EdgeInsets.symmetric(vertical: BaseSize.h6)),
      itemBuilder: (BuildContext context, int index) {
        final c = columns[index];
        return CardColumn(column: c, onPressed: () => onPressedCard(c));
      },
    );

    // return Column(
    //   children: [
    //     ...columns.map(
    //       (c) {
    //         // final c = columns[index];
    //         return CardColumn(
    //           church: c,
    //           onPressed: () {},
    //         );
    //       },
    //     ),
    //   ],
    // );
  }
}
