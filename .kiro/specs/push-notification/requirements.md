# Requirements Document

## Introduction

This document specifies the requirements for implementing push notifications using Pusher Beams in the Palakat church management platform. The system will enable real-time notifications for activity creation and approval workflow events across the mobile app (Android/iOS) and admin panel. All notifications will be persisted in a new `Notification` Prisma model with full CRUD capabilities.

The notification system will leverage Pusher Beams' device interests feature to target specific groups (BIPRA divisions within churches) and individual users (approvers, supervisors) based on workflow events.

## Glossary

- **Pusher Beams**: A push notification service that supports device interests and authenticated users for targeted notifications
- **Device Interest**: A topic-based subscription mechanism in Pusher Beams that allows devices to subscribe to specific channels. The system uses the following interest patterns:
  - `palakat` - Global interest for all app users
  - `church.{churchId}` - Church-wide notifications
  - `church.{churchId}_bipra.{BIPRA}` - BIPRA division within a church (BIPRA in uppercase)
  - `church.{churchId}_column.{columnId}` - Column/group within a church
  - `church.{churchId}_column.{columnId}_bipra.{BIPRA}` - BIPRA within a specific column (BIPRA in uppercase)
  - `membership.{membershipId}` - Individual membership notifications
- **BIPRA**: Church organizational divisions (PKB, WKI, PMD, RMJ, ASM) used for grouping activities and members
- **Supervisor**: The membership who creates and oversees an activity
- **Approver**: A membership assigned to approve or reject an activity based on approval rules
- **Notification Model**: A Prisma database model that stores all notification records for audit and retrieval
- **Backend**: The NestJS REST API (`apps/palakat_backend`)
- **Mobile App**: The Flutter mobile application (`apps/palakat`) for Android and iOS
- **Admin Panel**: The Flutter web admin panel (`apps/palakat_admin`)

## Requirements

### Requirement 1: Notification Data Model

**User Story:** As a system administrator, I want all notifications to be persisted in the database, so that I can track notification history and provide users with a notification inbox.

#### Acceptance Criteria

1. WHEN the system initializes THEN the Backend SHALL have a Notification model with fields: id, title, body, type, recipient (String storing the interest name), activityId, isRead, createdAt, and updatedAt
2. WHEN a notification is created THEN the Backend SHALL store the notification record with the recipient interest name (e.g., `membership.{membershipId}` or `church.{churchId}_bipra.{bipra}`) and associated activity ID
3. WHEN a notification record is queried THEN the Backend SHALL return the notification with all related data including activity details
4. WHEN a notification is marked as read THEN the Backend SHALL update the isRead field to true and persist the change
5. WHEN notifications are listed THEN the Backend SHALL support filtering by recipient interest pattern, isRead status, and type

### Requirement 2: Pusher Beams Backend Integration

**User Story:** As a backend developer, I want to integrate Pusher Beams server SDK, so that the system can send push notifications to subscribed devices.

#### Acceptance Criteria

1. WHEN the Backend starts THEN the Backend SHALL initialize the Pusher Beams client with instance ID and secret key from environment variables
2. WHEN sending a notification to a BIPRA group THEN the Backend SHALL publish to the device interest formatted as `church.{churchId}_bipra.{bipra}`
3. WHEN sending a notification to a specific membership THEN the Backend SHALL publish to the device interest formatted as `membership.{membershipId}`
4. WHEN a Pusher Beams API call fails THEN the Backend SHALL log the error and continue processing without blocking the main operation
5. WHEN the notification payload is constructed THEN the Backend SHALL include title, body, and deep link data for navigation

### Requirement 3: Mobile App Pusher Beams Integration

**User Story:** As a mobile app user, I want to receive push notifications on my device, so that I am informed about new activities and approval requests.

#### Acceptance Criteria

1. WHEN the Mobile App launches THEN the Mobile App SHALL initialize the Pusher Beams SDK with the instance ID
2. WHEN a user is already signed in or completes sign-in on the home screen THEN the Mobile App SHALL subscribe to all applicable device interests: `palakat`, `church.{churchId}`, `church.{churchId}_bipra.{BIPRA}`, `church.{churchId}_column.{columnId}`, `church.{churchId}_column.{columnId}_bipra.{BIPRA}`, and `membership.{membershipId}`
3. WHEN subscribing to device interests THEN the Mobile App SHALL log each interest registration with the interest name
4. WHEN a user logs out THEN the Mobile App SHALL unsubscribe from all device interests, log each unregistration, and clear the Pusher Beams state
5. WHEN a push notification is received THEN the Mobile App SHALL display the notification and handle tap navigation to the relevant screen

