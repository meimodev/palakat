# Requirements Document

## Introduction

Palakat is a comprehensive church activity management and event notification system designed for Indonesian church communities (GMIM - Gereja Masehi Injili di Minahasa). The system is a monorepo containing three interconnected applications: a Flutter mobile app for church members, a Flutter web/desktop admin panel for church administrators, and a NestJS REST API backend with PostgreSQL database.

The platform enables churches to:
- Manage members and organizational structure
- Track activities with multi-level approval workflows
- Handle financial operations (revenues and expenses) with centralized account number management
- Maintain a digital song book (hymnal)
- Generate reports and manage documents
- Support multi-tenant architecture for multiple churches

This specification serves as the comprehensive system documentation, consolidating all feature requirements into a single authoritative source. It includes:
- Widget consolidation from mobile and admin apps into the shared package
- Financial account unique constraint enforcement
- Activity approver automatic linking based on approval rules
- Searchable pickers for financial accounts and positions

## Glossary

### System Components
- **Palakat_System**: The complete platform including Mobile_App, Admin_Panel, and Backend_API
- **Mobile_App**: Flutter-based mobile application for church members (iOS/Android) located at `apps/palakat`
- **Admin_Panel**: Flutter-based web/desktop application for church administrators located at `apps/palakat_admin`
- **Backend_API**: NestJS REST API providing data persistence and business logic located at `apps/palakat_backend`
- **Shared_Package**: Reusable Flutter code shared between Mobile_App and Admin_Panel located at `packages/palakat_shared`

### User Roles
- **Member**: A church member with an account in the system
- **Administrator**: A church staff member with elevated permissions to manage church operations
- **Approver**: A member designated to review and approve specific activities
- **Supervisor**: The member who creates and oversees an activity

### Domain Concepts
- **Activity**: A church event, service, or announcement requiring approval workflow
- **Approval_Workflow**: A multi-step process where designated approvers review and approve activities
- **Approval_Rule**: A configuration that defines which membership positions are responsible for approving certain types of activities
- **BIPRA**: Church organizational units (PKB, WKI, PMD, RMJ, ASM)
- **Column**: A church sub-group or division for organizing members
- **Membership_Position**: A role or title held by a member within the church
- **Song_Book**: Digital hymnal containing songs from multiple books (NKB, NNBT, KJ, DSL)
- **Church_Request**: A request submitted by a member to register a new church in the system
- **Widget**: A reusable UI component in Flutter

### Financial Concepts
- **Revenue**: A financial record representing income associated with a church activity
- **Expense**: A financial record representing expenditure associated with a church activity
- **Financial_Account_Number**: A predefined account number record belonging to a church, containing an account number string and description
- **Payment_Method**: The method of payment, either CASH or CASHLESS
- **Finance_Create_Screen**: The screen in the mobile app where users input financial details
- **FinancialType**: Classification of financial data (REVENUE, EXPENSE)

### Activity Concepts
- **Reminder**: A time-based notification preference indicating when users should be reminded before an activity (TEN_MINUTES, THIRTY_MINUTES, ONE_HOUR, TWO_HOURS)
- **Supervised_Activity**: An Activity record where the current user's membership ID matches the supervisorId field
- **SERVICE/EVENT Activity**: Activity types that require date, time, location, and reminder fields
- **ANNOUNCEMENT Activity**: Activity type that does not require reminder field
- **ActivityType**: Classification of activity (SERVICE, EVENT, ANNOUNCEMENT)

### Technical Terms
- **JWT**: JSON Web Token used for authentication
- **Refresh_Token**: Long-lived token used to obtain new access tokens
- **Hive**: Local key-value storage used by Flutter apps for caching
- **Prisma**: ORM used by Backend_API for database operations
- **Riverpod**: State management library used by Flutter apps
- **InputWidget**: A Flutter widget that provides text, dropdown, and binary option input variants with custom display builder support
- **Custom Display Builder**: A callback function that allows rendering a custom widget instead of the default text display for selected values

### UI Components
- **Operations_Screen**: The screen where designated church members perform operational tasks
- **Song_Book_Screen**: The screen where users browse and search for hymns and songs
- **Bottom_Navigation_Bar**: The persistent navigation component at the bottom of the screen
- **Category_Card**: A collapsible card component that groups related items
- **Primary_Color**: The main brand color (teal) from which all other colors are derived
- **FinancialAccountPicker**: A searchable picker widget for selecting financial account numbers
- **PositionSelector**: A searchable selector widget for selecting membership positions

## Requirements

---

### Requirement 1: User Authentication

**User Story:** As a church member, I want to securely sign in to the system using my phone number and password, so that I can access my personalized church information and activities.

#### Acceptance Criteria

1. WHEN a user provides valid phone number and password credentials, THE Backend_API SHALL authenticate the user and return a JWT access token and refresh token
2. WHEN a user provides invalid credentials, THE Backend_API SHALL reject the authentication attempt and return an appropriate error message
3. WHEN a user's account is locked due to failed login attempts, THE Backend_API SHALL prevent authentication until the lock period expires
4. WHEN a user's access token expires, THE Mobile_App SHALL use the refresh token to obtain a new access token without requiring re-authentication
5. WHEN a user signs out, THE Backend_API SHALL invalidate the user's refresh token
6. WHERE a user has not claimed their account, THE Palakat_System SHALL allow account activation with password setup
7. THE Backend_API SHALL enforce role-based access control for all protected endpoints
8. THE Mobile_App SHALL store authentication tokens securely using Hive local storage
9. WHEN the Mobile_App launches, THE Mobile_App SHALL check for stored authentication tokens and navigate to the appropriate screen

---

### Requirement 2: Firebase Phone Authentication

**User Story:** As a church member, I want to authenticate using my phone number with SMS verification, so that I can securely access the app without remembering passwords.

#### Acceptance Criteria

1. WHEN the user opens the authentication screen, THE Mobile_App SHALL display a phone number input field with country code selector defaulting to Indonesia (+62)
2. WHEN the user enters a valid phone number and taps continue, THE Mobile_App SHALL initiate Firebase Phone Authentication and send an SMS OTP
3. WHEN Firebase sends the OTP, THE Mobile_App SHALL display an OTP verification screen with a 6-digit input field
4. WHEN the user enters the complete 6-digit OTP, THE Mobile_App SHALL verify the OTP with Firebase Authentication service
5. IF Firebase OTP verification fails, THEN THE Mobile_App SHALL display an error message indicating invalid OTP and allow retry
6. WHEN Firebase Phone Authentication succeeds, THE Mobile_App SHALL call the Backend_API validation endpoint with the verified phone number
7. WHEN the validation endpoint returns success with account data, THE Mobile_App SHALL store the authentication tokens and navigate to the home screen
8. WHEN the validation endpoint returns empty account data, THE Mobile_App SHALL navigate the user to the registration screen
9. THE Mobile_App SHALL display a 120-second countdown timer for OTP resend functionality
10. WHEN the countdown timer reaches zero, THE Mobile_App SHALL enable the resend OTP button

