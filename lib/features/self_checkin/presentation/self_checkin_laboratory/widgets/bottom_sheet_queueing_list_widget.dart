import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

Future<T?> showQueueingListBottomSheetWidget<T>(
  BuildContext context, {
  required List<Map<String, dynamic>> queueList,
  void Function()? onPressedOk,
}) => showCustomDialogWidget<T>(
    context,
    title: LocaleKeys.text_queueList.tr(),
    onTap: () {
      if (onPressedOk != null) {
        onPressedOk();
      }
      context.pop();
    },
    hideLeftButton: true,
    btnRightText: LocaleKeys.text_ok.tr(),
    content: BottomSheetQueueingListWidget(
      queueList: queueList,
    ),
  );

class BottomSheetQueueingListWidget extends StatelessWidget {
  const BottomSheetQueueingListWidget({super.key, required this.queueList});

  final List<Map<String, dynamic>> queueList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (Map<String, dynamic> q in queueList)
              _ListItemBottomSheetQueueingList(
                text: q["text"],
                index: q["index"],
                highlighted: q["current"],
              ),
          ],
        ),
      ),
    );
  }
}

class _ListItemBottomSheetQueueingList extends StatelessWidget {
  const _ListItemBottomSheetQueueingList({
    this.highlighted = false,
    required this.text,
    required this.index,
  });

  final bool highlighted;
  final String text;
  final String index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: highlighted ? BaseColor.primary2 : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.customWidth(10),
        vertical: BaseSize.customWidth(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              highlighted ? LocaleKeys.text_yourQueue.tr() : text,
              style: TypographyTheme.textLRegular.toNeutral80,
            ),
          ),
          Text(
            index,
            style: TypographyTheme.textLRegular.toNeutral80,
          ),
        ],
      ),
    );
  }
}
