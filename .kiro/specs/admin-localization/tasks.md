# Implementation Plan

- [x] 1. Add new localization keys to ARB files
  - [x] 1.1 Add admin screen title keys to `intl_en.arb`
    - Add keys: `admin_billing_title`, `admin_approval_title`, `admin_account_title`, `admin_activity_title`, `admin_revenue_title`, `admin_member_title`, `admin_financial_title`
    - Add corresponding subtitle keys
    - _Requirements: 1.1-1.7, 2.1-2.3_
  - [x] 1.2 Add card title and subtitle keys to `intl_en.arb`
    - Add keys for SurfaceCard and ExpandableSurfaceCard titles/subtitles
    - Include billing, approval, revenue, expense, activity, member, document, report, account, church, financial cards
    - _Requirements: 3.1-3.3_
  - [x] 1.3 Add drawer title and subtitle keys to `intl_en.arb`
    - Add keys for all SideDrawer titles and subtitles
    - Include member, approval, activity, revenue, expense, church, position, column, report, document, financial, account drawers
    - _Requirements: 4.1-4.3_
  - [x] 1.4 Add form label keys to `intl_en.arb`
    - Add keys for LabeledField, InfoSection, and InfoRow labels
    - Include all form fields across features
    - _Requirements: 5.1-5.3_
  - [x] 1.5 Add table column header keys to `intl_en.arb`
    - Add keys for all AppTableColumn titles
    - Include billing, revenue, expense, activity, member, approval, document, report, financial tables
    - _Requirements: 6.1-6.3_
  - [x] 1.6 Add button label keys to `intl_en.arb`
    - Add keys: `btn_addAccountNumber`, `btn_recordPayment`, `btn_exportReceipt`, `btn_create`, `btn_update`, `btn_addRule`, `btn_viewAll`
    - _Requirements: 7.1-7.5_
  - [x] 1.7 Add dialog keys to `intl_en.arb`
    - Add keys for dialog titles and content messages
    - Include delete confirmations, sign out confirmation, record payment dialog
    - _Requirements: 8.1-8.4_
  - [x] 1.8 Add dropdown and filter option keys to `intl_en.arb`
    - Add keys: `filter_allStatus`, `filter_allActivityTypes`, `filter_noFinancialFilter`, `filter_paymentMethod`
    - _Requirements: 9.1-9.4_
  - [x] 1.9 Add snackbar message keys to `intl_en.arb`
    - Add success and error message keys for all CRUD operations
    - Include saved, deleted, created, updated, failed messages
    - _Requirements: 10.1-10.4_
  - [x] 1.10 Add form hint and placeholder keys to `intl_en.arb`
    - Add hint keys for all text input fields
    - Include search hints, field placeholders
    - _Requirements: 11.1-11.3_
  - [x] 1.11 Add validation message keys to `intl_en.arb`
    - Add keys for required field, password validation, and other validation errors
    - _Requirements: 12.1-12.3_
  - [x] 1.12 Add loading and error state keys to `intl_en.arb`
    - Add keys for loading messages and error states
    - _Requirements: 13.1-13.3_
  - [x] 1.13 Add tooltip keys to `intl_en.arb`
    - Add keys: `tooltip_refresh`, `tooltip_viewActivityDetails`, `tooltip_downloadReport`, `tooltip_baptized`, `tooltip_sidi`, `tooltip_appLinked`
    - _Requirements: 14.1-14.3_
  - [x] 1.14 Add checkbox and toggle label keys to `intl_en.arb`
    - Add keys: `lbl_active`, `lbl_baptized`, `lbl_sidi`
    - _Requirements: 15.1-15.3_
  - [x] 1.15 Add sidebar and footer keys to `intl_en.arb`
    - Add keys: `appTitle_admin`, `lbl_adminUser`, `footer_copyright`
    - _Requirements: 16.1-16.2, 17.1_
  - [x] 1.16 Add time-relative string keys with pluralization to `intl_en.arb`
    - Add keys: `time_justNow`, `time_minutesAgo`, `time_hoursAgo`, `time_daysAgo` with ICU plural syntax
    - _Requirements: 18.1-18.3_
  - [x] 1.17 Copy all new keys to `intl_id.arb` with Indonesian translations
    - Translate all newly added keys to Indonesian
    - Ensure proper pluralization syntax for Indonesian
    - _Requirements: 19.1-19.2_

- [ ] 1.18 Write property test for ARB key parity
  - **Property 1: ARB Key Parity**
  - **Validates: Requirements 19.1**

- [x] 2. Regenerate localization files
  - Run `melos run build:runner` to regenerate `app_localizations.dart` files
  - Verify no errors in generated code
  - _Requirements: 19.1_