---

### Requirement 3: Member Management

**User Story:** As a church administrator, I want to manage member profiles and organizational structure, so that I can maintain accurate records of church membership and their roles.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to create new member accounts with name, phone, email, gender, marital status, and date of birth
2. THE Admin_Panel SHALL allow administrators to assign members to columns and BIPRA organizational units
3. THE Admin_Panel SHALL allow administrators to assign membership positions to members
4. WHEN an administrator updates member information, THE Backend_API SHALL persist the changes and update the timestamp
5. THE Admin_Panel SHALL display a paginated list of all members with search and filter capabilities
6. THE Backend_API SHALL ensure phone numbers are unique across all accounts
7. WHERE a member has an email address, THE Backend_API SHALL ensure email uniqueness across all accounts
8. THE Backend_API SHALL store member personal information including gender (MALE/FEMALE), marital status (MARRIED/SINGLE), and date of birth

---

### Requirement 4: Activity Management

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
9. THE Backend_API SHALL support five BIPRA organizational units: PKB, WKI, PMD, RMJ, ASM

---

### Requirement 5: Create Activity Screen

**User Story:** As a church member, I want to access a dedicated activity creation screen from the operations screen, so that I can quickly create activities based on the type I selected.

#### Acceptance Criteria

1. WHEN a user taps a publishing card in the Operations_Screen THEN the Create Activity Screen SHALL open with the activity type pre-configured according to the tapped card
2. WHEN the Create Activity Screen opens THEN the Create Activity Screen SHALL display the activity type name in the screen title
3. WHEN the user taps the back button THEN the Create Activity Screen SHALL navigate back to the Operations_Screen without saving any data
4. WHEN the Create Activity Screen loads THEN the Create Activity Screen SHALL display a form with fields appropriate for the selected activity type
5. WHEN the activity type is SERVICE or EVENT THEN the Create Activity Screen SHALL display fields for: Bipra selection, Title, Location, Pinpoint Location (map), Date, Time, Reminder, and Note
6. WHEN the activity type is ANNOUNCEMENT THEN the Create Activity Screen SHALL display fields for: Bipra selection, Title, Description, and File upload
7. WHEN the user attempts to submit the form with empty required fields THEN the Create Activity Screen SHALL display validation error messages for each empty required field
8. WHEN the Bipra field is empty THEN the Create Activity Screen SHALL display "Must be selected" error message
9. WHEN the Title field is empty THEN the Create Activity Screen SHALL display "Title is required" error message
10. WHEN the user taps the Pinpoint Location field THEN the Create Activity Screen SHALL navigate to the Map screen in pinpoint mode
11. WHEN the user selects a location on the map and returns THEN the Create Activity Screen SHALL display the selected location name in the Pinpoint Location field
12. WHEN the user taps the Date field THEN the Create Activity Screen SHALL display a date picker dialog
13. WHEN the user selects a date THEN the Create Activity Screen SHALL display the selected date in formatted text (EEEE, dd MMM yyyy)
14. WHEN the user taps the Time field THEN the Create Activity Screen SHALL display a time picker dialog
15. WHEN the user selects a time THEN the Create Activity Screen SHALL display the selected time in HH:mm format
16. WHEN the user taps the Submit button with valid form data THEN the Create Activity Screen SHALL send a create activity request to the Backend_API
17. WHILE the create activity request is in progress THEN the Create Activity Screen SHALL display a loading indicator and disable user interaction
18. WHEN the create activity request succeeds THEN the Create Activity Screen SHALL navigate back to the Operations_Screen and display a success message
19. IF the create activity request fails THEN the Create Activity Screen SHALL display an error message and allow the user to retry
20. WHEN the Create Activity Screen loads THEN the Create Activity Screen SHALL display the signed-in member's name as the publisher
21. WHEN the activity type is ANNOUNCEMENT and the user taps the File upload field THEN the Create Activity Screen SHALL open a file picker dialog

---

### Requirement 6: Activity Reminder

**User Story:** As a supervisor, I want to set a reminder time when creating a SERVICE or EVENT activity, so that members can be notified before the activity starts.

#### Acceptance Criteria

1. WHEN a supervisor creates a SERVICE or EVENT activity with a reminder selection THEN the Backend_API SHALL persist the reminder value to the database
2. WHEN a supervisor creates an ANNOUNCEMENT activity THEN the Backend_API SHALL accept the request without requiring a reminder field
3. WHEN the reminder field is provided THEN the Backend_API SHALL validate that the value is one of the allowed enum values (TEN_MINUTES, THIRTY_MINUTES, ONE_HOUR, TWO_HOURS)
4. IF an invalid reminder value is provided THEN the Backend_API SHALL return a validation error with a descriptive message
5. WHEN retrieving a single activity THEN the Backend_API SHALL include the reminder field in the response
6. WHEN retrieving a list of activities THEN the Backend_API SHALL include the reminder field for each activity in the response
7. WHEN an activity has no reminder set THEN the Backend_API SHALL return null for the reminder field
8. WHEN a supervisor updates an activity with a new reminder value THEN the Backend_API SHALL persist the updated reminder value
9. WHEN a supervisor updates an activity to remove the reminder THEN the Backend_API SHALL set the reminder field to null
10. WHEN the CreateActivityRequest is serialized THEN the System SHALL include the reminder field with the correct enum value format
11. WHEN serializing and then deserializing a CreateActivityRequest THEN the System SHALL produce an equivalent object (round-trip consistency)
12. WHEN submitting the activity creation form with a selected reminder THEN the Mobile_App SHALL include the reminder value in the API request

---

### Requirement 7: Supervised Activities

**User Story:** As a church supervisor, I want to see my most recent supervised activities on the Operations screen, so that I can quickly monitor activities under my responsibility.

#### Acceptance Criteria

