# Requirements Document

## Introduction

Palakat is a comprehensive church activity management system designed to digitize and streamline church operations. The system consists of three interconnected applications: a mobile app for church members, a web/desktop admin panel for church administrators, and a REST API backend for data management. The system enables churches to manage members, track activities, handle financial operations, manage approvals, and maintain a digital song book.

## Glossary

- **System**: The complete Palakat platform including mobile app, admin panel, and backend API
- **Mobile_App**: Flutter-based mobile application for church members (iOS/Android)
- **Admin_Panel**: Flutter-based web/desktop application for church administrators
- **Backend_API**: NestJS REST API providing data persistence and business logic
- **Member**: A church member with an account in the system
- **Administrator**: A church staff member with elevated permissions to manage church operations
- **Activity**: A church event, service, or announcement requiring approval workflow
- **Approval_Workflow**: A multi-step process where designated approvers review and approve activities
- **Approver**: A member designated to review and approve specific activities
- **Supervisor**: The member who creates and oversees an activity
- **BIPRA**: Church organizational units (PKB, WKI, PMD, RMJ, ASM)
- **Column**: A church sub-group or division for organizing members
- **Membership_Position**: A role or title held by a member within the church
- **Song_Book**: Digital hymnal containing songs from multiple books (NKB, NNBT, KJ, DSL)
- **Revenue**: Financial income recorded for church operations
- **Expense**: Financial expenditure recorded for church operations
- **Document**: File-based records associated with church operations
- **Report**: Generated financial or operational reports
- **JWT**: JSON Web Token used for authentication
- **Refresh_Token**: Long-lived token used to obtain new access tokens

## Requirements

### Requirement 1: User Authentication and Authorization

**User Story:** As a church member, I want to securely sign in to the system using my phone number and password, so that I can access my personalized church information and activities.

#### Acceptance Criteria

1. WHEN a user provides valid phone number and password credentials, THE Backend_API SHALL authenticate the user and return a JWT access token and refresh token
2. WHEN a user provides invalid credentials, THE Backend_API SHALL reject the authentication attempt and return an error message
3. WHEN a user's account is locked due to failed login attempts, THE Backend_API SHALL prevent authentication until the lock period expires
4. WHEN a user's access token expires, THE Mobile_App SHALL use the refresh token to obtain a new access token without requiring re-authentication
5. WHEN a user signs out, THE Backend_API SHALL invalidate the user's refresh token
6. WHERE a user has not claimed their account, THE System SHALL allow account activation with password setup
7. THE Backend_API SHALL enforce role-based access control for all protected endpoints

### Requirement 2: Member Management

**User Story:** As a church administrator, I want to manage member profiles and organizational structure, so that I can maintain accurate records of church membership and their roles.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to create new member accounts with name, phone, email, gender, marital status, and date of birth
2. THE Admin_Panel SHALL allow administrators to assign members to columns and BIPRA organizational units
3. THE Admin_Panel SHALL allow administrators to assign membership positions to members
4. WHEN an administrator updates member information, THE Backend_API SHALL persist the changes and update the timestamp
5. THE Admin_Panel SHALL display a paginated list of all members with search and filter capabilities
6. THE Backend_API SHALL ensure phone numbers are unique across all accounts
7. WHERE a member has an email address, THE Backend_API SHALL ensure email uniqueness across all accounts

### Requirement 3: Activity Management and Approval Workflow

**User Story:** As a church member, I want to create activities and have them reviewed by designated approvers, so that church events are properly coordinated and authorized.

#### Acceptance Criteria

1. THE Mobile_App SHALL allow supervisors to create activities with title, description, date, location, activity type, and BIPRA assignment
2. WHEN an activity is created, THE Backend_API SHALL automatically assign approvers based on the configured approval rules for the activity type and BIPRA
3. THE Mobile_App SHALL display activities assigned to a member as supervisor or approver
4. WHEN an approver reviews an activity, THE Mobile_App SHALL allow the approver to mark the activity as APPROVED or REJECTED
5. THE Mobile_App SHALL display the current approval status for each approver assigned to an activity
6. THE Admin_Panel SHALL allow administrators to view all activities with filtering by date, type, status, and BIPRA
7. WHEN an activity is deleted, THE Backend_API SHALL cascade delete all associated approver records
8. THE Backend_API SHALL support three activity types: SERVICE, EVENT, and ANNOUNCEMENT

### Requirement 4: Approval Rule Configuration