- [x] 3. Checkpoint - Ensure localization files are generated correctly
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Update billing feature screens
  - [x] 4.1 Update `billing_screen.dart` to use localized strings
    - Replace hardcoded page title, subtitle, card titles, table headers, button labels, dialog content, snackbar messages
    - _Requirements: 1.1, 2.1, 3.1-3.2, 6.1-6.2, 7.1-7.4, 8.1-8.2, 10.1-10.2, 11.1-11.2, 13.1-13.2_

- [x] 5. Update approval feature screens
  - [x] 5.1 Update `approval_screen.dart` to use localized strings
    - Replace hardcoded page title, card titles, table headers, button labels
    - _Requirements: 1.2, 3.1-3.2, 6.1, 7.1_
  - [x] 5.2 Update `approval_edit_drawer.dart` to use localized strings
    - Replace hardcoded drawer title, subtitle, form labels, dropdown options, dialog content, button labels
    - _Requirements: 4.1-4.2, 5.1-5.3, 8.1-8.2, 9.1-9.4, 15.1_

- [x] 6. Update account feature screens
  - [x] 6.1 Update `account_screen.dart` to use localized strings
    - Replace hardcoded page title, subtitle, card titles, button labels, dialog content, snackbar messages, validation messages
    - _Requirements: 1.3, 2.2, 3.1-3.2, 7.1-7.2, 8.1-8.4, 10.1-10.4, 12.1-12.3_

- [x] 7. Update activity feature screens
  - [x] 7.1 Update `activity_screen.dart` to use localized strings
    - Replace hardcoded page title, card titles, table headers
    - _Requirements: 1.4, 3.1-3.2, 6.1_
  - [x] 7.2 Update `activity_detail_drawer.dart` to use localized strings
    - Replace hardcoded drawer title, subtitle, section titles, labels, tooltips
    - _Requirements: 4.1-4.2, 5.1-5.3, 13.1, 14.1_

- [x] 8. Update revenue feature screens
  - [x] 8.1 Update `revenue_screen.dart` to use localized strings
    - Replace hardcoded page title ('Revenue'), subtitle ('Track and manage all revenue sources.'), card titles ('Revenue Log'), table headers ('Account Number', 'Activity', 'Request Date', 'Approval Date', 'Amount', 'Payment Method'), filter labels
    - _Requirements: 1.5, 3.1-3.2, 6.1, 9.1_
  - [x] 8.2 Update `revenue_detail_drawer.dart` to use localized strings
    - Replace hardcoded drawer title ('Revenue Details'), subtitle, section titles ('Basic Information', 'Activity Information', 'Supervisor', 'Approval', 'Timestamps'), labels, tooltips ('View Activity Details'), button labels ('Export Receipt')
    - _Requirements: 4.1-4.2, 5.1-5.3, 7.1, 13.1, 14.1_

- [x] 9. Update expense feature screens
  - [x] 9.1 Update `expense_screen.dart` to use localized strings
    - Replace hardcoded page title, card titles, table headers
    - _Requirements: 3.1-3.2, 6.1_
  - [x] 9.2 Update `expense_detail_drawer.dart` to use localized strings
    - Replace hardcoded drawer title, subtitle, section titles, labels, tooltips
    - _Requirements: 4.1-4.2, 5.1-5.3, 13.1, 14.1_

- [x] 10. Update member feature screens
  - [x] 10.1 Update `member_screen.dart` to use localized strings
    - Replace hardcoded page title, card titles, table headers, snackbar messages
    - _Requirements: 1.6, 3.1-3.2, 6.1-6.3, 10.1_
  - [x] 10.2 Update `member_edit_drawer.dart` to use localized strings
    - Replace hardcoded drawer title, subtitle, section titles, form labels, checkbox labels, dialog content, button labels
    - _Requirements: 4.1-4.3, 5.1-5.3, 8.1-8.2, 15.1-15.3_
  - [x] 10.3 Update `member_name_cell.dart` to use localized strings
    - Replace hardcoded tooltip texts
    - _Requirements: 14.1-14.3_

- [x] 11. Update financial feature screens
  - [x] 11.1 Update `financial_account_list_screen.dart` to use localized strings
    - Replace hardcoded page title ('Financial Account Numbers'), subtitle ('Manage predefined account numbers...'), card titles ('Account Numbers'), table headers ('Account Number', 'Type', 'Description', 'Linked Approval Rule'), button labels ('Add Account Number'), filter labels
    - _Requirements: 1.7, 2.3, 3.1-3.2, 6.1, 7.1-7.2, 9.1, 11.1_
  - [x] 11.2 Update `financial_account_edit_drawer.dart` to use localized strings
    - Replace hardcoded drawer title ('Edit/Add Account Number'), subtitle, form labels ('Account Number', 'Type', 'Description'), button labels ('Cancel', 'Create', 'Update'), snackbar messages, validation messages ('Account number is required')
    - _Requirements: 4.1-4.2, 5.1, 7.1-7.5, 10.1-10.2, 11.1-11.3, 12.1_

