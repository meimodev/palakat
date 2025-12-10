# Requirements Document

## Introduction

Palakat is a comprehensive church activity management and event notification system designed for Indonesian church communities (HKBP denomination). The system is a monorepo containing three interconnected applications: a Flutter mobile app for church members, a Flutter web admin panel for church administrators, and a NestJS REST API backend with PostgreSQL database.

The platform enables churches to:
- Manage members and organizational structure (columns, positions, BIPRA divisions)
- Track activities with multi-level approval workflows
- Handle financial operations (revenues and expenses) with centralized account number management
- Maintain a digital song book (hymnal) with NKB, NNBT, KJ, DSL books
- Generate reports and manage documents
- Support multi-tenant architecture for multiple churches
- Send push notifications via Pusher Beams
- Support multi-language (Indonesian/English) interface

This specification serves as the comprehensive system documentation, consolidating all feature requirements from:
- push-notification
- multi-language-support
- push-notification-ux-improvements
- Previous palakat-complete iterations

## Glossary

### System Components
- **Palakat_System**: The complete platform including Mobile_App, Admin_Panel, and Backend_API
- **Mobile_App**: Flutter-based mobile application for church members (iOS/Android) at `apps/palakat`
- **Admin_Panel**: Flutter-based web application for church administrators at `apps/palakat_admin`
- **Backend_API**: NestJS REST API providing data persistence and business logic at `apps/palakat_backend`
- **Shared_Package**: Reusable Flutter code shared between apps at `packages/palakat_shared`

### User Roles
- **Member**: A church member with an account in the system
- **Administrator**: A church staff member with elevated permissions
- **Approver**: A member designated to review and approve specific activities
- **Supervisor**: The member who creates and oversees an activity

### Domain Concepts
- **Activity**: A church event, service, or announcement requiring approval workflow
- **Approval_Workflow**: A multi-step process where designated approvers review activities
- **Approval_Rule**: Configuration defining which positions approve certain activity/financial types
- **BIPRA**: Church organizational units (PKB, WKI, PMD, RMJ, ASM)
- **Column**: A church sub-group or division for organizing members
- **Membership_Position**: A role or title held by a member within the church
- **Song_Book**: Digital hymnal containing songs from multiple books
- **Church_Request**: A request to register a new church in the system

### Financial Concepts
- **Revenue**: Financial record representing income associated with a church activity
- **Expense**: Financial record representing expenditure associated with a church activity
- **Financial_Account_Number**: Predefined account number record with account number string and description
- **Payment_Method**: Method of payment (CASH or CASHLESS)
- **FinancialType**: Classification of financial data (REVENUE, EXPENSE)

### Notification Concepts
- **Pusher Beams**: Push notification service supporting device interests
- **Device Interest**: Topic-based subscription for targeted notifications
- **System Notification**: Native Android/iOS notification in notification tray
- **Permission Rationale**: Explanation shown before requesting notification permissions

### Localization Concepts
- **Locale**: Language and country code combination (id_ID, en_US)
- **ARB File**: Application Resource Bundle for storing translated strings
- **AppLocalizations**: Generated class providing type-safe access to translations

### Technical Terms
- **JWT**: JSON Web Token for authentication
- **Refresh_Token**: Long-lived token for obtaining new access tokens
- **Hive**: Local key-value storage for Flutter apps
- **Prisma**: ORM used by Backend_API for database operations
- **Riverpod**: State management library for Flutter apps

---

## Requirements

### Requirement 1: User Authentication

**User Story:** As a church member, I want to securely sign in using my phone number and password, so that I can access my personalized church information.

#### Acceptance Criteria
1. WHEN valid credentials provided, Backend_API SHALL return JWT access token and refresh token
2. WHEN invalid credentials provided, Backend_API SHALL reject with appropriate error
3. WHEN account locked due to failed attempts, Backend_API SHALL prevent authentication until lock expires
4. WHEN access token expires, Mobile_App SHALL use refresh token to obtain new access token
5. WHEN user signs out, Backend_API SHALL invalidate refresh token
6. Backend_API SHALL enforce role-based access control for protected endpoints
7. Mobile_App SHALL store authentication tokens securely using Hive

