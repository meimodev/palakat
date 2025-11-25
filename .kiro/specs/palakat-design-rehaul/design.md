# Design Document

## Overview

This design document outlines the technical approach for the Palakat app design rehaul, focusing on implementing a unified monochromatic color system and redesigning the operations screen to reduce cognitive load through progressive disclosure and clear visual hierarchy.

The redesign follows Material Design 3 principles while maintaining the app's existing architecture patterns (Riverpod, Freezed, go_router).

## Architecture

### Color System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Color System Layer                        │
├─────────────────────────────────────────────────────────────┤
│  PalakatColors (Static Class)                               │
│  ├── primary: MaterialColor (teal 50-900)                   │
│  ├── surface: SurfaceColors (neutral palette)               │
│  ├── semantic: SemanticColors (success, error, warning)     │
│  └── text: TextColors (primary, secondary, disabled)        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Theme Layer                               │
├─────────────────────────────────────────────────────────────┤
│  buildAppTheme()                                            │
│  ├── ColorScheme.fromSeed(seedColor: PalakatColors.primary) │
│  ├── Component themes (buttons, cards, inputs)              │
│  └── Typography with color integration                      │
└─────────────────────────────────────────────────────────────┘
```

### Operations Screen Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  OperationsScreen                            │
├─────────────────────────────────────────────────────────────┤
│  ├── PositionSummaryCard                                    │
│  │   └── Displays user's positions and role count           │
│  ├── OperationCategoryList                                  │
│  │   ├── PublishingCategory (collapsible)                   │
│  │   │   ├── PublishServiceCard                             │
│  │   │   ├── PublishEventCard                               │
│  │   │   └── PublishAnnouncementCard                        │
│  │   ├── FinancialCategory (collapsible)                    │
│  │   │   ├── AddIncomeCard                                  │
│  │   │   └── AddExpenseCard                                 │
│  │   └── ReportsCategory (collapsible)                      │
│  │       └── GenerateReportCard                             │
│  └── EmptyStateWidget (when no operations available)        │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### Color System Components

#### PalakatColors Class

```dart
/// Centralized color definitions for the Palakat app
/// All colors derive from or complement the primary teal color
class PalakatColors {
  // Primary color with full tonal scale
  static const MaterialColor primary = MaterialColor(
    0xFF009688,
    <int, Color>{
      50: Color(0xFFE0F2F1),
      100: Color(0xFFB2DFDB),
      200: Color(0xFF80CBC4),
      300: Color(0xFF4DB6AC),
      400: Color(0xFF26A69A),
      500: Color(0xFF009688),
      600: Color(0xFF00897B),
      700: Color(0xFF00796B),
      800: Color(0xFF00695C),
      900: Color(0xFF004D40),
    },
  );
  
  // Surface colors (neutral with teal undertone)
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceMedium = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFFEEEEEE);
  
  // Semantic colors (teal-influenced where possible)
  static const Color success = Color(0xFF009688); // Primary teal
  static const Color error = Color(0xFFD32F2F);   // Red for accessibility
  static const Color warning = Color(0xFFFF8F00); // Amber
  static const Color info = Color(0xFF00796B);    // Dark teal
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}
```

### Operations Screen Components

#### OperationCategory Model

```dart
@freezed
class OperationCategory with _$OperationCategory {
  const factory OperationCategory({
    required String id,
    required String title,
    required IconData icon,
    required List<OperationItem> operations,
    @Default(false) bool isExpanded,
  }) = _OperationCategory;
}