- [x] 12. Update church feature screens
  - [x] 12.1 Update `church_screen.dart` to use localized strings
    - Replace hardcoded page title ('Church Profile'), subtitle ('Manage your church\'s public information...'), card titles ('Basic Information', 'Location', 'Column Management', 'Position Management'), info row labels ('Church Name', 'Phone Number', 'Email', 'About the Church', 'Address', 'Latitude', 'Longitude'), button labels ('Edit', 'Edit Location', 'Add Column', 'Add Position'), snackbar messages
    - _Requirements: 3.1-3.3, 5.3, 7.1, 10.1-10.4_
  - [x] 12.2 Update `info_edit_drawer.dart` to use localized strings
    - Replace hardcoded drawer title ('Edit Church Information'), subtitle ('Update your church details'), section titles ('Basic Information'), form labels ('Church Name', 'Phone Number', 'Email', 'Description'), hints, button labels ('Save Changes')
    - _Requirements: 4.1-4.2, 5.1-5.2, 7.1, 11.1_
  - [x] 12.3 Update `location_edit_drawer.dart` to use localized strings
    - Replace hardcoded drawer title ('Edit Location'), subtitle, section titles ('Location Details'), form labels ('Address', 'Latitude', 'Longitude'), hints, button labels ('Save Changes')
    - _Requirements: 4.1-4.2, 5.1-5.2, 7.1, 11.1_
  - [x] 12.4 Update `column_edit_drawer.dart` to use localized strings
    - Replace hardcoded drawer title ('Add/Edit Column'), subtitle, section titles ('Basic Information', 'Registered Members'), form labels ('Column ID', 'Column Name'), hints, button labels ('Delete', 'Create', 'Save'), dialog content ('Delete Column', 'Are you sure...')
    - _Requirements: 4.1-4.2, 5.1-5.2, 7.1, 8.1-8.2, 11.1_
  - [x] 12.5 Update `position_edit_drawer.dart` to use localized strings
    - Replace hardcoded drawer title ('Add/Edit Position'), subtitle, section titles ('Position Information', 'Member in this Position'), form labels ('Position ID', 'Position Name'), hints, button labels ('Delete', 'Create', 'Save'), snackbar messages, dialog content ('Delete Position', 'Are you sure...')
    - _Requirements: 4.1-4.2, 5.1-5.2, 7.1, 8.1-8.2, 10.1, 11.1_

- [x] 13. Update document feature screens
  - [x] 13.1 Update `document_screen.dart` to use localized strings
    - Replace hardcoded page title ('Document Settings'), subtitle ('Manage document identity numbers...'), card titles ('Document Identity Number', 'Document Directory'), table headers ('Document Name', 'Account Number', 'Created Date'), drawer titles ('Edit Document Identity Number'), loading messages, button labels ('Edit', 'Save Changes')
    - _Requirements: 3.1-3.2, 4.1-4.2, 6.1, 7.1, 13.1_

- [x] 14. Update report feature screens
  - [x] 14.1 Update `report_screen.dart` to use localized strings
    - Replace hardcoded page title ('Reports'), subtitle ('Generate and view comprehensive report data...'), card titles ('Generate Report', 'Report History'), table headers ('Report Name', 'By', 'On', 'File'), generate card titles ('Incoming Document', 'Congregation', 'Services', 'Activity'), tooltips ('Download Report')
    - _Requirements: 3.1, 6.1, 10.1, 14.1_
  - [x] 14.2 Update `report_generate_drawer.dart` to use localized strings
    - Replace hardcoded drawer title ('Generate Report'), subtitle, section titles ('Report Details'), form labels ('Report Type', 'Description', 'Date Range'), loading messages ('Generating report...'), button labels ('Generate Report'), info text
    - _Requirements: 4.1-4.2, 5.1-5.2, 7.1, 13.1_

- [x] 15. Update dashboard feature screens
  - [x] 15.1 Update `dashboard_screen.dart` to use localized strings
    - Replace hardcoded stat card change text ('+X from last month'), time-relative strings in `_ActivityItem` ('X days ago', 'X hours ago', 'X minutes ago', 'Just now'), and recent activities subtitle text
    - Dashboard now fully uses `context.l10n` for all user-facing strings including titles, subtitles, and `_formatTimestamp` method
    - _Requirements: 3.2, 14.1, 18.1-18.3_

