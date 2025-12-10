# Requirements Document: Push Notification UX Improvements

## Introduction

This document specifies enhancements to the existing push notification system to improve user experience. The improvements focus on two key areas:

1. **Proper notification display**: Show system notifications when the app receives push notifications (foreground and background), allowing users to tap the notification to navigate rather than forcing immediate navigation
2. **Permission handling**: Gracefully handle notification permission denial with educational UI and retry mechanisms

These improvements build upon the existing push notification implementation specified in `.kiro/specs/push-notification/`.

## Glossary

- **System Notification**: The native Android/iOS notification that appears in the notification tray/center
- **Foreground Notification**: A push notification received while the app is open and visible
- **Background Notification**: A push notification received while the app is closed or in the background
- **Permission Rationale**: An explanation shown to users about why the app needs notification permissions
- **Bottom Sheet**: A modal UI component that slides up from the bottom of the screen
- **Deep Link**: Navigation data embedded in a notification that directs users to a specific screen
- **FCM**: Firebase Cloud Messaging, the underlying service for Android push notifications
- **APNs**: Apple Push Notification service, the underlying service for iOS push notifications

## Requirements

### Requirement 1: Foreground Notification Display

**User Story:** As a mobile app user, I want to see a system notification when I receive a push notification while using the app, so that I can choose when to view the content rather than being interrupted immediately.

#### Acceptance Criteria

1. WHEN a push notification is received while the Mobile App is in the foreground THEN the Mobile App SHALL display a system notification in the notification tray
2. WHEN the foreground notification is displayed THEN the notification SHALL include the title, body, and icon from the push payload
3. WHEN the user taps the foreground notification THEN the Mobile App SHALL navigate to the relevant screen based on the deep link data
4. WHEN the user dismisses the foreground notification THEN the Mobile App SHALL not navigate and SHALL continue normal operation
5. WHEN multiple foreground notifications are received THEN the Mobile App SHALL display each notification separately in the notification tray

### Requirement 2: Background Notification Display

**User Story:** As a mobile app user, I want to see system notifications when I receive push notifications while the app is closed, so that I am informed about important events.

#### Acceptance Criteria

1. WHEN a push notification is received while the Mobile App is in the background or closed THEN the operating system SHALL display a system notification automatically
2. WHEN the background notification is displayed THEN the notification SHALL include the title, body, and icon from the push payload
3. WHEN the user taps the background notification THEN the Mobile App SHALL launch (if closed) or come to foreground (if backgrounded) and navigate to the relevant screen
4. WHEN the user dismisses the background notification THEN the Mobile App SHALL not launch or navigate
5. WHEN the Mobile App is launched from a background notification THEN the Mobile App SHALL extract the deep link data and navigate after initialization completes

### Requirement 3: Notification Tap Handling

**User Story:** As a mobile app user, I want to be taken to the relevant activity or approval screen when I tap a notification, so that I can quickly access the content I was notified about.

#### Acceptance Criteria

1. WHEN a notification with activityId and type="ACTIVITY_CREATED" is tapped THEN the Mobile App SHALL navigate to the activity detail screen for that activityId
2. WHEN a notification with activityId and type="APPROVAL_REQUIRED" is tapped THEN the Mobile App SHALL navigate to the approval detail screen for that activityId
3. WHEN a notification with activityId and type="APPROVAL_CONFIRMED" is tapped THEN the Mobile App SHALL navigate to the activity detail screen for that activityId
4. WHEN a notification with activityId and type="APPROVAL_REJECTED" is tapped THEN the Mobile App SHALL navigate to the activity detail screen for that activityId
5. WHEN a notification without activityId is tapped THEN the Mobile App SHALL navigate to the home screen or notification inbox

### Requirement 4: Permission Request Flow

**User Story:** As a mobile app user, I want to understand why the app needs notification permissions before granting them, so that I can make an informed decision.

#### Acceptance Criteria

1. WHEN the Mobile App attempts to register push notifications for the first time THEN the Mobile App SHALL show a permission rationale bottom sheet before requesting system permissions
2. WHEN the permission rationale bottom sheet is displayed THEN the bottom sheet SHALL explain the benefits of enabling notifications (activity updates, approval requests, important announcements)
3. WHEN the permission rationale bottom sheet is displayed THEN the bottom sheet SHALL have "Allow Notifications" and "Not Now" buttons
4. WHEN the user taps "Allow Notifications" THEN the Mobile App SHALL request system notification permissions
5. WHEN the user taps "Not Now" THEN the Mobile App SHALL dismiss the bottom sheet and continue without requesting permissions

### Requirement 5: Permission Denial Handling