@freezed
class OperationItem with _$OperationItem {
  const factory OperationItem({
    required String id,
    required String title,
    required String description,
    required IconData icon,
    required String routeName,
    Map<String, dynamic>? routeParams,
    @Default(true) bool isEnabled,
  }) = _OperationItem;
}
```

#### OperationCategoryCard Widget

```dart
/// Collapsible category card that groups related operations
/// Uses ExpansionTile pattern with custom styling
class OperationCategoryCard extends StatelessWidget {
  final OperationCategory category;
  final ValueChanged<bool> onExpansionChanged;
  final ValueChanged<OperationItem> onOperationTap;
}
```

#### OperationItemCard Widget

```dart
/// Individual operation card with icon, title, description
/// Provides visual feedback on interaction
class OperationItemCard extends StatelessWidget {
  final OperationItem operation;
  final VoidCallback onTap;
}
```

## Data Models

### OperationsState

```dart
@freezed
class OperationsState with _$OperationsState {
  const factory OperationsState({
    @Default(true) bool loadingScreen,
    String? errorMessage,
    Membership? membership,
    @Default([]) List<OperationCategory> categories,
    @Default({}) Map<String, bool> categoryExpansionState,
  }) = _OperationsState;
}
```

### Color Token Model

```dart
/// Represents a color token in the design system
/// Used for documentation and tooling
class ColorToken {
  final String name;
  final Color value;
  final String usage;
  final int? shade; // For MaterialColor shades
}
```

</text>
</invoke>

## C
orrectness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Position Summary Display Consistency

*For any* membership with positions, when the Operations_Screen renders, the summary card SHALL display the exact count of positions matching the membership data.

**Validates: Requirements 2.1**

### Property 2: Operation Category Membership

*For any* operation item in the system, it SHALL belong to exactly one category (Publishing, Financial, or Reports) and no operation SHALL exist outside these categories.

**Validates: Requirements 2.2**

### Property 3: Collapsed Category Item Limit

*For any* category in collapsed state with more than 3 operations, the visible item count SHALL be at most 3, and expanding the category SHALL reveal all operations.

**Validates: Requirements 2.3, 2.4**

### Property 4: Category Expansion Toggle

*For any* category, toggling its expansion state SHALL invert the isExpanded boolean value, and the state SHALL persist until toggled again or session ends.

**Validates: Requirements 4.4, 4.5**

### Property 5: Operation Item Completeness

*For any* OperationItem, it SHALL have non-empty title, description, and a valid icon, ensuring all required display fields are present.

**Validates: Requirements 5.3**

### Property 6: Disabled Operation State

*For any* operation with isEnabled = false, the UI representation SHALL have reduced opacity (0.5 or less) and SHALL NOT trigger navigation on tap.

**Validates: Requirements 5.4**

### Property 7: MaterialColor Shade Completeness

*For any* MaterialColor in the color system, it SHALL contain all standard Material shade keys: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900.

**Validates: Requirements 6.2**

### Property 8: Responsive Column Count

*For any* screen width, the operation card grid SHALL display 2 columns when width > 600px and 1 column when width <= 600px.

**Validates: Requirements 7.2, 7.3**

### Property 9: Touch Target Minimum Size

*For any* interactive element in the Operations_Screen, its tap target area SHALL be at least 48x48 pixels.

**Validates: Requirements 7.4**

### Property 10: Spacing Grid Alignment

*For any* spacing value used in the Operations_Screen, it SHALL be a multiple of 8 pixels.

**Validates: Requirements 3.4**

## Error Handling

### Color System Errors

| Error Scenario | Handling Strategy |
|----------------|-------------------|
| Invalid color shade access | Return primary[500] as fallback |
| Null color in theme | Use default Material colors |
| Color contrast insufficient | Log warning in debug mode |

### Operations Screen Errors

| Error Scenario | Handling Strategy |
|----------------|-------------------|
| Membership data fetch fails | Display error state with retry button |
| Empty membership positions | Display empty state widget |
| Navigation route not found | Show snackbar with error message |
| Category expansion state lost | Reset to all collapsed |

### State Recovery

```dart
// Error recovery in controller
void handleError(Object error, StackTrace stack) {
  state = state.copyWith(
    loadingScreen: false,
    errorMessage: 'Failed to load operations. Tap to retry.',
  );
}
```

## Testing Strategy

### Unit Testing Approach

Unit tests will verify:
- Color constant values match specifications
- MaterialColor shade completeness
- OperationCategory and OperationItem model validation
- Controller state transitions
- Category expansion logic

### Property-Based Testing Approach

Property-based tests will use the `glados` package for Dart to verify:
- Operation categorization invariants
- Responsive layout column calculations
- Spacing value grid alignment
- Touch target size constraints

**Testing Framework**: `glados` (Dart property-based testing library)

**Minimum Iterations**: 100 per property test

**Test Annotation Format**: Each property-based test MUST include a comment in the format:
`// **Feature: palakat-design-rehaul, Property {number}: {property_text}**`