---

### Requirement 2: Firebase Phone Authentication

**User Story:** As a church member, I want to authenticate using my phone number with SMS verification.

#### Acceptance Criteria
1. Mobile_App SHALL display phone input with country code defaulting to Indonesia (+62)
2. WHEN valid phone entered, Mobile_App SHALL initiate Firebase Phone Auth and send SMS OTP
3. Mobile_App SHALL display OTP verification screen with 6-digit input
4. WHEN OTP verified, Mobile_App SHALL call Backend_API validation endpoint
5. WHEN validation succeeds, Mobile_App SHALL store tokens and navigate to home
6. WHEN validation returns empty account, Mobile_App SHALL navigate to registration
7. Mobile_App SHALL display 120-second countdown for OTP resend

---

### Requirement 3: Member Management

**User Story:** As a church administrator, I want to manage member profiles and organizational structure.

#### Acceptance Criteria
1. Admin_Panel SHALL allow creating members with name, phone, email, gender, marital status, DOB
2. Admin_Panel SHALL allow assigning members to columns and BIPRA units
3. Admin_Panel SHALL allow assigning membership positions to members
4. Backend_API SHALL persist member updates with timestamp
5. Admin_Panel SHALL display paginated member list with search and filter
6. Backend_API SHALL ensure phone numbers are unique across accounts
7. Backend_API SHALL ensure email uniqueness where provided

---

### Requirement 4: Activity Management

**User Story:** As a church member, I want to create activities and have them reviewed by designated approvers.

#### Acceptance Criteria
1. Mobile_App SHALL allow supervisors to create activities with title, description, date, location, type, BIPRA
2. WHEN activity created, Backend_API SHALL automatically assign approvers based on approval rules
3. Mobile_App SHALL display activities assigned to member as supervisor or approver
4. Mobile_App SHALL allow approvers to mark activities as APPROVED or REJECTED
5. Mobile_App SHALL display current approval status for each approver
6. Admin_Panel SHALL allow viewing all activities with filtering
7. WHEN activity deleted, Backend_API SHALL cascade delete approver records
8. Backend_API SHALL support activity types: SERVICE, EVENT, ANNOUNCEMENT
9. Backend_API SHALL support BIPRA units: PKB, WKI, PMD, RMJ, ASM

---

### Requirement 5: Activity Reminder

**User Story:** As a supervisor, I want to set reminder times for SERVICE or EVENT activities.

#### Acceptance Criteria
1. WHEN creating SERVICE/EVENT with reminder, Backend_API SHALL persist reminder value
2. WHEN creating ANNOUNCEMENT, Backend_API SHALL accept without reminder field
3. Backend_API SHALL validate reminder is one of: TEN_MINUTES, THIRTY_MINUTES, ONE_HOUR, TWO_HOURS
4. Backend_API SHALL include reminder field in activity responses
5. WHEN updating activity, Backend_API SHALL persist updated reminder value

---

### Requirement 6: Supervised Activities

**User Story:** As a supervisor, I want to see my most recent supervised activities on the Operations screen.

#### Acceptance Criteria
1. WHEN Operations screen loads with supervised activities, System SHALL display "Supervised Activities" section with 3 most recent
2. WHEN no supervised activities, System SHALL hide the section
3. System SHALL show activity title, date, and type for each item
4. WHEN user taps activity, System SHALL navigate to activity detail
5. System SHALL display "See All" button navigating to full list
6. Supervised Activities List SHALL support pagination and filtering by type/date range

---

### Requirement 7: Approval Workflow Configuration

**User Story:** As an administrator, I want to configure approval rules that automatically assign approvers.

