# Implementation Plan

## Part 1: Financial Account Unique Constraint

- [x] 1. Update database schema for unique constraint
  - [x] 1.1 Add unique constraint to financialAccountNumberId in ApprovalRule model
    - Modify `apps/palakat_backend/prisma/schema.prisma`
    - Add `@unique` attribute to `financialAccountNumberId` field in `ApprovalRule` model
    - _Requirements: 3.4_
  - [x] 1.2 Generate Prisma client and create migration
    - Run `pnpm run prisma:generate` to update Prisma client
    - Run migration to apply schema changes
    - _Requirements: 3.4_

- [x] 2. Implement backend validation for financial account uniqueness
  - [x] 2.1 Add validation method to ApprovalRuleService
    - Create `validateFinancialAccountUniqueness` method
    - Check if account is already linked to another rule (excluding current rule for updates)
    - Throw appropriate error with clear message
    - _Requirements: 3.1, 3.2, 3.3, 3.5_
  - [x] 2.2 Update create method with validation
    - Call validation before creating approval rule
    - _Requirements: 3.2_
  - [x] 2.3 Update update method with validation
    - Call validation before updating approval rule
    - Exclude current rule from uniqueness check
    - _Requirements: 3.3_
  - [ ]* 2.4 Write property test for financial account uniqueness
    - **Property 1: Financial Account Uniqueness Constraint**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
    - Test that linking same account to two rules fails
    - _Requirements: 3.1_

- [x] 3. Add available accounts endpoint
  - [x] 3.1 Create getAvailableAccounts method in FinancialAccountNumberService
    - Filter out accounts already linked to approval rules
    - Accept optional `currentRuleId` to include current rule's account
    - _Requirements: 5.1, 5.2_
  - [x] 3.2 Add controller endpoint for available accounts
    - Create GET endpoint `/financial-account-number/available`
    - Accept query params: `churchId`, `financeType`, `currentRuleId`
    - _Requirements: 5.1_
  - [ ]* 3.3 Write property test for available accounts filtering
    - **Property 3: Available Accounts Filtering**
    - **Validates: Requirements 5.1**
    - Test that only unlinked accounts are returned
    - _Requirements: 5.1_

- [x] 4. Update seed script for unique constraint compliance
  - [x] 4.1 Modify seedApprovalRules to ensure unique financial account assignments
    - Track which accounts have been assigned
    - Skip accounts already linked to other rules
    - _Requirements: 4.1, 4.2_
  - [ ]* 4.2 Write property test for seed data uniqueness
    - **Property 2: Seed Data Financial Account Uniqueness**
    - **Validates: Requirements 4.1, 4.2, 4.3**
    - Verify no duplicate financialAccountNumberId values after seeding
    - _Requirements: 4.3_

- [ ] 5. Checkpoint - Ensure all backend tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Part 2: Widget Consolidation

- [x] 6. Migrate button widgets to shared package
  - [x] 6.1 Move button_widget.dart to shared package
    - Copy `apps/palakat/lib/core/widgets/button/button_widget.dart` to `packages/palakat_shared/lib/core/widgets/button/`
    - Update imports to use shared package dependencies
    - Export from widgets.dart barrel file
    - _Requirements: 1.1, 1.3_
  - [x] 6.2 Update palakat app to import from shared
    - Update imports in palakat app to use `palakat_shared`
    - Remove local button widget file
    - _Requirements: 1.3_

- [x] 7. Migrate card widgets to shared package
  - [x] 7.1 Move card widgets to shared package
    - Copy card widgets from `apps/palakat/lib/core/widgets/card/` to `packages/palakat_shared/lib/core/widgets/card/`
    - Include: card_bipra.dart, card_church.dart, card_column.dart, card_overview_list_item_widget.dart, card_reminder.dart, card.dart, membership_card_widget.dart
    - Update imports and export from barrel file
    - _Requirements: 1.1, 2.1_
  - [x] 7.2 Update palakat app to import cards from shared
    - Update imports in palakat app
    - Remove local card widget files
    - _Requirements: 1.3_

- [x] 8. Migrate dialog widgets to shared package
  - [x] 8.1 Move dialog widgets to shared package
    - Copy dialog widgets from `apps/palakat/lib/core/widgets/dialog/` to `packages/palakat_shared/lib/core/widgets/dialog/`
    - Include all picker dialogs and general dialog widgets
    - Update imports and export from barrel file
    - _Requirements: 1.1, 2.1_
  - [x] 8.2 Update palakat app to import dialogs from shared
    - Update imports in palakat app
    - Remove local dialog widget files
    - _Requirements: 1.3_