1. WHEN the Operations screen loads AND the user has supervised activities THEN the System SHALL display a "Supervised Activities" section showing the 3 most recent activities
2. WHEN the user has no supervised activities THEN the System SHALL hide the "Supervised Activities" section entirely
3. WHEN displaying supervised activities THEN the System SHALL show the activity title, date, and activity type for each item
4. WHEN the user taps on a supervised activity item THEN the System SHALL navigate to the activity detail screen
5. WHEN the "Supervised Activities" section is visible THEN the System SHALL display a "See All" button
6. WHEN the user taps the "See All" button THEN the System SHALL navigate to the Supervised Activities List screen
7. WHEN the Supervised Activities List screen loads THEN the System SHALL display all activities supervised by the current user with pagination support
8. WHEN displaying the activity list THEN the System SHALL show activity title, date, activity type, and approval status for each item
9. WHEN the Supervised Activities List screen is displayed THEN the System SHALL provide filter options for activity type
10. WHEN the Supervised Activities List screen is displayed THEN the System SHALL provide filter options for date range (start date and end date)
11. WHEN the user applies filters THEN the System SHALL update the activity list to show only matching activities
12. WHEN the user clears filters THEN the System SHALL display all supervised activities
13. WHEN filters are active THEN the System SHALL indicate the active filter state visually
14. WHEN fetching supervised activities THEN the System SHALL display a loading indicator
15. WHEN the fetch operation fails THEN the System SHALL display an error message with a retry option
16. WHEN the supervised activities list is empty after filtering THEN the System SHALL display an appropriate empty state message

---

### Requirement 8: Approval Workflow Configuration

**User Story:** As a church administrator, I want to configure approval rules that automatically assign approvers based on activity characteristics, so that the approval workflow is consistent and efficient.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to create approval rules with name, description, and associated membership positions
2. THE Admin_Panel SHALL allow administrators to assign multiple membership positions to an approval rule
3. THE Admin_Panel SHALL allow administrators to activate or deactivate approval rules
4. WHEN an activity is created, THE Backend_API SHALL apply active approval rules to determine which members should be assigned as approvers
5. THE Admin_Panel SHALL display all approval rules with their associated positions and active status
6. THE Backend_API SHALL associate approval rules with specific churches for multi-church support

---

### Requirement 9: Financial Account Number Management

**User Story:** As a church administrator, I want to manage a list of predefined financial account numbers, so that users can select from consistent account numbers when recording revenues and expenses.

#### Acceptance Criteria

1. WHEN an administrator navigates to the Financial menu in the Administration section THEN the Admin_Panel SHALL display a list of all financial account numbers for the church
2. WHEN an administrator clicks the "Add Account Number" button THEN the Admin_Panel SHALL display a form with fields for account number and description
3. WHEN an administrator submits a valid account number form THEN the System SHALL create a new Financial_Account_Number record associated with the church
4. WHEN an administrator edits an existing account number THEN the Admin_Panel SHALL display the edit form pre-populated with current values
5. WHEN an administrator deletes an account number THEN the System SHALL remove the Financial_Account_Number record from the database
6. WHEN displaying the account number list THEN the Admin_Panel SHALL show account number, description, and linked approval rule name for each entry
7. WHEN the database schema is updated THEN the Backend_API SHALL include a FinancialAccountNumber model with id, accountNumber, description, churchId, createdAt, and updatedAt fields
8. WHEN a FinancialAccountNumber is created THEN the Backend_API SHALL establish a many-to-one relationship with Church
9. WHEN a CRUD operation is performed on FinancialAccountNumber THEN the Backend_API SHALL validate that the account number is unique within the same church
10. WHEN listing financial account numbers THEN the Backend_API SHALL support filtering by churchId and searching by account number or description
11. WHEN displaying the financial account numbers table THEN the Admin_Panel SHALL NOT display the created date column
12. WHEN a financial account is not linked to any approval rule THEN the Admin_Panel SHALL display a clear indicator (e.g., "-" or "Not assigned")
13. WHEN a financial account is linked to an approval rule THEN the Admin_Panel SHALL display the approval rule name in the linked rule column

---

### Requirement 10: Activity Finance (Revenue/Expense)

**User Story:** As a church supervisor, I want to add revenue or expense records while publishing an activity, so that I can track financial information associated with the activity.

#### Acceptance Criteria

1. WHEN the Activity Publish Screen is displayed for service or event types THEN the System SHALL display a "Financial Record" section with an option to add revenue or expense
2. WHEN the user taps the "Add Financial Record" button THEN the System SHALL display a Finance Type Picker dialog with "Revenue" and "Expense" options
3. WHEN the user selects a finance type THEN the System SHALL navigate to the Finance Create Screen with the selected type pre-configured
4. WHEN the Finance Create Screen returns with valid data THEN the System SHALL display the attached financial record summary in the Activity Publish Screen
5. WHEN the user removes an attached financial record THEN the System SHALL clear the financial data and restore the "Add Financial Record" button
6. WHEN the Revenue Create Screen is displayed THEN the System SHALL show input fields for amount, account number picker, and payment method
7. WHEN the user enters an amount THEN the System SHALL validate that the amount is a positive integer
8. WHEN the user selects an account number THEN the System SHALL display the account number prominently with the description below it
9. WHEN the user selects a payment method THEN the System SHALL accept either CASH or CASHLESS values
10. WHEN all required fields are valid AND the user taps submit THEN the System SHALL return the finance data to the calling screen
11. WHEN a user opens the Finance_Create_Screen THEN the Mobile_App SHALL display an Account_Number_Picker instead of a text input field
12. WHEN a user taps the Account_Number_Picker THEN the Mobile_App SHALL display a searchable list of available account numbers
13. WHEN a user types in the search field THEN the Account_Number_Picker SHALL filter results by matching account number or description
14. WHEN no matching account numbers are found THEN the Account_Number_Picker SHALL display a "No results found" message
15. WHEN an activity with attached financial data is submitted THEN the System SHALL first create the activity via the backend API
16. WHEN the activity creation succeeds THEN the System SHALL create the financial record with the new activity ID
17. WHEN the financial record creation succeeds THEN the System SHALL display a success message indicating both records were created
18. IF the financial record creation fails after activity creation THEN the System SHALL display an error message but keep the activity created
19. WHEN displaying currency amounts THEN the System SHALL format them with Indonesian Rupiah formatting (Rp prefix, thousand separators)

---

### Requirement 11: Financial Operations

**User Story:** As a church administrator, I want to track revenues and expenses associated with church activities, so that I can maintain accurate financial records.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to record revenue with account number, amount, payment method, and optional activity association
2. THE Admin_Panel SHALL allow administrators to record expenses with account number, amount, payment method, and optional activity association
3. THE Backend_API SHALL support CASH and CASHLESS payment methods
4. THE Admin_Panel SHALL display paginated lists of revenues and expenses with date range filtering
5. WHEN a revenue or expense is associated with an activity, THE Backend_API SHALL create a one-to-one relationship between the financial record and activity
6. THE Backend_API SHALL associate all financial records with a specific church
7. THE Admin_Panel SHALL display total revenue and expense amounts for selected date ranges

---

### Requirement 12: Digital Song Book

**User Story:** As a church member, I want to access a digital hymnal with searchable songs, so that I can easily find and view song lyrics during services.

#### Acceptance Criteria