#### Acceptance Criteria
1. Admin_Panel SHALL allow creating approval rules with name, description, positions
2. Admin_Panel SHALL allow assigning multiple membership positions to a rule
3. Admin_Panel SHALL allow activating/deactivating approval rules
4. WHEN activity created, Backend_API SHALL apply active rules to determine approvers
5. Backend_API SHALL associate approval rules with specific churches

---

### Requirement 8: Financial Account Number Management

**User Story:** As an administrator, I want to manage predefined financial account numbers.

#### Acceptance Criteria
1. Admin_Panel SHALL display list of all financial account numbers for church
2. Admin_Panel SHALL allow creating account numbers with account number and description
3. Backend_API SHALL create Financial_Account_Number record associated with church
4. Backend_API SHALL validate account number uniqueness within same church
5. Backend_API SHALL support filtering by churchId and searching by account number/description
6. Admin_Panel SHALL display linked approval rule name for each account

---

### Requirement 9: Activity Finance (Revenue/Expense)

**User Story:** As a supervisor, I want to add revenue or expense records while publishing an activity.

#### Acceptance Criteria
1. WHEN Activity Publish Screen displayed for service/event, System SHALL show "Financial Record" section
2. WHEN user taps "Add Financial Record", System SHALL display Finance Type Picker
3. WHEN user selects finance type, System SHALL navigate to Finance Create Screen
4. Finance Create Screen SHALL show fields for amount, account number picker, payment method
5. System SHALL validate amount is positive integer
6. WHEN activity with finance submitted, System SHALL first create activity, then create finance record
7. System SHALL format currency with Indonesian Rupiah formatting (Rp prefix, thousand separators)

---

### Requirement 10: Financial Operations

**User Story:** As an administrator, I want to track revenues and expenses associated with activities.

#### Acceptance Criteria
1. Admin_Panel SHALL allow recording revenue with account number, amount, payment method, activity
2. Admin_Panel SHALL allow recording expenses with same fields
3. Backend_API SHALL support CASH and CASHLESS payment methods
4. Admin_Panel SHALL display paginated lists with date range filtering
5. Backend_API SHALL create one-to-one relationship between financial record and activity
6. Admin_Panel SHALL display total revenue and expense for selected date ranges

---

### Requirement 11: Digital Song Book

**User Story:** As a church member, I want to access a digital hymnal with searchable songs.

#### Acceptance Criteria
1. Mobile_App SHALL display songs organized by book (NKB, NNBT, KJ, DSL) and index
2. WHEN member selects song, Mobile_App SHALL display title, book, index, and all parts
3. Mobile_App SHALL allow searching songs by title or index number
4. Backend_API SHALL store songs with multiple parts (index, name, content)
5. Admin_Panel SHALL allow creating and editing songs with multiple parts
6. Backend_API SHALL ensure song index numbers are unique
7. Mobile_App SHALL display song parts in sequential order by part index

---

### Requirement 12: Church and Location Management

**User Story:** As an administrator, I want to manage church information and locations.

#### Acceptance Criteria
1. Admin_Panel SHALL allow creating/editing church profiles with name, phone, email, description
2. Backend_API SHALL associate each church with exactly one location (name, lat, lng)
3. Admin_Panel SHALL allow managing columns within a church
4. Backend_API SHALL ensure column names are unique within each church
5. Mobile_App SHALL display church location on Google Maps
6. Backend_API SHALL support multiple churches for multi-tenant capability

---

### Requirement 13: Church Registration Request

**User Story:** As a member, I want to request registration of a new church when mine isn't in the system.

#### Acceptance Criteria
1. Mobile_App SHALL allow members without church membership to submit registration request
2. Backend_API SHALL associate each request with requesting user's account
3. Backend_API SHALL enforce one church request per user account
4. Backend_API SHALL support statuses: TODO, DOING, DONE
5. Mobile_App SHALL display current status of user's church request
6. Admin_Panel SHALL allow viewing and updating church request status

---

### Requirement 14: Document and Report Management

**User Story:** As an administrator, I want to upload documents and generate reports.