- [x] 9. Migrate input widgets to shared package
  - [x] 9.1 Merge input widgets with existing shared input widgets
    - Copy additional input widgets from palakat to shared
    - Include: input_multiple_select_widget.dart, input_search_widget.dart, input_variant_*.dart
    - Merge with existing input/input.dart structure
    - _Requirements: 1.1, 2.1_
  - [x] 9.2 Update palakat app to import inputs from shared
    - Update imports in palakat app
    - Remove local input widget files
    - _Requirements: 1.3_

- [x] 10. Migrate loading and error widgets to shared package
  - [x] 10.1 Merge loading widgets with existing shared widgets
    - Copy loading_wrapper.dart, shimmer_widgets.dart to shared
    - Merge with existing loading_widget.dart, loading_shimmer.dart
    - _Requirements: 1.1, 2.1_
  - [x] 10.2 Merge error widgets with existing shared widgets
    - Copy error_display_widget.dart to shared
    - Merge with existing error_widget.dart
    - _Requirements: 1.1, 2.1_
  - [x] 10.3 Update palakat app to import from shared
    - Update imports in palakat app
    - Remove local loading and error widget files
    - _Requirements: 1.3_

- [x] 11. Migrate mobile-specific widgets to shared package
  - [x] 11.1 Create mobile subdirectory in shared widgets
    - Create `packages/palakat_shared/lib/core/widgets/mobile/` directory
    - _Requirements: 1.2_
  - [x] 11.2 Move appbar widget to shared mobile directory
    - Copy appbar_widget.dart to shared mobile directory
    - Update imports and exports
    - _Requirements: 1.2, 1.3_
  - [x] 11.3 Move bottom navbar widgets to shared mobile directory
    - Copy bottom_navbar.dart, bottom_navbar_item.dart to shared mobile directory
    - Update imports and exports
    - _Requirements: 1.2, 1.3_
  - [x] 11.4 Move scaffold widget to shared mobile directory
    - Copy scaffold_widget.dart to shared mobile directory
    - Update imports and exports
    - _Requirements: 1.2, 1.3_
  - [x] 11.5 Update palakat app to import mobile widgets from shared
    - Update imports in palakat app
    - Remove local mobile widget files
    - _Requirements: 1.3_

- [x] 12. Migrate remaining widgets to shared package
  - [x] 12.1 Move chips widget to shared
    - Copy chips_widget.dart to shared
    - Merge with existing chip widgets
    - _Requirements: 1.1_
  - [x] 12.2 Move output widget to shared
    - Copy output_widget.dart to shared
    - _Requirements: 1.1_
  - [x] 12.3 Move screen_title and segment_title widgets to shared
    - Copy screen_title_widget.dart and segment_title.dart to shared
    - _Requirements: 1.1_
  - [x] 12.4 Move info_box widgets to shared
    - Copy info_box_widget.dart and info_box_with_action_widget.dart to shared
    - Merge with existing info_section.dart
    - _Requirements: 1.1_
  - [x] 12.5 Move image_network widget to shared
    - Copy image_network_widget.dart to shared
    - _Requirements: 1.1_
  - [x] 12.6 Merge account_number_picker with financial_account_picker
    - Consolidate account_number_picker functionality into financial_account_picker
    - _Requirements: 1.1_
  - [x] 12.7 Update palakat app to import remaining widgets from shared
    - Update all remaining imports in palakat app
    - Remove local widget files
    - _Requirements: 1.3_

- [x] 13. Update barrel exports and clean up
  - [x] 13.1 Update shared package widgets.dart barrel file
    - Export all new widget categories
    - Organize exports by category
    - _Requirements: 2.2, 2.3_
  - [x] 13.2 Update palakat app widgets.dart to re-export from shared
    - Replace local exports with re-exports from palakat_shared
    - _Requirements: 1.5_
  - [x] 13.3 Verify palakat_admin imports from shared
    - Ensure palakat_admin uses shared widgets (already exports from palakat_shared/widgets.dart)
    - _Requirements: 1.4_

- [x] 14. Update frontend financial account picker for available accounts
  - [x] 14.1 Add getAvailableAccounts method to ApprovalRepository
    - Create method to call `/financial-account-number/available` endpoint
    - Accept churchId, financeType, and optional currentRuleId parameters
    - _Requirements: 5.1, 5.2_
  - [x] 14.2 Update ApprovalController to use available accounts endpoint
    - Modify `fetchFinancialAccountNumbers` to call available accounts endpoint
    - Pass currentRuleId when editing existing rules
    - _Requirements: 5.1, 5.2_
  - [x] 14.3 Update ApprovalEditDrawer to pass currentRuleId
    - Pass widget.ruleId when fetching financial accounts for edit mode
    - Ensure current rule's account is included in available options
    - _Requirements: 5.2_
  - [x] 14.4 Add empty state message for no available accounts
    - Update FinancialAccountPicker to show message when accounts list is empty
    - Display "All accounts are assigned to other rules" message
    - _Requirements: 5.3_

