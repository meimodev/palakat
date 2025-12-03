# Implementation Plan

- [x] 1. Update FinanceCreateScreen to accept initial data
  - [x] 1.1 Add optional `initialData` parameter to FinanceCreateScreen constructor
    - Add `FinanceData? initialData` parameter to the widget
    - Update provider call to pass initialData to controller
    - _Requirements: 1.1, 1.2, 1.3_

  - [x] 1.2 Update FinanceCreateController to handle initial data
    - Modify `build` method signature to accept `FinanceData? initialData`
    - Add `_createInitializedState` method to populate state from FinanceData
    - Add `_formatAmountForDisplay` helper method for amount formatting
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1_

  - [x] 1.3 Write property tests for initialization logic
    - **Property 1: Amount field initialization preserves value**
    - **Property 2: Account number initialization preserves selection**
    - **Property 3: Payment method initialization preserves selection**
    - **Property 4: Form validity reflects complete initial data**
    - **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 2.1**

- [x] 2. Update ActivityPublishScreen to pass initial data when editing
  - [x] 2.1 Modify `_handleEditFinance` method to pass existing finance data
    - Pass `currentFinance` as `initialData` parameter to FinanceCreateScreen
    - _Requirements: 1.1, 1.2, 1.3_

  - [x] 2.2 Write property test for validation updates after modification
    - **Property 5: Validation updates after field modification**
    - **Validates: Requirements 2.3**

- [x] 3. Checkpoint - Make sure all tests are passing
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Add delete confirmation dialog
  - [x] 4.1 Create `_handleRemoveFinance` method with confirmation dialog
    - Add async method that shows AlertDialog before removing
    - Include clear confirmation message and Cancel/Remove buttons
    - Style Remove button with error color for visual distinction
    - _Requirements: 3.1, 3.2_

  - [x] 4.2 Update FinanceSummaryCard onRemove callback to use confirmation handler
    - Replace direct `controller.removeAttachedFinance()` call with `_handleRemoveFinance`
    - _Requirements: 3.3, 3.4_

  - [x] 4.3 Write property tests for delete confirmation behavior
    - **Property 6: Confirmed deletion removes attached finance**
    - **Property 7: Cancelled deletion preserves attached finance**
    - **Validates: Requirements 3.3, 3.4**

- [x] 5. Run code generation and verify
  - [x] 5.1 Run build_runner to regenerate Riverpod providers
    - Execute `melos run build:runner` to regenerate `.g.dart` files
    - Verify no compilation errors after generation
    - _Requirements: 1.2_

- [x] 6. Final Checkpoint - Make sure all tests are passing
  - Ensure all tests pass, ask the user if questions arise.

  