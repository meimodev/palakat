import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/song_book/presentations/song_book_motion_widget.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:url_launcher/url_launcher.dart';

import 'song_detail_controller.dart';

class SongDetailScreen extends ConsumerWidget {
  const SongDetailScreen({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(songDetailControllerProvider(song));
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SongBookReveal(
            child: ScreenTitleWidget.primary(
              title: song.title,
              subTitle: song.subTitle,
              leadIcon: AppIcons.back,
              leadIconColor: BaseColor.black,
              onPressedLeadIcon: () => Navigator.pop(context),
            ),
          ),
          Gap.h16,
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                reverseDuration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  if (reduceMotion) {
                    return child;
                  }

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: state.when(
                  data: (songParts) => KeyedSubtree(
                    key: const ValueKey('song-detail-data'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...songParts.asMap().entries.map(
                          (entry) => SongBookReveal(
                            key: ValueKey(
                              'song-part-${entry.value.type.name}-${entry.key}',
                            ),
                            delay: Duration(
                              milliseconds: 40 + (entry.key * 28),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: BaseSize.h20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    _formatSongPartType(entry.value.type),
                                    style: BaseTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: BaseColor.neutral60,
                                    ),
                                  ),
                                  Gap.h8,
                                  SelectableText(
                                    entry.value.content,
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
                        if (song.urlImage.isNotEmpty) ...[
                          SongBookReveal(
                            delay: Duration(
                              milliseconds: 60 + (songParts.length * 28),
                            ),
                            child: Material(
                              color: BaseColor.cardBackground1,
                              elevation: 1,
                              shadowColor: Colors.black.withValues(alpha: 0.05),
                              surfaceTintColor: BaseColor.primary[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  BaseSize.radiusMd,
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: ImageNetworkWidget(
                                imageUrl: song.urlImage,
                                height: BaseSize.customHeight(300),
                              ),
                            ),
                          ),
                          Gap.h16,
                        ],
                        SongBookReveal(
                          delay: Duration(
                            milliseconds: 90 + (songParts.length * 28),
                          ),
                          child: _SongInfoCard(song: song),
                        ),
                        Gap.h24,
                      ],
                    ),
                  ),
                  loading: () => KeyedSubtree(
                    key: const ValueKey('song-detail-loading'),
                    child: LoadingShimmer(
                      isLoading: true,
                      child: Column(
                        children: [
                          PalakatShimmerPlaceholders.infoCard(),
                          Gap.h12,
                          PalakatShimmerPlaceholders.infoCard(),
                          Gap.h12,
                          PalakatShimmerPlaceholders.infoCard(),
                        ],
                      ),
                    ),
                  ),
                  error: (err, stack) => KeyedSubtree(
                    key: const ValueKey('song-detail-error'),
                    child: SongBookAnimatedPresence(
                      visible: true,
                      child: Center(
                        child: Material(
                          color: BaseColor.cardBackground1,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              BaseSize.radiusLg,
                            ),
                            side: BorderSide(
                              color: BaseColor.neutral20,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(BaseSize.w24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: BaseSize.w56,
                                  height: BaseSize.w56,
                                  decoration: BoxDecoration(
                                    color: BaseColor.red[50],
                                    borderRadius: BorderRadius.circular(
                                      BaseSize.radiusLg,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    AppIcons.error,
                                    size: BaseSize.w28,
                                    color: BaseColor.red[700],
                                  ),
                                ),
                                Gap.h12,
                                Text(
                                  l10n.songDetail_errorLoadingSong,
                                  textAlign: TextAlign.center,
                                  style: BaseTypography.titleMedium.copyWith(
                                    color: BaseColor.textPrimary,
                                    fontWeight: FontWeight.w700,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongInfoCard extends StatelessWidget {
  const _SongInfoCard({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final book = song.bookName.isNotEmpty
        ? (song.bookId.isNotEmpty
              ? '${song.bookName} (${song.bookId})'
              : song.bookName)
        : (song.bookId.isNotEmpty ? song.bookId : l10n.lbl_notSpecified);
    final author = song.author.isNotEmpty ? song.author : l10n.lbl_notSpecified;
    final baseNote = song.baseNote.isNotEmpty
        ? song.baseNote
        : l10n.lbl_notSpecified;
    final publisher = song.publisher.isNotEmpty
        ? song.publisher
        : l10n.lbl_notSpecified;
    final lastUpdate = song.lastUpdate != null
        ? song.lastUpdate!.EEEEddMMMyyyyShort
        : l10n.lbl_notSpecified;

    final videoUri = _parseExternalUri(song.urlVideo);
    final videoThumbnailUrl = _youtubeThumbnailUrl(videoUri);

    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.primary[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.songDetail_informationTitle,
              style: BaseTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: BaseColor.black,
              ),
            ),
            Gap.h4,
            Text(
              l10n.lbl_hashId(song.id),
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.secondaryText,
              ),
            ),
            Gap.h12,
            _InfoRow(label: l10n.songDetail_field_book, value: book),
            Gap.h8,
            _InfoRow(label: l10n.songDetail_field_author, value: author),
            Gap.h8,
            _InfoRow(label: l10n.songDetail_field_baseNote, value: baseNote),
            Gap.h8,
            _InfoRow(label: l10n.songDetail_field_publisher, value: publisher),
            Gap.h8,
            _InfoRow(label: l10n.lbl_updatedAt, value: lastUpdate),
            if (videoUri != null) ...[
              Gap.h12,
              InkWell(
                onTap: () async {
                  await launchUrl(
                    videoUri,
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: Stack(
                  children: [
                    if (videoThumbnailUrl != null)
                      ImageNetworkWidget(
                        imageUrl: videoThumbnailUrl,
                        height: BaseSize.customHeight(200),
                      )
                    else
                      Container(
                        height: BaseSize.customHeight(200),
                        color: BaseColor.neutral10,
                        alignment: Alignment.center,
                        child: Text(
                          l10n.songDetail_videoFallback,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.neutral60,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Positioned(
                      right: BaseSize.w12,
                      bottom: BaseSize.h12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: BaseSize.w10,
                          vertical: BaseSize.h6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.songDetail_openVideo,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: BaseTypography.bodyMedium.copyWith(color: BaseColor.neutral60),
        ),
        Gap.w16,
        Flexible(
          child: Text(
            value,
            style: BaseTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

String _formatSongPartType(SongPartType type) {
  final raw = type.name;
  final withCamelSpaces = raw.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m.group(1)} ${m.group(2)}',
  );
  final withNumberSpaces = withCamelSpaces.replaceAllMapped(
    RegExp(r'([a-zA-Z]+)(\d+)'),
    (m) => '${m.group(1)} ${m.group(2)}',
  );
  final parts = withNumberSpaces
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty);

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  return parts.map(capitalize).join(' ');
}

Uri? _parseExternalUri(String raw) {
  if (raw.trim().isEmpty) return null;
  Uri? uri = Uri.tryParse(raw.trim());
  if (uri == null) return null;
  if (uri.scheme.isEmpty) {
    uri = Uri.tryParse('https://${raw.trim()}');
  }
  return uri;
}

String? _youtubeThumbnailUrl(Uri? uri) {
  final id = _extractYoutubeVideoId(uri);
  if (id == null) return null;
  return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
}

String? _extractYoutubeVideoId(Uri? uri) {
  if (uri == null) return null;

  final host = uri.host.toLowerCase();

  if (host.contains('youtu.be')) {
    final seg = uri.pathSegments;
    if (seg.isEmpty) return null;
    return seg.first;
  }

  if (host.contains('youtube.com')) {
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;

    final seg = uri.pathSegments;
    final embedIndex = seg.indexOf('embed');
    if (embedIndex != -1 && seg.length > embedIndex + 1) {
      return seg[embedIndex + 1];
    }

    final shortsIndex = seg.indexOf('shorts');
    if (shortsIndex != -1 && seg.length > shortsIndex + 1) {
      return seg[shortsIndex + 1];
    }
  }

  // Fallback regex (handles various formats)
  final match = RegExp(
    r'(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([A-Za-z0-9_-]{6,})',
  ).firstMatch(uri.toString());
  return match?.group(1);
}
