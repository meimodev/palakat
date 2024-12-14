import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/song.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'song_detail_controller.dart';

class SongDetailScreen extends ConsumerWidget {
  const SongDetailScreen({
    super.key,
    required this.song,
  });

  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(songDetailControllerProvider(song));

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
              child: state.when(
                data: (songParts) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...songParts.map(
                      (songPart) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            songPart.type.name,
                            style: BaseTypography.bodyMedium.toBold.toSecondary,
                          ),
                          Text(
                            songPart.content,
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
