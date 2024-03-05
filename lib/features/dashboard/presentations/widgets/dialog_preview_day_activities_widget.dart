import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

Future<void> showDialogPreviewDayActivitiesWidget({
  required BuildContext context,
  required void Function() onPressedConfirm,
  required List<Map<String, dynamic>> data,
  required String title,
}) async {
  await showCustomDialogWidget(
    context: context,
    title: title,
    scrollControlled: true,
    content: _DialogPreviewDayActivitiesWidget(data: data),
  );
}

class _DialogPreviewDayActivitiesWidget extends StatelessWidget {
  const _DialogPreviewDayActivitiesWidget({
    required this.data,
  });

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: BaseSize.customHeight(300),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w12,
            ),
            separatorBuilder: (_, __) => Gap.h12,
            itemCount: data.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final d = data[index];
              return CardOverviewPublishingListItemWidget(
                title: d["title"],
                type: d['type'],
                onPressedCard: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
