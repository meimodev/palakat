import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_admin/core/models/models.dart' hide Column;

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
          Gap.h16,
          ScreenTitleWidget.primary(
            title: song.title,
            subTitle: song.subTitle,
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: BaseColor.black,
            onPressedLeadIcon: () => Navigator.pop(context),
          ),
          Gap.h16,
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: state.when(
                data: (songParts) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...songParts.map(
                      (songPart) => Padding(
                        padding: EdgeInsets.only(bottom: BaseSize.h16),
                        child: Material(
                          color: BaseColor.cardBackground1,
                          elevation: 1,
                          shadowColor: Colors.black.withValues(alpha: 0.05),
                          surfaceTintColor: BaseColor.red[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(BaseSize.w16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: BaseSize.w32,
                                      height: BaseSize.w32,
                                      decoration: BoxDecoration(
                                        color: BaseColor.red[100],
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.music_note,
                                        size: BaseSize.w16,
                                        color: BaseColor.red[700],
                                      ),
                                    ),
                                    Gap.w12,
                                    Expanded(
                                      child: Text(
                                        songPart.type.name,
                                        style: BaseTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: BaseColor.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Gap.h12,
                                Text(
                                  songPart.content,
                                  style: BaseTypography.bodyMedium.copyWith(
                                    color: BaseColor.black,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (song.urlImage.isNotEmpty) ...[
                      Material(
                        color: BaseColor.cardBackground1,
                        elevation: 1,
                        shadowColor: Colors.black.withValues(alpha: 0.05),
                        surfaceTintColor: BaseColor.red[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: ImageNetworkWidget(
                          imageUrl: song.urlImage,
                          height: BaseSize.customHeight(300),
                        ),
                      ),
                      Gap.h16,
                    ],
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Container(
                    padding: EdgeInsets.all(BaseSize.w24),
                    decoration: BoxDecoration(
                      color: BaseColor.cardBackground1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: BaseColor.neutral20,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: BaseSize.w48,
                          color: BaseColor.secondaryText,
                        ),
                        Gap.h12,
                        Text(
                          'Error loading song',
                          textAlign: TextAlign.center,
                          style: BaseTypography.titleMedium.copyWith(
                            color: BaseColor.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