1. THE Mobile_App SHALL display a list of songs organized by book (NKB, NNBT, KJ, DSL) and index number
2. WHEN a member selects a song, THE Mobile_App SHALL display the song title, book, index, and all song parts with their content
3. THE Mobile_App SHALL allow members to search songs by title or index number
4. THE Backend_API SHALL store songs with multiple parts, each having an index, name, and content
5. THE Admin_Panel SHALL allow administrators to create and edit songs with multiple parts
6. THE Backend_API SHALL ensure song index numbers are unique within the system
7. THE Mobile_App SHALL display song parts in sequential order by part index
8. WHEN the Song_Book_Screen loads THEN the Mobile_App SHALL display song categories as collapsible Category_Card components
9. WHEN displaying song categories THEN the Mobile_App SHALL group songs into logical categories (NNBT, KJ, NKB, DSL)
10. WHEN a user taps a category header THEN the Mobile_App SHALL expand that category to show a search-filtered list of songs from that hymnal
11. WHEN a user enters a search query in the search field, THE SongBook_Controller SHALL call the Song_Repository to fetch matching songs from the Backend_API
12. WHEN the Backend_API returns search results, THE SongBook_Controller SHALL update the state with the fetched songs
13. WHEN the song data is incomplete, THE SongDetail_Controller SHALL fetch the complete song from the Backend_API using the song ID
14. WHILE the SongBook_Controller is fetching songs, THE Song_Book_Screen SHALL display a loading shimmer placeholder
15. WHEN the fetch operation fails, THE Song_Book_Screen SHALL display an error message with a retry option

---

### Requirement 13: Church and Location Management

**User Story:** As a church administrator, I want to manage church information and locations, so that members can access accurate church details and activity locations.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to create and edit church profiles with name, phone, email, description, and document account number
2. THE Backend_API SHALL associate each church with exactly one location containing name, latitude, and longitude
3. THE Admin_Panel SHALL allow administrators to create and manage columns within a church
4. THE Backend_API SHALL ensure column names are unique within each church
5. THE Mobile_App SHALL display church location on a map using Google Maps integration
6. WHEN an activity has an associated location, THE Mobile_App SHALL display the activity location on a map
7. THE Backend_API SHALL support multiple churches within the system for multi-tenant capability

---

### Requirement 14: Church Registration Request

**User Story:** As a church member, I want to request registration of a new church when my church is not in the system, so that I can eventually join my church's membership in the application.

#### Acceptance Criteria

1. THE Mobile_App SHALL allow members without church membership to submit a church registration request with church name, address, contact person, and contact phone number
2. THE Backend_API SHALL associate each church request with the requesting user's account
3. THE Backend_API SHALL enforce one church request per user account
4. THE Backend_API SHALL support three request statuses: TODO (pending review), DOING (in progress), and DONE (completed)
5. THE Mobile_App SHALL display the current status of the user's church request on the membership screen
6. THE Mobile_App SHALL display a compact status card on the dashboard when a church request exists
7. THE Mobile_App SHALL show different status messages based on request status
8. THE Admin_Panel SHALL allow administrators to view all church requests with pagination and search
9. THE Admin_Panel SHALL allow administrators to update church request status
10. THE Mobile_App SHALL prevent submission of duplicate church requests from the same user

---

### Requirement 15: Document and Report Management

**User Story:** As a church administrator, I want to upload and manage documents and generate reports, so that I can maintain organized records and analyze church operations.

#### Acceptance Criteria

1. THE Admin_Panel SHALL allow administrators to upload documents with name and account number
2. THE Backend_API SHALL store uploaded files with size in kilobytes and URL
3. THE Admin_Panel SHALL allow administrators to generate reports manually or automatically
4. WHEN a report is generated, THE Backend_API SHALL create a report record with generation method (MANUAL or SYSTEM)
5. THE Admin_Panel SHALL display all documents and reports with pagination and filtering
6. THE Backend_API SHALL associate documents and reports with specific churches
7. THE Admin_Panel SHALL allow administrators to download documents and reports

---

### Requirement 16: Multi-Church Data Isolation

**User Story:** As a system administrator, I want to support multiple churches within a single system instance, so that different church organizations can use the platform independently.

#### Acceptance Criteria

1. THE Backend_API SHALL associate all church-specific data with a church identifier
2. THE Backend_API SHALL enforce data isolation between churches
3. WHEN a user authenticates, THE Backend_API SHALL determine the user's church affiliation through their membership
4. THE Backend_API SHALL filter all queries to return only data belonging to the user's church
5. THE Admin_Panel SHALL display only data for the administrator's assigned church
6. THE Mobile_App SHALL display only data for the member's assigned church

---

### Requirement 17: Unified Monochromatic Color System

**User Story:** As a user, I want a visually cohesive app experience, so that the interface feels calm and professional without overwhelming color variations.

#### Acceptance Criteria

1. THE Color_System SHALL use teal (0xFF009688) as the single Primary_Color for all accent and interactive elements
2. THE Color_System SHALL derive all Surface_Color values from neutral grays that complement the Primary_Color
3. THE Color_System SHALL generate Semantic_Color values (success, error, warning, info) as tonal variations of the Primary_Color where possible, with error remaining red for accessibility
4. WHEN displaying interactive elements THEN the Mobile_App SHALL use Primary_Color tonal variations (50-900 scale) for visual hierarchy
5. WHEN displaying backgrounds and surfaces THEN the Mobile_App SHALL use neutral colors derived from the Primary_Color undertone
6. THE Color_System SHALL be defined in a single source file (color_constants.dart)
7. THE Color_System SHALL provide a MaterialColor swatch for the Primary_Color with shades from 50 to 900

---

### Requirement 18: Operations Screen Design

**User Story:** As a church member with operational responsibilities, I want to see my available operations organized clearly, so that I can quickly find and perform the task I need without feeling overwhelmed.

#### Acceptance Criteria

1. WHEN the Operations_Screen loads THEN the Mobile_App SHALL display a summary card showing the user's current positions and role count
2. WHEN displaying available operations THEN the Mobile_App SHALL group operations into logical categories (Publishing, Financial, Reports)
3. WHEN a category contains multiple operations THEN the Mobile_App SHALL display them in a collapsed section that expands on user interaction
4. THE Operations_Screen SHALL limit visible operations to a maximum of 3 items per category before requiring expansion
5. WHEN no operations are available THEN the Mobile_App SHALL display an empty state with clear messaging
6. THE Operations_Screen SHALL use the Primary_Color for section headers and interactive elements only
7. THE Operations_Screen SHALL use neutral Surface_Color values for card backgrounds
8. WHEN displaying operation cards THEN the Mobile_App SHALL use subtle shadows and rounded corners (16px radius) for depth
9. THE Operations_Screen SHALL maintain consistent spacing using an 8px grid system
10. THE Operations_Screen SHALL display a "Publishing" category containing activity creation operations (Service, Event, Announcement)
11. THE Operations_Screen SHALL display a "Financial" category containing income and expense operations
12. THE Operations_Screen SHALL display a "Reports" category containing report generation operations
13. WHEN a user taps a category header THEN the Mobile_App SHALL expand or collapse that category's operations
14. THE Operations_Screen SHALL persist category expansion state during the session
15. WHEN a user taps an operation card THEN the Mobile_App SHALL display a ripple effect using Primary_Color at 10% opacity
16. THE operation cards SHALL display a title, brief description, and contextual icon

