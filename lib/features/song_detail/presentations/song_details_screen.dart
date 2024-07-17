import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/scaffold/scaffold_widget.dart';
import 'package:palakat/core/widgets/screen_title/screen_title_widget.dart';
import 'package:palakat/features/song_detail/presentations/song_details_data.dart';

class SongDetails extends StatelessWidget {
  SongDetails({super.key});

  final DummyData dummyData = DummyData();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dummyData.verse[0],
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h6,
          Text(
            dummyData.data[0],
            style: BaseTypography.bodyMedium.toPrimary,
          ),
          Gap.h12,
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dummyData.verse[1],
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h6,
          Text(
            dummyData.data[1],
            style: BaseTypography.bodyMedium.toPrimary,
          ),
          Gap.h12,
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dummyData.verse[2],
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h12,
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dummyData.verse[3],
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h12,
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dummyData.verse[4],
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h6,
          Text(
            dummyData.data[2],
            style: BaseTypography.bodyMedium.toPrimary,
          ),
          Gap.h24,
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dummyData.youtube,
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h6,
          CachedNetworkImage(imageUrl: dummyData.image)
        ],
      ),
    );
  }
}