- [ ]* 15.2 Write property test for time pluralization
  - **Property 2: Time Pluralization Correctness**
  - **Validates: Requirements 18.1, 18.3**

- [ ]* 15.3 Write property test for time unit selection
  - **Property 3: Time Unit Selection**
  - **Validates: Requirements 18.1**

- [x] 16. Update core layout and navigation
  - [x] 16.1 Update `app_scaffold.dart` to use localized strings
    - Replace hardcoded sign out confirmation content ('Are you sure you want to sign out?'), footer copyright text ('© YEAR Palakat. All rights reserved.')
    - _Requirements: 8.4, 17.1_
  - [x] 16.2 Update `sidebar.dart` in palakat_shared to use localized strings
    - Already uses `context.l10n` for navigation labels
    - Replace hardcoded 'Palakat Admin' title and 'Admin User' placeholder with localized strings
    - _Requirements: 16.1-16.2_

- [x] 17. Update authentication screens
  - [x] 17.1 Update `signin_screen.dart` to use localized strings
    - Already uses localized strings via `context.l10n`
    - _Requirements: 11.1_

- [x] 18. Update main.dart
  - [x] 18.1 Update `main.dart` to use localized app title
    - Replace hardcoded "Palakat Admin" in MaterialApp title with localized string using `onGenerateTitle: (context) => context.l10n.appTitle_admin`
    - _Requirements: 16.1_

- [x] 19. Fix import conflicts with Column widget
  - Update all admin screen files to resolve ambiguous imports between Flutter's Column widget and the shared Column model
  - Add proper import hiding: `import 'package:palakat_shared/palakat_shared.dart' hide Column;` where needed
  - Ensure all files compile without errors
  - _Requirements: Technical debt resolution_

- [ ] 20. Update remaining screens with hardcoded strings
  - [ ] 20.1 Update `activity_screen.dart` to use localized strings
    - Replace hardcoded subtitle "Monitor and manage all church activity." with localized string
    - _Requirements: 1.4, 2.1_
  - [ ] 20.2 Update `activity_detail_drawer.dart` to use localized strings
    - Replace any remaining hardcoded strings with localized equivalents
    - _Requirements: 4.1-4.2, 5.1-5.3_
  - [ ] 20.3 Update `expense_screen.dart` to use localized strings
    - Replace hardcoded dropdown options 'Cash', 'Cashless' with localized strings
    - Add missing page title and subtitle using localized strings
    - _Requirements: 3.1-3.2, 6.1, 9.1_
  - [ ] 20.4 Update `expense_detail_drawer.dart` to use localized strings
    - Replace any remaining hardcoded strings with localized equivalents
    - _Requirements: 4.1-4.2, 5.1-5.3_
  - [ ] 20.5 Update `revenue_screen.dart` to use localized strings (if not already complete)
    - Verify all hardcoded strings are replaced with localized equivalents
    - _Requirements: 1.5, 3.1-3.2, 6.1_
  - [ ] 20.6 Update `revenue_detail_drawer.dart` to use localized strings (if not already complete)
    - Verify all hardcoded strings are replaced with localized equivalents
    - _Requirements: 4.1-4.2, 5.1-5.3_
  - [ ] 20.7 Update `report_screen.dart` to use localized strings (if not already complete)
    - Verify all hardcoded strings are replaced with localized equivalents
    - _Requirements: 3.1, 6.1_

- [ ] 21. Add missing localization keys to ARB files
  - [ ] 21.1 Add missing payment method localization keys to `intl_en.arb`
    - Add keys: `paymentMethod_cash`, `paymentMethod_cashless`
    - _Requirements: 9.1_
  - [ ] 21.2 Add missing activity subtitle key to `intl_en.arb`
    - Add key: `admin_activity_subtitle` with value "Monitor and manage all church activity."
    - _Requirements: 1.4, 2.1_
  - [ ] 21.3 Add missing expense screen keys to `intl_en.arb`
    - Add keys: `admin_expense_title`, `admin_expense_subtitle`
    - _Requirements: 3.1-3.2_
  - [ ] 21.4 Copy all new keys to `intl_id.arb` with Indonesian translations
    - Translate all newly added keys to Indonesian
    - _Requirements: 19.1-19.2_

- [ ] 22. Regenerate localization files after adding new keys
  - Run `melos run build:runner` to regenerate `app_localizations.dart` files
  - Verify no errors in generated code
  - _Requirements: 19.1_

- [ ] 23. Final Checkpoint - Ensure all tests pass and verify localization
  - Ensure all tests pass, ask the user if questions arise.