### Requirement 4: Admin Panel Pusher Beams Integration

**User Story:** As an admin panel user, I want to receive push notifications in my browser, so that I am informed about approval requests requiring my attention.

#### Acceptance Criteria

1. WHEN the Admin Panel loads THEN the Admin Panel SHALL initialize the Pusher Beams web SDK with the instance ID
2. WHEN an admin signs in THEN the Admin Panel SHALL subscribe to all applicable device interests: `palakat`, `church.{churchId}`, `church.{churchId}_bipra.{BIPRA}`, `church.{churchId}_column.{columnId}`, `church.{churchId}_column.{columnId}_bipra.{BIPRA}`, and `membership.{membershipId}`
3. WHEN subscribing to device interests THEN the Admin Panel SHALL log each interest registration with the interest name
4. WHEN an admin signs out THEN the Admin Panel SHALL unsubscribe from all device interests, log each unregistration, and clear the Pusher Beams state
5. WHEN a push notification is received THEN the Admin Panel SHALL display a browser notification with the message content
6. WHEN a browser notification is clicked THEN the Admin Panel SHALL navigate to the relevant approval or activity screen

### Requirement 5: Activity Creation Notification

**User Story:** As a church member, I want to be notified when a new activity is created in my BIPRA division, so that I stay informed about upcoming events and services.

#### Acceptance Criteria

1. WHEN an activity is created THEN the Backend SHALL send a notification to the device interest `church.{churchId}_bipra.{BIPRA}` where BIPRA matches the activity's BIPRA in uppercase
2. WHEN an activity is created with approvers THEN the Backend SHALL send individual notifications to each approver's membership interest `membership.{membershipId}`
3. WHEN an activity creation notification is sent THEN the Backend SHALL create a Notification record for each recipient
4. WHEN the BIPRA notification is sent THEN the notification title SHALL include the activity title and the body SHALL include the activity type and date
5. WHEN the approver notification is sent THEN the notification body SHALL indicate that approval is required for the activity

### Requirement 6: Approval Status Change Notification

**User Story:** As an activity supervisor, I want to be notified when my activity's approval status changes, so that I can track the progress of my submissions.

#### Acceptance Criteria

1. WHEN an approver confirms or rejects an activity THEN the Backend SHALL notify the activity supervisor via `membership.{membershipId}` interest
2. WHEN an approver confirms or rejects an activity THEN the Backend SHALL notify other unconfirmed approvers via their `membership.{membershipId}` interests
3. WHEN the supervisor is also an approver THEN the Backend SHALL send only one notification to the supervisor combining both roles
4. WHEN an approval notification is sent THEN the notification body SHALL include the approver's name and the new status (approved/rejected)
5. WHEN an approval notification is sent THEN the Backend SHALL create a Notification record for each recipient

### Requirement 7: Notification CRUD API

**User Story:** As a client application, I want to perform CRUD operations on notifications, so that users can manage their notification inbox.

#### Acceptance Criteria

1. WHEN a GET request is made to list notifications THEN the Backend SHALL return paginated notifications filtered by the authenticated user's account ID
2. WHEN a GET request is made for a single notification THEN the Backend SHALL return the notification details if the user is the recipient
3. WHEN a PATCH request is made to mark a notification as read THEN the Backend SHALL update the isRead field and return the updated notification
4. WHEN a DELETE request is made THEN the Backend SHALL soft-delete or remove the notification record
5. WHEN notifications are listed THEN the Backend SHALL return unread count in the response metadata

### Requirement 8: Notification Service Architecture

**User Story:** As a developer, I want a well-structured notification service, so that notification logic is centralized and maintainable.

#### Acceptance Criteria

1. WHEN the notification module is created THEN the Backend SHALL have a NotificationService that handles all notification business logic
2. WHEN sending notifications THEN the NotificationService SHALL abstract Pusher Beams interactions from other services
3. WHEN the activity service creates an activity THEN the activity service SHALL call the NotificationService to handle notifications
4. WHEN the approver service updates approval status THEN the approver service SHALL call the NotificationService to handle notifications
5. WHEN notification payloads are constructed THEN the NotificationService SHALL use consistent formatting for titles and bodies