### Test File Organization

```
test/
├── features/
│   └── operations/
│       ├── operations_controller_test.dart
│       ├── operations_state_test.dart
│       └── widgets/
│           ├── operation_category_card_test.dart
│           └── operation_item_card_test.dart
├── core/
│   └── constants/
│       └── themes/
│           └── color_constants_test.dart
└── property/
    ├── color_system_property_test.dart
    ├── operations_layout_property_test.dart
    └── category_behavior_property_test.dart
```

### Widget Testing

Widget tests will verify:
- OperationCategoryCard renders correctly
- OperationItemCard displays all required fields
- Empty state displays when no operations
- Expansion animation triggers on tap
- Disabled state visual appearance

## Visual Design Specifications

### Color Palette

```
Primary Teal Scale:
┌────────┬───────────┬─────────────────────────────┐
│ Shade  │ Hex       │ Usage                       │
├────────┼───────────┼─────────────────────────────┤
│ 50     │ #E0F2F1   │ Subtle backgrounds          │
│ 100    │ #B2DFDB   │ Hover states                │
│ 200    │ #80CBC4   │ Borders, dividers           │
│ 300    │ #4DB6AC   │ Secondary accents           │
│ 400    │ #26A69A   │ Active states               │
│ 500    │ #009688   │ Primary actions, headers    │
│ 600    │ #00897B   │ Pressed states              │
│ 700    │ #00796B   │ Dark accents                │
│ 800    │ #00695C   │ High emphasis               │
│ 900    │ #004D40   │ Maximum emphasis            │
└────────┴───────────┴─────────────────────────────┘

Neutral Scale:
┌────────┬───────────┬─────────────────────────────┐
│ Shade  │ Hex       │ Usage                       │
├────────┼───────────┼─────────────────────────────┤
│ 50     │ #FAFAFA   │ Page background             │
│ 100    │ #F5F5F5   │ Card background             │
│ 200    │ #EEEEEE   │ Dividers                    │
│ 300    │ #E0E0E0   │ Borders                     │
│ 400    │ #BDBDBD   │ Disabled text               │
│ 500    │ #9E9E9E   │ Placeholder text            │
│ 600    │ #757575   │ Secondary text              │
│ 700    │ #616161   │ Body text                   │
│ 800    │ #424242   │ Headings                    │
│ 900    │ #212121   │ Primary text                │
└────────┴───────────┴─────────────────────────────┘
```

### Operations Screen Layout

```
┌─────────────────────────────────────────────────┐
│  Operations                              [icon] │  ← Screen title
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ 👤 Your Positions                    [3]    │ │  ← Position summary
│ │ ┌─────┐ ┌─────┐ ┌─────┐                     │ │
│ │ │Pos 1│ │Pos 2│ │Pos 3│                     │ │  ← Position chips
│ │ └─────┘ └─────┘ └─────┘                     │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ 📢 Publishing                          [▼]  │ │  ← Category header
│ ├─────────────────────────────────────────────┤ │
│ │ ┌───────────────────────────────────────┐   │ │
│ │ │ [+] Publish Service                   │   │ │  ← Operation card
│ │ │     Create church services            │   │ │
│ │ └───────────────────────────────────────┘   │ │
│ │ ┌───────────────────────────────────────┐   │ │
│ │ │ [+] Publish Event                     │   │ │
│ │ │     Create church events              │   │ │
│ │ └───────────────────────────────────────┘   │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ 💰 Financial                           [▶]  │ │  ← Collapsed category
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ 📊 Reports                             [▶]  │ │  ← Collapsed category
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Component Specifications

| Component | Border Radius | Shadow | Padding |
|-----------|---------------|--------|---------|
| Position Card | 16px | elevation 1 | 16px |
| Category Card | 16px | elevation 0 | 0px |
| Category Header | 12px (top) | none | 16px |
| Operation Card | 12px | elevation 0 | 12px |
| Position Chip | 8px | none | 8px h, 4px v |
