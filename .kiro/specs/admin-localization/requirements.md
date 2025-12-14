# Requirements Document

## Introduction

This document specifies the requirements for completing the localization of the Palakat Admin web application. The admin panel currently has approximately 300+ hardcoded English strings that need to be moved to the existing localization system (ARB files in `packages/palakat_shared/lib/l10n/`). The goal is to ensure all user-facing text in the admin panel is translatable, supporting both English (en) and Indonesian (id) languages.

## Glossary

- **ARB File**: Application Resource Bundle file format used by Flutter for localization
- **l10n**: Abbreviation for "localization"
- **Hardcoded String**: A text string directly embedded in source code rather than loaded from a localization resource
- **Localization Key**: A unique identifier used to reference a translated string in ARB files
- **palakat_admin**: The Flutter web admin panel application
- **palakat_shared**: The shared package containing common code including localization files

## Requirements

### Requirement 1: Screen Headers and Page Titles

**User Story:** As an admin user, I want all screen headers and page titles to be displayed in my preferred language, so that I can navigate the application comfortably.

#### Acceptance Criteria

1. WHEN the Billing Management screen loads THEN the System SHALL display the page title using the localized string `admin_billing_title`
2. WHEN the Approvals screen loads THEN the System SHALL display the page title using the localized string `admin_approval_title`
3. WHEN the Account screen loads THEN the System SHALL display the page title using the localized string `admin_account_title`
4. WHEN the Activity screen loads THEN the System SHALL display the page title using the localized string `admin_activity_title`
5. WHEN the Revenue screen loads THEN the System SHALL display the page title using the localized string `admin_revenue_title`
6. WHEN the Member screen loads THEN the System SHALL display the page title using the localized string `admin_member_title`
7. WHEN the Financial Account Numbers screen loads THEN the System SHALL display the page title using the localized string `admin_financial_title`

### Requirement 2: Screen Subtitles and Descriptions

**User Story:** As an admin user, I want all screen subtitles and descriptions to be displayed in my preferred language, so that I understand the purpose of each section.

#### Acceptance Criteria

1. WHEN the Billing Management screen loads THEN the System SHALL display the subtitle using the localized string `admin_billing_subtitle`
2. WHEN the Account screen loads THEN the System SHALL display the subtitle using the localized string `admin_account_subtitle`
3. WHEN the Financial Account Numbers screen loads THEN the System SHALL display the subtitle using the localized string `admin_financial_subtitle`

### Requirement 3: Card Titles and Subtitles

**User Story:** As an admin user, I want all card titles and subtitles (SurfaceCard, ExpandableSurfaceCard) to be displayed in my preferred language, so that I can understand the content of each section.

#### Acceptance Criteria

1. WHEN a SurfaceCard or ExpandableSurfaceCard is rendered THEN the System SHALL display the title using a localized string
2. WHEN a SurfaceCard or ExpandableSurfaceCard is rendered THEN the System SHALL display the subtitle using a localized string
3. WHEN the church management cards are displayed THEN the System SHALL use localized strings for "Basic Information", "Location", "Column Management", and "Position Management"

### Requirement 4: Drawer Titles and Subtitles

**User Story:** As an admin user, I want all drawer (SideDrawer) titles and subtitles to be displayed in my preferred language, so that I understand the context of the form I am working with.

#### Acceptance Criteria

1. WHEN a SideDrawer opens for adding or editing content THEN the System SHALL display the title using a localized string
2. WHEN a SideDrawer opens for adding or editing content THEN the System SHALL display the subtitle using a localized string
3. WHEN the member edit drawer opens THEN the System SHALL display "Add Member" or "Edit Member" using localized strings based on the mode

### Requirement 5: Form Labels and Field Names

**User Story:** As an admin user, I want all form labels and field names to be displayed in my preferred language, so that I can fill out forms correctly.

#### Acceptance Criteria

1. WHEN a form is displayed THEN the System SHALL render all LabeledField labels using localized strings
2. WHEN a form is displayed THEN the System SHALL render all InfoSection titles using localized strings
3. WHEN a form is displayed THEN the System SHALL render all InfoRow labels using localized strings

### Requirement 6: Table Column Headers

**User Story:** As an admin user, I want all table column headers to be displayed in my preferred language, so that I can understand the data being presented.

#### Acceptance Criteria

1. WHEN a data table is rendered THEN the System SHALL display all AppTableColumn titles using localized strings
2. WHEN the billing table is displayed THEN the System SHALL use localized strings for "Bill ID", "Description", "Amount", "Due Date", "Status"
3. WHEN the member table is displayed THEN the System SHALL use localized strings for "Name", "Phone", "Birth", "BIPRA", "Positions"

### Requirement 7: Button Labels

**User Story:** As an admin user, I want all button labels to be displayed in my preferred language, so that I understand the actions I can take.

#### Acceptance Criteria

1. WHEN action buttons are rendered THEN the System SHALL display labels using localized strings
2. WHEN the "Add Account Number" button is displayed THEN the System SHALL use the localized string `btn_addAccountNumber`
3. WHEN the "Record Payment" button is displayed THEN the System SHALL use the localized string `btn_recordPayment`
4. WHEN the "Export Receipt" button is displayed THEN the System SHALL use the localized string `btn_exportReceipt`
5. WHEN the "Create" or "Update" buttons are displayed THEN the System SHALL use localized strings `btn_create` and `btn_update`

### Requirement 8: Dialog Titles and Content

**User Story:** As an admin user, I want all dialog titles and content to be displayed in my preferred language, so that I understand confirmation prompts and warnings.

