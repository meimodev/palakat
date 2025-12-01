# Design Document: Financial Account Picker Fix

## Overview

This design addresses the overflow issues in the financial account picker by migrating existing widgets from the palakat mobile app to the palakat_shared package. The palakat app already has a well-designed `AccountNumberPicker` widget and `InputWidget` with custom display builder support. The migration requires refactoring these widgets to use theme-based styling instead of hardcoded constants (BaseColor, BaseTypography, BaseSize, Gap), ensuring compatibility with both palakat and palakat_admin apps.

## Architecture

### Current State

```
palakat/
├── lib/core/widgets/
│   ├── account_number_picker/
│   │   ├── account_number_picker.dart       # Well-designed picker with proper display
│   │   └── account_number_picker_dialog.dart # Dialog with search and pagination
│   ├── input/
│   │   ├── input_widget.dart                # Main widget with text/dropdown/binaryOption
│   │   ├── input_variant_dropdown_widget.dart
│   │   ├── input_variant_text_widget.dart
│   │   └── input_variant_binary_option_widget.dart
│   └── divider/
│       └── divider_widget.dart              # Simple divider widget

palakat_admin/
├── lib/features/approval/presentation/widgets/
│   └── approval_edit_drawer.dart      # Uses DropdownButtonFormField (has overflow issues)
```

### Target State

```
palakat_shared/
├── lib/core/widgets/
│   ├── input/
│   │   ├── input_widget.dart              # Theme-based main widget
│   │   ├── input_variant_dropdown_widget.dart
│   │   ├── input_variant_text_widget.dart
│   │   └── input_variant_binary_option_widget.dart
│   ├── financial_account_picker.dart      # Theme-based account picker
│   └── divider_widget.dart                # Theme-based divider

palakat/
├── lib/core/widgets/
│   ├── account_number_picker/             # Re-exports from palakat_shared
│   ├── input/                             # Re-exports from palakat_shared
│   └── divider/                           # Re-exports from palakat_shared

palakat_admin/
├── lib/features/approval/presentation/widgets/
│   └── approval_edit_drawer.dart      # Uses shared FinancialAccountPicker
```

## Components and Interfaces

### 1. FinancialAccountPicker (Shared - migrated from AccountNumberPicker)

The existing AccountNumberPicker will be migrated with theme-based styling:

```dart
/// A picker widget for selecting financial account numbers.
/// Displays the selected account number prominently with description below.
/// Uses Theme.of(context) for styling instead of hardcoded constants.
class FinancialAccountPicker extends StatelessWidget {
  const FinancialAccountPicker({
    super.key,
    required this.financeType,
    this.selectedAccount,
    required this.onSelected,
    this.errorText,
    this.label,
    this.accounts,           // Optional: provide accounts directly
    this.isLoading = false,  // Loading state for async fetching
  });

  final FinanceType financeType;
  final FinancialAccountNumber? selectedAccount;
  final ValueChanged<FinancialAccountNumber> onSelected;
  final String? errorText;
  final String? label;
  final List<FinancialAccountNumber>? accounts;
  final bool isLoading;
}
```

### 2. InputWidget (Shared)

The existing InputWidget will be migrated with theme-based styling:

```dart
/// Theme-aware input widget with multiple variants
class InputWidget<T> extends StatefulWidget {
  const InputWidget.text({...});
  const InputWidget.dropdown({
    // ... existing parameters
    this.customDisplayBuilder,
  });
  const InputWidget.binaryOption({...});
  
  /// Optional custom widget builder for displaying the selected value
  final Widget Function(T value)? customDisplayBuilder;
}
```

### 3. DividerWidget (Shared)

```dart
/// A simple divider widget that uses theme colors
class DividerWidget extends StatelessWidget {
  const DividerWidget({
    super.key,
    this.color,
    this.thickness = 2,
    this.axis = Axis.vertical,
    this.height,
    this.width,
  });
}
```

### 4. Theme-Based Styling Changes

All widgets will be refactored to use `Theme.of(context)` instead of hardcoded constants:

| Original (palakat) | Shared (theme-based) |
|-------------------|---------------------|
| `BaseColor.neutral30` | `theme.colorScheme.outline` |
| `BaseColor.neutral50` | `theme.colorScheme.onSurfaceVariant` |
| `BaseColor.neutral60` | `theme.colorScheme.onSurfaceVariant` |
| `BaseColor.black` | `theme.colorScheme.onSurface` |
| `BaseColor.white` | `theme.colorScheme.surface` |
| `BaseColor.error` | `theme.colorScheme.error` |
| `BaseColor.primary` | `theme.colorScheme.primary` |
| `BaseTypography.titleMedium` | `theme.textTheme.titleMedium` |
| `BaseTypography.bodySmall` | `theme.textTheme.bodySmall` |
| `BaseSize.w12` | `12.0` (or theme extension) |
| `Gap.h6` | `SizedBox(height: 6)` |

## Data Models

### FinancialAccountNumber (Existing)

```dart
@freezed
abstract class FinancialAccountNumber with _$FinancialAccountNumber {
  const factory FinancialAccountNumber({
    required int id,
    required String accountNumber,  // e.g., "1.2.22.44"
    String? description,
    required FinanceType type,
    int? churchId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FinancialAccountNumber;
}
```

### Seeder Account Number Format

Income accounts (type: REVENUE):
- Format: `1.X.XX.XX` where X represents hierarchy levels
- Examples: `1.1`, `1.1.01`, `1.1.01.01`, `1.2.22.44`