#### Acceptance Criteria
1. Admin_Panel SHALL allow uploading documents with name and account number
2. Backend_API SHALL store uploaded files with size and URL
3. Admin_Panel SHALL allow generating reports manually or automatically
4. Backend_API SHALL create report records with generation method (MANUAL or SYSTEM)
5. Admin_Panel SHALL display documents and reports with pagination and filtering

---

### Requirement 15: Multi-Church Data Isolation

**User Story:** As an administrator, I want to support multiple churches with data isolation.

#### Acceptance Criteria
1. Backend_API SHALL associate all church-specific data with church identifier
2. Backend_API SHALL enforce data isolation between churches
3. WHEN user authenticates, Backend_API SHALL determine church affiliation through membership
4. Backend_API SHALL filter all queries to return only data belonging to user's church
5. Admin_Panel SHALL display only data for administrator's assigned church
6. Mobile_App SHALL display only data for member's assigned church

---

### Requirement 16: Push Notification Data Model

**User Story:** As a system administrator, I want all notifications persisted in the database.

#### Acceptance Criteria
1. Backend_API SHALL have Notification model with: id, title, body, type, recipient, activityId, isRead, timestamps
2. Backend_API SHALL store notification record with recipient interest name and activity ID
3. Backend_API SHALL return notification with all related data including activity details
4. Backend_API SHALL update isRead field when notification marked as read
5. Backend_API SHALL support filtering by recipient, isRead status, and type

---

### Requirement 17: Pusher Beams Backend Integration

**User Story:** As a backend developer, I want to integrate Pusher Beams for push notifications.

#### Acceptance Criteria
1. Backend_API SHALL initialize Pusher Beams client with instance ID and secret key from env
2. WHEN sending to BIPRA group, Backend_API SHALL publish to `church.{churchId}_bipra.{bipra}`
3. WHEN sending to membership, Backend_API SHALL publish to `membership.{membershipId}`
4. WHEN Pusher API fails, Backend_API SHALL log error and continue without blocking
5. Backend_API SHALL include title, body, and deep link data in notification payload

---

### Requirement 18: Mobile App Push Notification Integration

**User Story:** As a mobile app user, I want to receive push notifications on my device.

#### Acceptance Criteria
1. WHEN Mobile_App launches, it SHALL initialize Pusher Beams SDK with instance ID
2. WHEN user signed in, Mobile_App SHALL subscribe to applicable device interests
3. Mobile_App SHALL log each interest registration with interest name
4. WHEN user logs out, Mobile_App SHALL unsubscribe from all interests and clear state
5. WHEN push notification received, Mobile_App SHALL display notification and handle tap navigation

---

### Requirement 19: Admin Panel Push Notification Integration

**User Story:** As an admin panel user, I want to receive push notifications in my browser.

#### Acceptance Criteria
1. WHEN Admin_Panel loads, it SHALL initialize Pusher Beams web SDK
2. WHEN admin signs in, Admin_Panel SHALL subscribe to applicable device interests
3. WHEN admin signs out, Admin_Panel SHALL unsubscribe from all interests
4. WHEN push notification received, Admin_Panel SHALL display browser notification
5. WHEN notification clicked, Admin_Panel SHALL navigate to relevant screen

---

### Requirement 20: Activity Creation Notification

**User Story:** As a church member, I want to be notified when a new activity is created in my BIPRA.

#### Acceptance Criteria
1. WHEN activity created, Backend_API SHALL send notification to BIPRA device interest
2. WHEN activity created with approvers, Backend_API SHALL send individual notifications to each approver
3. Backend_API SHALL create Notification record for each recipient
4. BIPRA notification title SHALL include activity title, body SHALL include type and date
5. Approver notification body SHALL indicate approval is required

---

### Requirement 21: Approval Status Change Notification

**User Story:** As a supervisor, I want to be notified when my activity's approval status changes.