- [x] 15. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Part 3: Financial Type Requires Account Number

- [x] 16. Add backend validation for financial type requiring account number
  - [x] 16.1 Add validation method to ApprovalRuleService
    - Create `validateFinancialTypeRequiresAccount` method
    - Check if financialType is set but financialAccountNumberId is null
    - Throw `FINANCIAL_ACCOUNT_REQUIRED` error with clear message
    - _Requirements: 6.1, 6.2_
  - [x] 16.2 Update create method with financial type validation
    - Call validation before creating approval rule
    - _Requirements: 6.1_
  - [x] 16.3 Update update method with financial type validation
    - Call validation before updating approval rule
    - _Requirements: 6.2_
  - [ ]* 16.4 Write property test for financial type requires account
    - **Property 4: Financial Type Requires Account Number**
    - **Validates: Requirements 6.1, 6.2**
    - Test that creating/updating rule with financial type but no account fails
    - _Requirements: 6.1, 6.2_

- [x] 17. Update frontend validation for financial type
  - [x] 17.1 Update ApprovalEditDrawer to show required indicator
    - Change label from "Financial Account Number (Optional)" to "Financial Account Number *" when financial type is selected
    - _Requirements: 6.3_
  - [x] 17.2 Add frontend validation before save
    - Check if financial type is selected but no account is chosen
    - Display validation error message
    - Prevent form submission
    - _Requirements: 6.4_

## Part 4: Searchable Pickers

- [x] 18. Add search functionality to FinancialAccountPicker
  - [x] 18.1 Convert FinancialAccountPicker to StatefulWidget
    - Add search text controller and state
    - Add search input field to the picker UI
    - _Requirements: 7.1_
  - [x] 18.2 Implement search filtering logic
    - Filter accounts by description match (case-insensitive)
    - If no description matches, fallback to account number match
    - _Requirements: 7.2, 7.3_
  - [x] 18.3 Update dropdown to show filtered results
    - Display filtered accounts in scrollable list
    - _Requirements: 7.4_
  - [ ]* 18.4 Write property test for financial account search
    - **Property 5: Financial Account Search by Description**
    - **Property 6: Financial Account Search Fallback to Account Number**
    - **Validates: Requirements 7.2, 7.3**
    - _Requirements: 7.2, 7.3_

- [x] 19. Add search functionality to PositionSelector
  - [x] 19.1 Convert PositionSelector to StatefulWidget
    - Add search text controller and state
    - Add search input field to the selector UI
    - _Requirements: 8.1_
  - [x] 19.2 Implement search filtering logic
    - Filter positions by name match (case-insensitive)
    - _Requirements: 8.2_
  - [x] 19.3 Update dropdown to show filtered results
    - Display filtered positions in scrollable list
    - _Requirements: 8.3_
  - [ ]* 19.4 Write property test for position search
    - **Property 7: Position Search by Name**
    - **Validates: Requirements 8.2**
    - _Requirements: 8.2_

## Part 5: Financial Account Table Updates

- [ ] 20. Update backend to include approval rule in financial account response
  - [ ] 20.1 Update FinancialAccountNumberService findAll method
    - Add option to include linked approval rule information
    - Include approval rule id and name in response
    - _Requirements: 9.2, 9.4_
  - [ ] 20.2 Update controller to pass includeApprovalRule option
    - Enable includeApprovalRule for list endpoint
    - _Requirements: 9.2_

- [ ] 21. Update frontend financial account model
  - [ ] 21.1 Update FinancialAccountNumber model
    - Add optional approvalRule field with id and name
    - Update fromJson to parse approval rule data
    - _Requirements: 9.2, 9.4_

- [ ] 22. Update financial account list screen
  - [ ] 22.1 Remove created date column from table
    - Remove the "Created Date" column from _buildTableColumns
    - _Requirements: 9.1_
  - [ ] 22.2 Add linked approval rule column
    - Add new column "Linked Approval Rule"
    - Display approval rule name if linked
    - Display "-" or "Not assigned" if not linked
    - _Requirements: 9.2, 9.3, 9.4_
  - [ ]* 22.3 Write property test for linked approval rule display
    - **Property 8: Linked Approval Rule Display**
    - **Validates: Requirements 9.4**
    - _Requirements: 9.4_

- [ ] 23. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