---

### Requirement 19: Bottom Navigation Bar Design

**User Story:** As a user, I want the bottom navigation bar to have a cleaner, more cohesive design, so that navigation feels seamless and consistent with the app's visual language.

#### Acceptance Criteria

1. THE Bottom_Navigation_Bar SHALL use a unified Primary_Color (teal) for all selected states instead of per-tab colors
2. THE Bottom_Navigation_Bar SHALL use neutral colors for unselected states
3. WHEN a navigation item is selected THEN the Mobile_App SHALL display a subtle indicator using Primary_Color at 15% opacity
4. THE Bottom_Navigation_Bar SHALL maintain consistent icon sizing (24px) and label typography
5. THE Bottom_Navigation_Bar SHALL use a subtle top border using Primary_Color at 12% opacity
6. WHEN a user taps a navigation item THEN the Mobile_App SHALL animate the selection indicator with 400ms duration
7. THE Bottom_Navigation_Bar SHALL always show labels for all navigation items
8. WHEN the user is not authenticated THEN the Mobile_App SHALL hide Operations and Approval navigation items
9. THE Bottom_Navigation_Bar SHALL maintain minimum touch target sizes of 48x48 pixels for all items

---

### Requirement 20: Data Pagination and Performance

**User Story:** As a user of the system, I want to load large datasets efficiently, so that the application remains responsive when viewing lists of activities, members, or financial records.

#### Acceptance Criteria

1. THE Backend_API SHALL support pagination for all list endpoints with page number and page size parameters
2. THE Backend_API SHALL return pagination metadata including total count, current page, and total pages
3. THE Admin_Panel SHALL display pagination controls for all data tables
4. THE Mobile_App SHALL implement infinite scroll for activity lists
5. THE Backend_API SHALL limit maximum page size to 100 records per request
6. THE Backend_API SHALL use database indexes on frequently queried fields for optimal performance

---

### Requirement 21: Input Validation and Error Handling

**User Story:** As a user of the system, I want to receive clear error messages when I provide invalid input, so that I can correct mistakes and successfully complete operations.

#### Acceptance Criteria

1. THE Backend_API SHALL validate all request data using class-validator decorators
2. WHEN validation fails, THE Backend_API SHALL return a 400 Bad Request response with detailed error messages
3. THE Mobile_App SHALL display user-friendly error messages for validation failures
4. THE Admin_Panel SHALL display user-friendly error messages for validation failures
5. THE Backend_API SHALL use a global exception filter to standardize error responses
6. THE Mobile_App SHALL validate form inputs before submitting to the Backend_API
7. THE Admin_Panel SHALL validate form inputs before submitting to the Backend_API

---

### Requirement 22: Audit Trail and Timestamps

**User Story:** As a church administrator, I want to track when records are created and modified, so that I can maintain accountability and audit church operations.

#### Acceptance Criteria

1. THE Backend_API SHALL automatically set createdAt timestamp when creating any record
2. THE Backend_API SHALL automatically update updatedAt timestamp when modifying any record
3. THE Admin_Panel SHALL display creation and modification timestamps for all records
4. THE Backend_API SHALL store all timestamps in UTC format
5. THE Mobile_App SHALL display timestamps in the user's local timezone

---

### Requirement 23: Responsive Layout

**User Story:** As a user on different device sizes, I want the app screens to adapt appropriately, so that I have a good experience regardless of my device.

#### Acceptance Criteria

1. THE Mobile_App SHALL use flexible layouts that adapt to screen width
2. WHEN the screen width exceeds 600px THEN the Mobile_App SHALL display cards in a 2-column grid where appropriate
3. WHEN the screen width is 600px or less THEN the Mobile_App SHALL display cards in a single column
4. THE Mobile_App SHALL maintain minimum touch target sizes of 48x48 pixels for all interactive elements
5. THE Admin_Panel SHALL adapt layout and navigation based on screen width using responsive design
6. WHERE screen width is less than 768 pixels, THE Admin_Panel SHALL display a mobile-optimized navigation menu
7. WHERE screen width is 768 pixels or greater, THE Admin_Panel SHALL display a side drawer navigation
8. THE Admin_Panel SHALL use flutter_screenutil for consistent sizing across devices
9. THE Admin_Panel SHALL display data tables with horizontal scrolling on narrow screens

---

### Requirement 24: Code Consolidation

**User Story:** As a developer, I want to remove duplicate code from palakat_admin's core folder, so that I maintain only one version of shared functionality in palakat_shared.

#### Acceptance Criteria

1. WHEN the consolidation is complete THEN the palakat_admin core folder SHALL contain only app-specific code (theme, navigation/routing, layout)
2. WHEN shared code exists in both palakat_admin and palakat_shared THEN the system SHALL use the palakat_shared version and remove the palakat_admin duplicate
3. WHEN palakat_admin imports core functionality THEN the system SHALL import from palakat_shared package instead of local core folder
4. IF code differences exist between palakat_admin and palakat_shared versions THEN the system SHALL merge functionality to support both use cases
5. WHEN palakat_admin needs models, repositories, services, extensions, utils, validation, or widgets THEN the system SHALL import them from palakat_shared
6. WHEN barrel exports are updated THEN the system SHALL re-export palakat_shared components for backward compatibility
7. WHEN the consolidation is complete THEN the palakat mobile app core folder SHALL remain unchanged

---

### Requirement 25: Widget Migration to Shared Package

**User Story:** As a developer, I want all custom widgets consolidated in the shared package, so that I can maintain consistency across both apps and have centralized control over UI components.

#### Acceptance Criteria

1. WHEN a widget exists in both palakat and palakat_admin apps, THE Shared Package SHALL contain a single unified implementation of that widget
2. WHEN a widget is mobile-specific (e.g., bottom navbar, mobile scaffold), THE Shared Package SHALL organize it in a platform-specific subdirectory
3. WHEN a widget is migrated to the shared package, THE palakat app SHALL import the widget from palakat_shared instead of local definitions
4. WHEN a widget is migrated to the shared package, THE palakat_admin app SHALL import the widget from palakat_shared instead of local definitions
5. WHEN all widgets are migrated, THE palakat app core/widgets directory SHALL contain only re-exports or platform-specific wrappers