**User Story:** As a church administrator, I want to configure approval rules that automatically assign approvers based on activity characteristics, so that the approval workflow is consistent and efficient.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to create approval rules with name, description, and associated membership positions
2. THE Admin_Panel SHALL allow administrators to assign multiple membership positions to an approval rule
3. THE Admin_Panel SHALL allow administrators to activate or deactivate approval rules
4. WHEN an activity is created, THE Backend_API SHALL apply active approval rules to determine which members should be assigned as approvers
5. THE Admin_Panel SHALL display all approval rules with their associated positions and active status
6. THE Backend_API SHALL associate approval rules with specific churches for multi-church support

### Requirement 5: Financial Operations Management

**User Story:** As a church administrator, I want to track revenues and expenses associated with church activities, so that I can maintain accurate financial records.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to record revenue with account number, amount, payment method, and optional activity association
2. THE Admin_Panel SHALL allow administrators to record expenses with account number, amount, payment method, and optional activity association
3. THE Backend_API SHALL support CASH and CASHLESS payment methods
4. THE Admin_Panel SHALL display paginated lists of revenues and expenses with date range filtering
5. WHEN a revenue or expense is associated with an activity, THE Backend_API SHALL create a one-to-one relationship between the financial record and activity
6. THE Backend_API SHALL associate all financial records with a specific church
7. THE Admin_Panel SHALL display total revenue and expense amounts for selected date ranges

### Requirement 6: Digital Song Book

**User Story:** As a church member, I want to access a digital hymnal with searchable songs, so that I can easily find and view song lyrics during services.

#### Acceptance Criteria

1. THE Mobile_App SHALL display a list of songs organized by book (NKB, NNBT, KJ, DSL) and index number
2. WHEN a member selects a song, THE Mobile_App SHALL display the song title, book, index, and all song parts with their content
3. THE Mobile_App SHALL allow members to search songs by title or index number
4. THE Backend_API SHALL store songs with multiple parts, each having an index, name, and content
5. THE Admin_Panel SHALL allow administrators to create and edit songs with multiple parts
6. THE Backend_API SHALL ensure song index numbers are unique within the system
7. THE Mobile_App SHALL display song parts in sequential order by part index

### Requirement 7: Church and Location Management

**User Story:** As a church administrator, I want to manage church information and locations, so that members can access accurate church details and activity locations.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to create and edit church profiles with name, phone, email, description, and document account number
2. THE Backend_API SHALL associate each church with exactly one location containing name, latitude, and longitude
3. THE Admin_Panel SHALL allow administrators to create and manage columns within a church
4. THE Backend_API SHALL ensure column names are unique within each church
5. THE Mobile_App SHALL display church location on a map using Google Maps integration
6. WHEN an activity has an associated location, THE Mobile_App SHALL display the activity location on a map
7. THE Backend_API SHALL support multiple churches within the system for multi-tenant capability

### Requirement 8: Document and Report Management

**User Story:** As a church administrator, I want to upload and manage documents and generate reports, so that I can maintain organized records and analyze church operations.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to upload documents with name and account number
2. THE Backend_API SHALL store uploaded files with size in kilobytes and URL
3. THE Admin_Panel SHALL allow administrators to generate reports manually or automatically
4. WHEN a report is generated, THE Backend_API SHALL create a report record with generation method (MANUAL or SYSTEM)
5. THE Admin_Panel SHALL display all documents and reports with pagination and filtering
6. THE Backend_API SHALL associate documents and reports with specific churches
7. THE Admin_Panel SHALL allow administrators to download documents and reports

### Requirement 9: Secure Token Storage

**User Story:** As a church member, I want my authentication credentials stored securely on my device, so that my account remains protected.

#### Acceptance Criteria

1. THE Mobile_App SHALL cache user authentication tokens securely in local storage using Hive
2. THE Mobile_App SHALL encrypt sensitive data stored locally
3. WHEN a user signs out, THE Mobile_App SHALL clear all cached authentication tokens
4. THE Mobile_App SHALL validate stored tokens on app startup and refresh if expired

### Requirement 10: Responsive Admin Interface

**User Story:** As a church administrator, I want to use the admin panel on various screen sizes, so that I can manage church operations from desktop computers, tablets, or mobile devices.

#### Acceptance Criteria

