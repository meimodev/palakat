# Design Document

## Overview

This design document outlines the technical approach for redesigning the Palakat app's Song Book screen and Bottom Navigation Bar to align with the design patterns established in the Operations screen redesign. The goal is to create a visually cohesive, calm, and user-friendly experience using the monochromatic teal color system and progressive disclosure patterns.

The redesign follows Material Design 3 principles while maintaining the app's existing architecture patterns (Riverpod, Freezed, go_router).

## Architecture

### Song Book Screen Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SongBookScreen                            │
├─────────────────────────────────────────────────────────────┤
│  ├── ScreenTitleWidget                                      │
│  ├── SearchInputWidget                                      │
│  │   └── Debounced search with 500ms delay                  │
│  ├── ConditionalContent                                     │
│  │   ├── SearchResultsView (when searching)                 │
│  │   │   ├── SongItemCard (list)                            │
│  │   │   └── EmptyStateWidget (no results)                  │
│  │   └── CategoryView (when not searching)                  │
│  │       └── SongCategoryList                               │
│  │           ├── SongCategoryCard (NNBT)                    │
│  │           ├── SongCategoryCard (KJ)                      │
│  │           ├── SongCategoryCard (NKB)                     │
│  │           └── SongCategoryCard (DSL)                     │
│  └── LoadingWrapper                                         │
└─────────────────────────────────────────────────────────────┘
```

### Bottom Navigation Bar Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    BottomNavBar                              │
├─────────────────────────────────────────────────────────────┤
│  ├── Material Container                                     │
│  │   └── Top border with teal at 12% opacity                │
│  ├── NavigationBar                                          │
│  │   ├── NavigationDestination (Home)                       │
│  │   ├── NavigationDestination (Songs)                      │
│  │   ├── NavigationDestination (Ops) - auth only            │
│  │   └── NavigationDestination (Approval) - auth only       │
│  └── Unified teal selection indicator                       │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### Song Category Model

```dart
@freezed
class SongCategory with _$SongCategory {
  const factory SongCategory({
    required String id,
    required String title,
    required String abbreviation,
    required IconData icon,
    @Default(false) bool isExpanded,
  }) = _SongCategory;
}
```

### Updated SongBookState

```dart
@freezed
class SongBookState with _$SongBookState {
  const factory SongBookState({
    @Default([]) List<Song> songs,
    @Default([]) List<Song> filteredSongs,
    @Default(false) bool isLoading,
    @Default(false) bool isSearching,
    @Default('') String searchQuery,
    @Default(null) String? errorMessage,
    @Default([]) List<SongCategory> categories,
    @Default({}) Map<String, bool> categoryExpansionState,
  }) = _SongBookState;
}
```

### SongCategoryCard Widget

```dart
/// Collapsible category card that groups songs by hymnal type.
/// Uses the same visual pattern as OperationCategoryCard.
class SongCategoryCard extends StatelessWidget {
  final SongCategory category;
  final List<Song> songs;
  final ValueChanged<bool> onExpansionChanged;
  final ValueChanged<Song> onSongTap;
}
```

### SongItemCard Widget

```dart
/// Individual song card with icon, title, and subtitle.
/// Uses the same visual pattern as OperationItemCard.
class SongItemCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
}
```

## Data Models

### SongCategory Constants

```dart
/// Predefined song categories for the hymnal types
class SongCategories {
  static const List<SongCategory> all = [
    SongCategory(
      id: 'nnbt',
      title: 'Nanyikanlah Nyanyian Baru Bagi Tuhan',
      abbreviation: 'NNBT',
      icon: Icons.library_music_outlined,
    ),
    SongCategory(
      id: 'kj',
      title: 'Kidung Jemaat',
      abbreviation: 'KJ',
      icon: Icons.library_music_outlined,
    ),
    SongCategory(
      id: 'nkb',
      title: 'Nanyikanlah Kidung Baru',
      abbreviation: 'NKB',
      icon: Icons.library_music_outlined,
    ),
    SongCategory(
      id: 'dsl',
      title: 'Dua Sahabat Lama',
      abbreviation: 'DSL',
      icon: Icons.library_music_outlined,
    ),
  ];
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Song Category Membership

*For any* song in the system, it SHALL belong to exactly one of the four categories (NNBT, KJ, NKB, DSL) based on its hymnal type prefix.

**Validates: Requirements 1.2**

### Property 2: Category Expansion Toggle

*For any* song category, toggling its expansion state SHALL invert the isExpanded boolean value, and the state SHALL persist until toggled again or session ends.

**Validates: Requirements 1.3, 7.1**

### Property 3: Search Filter Correctness

*For any* search query and list of songs, the filtered results SHALL contain only songs whose title or subtitle contains the query string (case-insensitive).

**Validates: Requirements 3.2**

### Property 4: Search State Transition

*For any* search query, when the query is empty the screen SHALL display the category view, and when the query is non-empty the screen SHALL display search results.

**Validates: Requirements 3.4**

### Property 5: Song Card Completeness

*For any* Song object, the rendered SongItemCard SHALL display the song's title, subtitle (hymnal abbreviation), and a music icon.

**Validates: Requirements 3.3, 4.2**

### Property 6: Multiple Category Expansion

*For any* set of song categories, expanding one category SHALL NOT collapse any other expanded categories.

**Validates: Requirements 7.3**

### Property 7: Initial Expansion State

*For any* new session, all song categories SHALL start in the collapsed state (isExpanded = false).

**Validates: Requirements 7.4**

### Property 8: Responsive Column Count

*For any* screen width, the category card grid SHALL display 2 columns when width > 600px and 1 column when width <= 600px.

**Validates: Requirements 8.2, 8.3**

### Property 9: Navigation Item Visibility

*For any* authentication state, when the user is not authenticated the Bottom_Navigation_Bar SHALL display only Home and Songs items, and when authenticated it SHALL display all four items.

**Validates: Requirements 6.3**

### Property 10: Touch Target Minimum Size

*For any* interactive element in the Song_Book_Screen and Bottom_Navigation_Bar, its tap target area SHALL be at least 48x48 pixels.

**Validates: Requirements 6.4, 8.4**

### Property 11: Spacing Grid Alignment

*For any* spacing value used in the Song_Book_Screen, it SHALL be a multiple of 8 pixels.

**Validates: Requirements 2.4**

## Error Handling

### Song Book Screen Errors

| Error Scenario | Handling Strategy |
|----------------|-------------------|
| Song data fetch fails | Display error state with retry button |
| Empty search results | Display empty state widget with helpful message |
| Category expansion state lost | Reset to all collapsed |
| Navigation route not found | Show snackbar with error message |

### State Recovery

```dart
// Error recovery in controller
void handleError(Object error, StackTrace stack) {
  state = state.copyWith(
    isLoading: false,
    errorMessage: 'Failed to load songs. Tap to retry.',
  );
}
```

## Testing Strategy

### Unit Testing Approach

Unit tests will verify:
- SongCategory model validation
- Song filtering logic
- Controller state transitions
- Category expansion logic
- Navigation item visibility based on auth state

### Property-Based Testing Approach

Property-based tests will use the `glados` package for Dart to verify:
- Song categorization invariants
- Search filter correctness
- Responsive layout column calculations
- Spacing value grid alignment
- Touch target size constraints

**Testing Framework**: `glados` (Dart property-based testing library)

**Minimum Iterations**: 100 per property test

**Test Annotation Format**: Each property-based test MUST include a comment in the format:
`// **Feature: songbook-navbar-redesign, Property {number}: {property_text}**`

### Test File Organization

```
test/
├── features/
│   └── song_book/
│       ├── song_book_controller_test.dart
│       ├── song_book_state_test.dart
│       └── widgets/
│           ├── song_category_card_test.dart
│           └── song_item_card_test.dart
├── core/
│   └── widgets/
│       └── bottom_navbar/
│           └── bottom_navbar_test.dart
└── property/
    ├── song_filter_property_test.dart
    ├── category_expansion_property_test.dart
    └── responsive_layout_property_test.dart
```

## Visual Design Specifications

### Song Book Screen Layout

```
┌─────────────────────────────────────────────────┐
│  Song Book                               [icon] │  ← Screen title
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ 🔍 Search song title or number...           │ │  ← Search input
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ 🎵 NNBT                                [▼]  │ │  ← Category header
│ ├─────────────────────────────────────────────┤ │
│ │ ┌───────────────────────────────────────┐   │ │
│ │ │ [♪] NNBT 001 - Song Title             │   │ │  ← Song card
│ │ │     Nanyikanlah Nyanyian Baru...      │   │ │
│ │ └───────────────────────────────────────┘   │ │
│ │ ┌───────────────────────────────────────┐   │ │
│ │ │ [♪] NNBT 002 - Song Title             │   │ │
│ │ │     Nanyikanlah Nyanyian Baru...      │   │ │
│ │ └───────────────────────────────────────┘   │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ 🎵 KJ                                  [▶]  │ │  ← Collapsed category
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ 🎵 NKB                                 [▶]  │ │  ← Collapsed category
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ 🎵 DSL                                 [▶]  │ │  ← Collapsed category
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Bottom Navigation Bar Layout

```
┌─────────────────────────────────────────────────┐
│ ─────────────────────────────────────────────── │  ← Top border (teal 12%)
│                                                 │
│   [🏠]        [🎵]        [📄]        [📋]     │  ← Icons (24px)
│   Home        Songs        Ops       Approval   │  ← Labels
│                                                 │
│         ┌──────────┐                            │  ← Selection indicator
│         │  teal 15%│                            │     (rounded rect)
│         └──────────┘                            │
└─────────────────────────────────────────────────┘
```

### Component Specifications

| Component | Border Radius | Shadow | Padding |
|-----------|---------------|--------|---------|
| Search Input | 12px | none | 16px |
| Category Card | 16px | elevation 0 | 0px |
| Category Header | 12px (top) | none | 16px |
| Song Card | 12px | elevation 0 | 12px |
| Nav Indicator | 16px | none | - |

### Color Usage

| Element | Color |
|---------|-------|
| Category Header Background | BaseColor.primary[50] |
| Category Header Icon | BaseColor.primary |
| Category Header Text | BaseColor.textPrimary |
| Song Card Background | BaseColor.surfaceLight |
| Song Card Icon Container | BaseColor.primary[50] |
| Song Card Icon | BaseColor.primary |
| Song Card Title | BaseColor.textPrimary |
| Song Card Subtitle | BaseColor.textSecondary |
| Nav Selected Icon | BaseColor.primary |
| Nav Unselected Icon | BaseColor.textSecondary |
| Nav Indicator | BaseColor.primary (15% opacity) |
| Nav Top Border | BaseColor.primary (12% opacity) |