---

### Requirement 26: Widget Organization Structure

**User Story:** As a developer, I want widgets organized by category in the shared package, so that I can easily find and maintain related components.

#### Acceptance Criteria

1. WHEN widgets are organized, THE Shared Package SHALL group widgets by functional category (input, button, card, dialog, loading, error, layout)
2. WHEN a new widget category is added, THE Shared Package SHALL provide a barrel export file for that category
3. WHEN the widgets barrel file is updated, THE Shared Package SHALL export all widget categories through a single widgets.dart file

---

### Requirement 27: Financial Account Number Unique Constraint

**User Story:** As a church administrator, I want each financial account number to be linked to only one approval rule, so that financial approval workflows remain clear and unambiguous.

#### Acceptance Criteria

1. WHEN a financial account number is already linked to an approval rule, THE Backend SHALL reject attempts to link the same account to another rule
2. WHEN creating an approval rule with a financial account number, THE Backend SHALL validate that the account is not already linked to another rule
3. WHEN updating an approval rule to use a financial account number, THE Backend SHALL validate that the account is not already linked to a different rule
4. WHEN the database schema is updated, THE FinancialAccountNumber model SHALL have a unique constraint on the approval rule relationship
5. IF a duplicate financial account link is attempted, THEN THE Backend SHALL return a clear error message indicating the account is already assigned

---

### Requirement 28: Seed Data Compliance

**User Story:** As a developer, I want the seed data to comply with the unique financial account constraint, so that the development database reflects production constraints.

#### Acceptance Criteria

1. WHEN seeding approval rules, THE Seed Script SHALL assign each financial account number to at most one approval rule
2. WHEN seeding financial data, THE Seed Script SHALL verify no duplicate financial account assignments exist
3. WHEN the seed script completes, THE Database SHALL contain approval rules with unique financial account number assignments

---

### Requirement 29: Frontend Validation for Financial Account Selection

**User Story:** As an admin user, I want the financial account picker to show only available accounts, so that I cannot accidentally select an account already assigned to another rule.

#### Acceptance Criteria

1. WHEN displaying financial accounts in the approval rule form, THE Financial Account Picker SHALL filter out accounts already linked to other approval rules
2. WHEN editing an existing approval rule, THE Financial Account Picker SHALL include the currently assigned account in the available options
3. WHEN no available financial accounts exist, THE Financial Account Picker SHALL display an appropriate message indicating all accounts are assigned

---

### Requirement 30: Financial Type Requires Financial Account Number

**User Story:** As a church administrator, I want the system to require a financial account number when a financial type is selected for an approval rule, so that financial workflows are always properly linked to specific accounts.

#### Acceptance Criteria

1. WHEN creating an approval rule with a financial type selected, THE Backend SHALL reject the request if no financial account number is provided
2. WHEN updating an approval rule to add a financial type, THE Backend SHALL reject the request if no financial account number is provided
3. WHEN a financial type is selected in the approval rule form, THE Admin Panel SHALL display the financial account number field as required
4. IF a user attempts to save an approval rule with a financial type but no financial account number, THEN THE Admin Panel SHALL display a validation error message

---

### Requirement 31: Searchable Financial Account Picker

**User Story:** As an admin user, I want to search financial accounts by description or name, so that I can quickly find the correct account when there are many options.

#### Acceptance Criteria

1. WHEN the financial account picker is displayed, THE Picker SHALL provide a search input field
2. WHEN a user types in the search field, THE Picker SHALL filter accounts by matching the description field
3. WHEN no accounts match the description search, THE Picker SHALL fallback to matching by account number
4. WHEN search results are displayed, THE Picker SHALL show matching accounts in a scrollable list

---

### Requirement 32: Searchable Membership Positions Picker

**User Story:** As an admin user, I want to search membership positions by name, so that I can quickly find the correct position when there are many options.

#### Acceptance Criteria

1. WHEN the position selector dropdown is displayed, THE Selector SHALL provide a search input field
2. WHEN a user types in the search field, THE Selector SHALL filter positions by matching the position name
3. WHEN search results are displayed, THE Selector SHALL show matching positions in a scrollable list

---

### Requirement 33: Activity Approver Automatic Linking

**User Story:** As a church administrator, I want approval rules to be linked to specific activity types, so that the correct approvers are automatically assigned based on the type of activity being created.

#### Acceptance Criteria

1. WHEN an approval rule is created or updated THEN the ApprovalRule model SHALL support an optional activityType field that links to ActivityType enum values
2. WHEN an activity is created with a specific activityType THEN the system SHALL query approval rules that match the activity's activityType within the same church
3. WHEN no approval rules match the activityType THEN the system SHALL fall back to approval rules without an activityType filter within the same church
4. WHEN multiple approval rules match the activityType THEN the system SHALL use all matching active approval rules to determine approvers

---

### Requirement 34: Financial Type Filtering for Approval Rules

**User Story:** As a church administrator, I want approval rules to support financial type filtering, so that activities with financial data are routed to the appropriate financial approvers.

#### Acceptance Criteria

1. WHEN an approval rule is created or updated THEN the ApprovalRule model SHALL support an optional financialType field that links to FinancialType enum values (REVENUE, EXPENSE)
2. WHEN an activity with revenue data is created THEN the system SHALL identify approval rules that have financialType set to REVENUE
3. WHEN an activity with expense data is created THEN the system SHALL identify approval rules that have financialType set to EXPENSE
4. WHEN an activity has no financial data THEN the system SHALL exclude approval rules that have a financialType filter from consideration

---

### Requirement 35: Financial Account Number Filtering for Approval Rules

**User Story:** As a church administrator, I want approval rules to support financial account number filtering, so that activities with specific account numbers are routed to specialized approvers.

#### Acceptance Criteria

1. WHEN an approval rule is created or updated THEN the ApprovalRule model SHALL support an optional relation to FinancialAccountNumber
2. WHEN an activity with financial data is created THEN the system SHALL match the activity's financial account number with approval rules that have the same financialAccountNumber
3. WHEN an approval rule has both financialType and financialAccountNumber THEN the system SHALL require both conditions to match for the rule to apply
4. WHEN an approval rule has financialType but no financialAccountNumber THEN the system SHALL apply the rule to all activities with matching financialType regardless of account number

---

### Requirement 36: Automatic Approver Assignment on Activity Creation

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

---

### Requirement 37: Admin Panel Approval Rule Configuration

**User Story:** As an admin panel user, I want to configure approval rules with activity type and financial filters, so that I can set up automated approval workflows for my church.

#### Acceptance Criteria

