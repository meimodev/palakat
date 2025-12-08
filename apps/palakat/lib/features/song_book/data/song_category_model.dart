import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/constants.dart';

part 'song_category_model.freezed.dart';

/// Represents a category of songs in the Song Book screen.
/// Categories group songs by hymnal type (NNBT, KJ, NKB, DSL).
@freezed
abstract class SongCategory with _$SongCategory {
  const factory SongCategory({
    /// Unique identifier for the category (e.g., 'nnbt', 'kj', 'nkb', 'dsl')
    required String id,

    /// Full display title for the category header
    required String title,

    /// Short abbreviation for the hymnal type (e.g., 'NNBT', 'KJ')
    required String abbreviation,

    /// Icon displayed in the category header
    required IconData icon,

    /// Whether the category is currently expanded to show songs
    @Default(false) bool isExpanded,
  }) = _SongCategory;
}

/// Predefined song categories for the hymnal types.
/// These represent the four main hymnals used in the app.
class SongCategories {
  SongCategories._();

  static const List<SongCategory> all = [
    SongCategory(
      id: 'nnbt',
      title: 'Nanyikanlah Nyanyian Baru Bagi Tuhan',
      abbreviation: 'NNBT',
      icon: AppIcons.libraryMusic,
    ),
    SongCategory(
      id: 'kj',
      title: 'Kidung Jemaat',
      abbreviation: 'KJ',
      icon: AppIcons.libraryMusic,
    ),
    SongCategory(
      id: 'nkb',
      title: 'Nanyikanlah Kidung Baru',
      abbreviation: 'NKB',
      icon: AppIcons.libraryMusic,
    ),
    SongCategory(
      id: 'dsl',
      title: 'Dua Sahabat Lama',
      abbreviation: 'DSL',
      icon: AppIcons.libraryMusic,
    ),
  ];

  /// Get a category by its ID
  static SongCategory? getById(String id) {
    try {
      return all.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a category by its abbreviation
  static SongCategory? getByAbbreviation(String abbreviation) {
    try {
      return all.firstWhere(
        (category) =>
            category.abbreviation.toLowerCase() == abbreviation.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
