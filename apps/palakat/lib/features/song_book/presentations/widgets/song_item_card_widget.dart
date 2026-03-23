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

  String _removeWhitespace(String value) {
    final buffer = StringBuffer();
    for (final codeUnit in value.toLowerCase().codeUnits) {
      if (codeUnit != 32 && codeUnit != 9 && codeUnit != 10 && codeUnit != 13) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  String _collapseWhitespace(String value) {
    final buffer = StringBuffer();
    var previousWasWhitespace = false;
    for (final codeUnit in value.trim().codeUnits) {
      final isWhitespace =
          codeUnit == 32 || codeUnit == 9 || codeUnit == 10 || codeUnit == 13;
      if (isWhitespace) {
        if (!previousWasWhitespace) {
          buffer.write(' ');
          previousWasWhitespace = true;
        }
      } else {
        buffer.writeCharCode(codeUnit);
        previousWasWhitespace = false;
      }
    }
    return buffer.toString().trim();
  }

  String _normalize(String value) {
    return _removeWhitespace(value);
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

    final content = _collapseWhitespace(part.content);
    const maxLen = 140;
    if (content.length <= maxLen) return content;
    return '${content.substring(0, maxLen)}…';
  }

  @override
  Widget build(BuildContext context) {
    final snippet = _lyricsSnippet();
    final borderRadius = 8.0;
    return Material(
      color: AppColors.surfaceBright,
      elevation: 0,
      shadowColor: AppColors.onSurface.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: AppColors.neutral, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        // Ripple effect with primary color at 10% opacity (Requirement 4.1)
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                constraints.maxWidth < 260 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.1;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
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
                            color: AppColors.onSurfaceVariant,
                            size: 20.0,
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
                          color: AppColors.onSurfaceVariant,
                          size: 20.0,
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
      width: isCompact ? 36.0 : 40.0,
      height: isCompact ? 36.0 : 40.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: FaIcon(
        AppIcons.musicNote,
        color: AppColors.onPrimary,
        size: isCompact ? 18.0 : 20.0,
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

  String _collapseWhitespace(String value) {
    final buffer = StringBuffer();
    var previousWasWhitespace = false;
    for (final codeUnit in value.trim().codeUnits) {
      final isWhitespace =
          codeUnit == 32 || codeUnit == 9 || codeUnit == 10 || codeUnit == 13;
      if (isWhitespace) {
        if (!previousWasWhitespace) {
          buffer.write(' ');
          previousWasWhitespace = true;
        }
      } else {
        buffer.writeCharCode(codeUnit);
        previousWasWhitespace = false;
      }
    }
    return buffer.toString().trim();
  }

  String _stripLeadingNoPrefix(String value) {
    final trimmed = value.trimLeft();
    if (trimmed.length < 2 || trimmed.substring(0, 2).toUpperCase() != 'NO') {
      return value;
    }

    var index = 2;
    while (index < trimmed.length && trimmed[index] == '.') {
      index++;
    }
    while (index < trimmed.length) {
      final codeUnit = trimmed.codeUnitAt(index);
      final isWhitespace =
          codeUnit == 32 || codeUnit == 9 || codeUnit == 10 || codeUnit == 13;
      if (!isWhitespace) break;
      index++;
    }
    return trimmed.substring(index);
  }

  String _displayTitle(String value) {
    return _collapseWhitespace(_stripLeadingNoPrefix(value));
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
                      ? Theme.of(context).textTheme.bodyMedium!
                      : Theme.of(context).textTheme.titleMedium!)
                  .copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
          maxLines: isCompact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        Gap.h4,
        // Subtitle (song name)
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurfaceVariant),
          maxLines: isCompact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (snippet != null && snippet!.trim().isNotEmpty) ...[
          Gap.h4,
          Text(
            snippet!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurfaceVariant),
            maxLines: isCompact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
