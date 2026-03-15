import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

/// Individual song card with icon, title, and subtitle.
/// Uses the same visual pattern as OperationItemCard.
///
/// Requirements: 2.3, 4.1, 4.2, 4.4
class SongItemCard extends StatelessWidget {
  const SongItemCard({
    super.key,
    required this.song,
    required this.onTap,
    this.searchQuery,
  });

  /// The song data to display
  final Song song;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  final String? searchQuery;

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  String? _lyricsSnippet() {
    final qRaw = (searchQuery ?? '').trim();
    if (qRaw.isEmpty) return null;

    final q = _normalize(qRaw);
    if (q.isEmpty) return null;

    SongPart? firstMatch;
    for (final p in song.definition) {
      if (_normalize(p.content).contains(q)) {
        firstMatch = p;
        break;
      }
    }

    SongPart? verseMatch;
    for (final p in song.definition) {
      if (p.type.name.startsWith('verse') &&
          _normalize(p.content).contains(q)) {
        verseMatch = p;
        break;
      }
    }

    SongPart? firstVerse;
    for (final p in song.definition) {
      if (p.type.name.startsWith('verse')) {
        firstVerse = p;
        break;
      }
    }

    final part = verseMatch ?? firstVerse ?? firstMatch;
    if (part == null) return null;

    final content = part.content.trim().replaceAll(RegExp(r'\s+'), ' ');
    const maxLen = 140;
    if (content.length <= maxLen) return content;
    return '${content.substring(0, maxLen)}…';
  }

  @override
  Widget build(BuildContext context) {
    final snippet = _lyricsSnippet();
    final borderRadius = BaseSize.radiusMd;
    return Material(
      color: BaseColor.surfaceLight,
      elevation: 0,
      shadowColor: BaseColor.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        // Ripple effect with primary color at 10% opacity (Requirement 4.1)
        splashColor: BaseColor.primary.withValues(alpha: 0.1),
        highlightColor: BaseColor.primary.withValues(alpha: 0.05),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                constraints.maxWidth < 260 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.1;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w10,
                vertical: BaseSize.w8,
              ),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Song icon container
                            _SongIcon(isCompact: isCompact),
                            Gap.w10,
                            // Title and subtitle
                            Expanded(
                              child: _SongContent(
                                title: song.title,
                                subtitle: song.subTitle,
                                snippet: snippet,
                                isCompact: isCompact,
                              ),
                            ),
                          ],
                        ),
                        Gap.h8,
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            AppIcons.forward,
                            color: BaseColor.textSecondary,
                            size: BaseSize.w20,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // Song icon container
                        _SongIcon(isCompact: isCompact),
                        Gap.w10,
                        // Title and subtitle
                        Expanded(
                          child: _SongContent(
                            title: song.title,
                            subtitle: song.subTitle,
                            snippet: snippet,
                            isCompact: isCompact,
                          ),
                        ),
                        Gap.w6,
                        Icon(
                          AppIcons.forward,
                          color: BaseColor.textSecondary,
                          size: BaseSize.w20,
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// Icon container for the song card
class _SongIcon extends StatelessWidget {
  const _SongIcon({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? BaseSize.w36 : BaseSize.w40,
      height: isCompact ? BaseSize.w36 : BaseSize.w40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BaseColor.primary[50],
        borderRadius: BorderRadius.circular(BaseSize.w12),
      ),
      child: FaIcon(
        AppIcons.musicNote,
        color: BaseColor.primary,
        size: isCompact ? BaseSize.w18 : BaseSize.w20,
      ),
    );
  }
}

/// Content section with title and subtitle
class _SongContent extends StatelessWidget {
  const _SongContent({
    required this.title,
    required this.subtitle,
    required this.snippet,
    required this.isCompact,
  });

  final String title;
  final String subtitle;
  final String? snippet;
  final bool isCompact;

  String _displayTitle(String value) {
    return value
        .replaceAll(RegExp(r'\bNO\.?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title (e.g., "KJ NO.1")
        Text(
          _displayTitle(title),
          style:
              (isCompact
                      ? BaseTypography.bodyMedium
                      : BaseTypography.titleMedium)
                  .copyWith(
                    fontWeight: FontWeight.w600,
                    color: BaseColor.textPrimary,
                  ),
          maxLines: isCompact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        Gap.h4,
        // Subtitle (song name)
        Text(
          subtitle,
          style: BaseTypography.bodyMedium.copyWith(
            color: BaseColor.textSecondary,
          ),
          maxLines: isCompact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (snippet != null && snippet!.trim().isNotEmpty) ...[
          Gap.h4,
          Text(
            snippet!,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.textSecondary,
            ),
            maxLines: isCompact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
