# Requirements Document

## Introduction

This feature adds revenue and expense management capabilities to the Palakat mobile app's activity publishing flow. Users can attach financial records (revenue or expense) to activities during the publishing process. Additionally, a standalone screen allows users to create revenue/expense records and attach them to existing activities. The feature integrates with the existing backend API endpoints for revenue and expense management.

## Glossary

- **Revenue**: A financial record representing income associated with a church activity, containing amount, account number, payment method, and activity reference
- **Expense**: A financial record representing expenditure associated with a church activity, containing amount, account number, payment method, and activity reference
- **Activity**: A church event, service, or announcement that can have associated financial records
- **Payment Method**: The method of payment, either CASH or CASHLESS
- **Activity Publish Screen**: The existing screen for creating new activities (services, events, announcements)
- **Finance Type Picker**: A UI component allowing users to choose between adding revenue or expense
- **Activity Picker**: A UI component allowing users to select an existing activity to attach financial records

## Requirements

### Requirement 1

**User Story:** As a church supervisor, I want to add revenue or expense records while publishing an activity, so that I can track financial information associated with the activity.

#### Acceptance Criteria

1. WHEN the Activity Publish Screen is displayed for service or event types THEN the System SHALL display a "Financial Record" section with an option to add revenue or expense
2. WHEN the user taps the "Add Financial Record" button THEN the System SHALL display a Finance Type Picker dialog with "Revenue" and "Expense" options
3. WHEN the user selects a finance type THEN the System SHALL navigate to the Finance Create Screen with the selected type pre-configured
4. WHEN the Finance Create Screen returns with valid data THEN the System SHALL display the attached financial record summary in the Activity Publish Screen
5. WHEN the user removes an attached financial record THEN the System SHALL clear the financial data and restore the "Add Financial Record" button

### Requirement 2

**User Story:** As a church supervisor, I want to create revenue records with all required information, so that I can accurately track church income.

#### Acceptance Criteria

1. WHEN the Revenue Create Screen is displayed THEN the System SHALL show input fields for amount, account number, and payment method
2. WHEN the user enters an amount THEN the System SHALL validate that the amount is a positive integer
3. WHEN the user enters an account number THEN the System SHALL validate that the account number is not empty
4. WHEN the user selects a payment method THEN the System SHALL accept either CASH or CASHLESS values
5. WHEN all required fields are valid AND the user taps submit THEN the System SHALL return the revenue data to the calling screen

### Requirement 3

**User Story:** As a church supervisor, I want to create expense records with all required information, so that I can accurately track church expenditures.

#### Acceptance Criteria

1. WHEN the Expense Create Screen is displayed THEN the System SHALL show input fields for amount, account number, and payment method
2. WHEN the user enters an amount THEN the System SHALL validate that the amount is a positive integer
3. WHEN the user enters an account number THEN the System SHALL validate that the account number is not empty
4. WHEN the user selects a payment method THEN the System SHALL accept either CASH or CASHLESS values
5. WHEN all required fields are valid AND the user taps submit THEN the System SHALL return the expense data to the calling screen

### Requirement 4

**User Story:** As a church supervisor, I want to create standalone revenue or expense records attached to existing activities, so that I can add financial records to activities after they are published.

#### Acceptance Criteria

1. WHEN the standalone Finance Create Screen is accessed THEN the System SHALL display an Activity Picker field
2. WHEN the user taps the Activity Picker THEN the System SHALL display a searchable list of activities supervised by the current user
3. WHEN the user selects an activity THEN the System SHALL display the selected activity information in the picker field
4. WHEN the user submits a standalone financial record with a selected activity THEN the System SHALL call the backend API to create the record
5. WHEN the backend API returns success THEN the System SHALL navigate back and display a success message

### Requirement 5

**User Story:** As a church supervisor, I want the financial record creation to integrate with the activity publishing flow, so that the activity and its financial record are created together.

#### Acceptance Criteria

1. WHEN an activity with attached financial data is submitted THEN the System SHALL first create the activity via the backend API
2. WHEN the activity creation succeeds THEN the System SHALL create the financial record with the new activity ID
3. WHEN the financial record creation succeeds THEN the System SHALL display a success message indicating both records were created
4. IF the financial record creation fails after activity creation THEN the System SHALL display an error message but keep the activity created

### Requirement 6

**User Story:** As a church supervisor, I want clear visual feedback during financial record creation, so that I understand the current state of my input.

#### Acceptance Criteria

1. WHEN a form field has validation errors THEN the System SHALL display the error message below the field
2. WHEN the form is being submitted THEN the System SHALL display a loading indicator and disable the submit button
3. WHEN the submission fails THEN the System SHALL display an error message with a retry option
4. WHEN displaying currency amounts THEN the System SHALL format them with Indonesian Rupiah formatting (Rp prefix, thousand separators)

