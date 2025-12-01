# Implementation Plan

- [x] 1. Create shared DividerWidget in palakat_shared
  - [x] 1.1 Create `packages/palakat_shared/lib/core/widgets/divider_widget.dart`
    - Implement theme-based DividerWidget using `Theme.of(context)` for colors
    - Support vertical and horizontal orientations
    - Support custom thickness, height, width, and color
    - _Requirements: 2.1, 3.1_
  - [x] 1.2 Export DividerWidget from widgets barrel file
    - Add export to `packages/palakat_shared/lib/core/widgets/widgets.dart`
    - _Requirements: 2.2_

- [x] 2. Create shared InputWidget in palakat_shared
  - [x] 2.1 Create `packages/palakat_shared/lib/core/widgets/input/input_widget.dart`
    - Migrate from `apps/palakat/lib/core/widgets/input/input_widget.dart`
    - Replace BaseColor with `Theme.of(context).colorScheme`
    - Replace BaseTypography with `Theme.of(context).textTheme`
    - Replace BaseSize and Gap with direct values or SizedBox
    - Maintain all three constructors: text, dropdown, binaryOption
    - _Requirements: 2.1, 2.2, 2.3_
  - [x] 2.2 Create `packages/palakat_shared/lib/core/widgets/input/input_variant_dropdown_widget.dart`
    - Migrate from palakat with theme-based styling
    - Preserve customDisplayBuilder functionality
    - _Requirements: 2.3_
  - [x] 2.3 Create `packages/palakat_shared/lib/core/widgets/input/input_variant_text_widget.dart`
    - Migrate from palakat with theme-based styling
    - _Requirements: 2.1, 3.1_
  - [x] 2.4 Create `packages/palakat_shared/lib/core/widgets/input/input_variant_binary_option_widget.dart`
    - Migrate from palakat with theme-based styling
    - _Requirements: 2.1, 3.3_
  - [x] 2.5 Create barrel file `packages/palakat_shared/lib/core/widgets/input/input.dart`
    - Export all input widgets
    - _Requirements: 2.2_
  - [x] 2.6 Export input widgets from main widgets barrel file
    - Add export to `packages/palakat_shared/lib/core/widgets/widgets.dart`
    - _Requirements: 2.2_

- [x] 3. Create shared FinancialAccountPicker in palakat_shared
  - [x] 3.1 Create `packages/palakat_shared/lib/core/widgets/financial_account_picker.dart`
    - Migrate from `apps/palakat/lib/core/widgets/account_number_picker/account_number_picker.dart`
    - Replace hardcoded constants with theme-based styling
    - Accept accounts list as parameter (no internal fetching)
    - Add isLoading parameter for loading state
    - Display account number prominently with description below
    - _Requirements: 1.1, 1.2, 5.1, 5.2, 5.3_
  - [x] 3.2 Export FinancialAccountPicker from widgets barrel file
    - Add export to `packages/palakat_shared/lib/core/widgets/widgets.dart`
    - _Requirements: 2.2_

- [ ] 4. Checkpoint - Ensure shared widgets compile
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Update palakat app to use shared widgets
  - [x] 5.1 Update palakat DividerWidget to re-export from shared
    - Modify `apps/palakat/lib/core/widgets/divider/divider_widget.dart` to re-export
    - Or update imports throughout the app
    - _Requirements: 3.1_
  - [x] 5.2 Update palakat InputWidget to re-export from shared
    - Modify input widget files to re-export from shared
    - Or update imports throughout the app
    - _Requirements: 3.1, 3.2, 3.3_
  - [x] 5.3 Update palakat AccountNumberPicker to use shared FinancialAccountPicker
    - Keep dialog implementation in palakat (uses Riverpod)
    - Update picker to use shared widget internally or re-export
    - _Requirements: 3.2_

- [x] 6. Update palakat_admin approval edit drawer
  - [x] 6.1 Replace DropdownButtonFormField with FinancialAccountPicker
    - Import FinancialAccountPicker from palakat_shared
    - Replace financial account dropdown in approval_edit_drawer.dart
    - Pass fetched accounts list to the picker
    - Handle selection callback
    - _Requirements: 1.1, 1.2, 1.3, 5.1, 5.2, 5.3_

- [ ] 7. Checkpoint - Ensure apps compile and work
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Update database seeder with hierarchical account numbers
  - [x] 8.1 Update INCOME_ACCOUNTS in seed.ts
    - Change account codes to hierarchical format starting with "1"
    - Use format like "1.1", "1.1.01", "1.1.01.01", "1.2.22.44"
    - Ensure varying hierarchy depths (2-4 levels)
    - _Requirements: 4.1, 4.2, 4.4_
  - [x] 8.2 Update EXPENSE_ACCOUNTS in seed.ts
    - Change account codes to hierarchical format starting with "2"
    - Use format like "2.1", "2.1.01", "2.1.01.01", "2.2.22.44"
    - Ensure varying hierarchy depths (2-4 levels)
    - _Requirements: 4.1, 4.3, 4.4_

- [ ] 9. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
