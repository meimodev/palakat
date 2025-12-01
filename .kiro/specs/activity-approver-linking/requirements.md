# Requirements Document

## Introduction

This feature implements automatic linking of activity approvers based on approval rules when creating activities. The system will automatically assign approvers to newly created activities by matching the activity type and financial data (if applicable) with configured approval rules within the same church. This ensures consistent approval workflows and reduces manual approver assignment.

## Glossary

- **Activity**: A church event, service, or announcement that may require approval from designated members
- **Approver**: A church member assigned to approve or reject an activity
- **Approval Rule**: A configuration that defines which membership positions are responsible for approving certain types of activities
- **Membership Position**: A role or title held by a church member (e.g., Penatua, Bendahara, Sekretaris)
- **Activity Type**: Classification of activity (SERVICE, EVENT, ANNOUNCEMENT)
- **Financial Account Number**: A categorized account code used for tracking revenue or expense transactions
- **Financial Type**: Classification of financial data (REVENUE, EXPENSE)
- **Bipra**: Church organizational unit classification (PKB, WKI, PMD, RMJ, ASM)

## Requirements

### Requirement 1

**User Story:** As a church administrator, I want approval rules to be linked to specific activity types, so that the correct approvers are automatically assigned based on the type of activity being created.

#### Acceptance Criteria

1. WHEN an approval rule is created or updated THEN the ApprovalRule model SHALL support an optional activityType field that links to ActivityType enum values
2. WHEN an activity is created with a specific activityType THEN the system SHALL query approval rules that match the activity's activityType within the same church
3. WHEN no approval rules match the activityType THEN the system SHALL fall back to approval rules without an activityType filter within the same church
4. WHEN multiple approval rules match the activityType THEN the system SHALL use all matching active approval rules to determine approvers

### Requirement 2

**User Story:** As a church administrator, I want approval rules to support financial type filtering, so that activities with financial data are routed to the appropriate financial approvers.

#### Acceptance Criteria

1. WHEN an approval rule is created or updated THEN the ApprovalRule model SHALL support an optional financialType field that links to FinancialType enum values (REVENUE, EXPENSE)
2. WHEN an activity with revenue data is created THEN the system SHALL identify approval rules that have financialType set to REVENUE
3. WHEN an activity with expense data is created THEN the system SHALL identify approval rules that have financialType set to EXPENSE
4. WHEN an activity has no financial data THEN the system SHALL exclude approval rules that have a financialType filter from consideration

### Requirement 3

**User Story:** As a church administrator, I want approval rules to support financial account number filtering, so that activities with specific account numbers are routed to specialized approvers.

#### Acceptance Criteria

1. WHEN an approval rule is created or updated THEN the ApprovalRule model SHALL support an optional relation to FinancialAccountNumber
2. WHEN an activity with financial data is created THEN the system SHALL match the activity's financial account number with approval rules that have the same financialAccountNumber
3. WHEN an approval rule has both financialType and financialAccountNumber THEN the system SHALL require both conditions to match for the rule to apply
4. WHEN an approval rule has financialType but no financialAccountNumber THEN the system SHALL apply the rule to all activities with matching financialType regardless of account number

### Requirement 4

**User Story:** As a church administrator, I want approvers to be automatically linked when creating an activity, so that I do not need to manually assign approvers for each activity.

#### Acceptance Criteria

1. WHEN an activity is created THEN the system SHALL first identify approval rules that match the activity's activityType within the same church
2. WHEN activity type matching approval rules are found THEN the system SHALL retrieve all membership positions linked to those approval rules as base approvers
3. WHEN the activity includes financial data (revenue or expense) THEN the system SHALL additionally identify approval rules that match the financial account number
4. WHEN financial account number matching approval rules are found THEN the system SHALL add the membership positions from those rules to the approvers list
5. WHEN membership positions are collected from both activity type and financial rules THEN the system SHALL deduplicate the membership positions to prevent duplicate approvers
6. WHEN membership positions are deduplicated THEN the system SHALL find all memberships that hold those positions within the same church
7. WHEN memberships are found THEN the system SHALL create Approver records linking those memberships to the newly created activity
8. WHEN the activity supervisor holds a matching membership position THEN the system SHALL include the supervisor as an approver (self-approval scenario)
9. WHEN no matching approval rules are found THEN the system SHALL create the activity without any approvers

### Requirement 5

**User Story:** As a developer, I want the database seeder to reflect the new approval rule structure, so that test data demonstrates the complete approval workflow.

#### Acceptance Criteria

1. WHEN the seeder creates approval rules THEN the seeder SHALL assign activityType values to a subset of approval rules
2. WHEN the seeder creates approval rules THEN the seeder SHALL assign financialType values to a subset of approval rules
3. WHEN the seeder creates approval rules with financialType THEN the seeder SHALL optionally link financialAccountNumber to demonstrate account-specific routing
4. WHEN the seeder creates activities THEN the seeder SHALL use the new automatic approver linking logic instead of random approver assignment
5. WHEN the seeder completes THEN the seeder SHALL produce activities with approvers that match the configured approval rules

### Requirement 6

**User Story:** As an admin panel user, I want to configure approval rules with activity type and financial filters, so that I can set up automated approval workflows for my church.

#### Acceptance Criteria

1. WHEN viewing the approval rule form in the admin panel THEN the form SHALL display an optional activity type dropdown with SERVICE, EVENT, and ANNOUNCEMENT options
2. WHEN viewing the approval rule form in the admin panel THEN the form SHALL display an optional financial type dropdown with REVENUE and EXPENSE options
3. WHEN a financial type is selected THEN the form SHALL display an optional financial account number dropdown filtered by the selected financial type and church
4. WHEN saving an approval rule THEN the admin panel SHALL send the activityType, financialType, and financialAccountNumberId to the backend API
5. WHEN viewing the approval rules list THEN the admin panel SHALL display the configured activity type, financial type, and financial account number for each rule

### Requirement 7

**User Story:** As an admin panel user, I want to see which approvers were automatically assigned to an activity, so that I can verify the approval workflow is working correctly.

#### Acceptance Criteria

1. WHEN viewing an activity detail in the admin panel THEN the panel SHALL display the list of automatically assigned approvers
2. WHEN viewing an activity detail THEN the panel SHALL show each approver's name, position, and approval status
3. WHEN viewing the activity list THEN the panel SHALL indicate the number of approvers assigned to each activity

### Requirement 8

**User Story:** As a mobile app user (supervisor), I want to be able to approve my own activity when I am also assigned as an approver, so that I can complete the approval workflow without requiring another person.

#### Acceptance Criteria

1. WHEN viewing an activity detail in the mobile app THEN the app SHALL check if the current user is both the supervisor and an approver
2. WHEN the current user is both supervisor and approver THEN the app SHALL display approval action buttons (approve/reject) for the user's own approver record
3. WHEN the supervisor approves their own approver record THEN the system SHALL update the approver status to APPROVED
4. WHEN the supervisor rejects their own approver record THEN the system SHALL update the approver status to REJECTED
5. WHEN displaying the activity detail THEN the app SHALL visually indicate when the supervisor is also an approver
