# Requirements Document

## Introduction

This feature consolidates custom UI widgets from the `palakat` mobile app and `palakat_admin` web app into the `palakat_shared` package for consistency and centralized control. Additionally, it enforces a unique constraint ensuring that each financial account number can only be linked to one approval rule, preventing duplicate assignments.

## Glossary

- **Palakat**: The Flutter mobile application for church members
- **Palakat Admin**: The Flutter web admin dashboard for church staff
- **Palakat Shared**: The shared Flutter package containing common code, models, and widgets
- **Widget**: A reusable UI component in Flutter
- **Financial Account Number**: A unique account identifier used for tracking church revenues and expenses
- **Approval Rule**: A configurable rule that determines which positions must approve activities or financial transactions
- **Prisma**: The ORM used in the NestJS backend for database operations

## Requirements

### Requirement 1: Widget Migration to Shared Package

**User Story:** As a developer, I want all custom widgets consolidated in the shared package, so that I can maintain consistency across both apps and have centralized control over UI components.

#### Acceptance Criteria

1. WHEN a widget exists in both palakat and palakat_admin apps, THE Shared Package SHALL contain a single unified implementation of that widget
2. WHEN a widget is mobile-specific (e.g., bottom navbar, mobile scaffold), THE Shared Package SHALL organize it in a platform-specific subdirectory
3. WHEN a widget is migrated to the shared package, THE palakat app SHALL import the widget from palakat_shared instead of local definitions
4. WHEN a widget is migrated to the shared package, THE palakat_admin app SHALL import the widget from palakat_shared instead of local definitions
5. WHEN all widgets are migrated, THE palakat app core/widgets directory SHALL contain only re-exports or platform-specific wrappers

### Requirement 2: Widget Organization Structure

**User Story:** As a developer, I want widgets organized by category in the shared package, so that I can easily find and maintain related components.

#### Acceptance Criteria

1. WHEN widgets are organized, THE Shared Package SHALL group widgets by functional category (input, button, card, dialog, loading, error, layout)
2. WHEN a new widget category is added, THE Shared Package SHALL provide a barrel export file for that category
3. WHEN the widgets barrel file is updated, THE Shared Package SHALL export all widget categories through a single widgets.dart file

### Requirement 3: Financial Account Number Unique Constraint

**User Story:** As a church administrator, I want each financial account number to be linked to only one approval rule, so that financial approval workflows remain clear and unambiguous.

#### Acceptance Criteria

1. WHEN a financial account number is already linked to an approval rule, THE Backend SHALL reject attempts to link the same account to another rule
2. WHEN creating an approval rule with a financial account number, THE Backend SHALL validate that the account is not already linked to another rule
3. WHEN updating an approval rule to use a financial account number, THE Backend SHALL validate that the account is not already linked to a different rule
4. WHEN the database schema is updated, THE FinancialAccountNumber model SHALL have a unique constraint on the approval rule relationship
5. IF a duplicate financial account link is attempted, THEN THE Backend SHALL return a clear error message indicating the account is already assigned

### Requirement 4: Seed Data Compliance

**User Story:** As a developer, I want the seed data to comply with the unique financial account constraint, so that the development database reflects production constraints.

#### Acceptance Criteria

1. WHEN seeding approval rules, THE Seed Script SHALL assign each financial account number to at most one approval rule
2. WHEN seeding financial data, THE Seed Script SHALL verify no duplicate financial account assignments exist
3. WHEN the seed script completes, THE Database SHALL contain approval rules with unique financial account number assignments

### Requirement 5: Frontend Validation for Financial Account Selection

**User Story:** As an admin user, I want the financial account picker to show only available accounts, so that I cannot accidentally select an account already assigned to another rule.

#### Acceptance Criteria

1. WHEN displaying financial accounts in the approval rule form, THE Financial Account Picker SHALL filter out accounts already linked to other approval rules
2. WHEN editing an existing approval rule, THE Financial Account Picker SHALL include the currently assigned account in the available options
3. WHEN no available financial accounts exist, THE Financial Account Picker SHALL display an appropriate message indicating all accounts are assigned

### Requirement 6: Financial Type Requires Financial Account Number

**User Story:** As a church administrator, I want the system to require a financial account number when a financial type is selected for an approval rule, so that financial workflows are always properly linked to specific accounts.

#### Acceptance Criteria

1. WHEN creating an approval rule with a financial type selected, THE Backend SHALL reject the request if no financial account number is provided
2. WHEN updating an approval rule to add a financial type, THE Backend SHALL reject the request if no financial account number is provided
3. WHEN a financial type is selected in the approval rule form, THE Admin Panel SHALL display the financial account number field as required
4. IF a user attempts to save an approval rule with a financial type but no financial account number, THEN THE Admin Panel SHALL display a validation error message

### Requirement 7: Searchable Financial Account Picker

**User Story:** As an admin user, I want to search financial accounts by description or name, so that I can quickly find the correct account when there are many options.

#### Acceptance Criteria

1. WHEN the financial account picker is displayed, THE Picker SHALL provide a search input field
2. WHEN a user types in the search field, THE Picker SHALL filter accounts by matching the description field
3. WHEN no accounts match the description search, THE Picker SHALL fallback to matching by account number
4. WHEN search results are displayed, THE Picker SHALL show matching accounts in a scrollable list

### Requirement 8: Searchable Membership Positions Picker

**User Story:** As an admin user, I want to search membership positions by name, so that I can quickly find the correct position when there are many options.

#### Acceptance Criteria

1. WHEN the position selector dropdown is displayed, THE Selector SHALL provide a search input field
2. WHEN a user types in the search field, THE Selector SHALL filter positions by matching the position name
3. WHEN search results are displayed, THE Selector SHALL show matching positions in a scrollable list

### Requirement 9: Financial Account Approval Rule Display

**User Story:** As an admin user, I want to see which approval rule is connected to each financial account number on the financial page, so that I can easily understand the approval workflow for each account.

#### Acceptance Criteria

1. WHEN displaying the financial account numbers table, THE Admin Panel SHALL NOT display the created date column
2. WHEN displaying the financial account numbers table, THE Admin Panel SHALL display a column showing the linked approval rule name
3. WHEN a financial account is not linked to any approval rule, THE Admin Panel SHALL display a clear indicator (e.g., "-" or "Not assigned")
4. WHEN a financial account is linked to an approval rule, THE Admin Panel SHALL display the approval rule name in the linked rule column