#### Acceptance Criteria

1. WHEN a confirmation dialog is displayed THEN the System SHALL render the title using a localized string
2. WHEN a confirmation dialog is displayed THEN the System SHALL render the content message using a localized string
3. WHEN the delete confirmation dialog is displayed THEN the System SHALL use localized strings for "Delete Rule", "Delete Member", "Delete Position"
4. WHEN the sign out confirmation dialog is displayed THEN the System SHALL use the localized string for "Are you sure you want to sign out?"

### Requirement 9: Dropdown and Filter Options

**User Story:** As an admin user, I want all dropdown options and filter labels to be displayed in my preferred language, so that I can filter and select options correctly.

#### Acceptance Criteria

1. WHEN dropdown menus are rendered THEN the System SHALL display option labels using localized strings
2. WHEN the status filter dropdown is displayed THEN the System SHALL use the localized string for "All Status"
3. WHEN the activity type filter is displayed THEN the System SHALL use the localized string for "All activity types"
4. WHEN the financial filter is displayed THEN the System SHALL use the localized string for "No financial filter"

### Requirement 10: Snackbar and Toast Messages

**User Story:** As an admin user, I want all snackbar and toast messages to be displayed in my preferred language, so that I understand the result of my actions.

#### Acceptance Criteria

1. WHEN a success snackbar is displayed THEN the System SHALL render the message using a localized string
2. WHEN an error snackbar is displayed THEN the System SHALL render the message using a localized string
3. WHEN a record is saved successfully THEN the System SHALL display a localized success message
4. WHEN a record is deleted successfully THEN the System SHALL display a localized success message

### Requirement 11: Form Hints and Placeholders

**User Story:** As an admin user, I want all form hints and placeholders to be displayed in my preferred language, so that I understand what input is expected.

#### Acceptance Criteria

1. WHEN a text input field is rendered THEN the System SHALL display the hint text using a localized string
2. WHEN a search field is rendered THEN the System SHALL display the search hint using a localized string
3. WHEN the account number field is displayed THEN the System SHALL use the localized string for "Enter account number"

### Requirement 12: Validation Messages

**User Story:** As an admin user, I want all validation error messages to be displayed in my preferred language, so that I understand what corrections are needed.

#### Acceptance Criteria

1. WHEN form validation fails THEN the System SHALL display error messages using localized strings
2. WHEN a required field is empty THEN the System SHALL display the localized string for "This field is required" or a field-specific message
3. WHEN password validation fails THEN the System SHALL display localized messages for password requirements

### Requirement 13: Loading and Error States

**User Story:** As an admin user, I want all loading and error state messages to be displayed in my preferred language, so that I understand the current state of the application.

#### Acceptance Criteria

1. WHEN data is loading THEN the System SHALL display loading messages using localized strings
2. WHEN data loading fails THEN the System SHALL display error messages using localized strings
3. WHEN no data is available THEN the System SHALL display the localized string for "No data available" or a context-specific message

### Requirement 14: Tooltips

**User Story:** As an admin user, I want all tooltips to be displayed in my preferred language, so that I understand the purpose of UI elements.

#### Acceptance Criteria

1. WHEN a tooltip is displayed THEN the System SHALL render the tooltip text using a localized string
2. WHEN the refresh button tooltip is displayed THEN the System SHALL use the localized string for "Refresh"
3. WHEN the "View Activity Details" tooltip is displayed THEN the System SHALL use a localized string

### Requirement 15: Checkbox and Toggle Labels

**User Story:** As an admin user, I want all checkbox and toggle labels to be displayed in my preferred language, so that I understand the options I am selecting.

#### Acceptance Criteria

1. WHEN a checkbox or toggle is rendered THEN the System SHALL display the label using a localized string
2. WHEN the "Active" toggle is displayed THEN the System SHALL use the localized string `lbl_active`
3. WHEN the "Baptized" and "SIDI" checkboxes are displayed THEN the System SHALL use localized strings

### Requirement 16: Sidebar and Navigation

**User Story:** As an admin user, I want the sidebar header and user display name placeholder to be displayed in my preferred language, so that the navigation is consistent with my language preference.

#### Acceptance Criteria

1. WHEN the sidebar is rendered THEN the System SHALL display "Palakat Admin" using the localized string `appTitle_admin`
2. WHEN the user display name is not available THEN the System SHALL display a localized placeholder string

### Requirement 17: Footer and Copyright

**User Story:** As an admin user, I want the footer and copyright text to be displayed in my preferred language, so that the entire application is consistently localized.

#### Acceptance Criteria

1. WHEN the footer is rendered THEN the System SHALL display the copyright text using a localized string with year interpolation

### Requirement 18: Time-Relative Strings

**User Story:** As an admin user, I want time-relative strings (e.g., "2 days ago", "Just now") to be displayed in my preferred language, so that I understand when events occurred.

#### Acceptance Criteria

1. WHEN a relative time is displayed THEN the System SHALL use localized strings with proper pluralization
2. WHEN an event occurred less than a minute ago THEN the System SHALL display the localized string for "Just now"
3. WHEN an event occurred days ago THEN the System SHALL display the localized string with proper day/days pluralization

### Requirement 19: Indonesian Language Support

**User Story:** As an Indonesian-speaking admin user, I want all newly localized strings to have Indonesian translations, so that I can use the application in my native language.

#### Acceptance Criteria

1. WHEN a new localization key is added to `intl_en.arb` THEN the System SHALL have a corresponding entry in `intl_id.arb`
2. WHEN the application language is set to Indonesian THEN the System SHALL display all admin-specific strings in Indonesian