#### Acceptance Criteria
1. WHEN approver confirms/rejects, Backend_API SHALL notify supervisor via membership interest
2. WHEN approver confirms/rejects, Backend_API SHALL notify other unconfirmed approvers
3. WHEN supervisor is also approver, Backend_API SHALL send only one notification
4. Notification body SHALL include approver's name and new status
5. Backend_API SHALL create Notification record for each recipient

---

### Requirement 22: Notification CRUD API

**User Story:** As a client application, I want to perform CRUD operations on notifications.

#### Acceptance Criteria
1. GET request SHALL return paginated notifications filtered by authenticated user's account
2. GET by ID SHALL return notification details if user is recipient
3. PATCH request SHALL update isRead field and return updated notification
4. DELETE request SHALL soft-delete or remove notification record
5. List response SHALL return unread count in metadata

---

### Requirement 23: Multi-Language Support

**User Story:** As a user, I want to select my preferred language (Indonesian or English).

#### Acceptance Criteria
1. WHEN application starts first time, it SHALL default to Indonesian locale
2. WHEN user navigates to account/settings, System SHALL display language selection option
3. WHEN user selects different language, System SHALL immediately update all visible text
4. WHEN user selects language, System SHALL persist selection to local storage
5. WHEN application restarts, System SHALL restore previously selected language

---

### Requirement 24: Localization Infrastructure

**User Story:** As a developer, I want centralized localization infrastructure in the shared package.

#### Acceptance Criteria
1. Palakat_Shared SHALL contain ARB files for both languages
2. System SHALL generate type-safe accessor methods via intl code generation
3. Developer SHALL add translations to both intl_id.arb and intl_en.arb files
4. System SHALL produce AppLocalizations class with all translation methods
5. Code generation SHALL fail if translation key exists in one ARB but not other

---

### Requirement 25: Notification Permission Flow

**User Story:** As a mobile user, I want to understand why the app needs notification permissions.

#### Acceptance Criteria
1. WHEN first push notification registration, Mobile_App SHALL show permission rationale bottom sheet
2. Bottom sheet SHALL explain benefits of enabling notifications
3. Bottom sheet SHALL have "Allow Notifications" and "Not Now" buttons
4. WHEN user taps "Allow", Mobile_App SHALL request system permissions
5. WHEN user taps "Not Now", Mobile_App SHALL dismiss and continue without requesting

---

### Requirement 26: Permission Denial Handling

**User Story:** As a user who denied permissions, I want to understand consequences and enable later.

#### Acceptance Criteria
1. WHEN user denies permissions, Mobile_App SHALL show consequence explanation bottom sheet
2. Bottom sheet SHALL list what user will miss (activity notifications, approval requests)
3. Bottom sheet SHALL have "Enable in Settings" and "Continue Without" buttons
4. WHEN user taps "Enable in Settings", Mobile_App SHALL open system settings
5. WHEN user taps "Continue Without", Mobile_App SHALL dismiss and continue

---

### Requirement 27: Notification Channels (Android)

**User Story:** As an Android user, I want to control notification settings for different types.

#### Acceptance Criteria
1. WHEN Mobile_App initializes on Android, it SHALL create channels for Activity Updates, Approval Requests, General Announcements
2. WHEN notification displayed, Mobile_App SHALL assign to appropriate channel based on type
3. WHEN user opens notification settings, user SHALL see separate controls for each channel
4. Approval Requests channel SHALL have HIGH importance, Activity Updates DEFAULT, General LOW

---

### Requirement 28: Notification Badge Count (iOS)

**User Story:** As an iOS user, I want to see badge count on app icon showing unread notifications.

#### Acceptance Criteria
1. WHEN notification received on iOS, Mobile_App SHALL increment app icon badge count
2. WHEN user opens Mobile_App, it SHALL clear badge count
3. WHEN user marks notifications as read, Mobile_App SHALL decrement badge count
4. WHEN all notifications read, badge count SHALL be zero (hidden)

---

### Requirement 29: Activity Approver Automatic Linking