1. THE Admin_Panel SHALL adapt layout and navigation based on screen width using responsive design
2. WHERE screen width is less than 768 pixels, THE Admin_Panel SHALL display a mobile-optimized navigation menu
3. WHERE screen width is 768 pixels or greater, THE Admin_Panel SHALL display a side drawer navigation
4. THE Admin_Panel SHALL use flutter_screenutil for consistent sizing across devices
5. THE Admin_Panel SHALL display data tables with horizontal scrolling on narrow screens
6. THE Admin_Panel SHALL maintain usability and readability across all supported screen sizes

### Requirement 11: Data Pagination and Performance

**User Story:** As a user of the system, I want to load large datasets efficiently, so that the application remains responsive when viewing lists of activities, members, or financial records.

#### Acceptance Criteria

1. THE Backend_API SHALL support pagination for all list endpoints with page number and page size parameters
2. THE Backend_API SHALL return pagination metadata including total count, current page, and total pages
3. THE Admin_Panel SHALL display pagination controls for all data tables
4. THE Mobile_App SHALL implement infinite scroll for activity lists
5. THE Backend_API SHALL limit maximum page size to 100 records per request
6. THE Backend_API SHALL use database indexes on frequently queried fields for optimal performance

### Requirement 12: Input Validation and Error Handling

**User Story:** As a user of the system, I want to receive clear error messages when I provide invalid input, so that I can correct mistakes and successfully complete operations.

#### Acceptance Criteria

1. THE Backend_API SHALL validate all request data using class-validator decorators
2. WHEN validation fails, THE Backend_API SHALL return a 400 Bad Request response with detailed error messages
3. THE Mobile_App SHALL display user-friendly error messages for validation failures
4. THE Admin_Panel SHALL display user-friendly error messages for validation failures
5. THE Backend_API SHALL use a global exception filter to standardize error responses
6. THE Mobile_App SHALL validate form inputs before submitting to the Backend_API
7. THE Admin_Panel SHALL validate form inputs before submitting to the Backend_API

### Requirement 13: Multi-Church Support

**User Story:** As a system administrator, I want to support multiple churches within a single system instance, so that different church organizations can use the platform independently.

#### Acceptance Criteria

1. THE Backend_API SHALL associate all church-specific data with a church identifier
2. THE Backend_API SHALL enforce data isolation between churches
3. WHEN a user authenticates, THE Backend_API SHALL determine the user's church affiliation through their membership
4. THE Backend_API SHALL filter all queries to return only data belonging to the user's church
5. THE Admin_Panel SHALL display only data for the administrator's assigned church
6. THE Mobile_App SHALL display only data for the member's assigned church

### Requirement 14: Audit Trail and Timestamps

**User Story:** As a church administrator, I want to track when records are created and modified, so that I can maintain accountability and audit church operations.

#### Acceptance Criteria

1. THE Backend_API SHALL automatically set createdAt timestamp when creating any record
2. THE Backend_API SHALL automatically update updatedAt timestamp when modifying any record
3. THE Admin_Panel SHALL display creation and modification timestamps for all records
4. THE Backend_API SHALL use Prisma middleware to enforce timestamp management
5. THE Backend_API SHALL store all timestamps in UTC format
6. THE Mobile_App SHALL display timestamps in the user's local timezone

### Requirement 15: Church Registration Request

**User Story:** As a church member, I want to request registration of a new church when my church is not in the system, so that I can eventually join my church's membership in the application.

#### Acceptance Criteria

1. THE Mobile_App SHALL allow members without church membership to submit a church registration request with church name, address, contact person, and contact phone number
2. THE Backend_API SHALL associate each church request with the requesting user's account
3. THE Backend_API SHALL enforce one church request per user account
4. THE Backend_API SHALL support three request statuses: TODO (pending review), DOING (in progress), and DONE (completed)
5. THE Mobile_App SHALL display the current status of the user's church request on the membership screen
6. THE Mobile_App SHALL display a compact status card on the dashboard when a church request exists
7. THE Mobile_App SHALL show different status messages based on request status:
   - TODO: "Your request is waiting to be reviewed by our team"
   - DOING: "We are processing your request. This usually takes 1-2 business days"
   - DONE: "Your church has been registered! You can now select it in your membership"
8. THE Backend_API SHALL allow administrators to view all church requests with pagination and search
9. THE Backend_API SHALL allow administrators to update church request status
10. THE Backend_API SHALL allow administrators to delete church requests
11. THE Mobile_App SHALL prevent submission of duplicate church requests from the same user
12. THE Mobile_App SHALL validate church request form inputs including minimum/maximum length requirements
13. THE Backend_API SHALL return complete account information (including dob, gender, maritalStatus) when fetching church requests to support proper JSON deserialization
