# Requirements Document

## Introduction

This feature addresses overflow issues in the financial account picker component used in the approval edit drawer. The current implementation uses a standard DropdownButtonFormField that cannot properly display financial account numbers with the format "1.2.22.44" along with their descriptions. The solution involves adapting the existing InputWidget from the palakat mobile app (which already supports custom widget builders) to work in palakat_admin by moving it to the palakat_shared package with theme-based styling, and updating the database seeder to use realistic hierarchical account number formats.

## Glossary

- **Financial Account Number**: A hierarchical accounting code (e.g., "1.2.22.44") used to categorize revenues and expenses in church financial management
- **InputWidget**: An existing Flutter widget in palakat app that provides text, dropdown, and binary option input variants with custom display builder support
- **Custom Display Builder**: A callback function (`Widget Function(T value)`) that allows rendering a custom widget instead of the default text display for selected values
- **Approval Edit Drawer**: A side drawer component in palakat_admin used to create and edit approval rules
- **palakat_shared**: A shared Flutter package containing models, services, and widgets used by both palakat mobile app and palakat_admin
- **Theme-based Styling**: Using `Theme.of(context)` to obtain colors and text styles instead of hardcoded constants

## Requirements

### Requirement 1

**User Story:** As an admin user, I want to see financial account numbers displayed without overflow, so that I can clearly identify and select the correct account when configuring approval rules.

#### Acceptance Criteria

1. WHEN a financial account number is displayed in the picker THEN the system SHALL render the account number and description without text overflow or truncation that obscures critical information
2. WHEN the financial account picker shows a selected value THEN the system SHALL display the account number prominently with the description on a separate line or in a secondary style
3. WHEN the dropdown list shows available accounts THEN the system SHALL display each account with proper spacing and visual hierarchy between account number and description

### Requirement 2

**User Story:** As a developer, I want to move the existing InputWidget from palakat to palakat_shared, so that both apps can use the same flexible input component with custom display support.

#### Acceptance Criteria

1. WHEN the InputWidget is moved to palakat_shared THEN the system SHALL refactor styling to use theme-based colors from `Theme.of(context)` instead of hardcoded BaseColor constants
2. WHEN the InputWidget is moved to palakat_shared THEN the system SHALL maintain the existing API including text, dropdown, and binaryOption constructors
3. WHEN the InputWidget dropdown variant is used with customDisplayBuilder THEN the system SHALL render the custom widget for the selected value display
4. WHEN the palakat app imports the shared InputWidget THEN the system SHALL maintain visual consistency with the current design through theme configuration

### Requirement 3

**User Story:** As a developer, I want backward compatibility when migrating to the shared InputWidget, so that existing code in both apps continues to work without breaking changes.

#### Acceptance Criteria

1. WHEN existing palakat code uses InputWidget.text THEN the system SHALL continue to function with identical behavior after migration
2. WHEN existing palakat code uses InputWidget.dropdown THEN the system SHALL continue to function with identical behavior after migration
3. WHEN existing palakat code uses InputWidget.binaryOption THEN the system SHALL continue to function with identical behavior after migration

### Requirement 4

**User Story:** As a developer, I want the database seeder to use realistic hierarchical account numbers, so that test data accurately represents real-world financial account structures.

#### Acceptance Criteria

1. WHEN the seeder creates financial account numbers THEN the system SHALL use hierarchical format with dot separators (e.g., "1.2.22.44" for income, "2.1.01.01" for expense)
2. WHEN generating income accounts THEN the system SHALL use account numbers starting with "1" following the specified accounting conventions
3. WHEN generating expense accounts THEN the system SHALL use account numbers starting with "2" following the specified accounting conventions
4. WHEN the seeder runs THEN the system SHALL create accounts with varying hierarchy depths (2-4 levels) to test display flexibility

### Requirement 5

**User Story:** As an admin user, I want the financial account picker to show a clear visual distinction between account number and description, so that I can quickly scan and identify accounts.

#### Acceptance Criteria

1. WHEN displaying a financial account in the picker THEN the system SHALL show the account number in a monospace or semi-bold font style
2. WHEN displaying a financial account with a description THEN the system SHALL show the description in a secondary text style below or after the account number
3. WHEN the account has no description THEN the system SHALL display only the account number without placeholder text
