import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/song.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

class SongDetailScreen extends StatelessWidget {
  const SongDetailScreen({
    super.key,
    required this.song,
  });

  final Song song;

  @override
  Widget build(BuildContext context) {
    final parts = song.composition
        .map(
          (e) => song.definition.firstWhere((f) => f.type == e),
        )
        .toList();

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.h24,
          ScreenTitleWidget.primary(
            title: song.title,
            subTitle: song.subTitle,
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: BaseColor.black,
            onPressedLeadIcon: () => Navigator.pop(context),
          ),
          Gap.h24,
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...parts.map(
                    (e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          e.type.name,
                          style: BaseTypography.bodyMedium.toBold.toSecondary,
                        ),
                        Text(
                          e.content,
                          style: BaseTypography.bodyMedium.toPrimary,
                        ),
                        Gap.h12,
                      ],
                    ),
                  ),
                  Gap.h24,
                  song.urlImage.isEmpty
                      ? const SizedBox()
                      : ImageNetworkWidget(
                          imageUrl: song.urlImage,
                          height: BaseSize.customHeight(300),
                        ),
                  Gap.h24,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
