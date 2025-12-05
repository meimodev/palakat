# Requirements Document

## Introduction

This specification covers three related improvements to the Palakat church management platform:

1. **Announcement Activity Financial Support**: Enable announcement-type activities to include optional financial records (expense or revenue), extending the existing financial capability from service/event activities to announcements.

2. **Admin Panel Inventory Removal**: Remove the unused inventory feature from the palakat_admin web application to simplify the codebase and navigation.

3. **Mobile Approval Screen Redesign**: Redesign the approval screen in the palakat mobile app to provide users with quick and easy access to manage activities based on their approval status, improving workflow efficiency.

## Glossary

- **Activity**: A church event, service, or announcement that may require approval and optionally include financial records
- **ActivityType**: Enum with values SERVICE, EVENT, ANNOUNCEMENT
- **Approval**: The process by which designated approvers confirm or reject an activity
- **Approver**: A church member assigned to approve/reject an activity
- **ApprovalStatus**: Enum with values UNCONFIRMED, APPROVED, REJECTED
- **Financial Record**: Either a Revenue or Expense record linked to an activity
- **FinancialType**: Enum with values REVENUE, EXPENSE
- **Supervisor**: The membership who creates and owns an activity
- **Palakat Admin**: The Flutter web admin panel application
- **Palakat App**: The Flutter mobile application for church members

## Requirements

### Requirement 1: Announcement Activity Financial Support

**User Story:** As a church administrator, I want to attach financial records (expense or revenue) to announcement-type activities, so that I can track financial transactions associated with announcements like fundraising campaigns or special collections.

#### Acceptance Criteria

1.1. WHEN a user creates an activity with activityType ANNOUNCEMENT THEN the System SHALL accept an optional finance object containing type, accountNumber, amount, paymentMethod, and financialAccountNumberId fields

1.2. WHEN a user creates an ANNOUNCEMENT activity with a finance object THEN the System SHALL create the corresponding Revenue or Expense record linked to the activity

1.3. WHEN a user queries activities with hasExpense or hasRevenue filters THEN the System SHALL return ANNOUNCEMENT activities that match the financial filter criteria

1.4. WHEN a user retrieves an ANNOUNCEMENT activity detail THEN the System SHALL include the linked financial record data (revenue or expense) in the response

1.5. WHEN an ANNOUNCEMENT activity with financial data is created THEN the System SHALL resolve approvers based on both activityType and financialAccountNumberId if provided

### Requirement 2: Admin Panel Inventory Feature Removal

**User Story:** As a development team member, I want to remove the unused inventory feature from the admin panel, so that the codebase is cleaner and users are not confused by non-functional menu items.

#### Acceptance Criteria

2.1. WHEN a user navigates the admin panel THEN the System SHALL display navigation without an inventory menu item

2.2. WHEN a user attempts to access the /inventory route directly THEN the System SHALL redirect to the dashboard or show a 404 page

2.3. WHEN the admin panel loads THEN the System SHALL operate without any inventory-related imports or dependencies

2.4. WHEN viewing the dashboard THEN the System SHALL display statistics without inventory-related cards or data

2.5. WHEN generating reports THEN the System SHALL display report options without an inventory report option

### Requirement 3: Mobile Approval Screen Redesign

**User Story:** As a church member with approval responsibilities, I want a redesigned approval screen that lets me quickly see and act on pending approvals, so that I can efficiently manage my approval tasks.

#### Acceptance Criteria

3.1. WHEN a user opens the approval screen THEN the System SHALL display activities grouped or filterable by approval status (pending my action, pending others, approved, rejected)

3.2. WHEN a user views the approval screen THEN the System SHALL prominently highlight activities that require the current user's action at the top or in a dedicated section

3.3. WHEN a user views an activity card THEN the System SHALL display the activity title, supervisor name, date, activity type, and overall approval status

3.4. WHEN a user has pending approval actions THEN the System SHALL display approve and reject action buttons directly on the activity card for quick action

3.5. WHEN a user taps approve or reject on an activity card THEN the System SHALL update the approval status and refresh the list without requiring navigation to a detail screen

3.6. WHEN a user filters activities by date range THEN the System SHALL filter the displayed activities accordingly while maintaining the status grouping

3.7. WHEN a user views the approval screen THEN the System SHALL display a count badge or summary showing the number of pending approvals requiring the user's action

3.8. WHEN the approval screen loads THEN the System SHALL fetch real activity data from the backend API instead of using dummy data

3.9. WHEN an activity has financial data attached THEN the System SHALL display a visual indicator (icon or badge) showing whether it has revenue or expense

3.10. WHEN a user pulls to refresh the approval screen THEN the System SHALL reload the approval data from the backend