1. WHEN viewing the approval rule form in the admin panel THEN the form SHALL display an optional activity type dropdown with SERVICE, EVENT, and ANNOUNCEMENT options
2. WHEN viewing the approval rule form in the admin panel THEN the form SHALL display an optional financial type dropdown with REVENUE and EXPENSE options
3. WHEN a financial type is selected THEN the form SHALL display an optional financial account number dropdown filtered by the selected financial type and church
4. WHEN saving an approval rule THEN the admin panel SHALL send the activityType, financialType, and financialAccountNumberId to the backend API
5. WHEN viewing the approval rules list THEN the admin panel SHALL display the configured activity type, financial type, and financial account number for each rule

---

### Requirement 38: Supervisor Self-Approval

**User Story:** As a mobile app user (supervisor), I want to be able to approve my own activity when I am also assigned as an approver, so that I can complete the approval workflow without requiring another person.

#### Acceptance Criteria

1. WHEN viewing an activity detail in the mobile app THEN the app SHALL check if the current user is both the supervisor and an approver
2. WHEN the current user is both supervisor and approver THEN the app SHALL display approval action buttons (approve/reject) for the user's own approver record
3. WHEN the supervisor approves their own approver record THEN the system SHALL update the approver status to APPROVED
4. WHEN the supervisor rejects their own approver record THEN the system SHALL update the approver status to REJECTED
5. WHEN displaying the activity detail THEN the app SHALL visually indicate when the supervisor is also an approver

---

### Requirement 39: InputWidget Migration

**User Story:** As a developer, I want to move the existing InputWidget from palakat to palakat_shared, so that both apps can use the same flexible input component with custom display support.

#### Acceptance Criteria

1. WHEN the InputWidget is moved to palakat_shared THEN the system SHALL refactor styling to use theme-based colors from `Theme.of(context)` instead of hardcoded BaseColor constants
2. WHEN the InputWidget is moved to palakat_shared THEN the system SHALL maintain the existing API including text, dropdown, and binaryOption constructors
3. WHEN the InputWidget dropdown variant is used with customDisplayBuilder THEN the system SHALL render the custom widget for the selected value display
4. WHEN the palakat app imports the shared InputWidget THEN the system SHALL maintain visual consistency with the current design through theme configuration

---

### Requirement 40: InputWidget Backward Compatibility

**User Story:** As a developer, I want backward compatibility when migrating to the shared InputWidget, so that existing code in both apps continues to work without breaking changes.

#### Acceptance Criteria

1. WHEN existing palakat code uses InputWidget.text THEN the system SHALL continue to function with identical behavior after migration
2. WHEN existing palakat code uses InputWidget.dropdown THEN the system SHALL continue to function with identical behavior after migration
3. WHEN existing palakat code uses InputWidget.binaryOption THEN the system SHALL continue to function with identical behavior after migration

---

### Requirement 41: Hierarchical Account Number Format

**User Story:** As a developer, I want the database seeder to use realistic hierarchical account numbers, so that test data accurately represents real-world financial account structures.

#### Acceptance Criteria

1. WHEN the seeder creates financial account numbers THEN the system SHALL use hierarchical format with dot separators (e.g., "1.2.22.44" for income, "2.1.01.01" for expense)
2. WHEN generating income accounts THEN the system SHALL use account numbers starting with "1" following the specified accounting conventions
3. WHEN generating expense accounts THEN the system SHALL use account numbers starting with "2" following the specified accounting conventions
4. WHEN the seeder runs THEN the system SHALL create accounts with varying hierarchy depths (2-4 levels) to test display flexibility


---

### Requirement 42: Approval Rule Name from Financial Account

**User Story:** As a church administrator, I want approval rules with financial accounts to automatically use the financial account description as the rule name, so that the rule purpose is immediately clear from its name.

#### Acceptance Criteria

1. WHEN an approval rule is created with a financial type and financial account number THEN the Backend_API SHALL automatically set the approval rule name to the financial account description
2. WHEN an approval rule is updated to link a financial account number THEN the Backend_API SHALL automatically update the approval rule name to the financial account description
3. WHEN an approval rule has a linked financial account THEN the Backend_API SHALL override any manually provided name with the financial account description
4. WHEN displaying approval rules in the admin panel THEN the system SHALL show the financial account description as the rule name for rules with linked financial accounts
5. WHEN the seeder creates approval rules with financial accounts THEN the seeder SHALL use the financial account name as the approval rule name
6. WHEN a financial account is not linked to an approval rule THEN the system SHALL use the manually provided rule name

---

### Requirement 43: Approver Module CRUD Operations

**User Story:** As a church administrator, I want to manage approver records through a REST API, so that I can assign members to approve specific activities and track their approval status.

#### Acceptance Criteria

1. WHEN a user sends a POST request to `/approver` with valid membershipId and activityId, THE Backend_API SHALL create a new approver record with UNCONFIRMED status and return the created record
2. WHEN a user sends a POST request with a duplicate membershipId and activityId combination, THE Backend_API SHALL reject the request with a 400 Bad Request error indicating the approver already exists
3. WHEN a user sends a POST request with a non-existent membershipId, THE Backend_API SHALL reject the request with a 404 Not Found error
4. WHEN a user sends a POST request with a non-existent activityId, THE Backend_API SHALL reject the request with a 404 Not Found error
5. WHEN a user sends a GET request to `/approver` without filters, THE Backend_API SHALL return a paginated list of all approver records
6. WHEN a user sends a GET request to `/approver` with a membershipId query parameter, THE Backend_API SHALL return only approver records for that membership
7. WHEN a user sends a GET request to `/approver` with an activityId query parameter, THE Backend_API SHALL return only approver records for that activity
8. WHEN a user sends a GET request to `/approver` with a status query parameter, THE Backend_API SHALL return only approver records matching that status
9. WHEN a user sends a GET request to `/approver/:id`, THE Backend_API SHALL return the specific approver record with related activity and membership details
10. WHEN a user sends a PATCH request to `/approver/:id` with a valid status, THE Backend_API SHALL update the approver record's status and return the updated record
11. WHEN a user sends a DELETE request to `/approver/:id`, THE Backend_API SHALL delete the approver record and return a success message
12. THE Approver Module SHALL use the same NestJS module structure as existing modules (controller, service, module, DTOs)
13. THE Approver Module SHALL use class-validator decorators for DTO validation
14. THE Approver Module SHALL be protected by JWT authentication using the existing AuthGuard
15. THE Approver Module SHALL follow the existing response format with `message` and `data` fields

---

### Requirement 44: Finance Edit Pre-populate

**User Story:** As a church member, I want to edit an attached financial record and see my previously entered values, so that I can make corrections without re-entering all information.

#### Acceptance Criteria

