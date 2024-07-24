import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

class SongDetails extends StatelessWidget {
  SongDetails({super.key});

  final DummyData dummyData = DummyData();
  final SongPart songPart = SongPart();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            title: dummyData.titles,
            subTitle: dummyData.subtitles,
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: BaseColor.black,
            onPressedLeadIcon: () {
              Navigator.pop(context);
            },
          ),
          Gap.h24,
          Text(
            songPart.data[0],
            style: BaseTypography.bodyMedium.toBold.toSecondary,
          ),
          Gap.h6,
          Text(
            songPart.data[5],
            style: BaseTypography.bodyMedium.toPrimary,
          ),
          Gap.h12,
          Text(
            songPart.data[1],
            style: BaseTypography.bodyMedium.toBold.toSecondary,
          ),
          Gap.h6,
          Text(
            songPart.data[7],
            style: BaseTypography.bodyMedium.toPrimary,
          ),
          Gap.h12,
          Text(
            songPart.data[2],
            style: BaseTypography.bodyMedium.toBold.toSecondary,
          ),
          Gap.h12,
          Text(
            songPart.data[3],
            style: BaseTypography.bodyMedium.toBold.toSecondary,
          ),
          Gap.h12,
          Text(
            textAlign: TextAlign.left,
            songPart.data[4],
            style: BaseTypography.bodyMedium.toBold.toSecondary,
          ),
          Gap.h6,
          Text(
            songPart.data[6],
            style: BaseTypography.bodyMedium.toPrimary,
          ),
          Gap.h24,
          Text(
            dummyData.youtube,
            style: BaseTypography.bodyMedium.toBold.toSecondary,
          ),
          Gap.h6,
          ImageNetworkWidget(
            imageUrl: dummyData.image,
            height: 336.0,
            width: 736.0,
          )
        ],
      ),
    );
  }
}
