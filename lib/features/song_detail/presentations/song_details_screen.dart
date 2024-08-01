import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/dummy_data.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

class SongDetails extends StatelessWidget {
  SongDetails({super.key});

  final DummyData dummyData = DummyData();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            title: dummyData.title,
            subTitle: dummyData.subTitle,
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: BaseColor.black,
            onPressedLeadIcon: () {
              Navigator.pop(context);
            },
          ),
          Gap.h24,
          ...dummyData.data.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;
            bool isBeforeLastItem = index == dummyData.data.length - 2;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.type.isNotEmpty) ...[
                  Gap.h6,
                  Text(
                    item.type,
                    style: BaseTypography.bodyMedium.toBold.toSecondary,
                  ),
                ],
                if (item.content.isNotEmpty) ...[
                  Gap.h6,
                  Text(
                    item.content,
                    style: BaseTypography.bodyMedium.toPrimary,
                  ),
                ],
                if (isBeforeLastItem) ...[
                  Gap.h24,
                ],
              ],
            );
          }).toList(),
          Gap.h24,
          ImageNetworkWidget(
            imageUrl: dummyData.source[0],
            height: 336.0,
            width: 736.0,
          ),
        ],
      ),
    );
  }
}
