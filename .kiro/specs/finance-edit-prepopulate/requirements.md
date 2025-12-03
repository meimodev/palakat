# Requirements Document

## Introduction

This feature enables pre-population of the Finance Create Screen with previously filled values when editing an attached financial record from the Activity Publish Screen. Currently, when a user edits an attached financial record, the Finance Create Screen opens with empty fields, requiring the user to re-enter all information. This enhancement improves user experience by preserving the previously entered data.

## Glossary

- **Finance Create Screen**: The screen used to create or edit revenue/expense records
- **Activity Publish Screen**: The screen where users create activities and can attach financial records
- **FinanceData**: A data transfer object containing financial record information (type, amount, account number, payment method)
- **FinancialAccountNumber**: A predefined account number record from the church's chart of accounts
- **Embedded Mode**: When Finance Create Screen is opened from Activity Publish Screen (not standalone)

## Requirements

### Requirement 1

**User Story:** As a church member, I want to edit an attached financial record and see my previously entered values, so that I can make corrections without re-entering all information.

#### Acceptance Criteria

1. WHEN a user taps the edit button on an attached financial record THEN the Finance Create Screen SHALL display the previously entered amount value in the amount field
2. WHEN a user taps the edit button on an attached financial record THEN the Finance Create Screen SHALL display the previously selected account number in the account picker
3. WHEN a user taps the edit button on an attached financial record THEN the Finance Create Screen SHALL display the previously selected payment method in the payment method picker
4. WHEN the Finance Create Screen receives initial finance data THEN the Finance Create Screen SHALL validate that the initial data contains all required fields before populating

### Requirement 2

**User Story:** As a church member, I want the edit flow to feel seamless, so that I can quickly modify financial details without confusion.

#### Acceptance Criteria

1. WHEN the Finance Create Screen is opened with initial data THEN the form SHALL be immediately valid if all required fields are populated
2. WHEN the Finance Create Screen is opened with initial data THEN the submit button SHALL be enabled if the form is valid
3. WHEN a user modifies any pre-populated field THEN the Finance Create Screen SHALL update validation state in real-time

### Requirement 3

**User Story:** As a church member, I want to confirm before deleting an attached financial record, so that I can avoid accidental data loss.

#### Acceptance Criteria

1. WHEN a user taps the remove button on an attached financial record THEN the Activity Publish Screen SHALL display a confirmation dialog
2. WHEN the confirmation dialog is displayed THEN the dialog SHALL show a clear message asking the user to confirm deletion
3. WHEN the user confirms deletion in the dialog THEN the Activity Publish Screen SHALL remove the attached financial record
4. WHEN the user cancels deletion in the dialog THEN the Activity Publish Screen SHALL keep the attached financial record unchanged