**User Story:** As an administrator, I want approval rules linked to activity types for automatic approver assignment.

#### Acceptance Criteria
1. ApprovalRule model SHALL support optional activityType field linking to ActivityType enum
2. WHEN activity created with specific activityType, System SHALL query matching approval rules
3. WHEN no rules match activityType, System SHALL fall back to rules without activityType filter
4. WHEN multiple rules match, System SHALL use all matching active rules to determine approvers
5. System SHALL deduplicate membership positions from multiple rules
6. System SHALL find memberships holding those positions within same church
7. System SHALL create Approver records linking memberships to activity
8. WHEN supervisor holds matching position, System SHALL include supervisor as approver (self-approval)

---

### Requirement 30: Financial Type Filtering for Approval Rules

**User Story:** As an administrator, I want approval rules to support financial type filtering.

#### Acceptance Criteria
1. ApprovalRule model SHALL support optional financialType field (REVENUE, EXPENSE)
2. WHEN activity with revenue created, System SHALL identify rules with financialType REVENUE
3. WHEN activity with expense created, System SHALL identify rules with financialType EXPENSE
4. WHEN activity has no financial data, System SHALL exclude financial-type rules

---

### Requirement 31: Financial Account Unique Constraint

**User Story:** As an administrator, I want each financial account linked to only one approval rule.

#### Acceptance Criteria
1. WHEN financial account already linked to rule, Backend SHALL reject linking to another rule
2. WHEN creating rule with financial account, Backend SHALL validate account not already linked
3. WHEN updating rule to use financial account, Backend SHALL validate account not linked elsewhere
4. FinancialAccountNumber model SHALL have unique constraint on approval rule relationship

---

### Requirement 32: Searchable Financial Account Picker

**User Story:** As an admin user, I want to search financial accounts by description or name.

#### Acceptance Criteria
1. WHEN financial account picker displayed, Picker SHALL provide search input field
2. WHEN user types in search, Picker SHALL filter accounts by matching description
3. WHEN no accounts match description, Picker SHALL fallback to matching by account number
4. Search results SHALL show matching accounts in scrollable list

---

### Requirement 33: Searchable Membership Positions Picker

**User Story:** As an admin user, I want to search membership positions by name.

#### Acceptance Criteria
1. WHEN position selector displayed, Selector SHALL provide search input field
2. WHEN user types in search, Selector SHALL filter positions by matching name
3. Search results SHALL show matching positions in scrollable list

---

### Requirement 34: Approver Module CRUD Operations

**User Story:** As an administrator, I want to manage approver records through REST API.

#### Acceptance Criteria
1. POST /approver with valid membershipId and activityId SHALL create approver with UNCONFIRMED status
2. POST with duplicate membershipId/activityId SHALL reject with 400 error
3. GET /approver SHALL return paginated list of all approver records
4. GET /approver with filters SHALL return filtered records (membershipId, activityId, status)
5. PATCH /approver/:id with valid status SHALL update and return updated record
6. DELETE /approver/:id SHALL delete record and return success message

---

### Requirement 35: Finance Edit Pre-populate

**User Story:** As a member, I want to edit attached financial record and see previously entered values.

#### Acceptance Criteria
1. WHEN user taps edit on attached finance, Finance Create Screen SHALL display previous amount
2. Finance Create Screen SHALL display previously selected account number
3. Finance Create Screen SHALL display previously selected payment method
4. WHEN opened with initial data, form SHALL be immediately valid if all fields populated
5. WHEN user modifies pre-populated field, validation SHALL update in real-time

---

### Requirement 36: Finance Delete Confirmation

**User Story:** As a member, I want to confirm before deleting attached financial record.

#### Acceptance Criteria
1. WHEN user taps remove on attached finance, System SHALL display confirmation dialog
2. Dialog SHALL explain that financial data will be removed
3. WHEN user confirms, System SHALL remove attached finance from activity
4. WHEN user cancels, System SHALL preserve attached finance
