# Requirements Document

## Introduction

This feature introduces a centralized Financial Account Number management system for the Palakat church management platform. Currently, account numbers are entered as free-text strings in Revenue, Expense, and Document records. This feature will create a dedicated `FinancialAccountNumber` model that allows churches to define and manage their account numbers with descriptions, enabling users to select from predefined account numbers via searchable dropdowns instead of manual text entry.

The feature spans three applications:
1. **Backend (NestJS)**: New `FinancialAccountNumber` model with CRUD operations
2. **Admin Panel (Flutter Web)**: New "Financial" menu under Administration for managing account numbers
3. **Mobile App (Flutter)**: Replace text inputs with searchable account number dropdowns and fix UX for confirming financial detail input

## Glossary

- **Financial_Account_Number**: A predefined account number record belonging to a church, containing an account number string and description
- **Church**: The organization entity that owns financial account numbers
- **Revenue**: Income record that references a financial account number
- **Expense**: Expenditure record that references a financial account number
- **Account_Number_Picker**: A searchable dropdown widget that allows users to select from predefined account numbers
- **Finance_Create_Screen**: The screen in the mobile app where users input financial details (revenue/expense) when publishing activities

## Requirements

### Requirement 1

**User Story:** As a church administrator, I want to manage a list of predefined financial account numbers, so that users can select from consistent account numbers when recording revenues and expenses.

#### Acceptance Criteria

1. WHEN an administrator navigates to the Financial menu in the Administration section THEN the Admin_Panel SHALL display a list of all financial account numbers for the church
2. WHEN an administrator clicks the "Add Account Number" button THEN the Admin_Panel SHALL display a form with fields for account number and description
3. WHEN an administrator submits a valid account number form THEN the System SHALL create a new Financial_Account_Number record associated with the church
4. WHEN an administrator edits an existing account number THEN the Admin_Panel SHALL display the edit form pre-populated with current values
5. WHEN an administrator deletes an account number THEN the System SHALL remove the Financial_Account_Number record from the database
6. WHEN displaying the account number list THEN the Admin_Panel SHALL show account number, description, and creation date for each entry

### Requirement 2

**User Story:** As a backend developer, I want a FinancialAccountNumber model with proper relationships, so that account numbers can be managed and referenced by financial records.

#### Acceptance Criteria

1. WHEN the database schema is updated THEN the Backend SHALL include a FinancialAccountNumber model with id, accountNumber, description, churchId, createdAt, and updatedAt fields
2. WHEN a FinancialAccountNumber is created THEN the Backend SHALL establish a many-to-one relationship with Church
3. WHEN a Revenue record references an account number THEN the Backend SHALL support an optional one-to-one relationship between Revenue and FinancialAccountNumber
4. WHEN an Expense record references an account number THEN the Backend SHALL support an optional one-to-one relationship between Expense and FinancialAccountNumber
5. WHEN a CRUD operation is performed on FinancialAccountNumber THEN the Backend SHALL validate that the account number is unique within the same church
6. WHEN listing financial account numbers THEN the Backend SHALL support filtering by churchId and searching by account number or description

### Requirement 3

**User Story:** As a mobile app user, I want to select account numbers from a searchable dropdown, so that I can quickly find and use the correct account number when recording financial transactions.

#### Acceptance Criteria

1. WHEN a user opens the Finance_Create_Screen THEN the Mobile_App SHALL display an Account_Number_Picker instead of a text input field
2. WHEN a user taps the Account_Number_Picker THEN the Mobile_App SHALL display a searchable list of available account numbers
3. WHEN a user types in the search field THEN the Account_Number_Picker SHALL filter results by matching account number or description
4. WHEN a user selects an account number THEN the Account_Number_Picker SHALL display the account number prominently with the description below it
5. WHEN no matching account numbers are found THEN the Account_Number_Picker SHALL display a "No results found" message

### Requirement 4

**User Story:** As a mobile app user, I want a clear confirmation button when attaching financial details to an activity, so that I know how to complete the financial input process.

#### Acceptance Criteria

1. WHEN a user is on the Finance_Create_Screen in embedded mode THEN the Mobile_App SHALL display a prominent "Confirm" or "Add" button at the bottom
2. WHEN a user taps the confirm button with valid input THEN the Mobile_App SHALL return the financial data to the activity publish screen
3. WHEN a user taps the confirm button with invalid input THEN the Mobile_App SHALL display validation errors and remain on the screen
4. WHEN the confirm button is displayed THEN the Mobile_App SHALL use clear labeling that indicates the action will attach the financial record to the activity

### Requirement 5

**User Story:** As a system administrator, I want the API to provide endpoints for managing financial account numbers, so that client applications can perform CRUD operations.

#### Acceptance Criteria

1. WHEN a GET request is made to /financial-account-number THEN the Backend SHALL return a paginated list of account numbers for the authenticated user's church
2. WHEN a POST request is made to /financial-account-number with valid data THEN the Backend SHALL create a new account number and return the created record
3. WHEN a PATCH request is made to /financial-account-number/:id THEN the Backend SHALL update the specified account number and return the updated record
4. WHEN a DELETE request is made to /financial-account-number/:id THEN the Backend SHALL delete the specified account number and return success status
5. WHEN a GET request includes a search query parameter THEN the Backend SHALL filter results by account number or description containing the search term