**User Story:** As a mobile app user who denied notification permissions, I want to understand the consequences and have an easy way to enable them later, so that I don't miss important updates.

#### Acceptance Criteria

1. WHEN the user denies notification permissions THEN the Mobile App SHALL show a consequence explanation bottom sheet
2. WHEN the consequence explanation bottom sheet is displayed THEN the bottom sheet SHALL list what the user will miss (activity notifications, approval requests, important updates)
3. WHEN the consequence explanation bottom sheet is displayed THEN the bottom sheet SHALL have "Enable in Settings" and "Continue Without Notifications" buttons
4. WHEN the user taps "Enable in Settings" THEN the Mobile App SHALL open the system settings page for the app's notification permissions
5. WHEN the user taps "Continue Without Notifications" THEN the Mobile App SHALL dismiss the bottom sheet and continue without push notification registration

### Requirement 6: Permission Re-request Flow

**User Story:** As a mobile app user who previously denied permissions, I want to be reminded about enabling notifications at appropriate times, so that I can reconsider my decision.

#### Acceptance Criteria

1. WHEN the user denied permissions and signs in again after 7 days THEN the Mobile App SHALL show the permission rationale bottom sheet again
2. WHEN the user denied permissions and navigates to the notifications/settings screen THEN the Mobile App SHALL show a banner with "Enable Notifications" button
3. WHEN the user taps "Enable Notifications" from the banner THEN the Mobile App SHALL show the permission rationale bottom sheet
4. WHEN the user has permanently denied permissions (selected "Don't ask again" on Android) THEN the Mobile App SHALL only show the "Enable in Settings" option
5. WHEN the user returns from settings after enabling permissions THEN the Mobile App SHALL automatically attempt to register push notifications

### Requirement 7: Permission Status Persistence

**User Story:** As a system, I want to track the user's notification permission status, so that I can provide appropriate UI and avoid repeatedly asking for permissions.

#### Acceptance Criteria

1. WHEN the user grants notification permissions THEN the Mobile App SHALL store the permission status as "granted" in local storage
2. WHEN the user denies notification permissions THEN the Mobile App SHALL store the permission status as "denied" with a timestamp in local storage
3. WHEN the user permanently denies permissions THEN the Mobile App SHALL store the permission status as "permanently_denied" in local storage
4. WHEN the Mobile App checks permission status THEN the Mobile App SHALL query both the stored status and the current system permission status
5. WHEN the system permission status changes (user enabled in settings) THEN the Mobile App SHALL update the stored status to match

### Requirement 8: Notification Channel Configuration (Android)

**User Story:** As an Android user, I want to control notification settings for different types of notifications, so that I can customize my notification experience.

#### Acceptance Criteria

1. WHEN the Mobile App initializes on Android THEN the Mobile App SHALL create notification channels for "Activity Updates", "Approval Requests", and "General Announcements"
2. WHEN a notification is displayed THEN the Mobile App SHALL assign it to the appropriate channel based on the notification type
3. WHEN the user opens notification settings THEN the user SHALL see separate controls for each notification channel
4. WHEN the user disables a notification channel THEN the Mobile App SHALL not display notifications for that channel
5. WHEN a notification channel is configured THEN the channel SHALL have appropriate importance level (HIGH for approvals, DEFAULT for activities)

### Requirement 9: Notification Sound and Vibration

**User Story:** As a mobile app user, I want notifications to have appropriate sound and vibration, so that I notice important updates.

#### Acceptance Criteria

1. WHEN an approval request notification is received THEN the notification SHALL play a sound and vibrate (if not in silent mode)
2. WHEN an activity update notification is received THEN the notification SHALL play a sound without vibration
3. WHEN a general announcement notification is received THEN the notification SHALL display silently without sound or vibration
4. WHEN the device is in Do Not Disturb mode THEN the Mobile App SHALL respect the system settings and not override them
5. WHEN notification sound/vibration settings are configured THEN the settings SHALL persist across app restarts

### Requirement 10: Notification Badge Count (iOS)

**User Story:** As an iOS user, I want to see a badge count on the app icon showing unread notifications, so that I know when I have pending items.

#### Acceptance Criteria

1. WHEN a notification is received on iOS THEN the Mobile App SHALL increment the app icon badge count
2. WHEN the user opens the Mobile App THEN the Mobile App SHALL clear the badge count
3. WHEN the user marks notifications as read THEN the Mobile App SHALL decrement the badge count accordingly
4. WHEN all notifications are read THEN the badge count SHALL be zero (hidden)
5. WHEN the badge count is updated THEN the change SHALL be visible immediately on the home screen