Expense accounts (type: EXPENSE):
- Format: `2.X.XX.XX` where X represents hierarchy levels
- Examples: `2.1`, `2.1.01`, `2.1.01.01`, `2.2.22.44`

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, the following properties can be verified through property-based testing:

### Property 1: Theme-based styling adaptation
*For any* valid ThemeData configuration, the InputWidget SHALL render using colors and text styles from the provided theme context, not hardcoded values.
**Validates: Requirements 2.1**

### Property 2: Custom display builder invocation
*For any* InputWidget.dropdown with a customDisplayBuilder and a non-null selected value, the widget tree SHALL contain the widget returned by customDisplayBuilder(value).
**Validates: Requirements 2.3**

### Property 3: InputWidget.text backward compatibility
*For any* InputWidget.text configuration with valid parameters, the widget SHALL render a text input field that accepts user input and triggers onChanged callbacks.
**Validates: Requirements 3.1**

### Property 4: InputWidget.dropdown backward compatibility
*For any* InputWidget.dropdown configuration with valid parameters, the widget SHALL render a tappable dropdown that triggers onPressedWithResult and updates the display on selection.
**Validates: Requirements 3.2**

### Property 5: InputWidget.binaryOption backward compatibility
*For any* InputWidget.binaryOption configuration with valid options, the widget SHALL render selectable options that trigger onChanged when tapped.
**Validates: Requirements 3.3**

### Property 6: Account number format validation
*For any* financial account number generated by the seeder, the accountNumber field SHALL match the pattern `^[12]\.\d+(\.\d+)*$` (starting with 1 or 2, followed by dot-separated numeric segments).
**Validates: Requirements 4.1**

### Property 7: Income account prefix
*For any* financial account number with type REVENUE, the accountNumber SHALL start with "1".
**Validates: Requirements 4.2**

### Property 8: Expense account prefix
*For any* financial account number with type EXPENSE, the accountNumber SHALL start with "2".
**Validates: Requirements 4.3**

### Property 9: Account hierarchy depth variation
*For any* complete set of seeded financial accounts, there SHALL exist accounts with 2, 3, and 4 hierarchy levels (1, 2, and 3 dots respectively).
**Validates: Requirements 4.4**

### Property 10: Null description handling
*For any* FinancialAccountDisplay with description=null, the rendered widget SHALL NOT contain placeholder text or empty description elements.
**Validates: Requirements 5.3**

## Error Handling

1. **Missing Theme Context**: If Theme.of(context) fails, fall back to default Material theme colors
2. **Null Value in Dropdown**: Handle gracefully by showing hint text
3. **Invalid Account Number Format**: Log warning but don't crash; display as-is
4. **Empty Options List**: Show disabled state with appropriate message

## Testing Strategy

### Unit Tests

1. **FinancialAccountDisplay widget tests**
   - Verify account number is displayed
   - Verify description is displayed when provided
   - Verify description is not displayed when null

2. **InputWidget variant tests**
   - Test each constructor creates valid widget
   - Test onChanged callbacks are triggered
   - Test customDisplayBuilder is used when provided

### Property-Based Tests

Using the `fast-check` library for backend (seeder) tests:

1. **Account number format property** (Property 6)
   - Generate random account configurations
   - Verify all generated account numbers match expected format

2. **Account type prefix property** (Properties 7, 8)
   - Generate accounts of each type
   - Verify prefix matches type

3. **Hierarchy depth property** (Property 9)
   - Generate full account set
   - Verify depth variation exists

### Integration Tests

1. **Approval Edit Drawer with Financial Account Picker**
   - Open drawer
   - Select financial type
   - Verify accounts load
   - Select account
   - Verify display shows account number and description without overflow

## Migration Plan

1. **Phase 1**: Create shared widgets in palakat_shared
   - Create `DividerWidget` with theme-based styling
   - Create `InputWidget` and variants with theme-based styling
   - Create `FinancialAccountPicker` with theme-based styling (simplified version without dialog)

2. **Phase 2**: Update palakat app
   - Update imports to use shared widgets where applicable
   - Keep app-specific dialog implementation (uses Riverpod providers)
   - Ensure visual consistency through theme configuration

3. **Phase 3**: Update palakat_admin
   - Replace `DropdownButtonFormField` in approval_edit_drawer with `FinancialAccountPicker`
   - Pass accounts list directly (already fetched by the drawer)

4. **Phase 4**: Update seeder
   - Change account number format to hierarchical (1.X.XX.XX for income, 2.X.XX.XX for expense)
   - Ensure variety in hierarchy depths (2-4 levels)

## Widgets to Share

Based on analysis of both apps, the following widgets should be moved to palakat_shared:

| Widget | Source | Reason |
|--------|--------|--------|
| `InputWidget` | palakat | Flexible input with custom display builder |
| `InputVariantDropdownWidget` | palakat | Dropdown with custom display support |
| `InputVariantTextWidget` | palakat | Text input with consistent styling |
| `InputVariantBinaryOptionWidget` | palakat | Binary option selector |
| `DividerWidget` | palakat | Simple divider used by InputWidget |
| `FinancialAccountPicker` | palakat (AccountNumberPicker) | Account selection with proper display |

Note: The `AccountNumberPickerDialog` will remain in palakat as it uses app-specific providers (Riverpod). The shared `FinancialAccountPicker` will accept accounts as a parameter instead of fetching them internally.
