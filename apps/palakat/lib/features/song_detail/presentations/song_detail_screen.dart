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
              leadIconColor: AppColors.primary,
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
                              padding: EdgeInsets.only(bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    _formatSongPartType(entry.value.type),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                  Gap.h8,
                                  SelectableText(
                                    entry.value.content,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: AppColors.primary,
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
                              color: AppColors.surfaceContainerLowest,
                              elevation: 1,
                              shadowColor: AppColors.onSurface,
                              surfaceTintColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: ImageNetworkWidget(
                                imageUrl: song.urlImage,
                                height: 300,
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
                          color: AppColors.surfaceContainerLowest,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(
                              color: AppColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56.0,
                                  height: 56.0,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    AppIcons.error,
                                    size: 28.0,
                                    color: AppColors.onError,
                                  ),
                                ),
                                Gap.h12,
                                Text(
                                  l10n.songDetail_errorLoadingSong,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                Gap.h4,
                                Text(
                                  err.toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        color: AppColors.onSurfaceVariant,
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
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.songDetail_informationTitle,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Gap.h4,
            Text(
              l10n.lbl_hashId(song.id),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
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
                        height: 200,
                      )
                    else
                      Container(
                        height: 200,
                        color: AppColors.surfaceContainerHigh,
                        alignment: Alignment.center,
                        child: Text(
                          l10n.songDetail_videoFallback,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    Positioned(
                      right: 12.0,
                      bottom: 12.0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.onSurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.songDetail_openVideo,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: AppColors.surfaceContainerLowest,
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurfaceVariant),
        ),
        Gap.w16,
        Flexible(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

String _formatSongPartType(SongPartType type) {
  final raw = type.name;
  final normalized = StringBuffer();
  for (int i = 0; i < raw.length; i++) {
    final current = raw.codeUnitAt(i);
    final previous = i > 0 ? raw.codeUnitAt(i - 1) : null;
    final isUppercase = current >= 65 && current <= 90;
    final wasLowercase = previous != null && previous >= 97 && previous <= 122;
    final isDigit = current >= 48 && current <= 57;
    final wasLetter =
        previous != null &&
        ((previous >= 65 && previous <= 90) ||
            (previous >= 97 && previous <= 122));
    if (i > 0 && ((isUppercase && wasLowercase) || (isDigit && wasLetter))) {
      normalized.write(' ');
    }
    normalized.writeCharCode(current);
  }

  final parts = normalized
      .toString()
      .split(' ')
      .where((p) => p.trim().isNotEmpty);

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

  final uriText = uri.toString();
  const fallbackMarkers = <String>[
    'watch?v=',
    'embed/',
    'shorts/',
    'youtu.be/',
  ];
  for (final marker in fallbackMarkers) {
    final markerIndex = uriText.indexOf(marker);
    if (markerIndex == -1) continue;
    final start = markerIndex + marker.length;
    final buffer = StringBuffer();
    for (int i = start; i < uriText.length; i++) {
      final codeUnit = uriText.codeUnitAt(i);
      final isValid =
          (codeUnit >= 48 && codeUnit <= 57) ||
          (codeUnit >= 65 && codeUnit <= 90) ||
          (codeUnit >= 97 && codeUnit <= 122) ||
          codeUnit == 95 ||
          codeUnit == 45;
      if (!isValid) break;
      buffer.writeCharCode(codeUnit);
    }
    final candidate = buffer.toString();
    if (candidate.length >= 6) {
      return candidate;
    }
  }
  return null;
}
