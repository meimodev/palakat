import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

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
            title: dummyData.titles[0],
            subTitle: dummyData.titles[1],
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: BaseColor.black,
            onPressedLeadIcon: () {
              Navigator.pop(context);
            },
          ),
          Gap.h24,
          ...data.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (item.type != null) ...[
                    Text(
                      item.type!,
                      style: BaseTypography.bodyMedium.toBold.toSecondary,
                    ),
                  ],
                  if (item.content != null) ...[
                    Gap.h6,
                    Text(
                      item.content!,
                      style: BaseTypography.bodyMedium.toPrimary,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          Gap.h24,
          Text(
            dummyData.source[0],
            style: BaseTypography.bodyMedium.toBold.toSecondary,
          ),
          Gap.h6,
          ImageNetworkWidget(
            imageUrl: dummyData.source[1],
            height: 336.0,
            width: 736.0,
          )
        ],
      ),
    );
  }
}