1. WHEN a user taps the edit button on an attached financial record THEN the Finance Create Screen SHALL display the previously entered amount value in the amount field
2. WHEN a user taps the edit button on an attached financial record THEN the Finance Create Screen SHALL display the previously selected account number in the account picker
3. WHEN a user taps the edit button on an attached financial record THEN the Finance Create Screen SHALL display the previously selected payment method in the payment method picker
4. WHEN the Finance Create Screen receives initial finance data THEN the Finance Create Screen SHALL validate that the initial data contains all required fields before populating
5. WHEN the Finance Create Screen is opened with initial data THEN the form SHALL be immediately valid if all required fields are populated
6. WHEN the Finance Create Screen is opened with initial data THEN the submit button SHALL be enabled if the form is valid
7. WHEN a user modifies any pre-populated field THEN the Finance Create Screen SHALL update validation state in real-time

---

### Requirement 45: Finance Delete Confirmation

**User Story:** As a church member, I want to confirm before deleting an attached financial record, so that I can avoid accidental data loss.

#### Acceptance Criteria

1. WHEN a user taps the remove button on an attached financial record THEN the Activity Publish Screen SHALL display a confirmation dialog
2. WHEN the confirmation dialog is displayed THEN the dialog SHALL show a clear message asking the user to confirm deletion
3. WHEN the user confirms deletion in the dialog THEN the Activity Publish Screen SHALL remove the attached financial record
4. WHEN the user cancels deletion in the dialog THEN the Activity Publish Screen SHALL keep the attached financial record unchanged



---

### Requirement 46: Activity Financial Filter

**User Story:** As an API consumer, I want to filter activities by their financial record status, so that I can retrieve only activities that have expenses, revenues, or no financial records attached.

#### Acceptance Criteria

1. WHEN the `hasExpense` query parameter is set to `true`, THE Backend_API SHALL return only activities that have an associated Expense record
2. WHEN the `hasExpense` query parameter is set to `false`, THE Backend_API SHALL return only activities that do not have an associated Expense record
3. WHEN the `hasRevenue` query parameter is set to `true`, THE Backend_API SHALL return only activities that have an associated Revenue record
4. WHEN the `hasRevenue` query parameter is set to `false`, THE Backend_API SHALL return only activities that do not have an associated Revenue record
5. WHEN both `hasExpense` and `hasRevenue` query parameters are omitted, THE Backend_API SHALL return activities regardless of their financial record status
6. WHEN `hasExpense=false` AND `hasRevenue=false` are both provided, THE Backend_API SHALL return only activities that have neither an Expense nor a Revenue record
7. WHEN `hasExpense=true` AND `hasRevenue=true` are both provided, THE Backend_API SHALL return only activities that have both an Expense AND a Revenue record
8. WHEN financial filters are combined with existing filters, THE Backend_API SHALL apply all filters together using AND logic

---

### Requirement 47: Announcement Activity Financial Support

**User Story:** As a church administrator, I want to attach financial records to announcement-type activities, so that I can track financial transactions associated with announcements.

#### Acceptance Criteria

1. WHEN a user creates an activity with activityType ANNOUNCEMENT THEN the System SHALL accept an optional finance object
2. WHEN a user creates an ANNOUNCEMENT activity with a finance object THEN the System SHALL create the corresponding Revenue or Expense record linked to the activity
3. WHEN a user queries activities with hasExpense or hasRevenue filters THEN the System SHALL return ANNOUNCEMENT activities that match the financial filter criteria
4. WHEN a user retrieves an ANNOUNCEMENT activity detail THEN the System SHALL include the linked financial record data in the response
5. WHEN an ANNOUNCEMENT activity with financial data is created THEN the System SHALL resolve approvers based on both activityType and financialAccountNumberId if provided

---

### Requirement 48: Mobile Approval Screen Redesign

**User Story:** As a church member with approval responsibilities, I want a redesigned approval screen that lets me quickly see and act on pending approvals, so that I can efficiently manage my approval tasks.

#### Acceptance Criteria

1. WHEN a user opens the approval screen THEN the System SHALL display activities grouped or filterable by approval status
2. WHEN a user views the approval screen THEN the System SHALL prominently highlight activities that require the current user's action
3. WHEN a user views an activity card THEN the System SHALL display the activity title, supervisor name, date, activity type, and overall approval status
4. WHEN a user has pending approval actions THEN the System SHALL display approve and reject action buttons directly on the activity card
5. WHEN a user taps approve or reject on an activity card THEN the System SHALL update the approval status and refresh the list
6. WHEN a user filters activities by date range THEN the System SHALL filter the displayed activities while maintaining status grouping
7. WHEN a user views the approval screen THEN the System SHALL display a count badge showing the number of pending approvals
8. WHEN the approval screen loads THEN the System SHALL fetch real activity data from the backend API
9. WHEN an activity has financial data attached THEN the System SHALL display a visual indicator showing whether it has revenue or expense
10. WHEN a user pulls to refresh the approval screen THEN the System SHALL reload the approval data from the backend

---

### Requirement 49: Approval Card and Detail Screen Redesign

**User Story:** As a church member, I want approval cards to be visually distinct and the detail screen to clearly present information, so that I can easily review and act on approvals.

#### Acceptance Criteria

1. WHEN the approval screen displays multiple cards THEN the System SHALL render each card with increased vertical spacing for clear visual separation
2. WHEN an approver name is displayed THEN the System SHALL render the name without a colored background container
3. WHEN an approver's status is displayed THEN the System SHALL use a prominent colored status indicator that is larger and more visible
4. WHEN a user opens the approval detail screen THEN the System SHALL display a clear header section with the activity title and type
5. WHEN the approval detail screen loads THEN the System SHALL display approval-specific information in a dedicated prominent section
6. WHEN the current user is a pending approver THEN the System SHALL display prominent approve and reject buttons
7. WHEN viewing the approval detail screen THEN the System SHALL display a "View Activity Details" link or button
8. WHEN the user taps "View Activity Details" THEN the System SHALL navigate to the activity detail screen in read-only mode

---

### Requirement 50: Icon Consolidation

**User Story:** As a developer, I want a centralized icon registry using Font Awesome, so that I can access all icons from a single location with consistent styling.

#### Acceptance Criteria

1. WHEN a developer needs to use an icon THEN the AppIcons class SHALL provide a static accessor returning a FontAwesomeIcons IconData
2. WHEN the font_awesome_flutter package is added THEN the pubspec.yaml SHALL include the dependency
3. WHEN rendering an icon THEN the system SHALL provide helper methods that apply consistent sizing
4. WHEN the migration is complete THEN all direct `Icons.*` usages in feature code SHALL be replaced with AppIcons accessors
5. WHEN the migration is complete THEN all `Assets.icons.*` SVG usages SHALL be replaced with AppIcons accessors
6. WHEN accessing icons THEN the AppIcons class SHALL organize icons into logical categories
7. WHEN the migration is complete THEN unused SVG icon files SHALL be removed
