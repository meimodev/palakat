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

  /// Border radius for the card (12px as per design spec)
  static const double borderRadius = 12.0;

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
    return Material(
      color: BaseColor.surfaceLight,
      elevation: 0.5,
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w12,
            vertical: BaseSize.w10,
          ),
          child: Row(
            children: [
              // Song icon container
              _SongIcon(),
              Gap.w12,
              // Title and subtitle
              Expanded(
                child: _SongContent(
                  title: song.title,
                  subtitle: song.subTitle,
                  snippet: snippet,
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon container for the song card
class _SongIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: BaseSize.w32,
      height: BaseSize.w32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BaseColor.primary[50],
        borderRadius: BorderRadius.circular(BaseSize.w12),
      ),
      child: FaIcon(
        AppIcons.musicNote,
        color: BaseColor.primary,
        size: BaseSize.w16,
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
  });

  final String title;
  final String subtitle;
  final String? snippet;

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
          style: BaseTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: BaseColor.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Gap.h4,
        // Subtitle (song name)
        Text(
          subtitle,
          style: BaseTypography.bodySmall.copyWith(
            color: BaseColor.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (snippet != null && snippet!.trim().isNotEmpty) ...[
          Gap.h4,
          Text(
            snippet!,
            style: BaseTypography.bodySmall.copyWith(
              color: BaseColor.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
