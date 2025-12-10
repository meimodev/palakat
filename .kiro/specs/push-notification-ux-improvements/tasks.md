# Implementation Plan: Push Notification UX Improvements

- [x] 1. Set up project dependencies and configuration
  - Add flutter_local_notifications, permission_handler, app_settings, and kiri_check to pubspec.yaml
  - Configure Android notification icons and metadata
  - Configure iOS notification capabilities
  - _Requirements: All requirements depend on these dependencies_

- [x] 2. Implement notification channel configuration
  - Create NotificationChannel model class with id, name, description, importance, vibration, and sound properties
  - Create NotificationChannels constants class with activityUpdates, approvalRequests, and generalAnnouncements channels
  - Implement getChannelForType method to map notification types to channels
  - _Requirements: 8.1, 8.2, 8.5, 9.1, 9.2, 9.3_

- [x] 2.1 Write property test for notification channel assignment
  - **Property 7: Notification Channel Assignment**
  - **Validates: Requirements 8.2, 9.1, 9.2, 9.3**

- [x] 3. Implement permission state models and storage
  - Create PermissionStatus enum (notDetermined, granted, denied, permanentlyDenied)
  - Create PermissionStateModel with freezed (status, deniedAt, denialCount, lastCheckedAt)
  - Create NotificationSettingsModel with freezed for user preferences
  - Set up Hive boxes for permission_state and notification_settings
  - _Requirements: 7.1, 7.2, 7.3_

- [x] 3.1 Write property test for permission state persistence
  - **Property 4: Permission State Persistence**
  - **Validates: Requirements 7.1, 7.2, 7.3**

- [x] 4. Implement PermissionManagerService
  - Create abstract interface with getPermissionState, shouldShowRationale, requestPermissionsWithRationale, openAppSettings, storePermissionStatus, shouldRetryAfterDenial, and syncPermissionStatus methods
  - Implement concrete class using permission_handler and app_settings packages
  - Implement 7-day retry logic for denied permissions
  - Implement detection of permanent denial on Android
  - Implement permission status synchronization between storage and system
  - _Requirements: 4.1, 4.4, 4.5, 5.1, 5.4, 5.5, 6.1, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 4.1 Write property test for permission denial retry timing
  - **Property 5: Permission Denial Retry Timing**
  - **Validates: Requirements 6.1**

- [x] 4.2 Write property test for permission status synchronization
  - **Property 6: Permission Status Synchronization**
  - **Validates: Requirements 7.4, 7.5**

- [x] 4.3 Write unit tests for PermissionManagerService
  - Test getPermissionState returns correct state from storage and system
  - Test shouldShowRationale logic for different permission states
  - Test openAppSettings opens correct platform-specific settings
  - Test storePermissionStatus persists to Hive
  - Test shouldRetryAfterDenial with various timestamps
  - Test syncPermissionStatus updates storage when system status changes
  - _Requirements: 4.1, 4.4, 4.5, 5.1, 5.4, 5.5, 6.1, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 5. Implement NotificationDisplayService (broken down into subtasks)

- [x] 5.1 Create NotificationPayload model
  - Create NotificationPayload model class with title, body, icon, and data properties
  - Use freezed for immutability and json_serializable for serialization
  - Add validation for required fields
  - _Requirements: 1.2, 2.2_

- [x] 5.2 Create NotificationDisplayService interface
  - Create abstract interface with initializeChannels method
  - Add displayNotification method signature
  - Add setNotificationTapHandler method signature
  - Add clearAllNotifications method signature
  - Add updateBadgeCount method signature
  - _Requirements: 1.1, 1.3, 2.1, 2.3, 8.1, 10.1, 10.2, 10.3_

- [x] 5.3 Implement NotificationDisplayService - Channel Management
  - Implement concrete class using flutter_local_notifications
  - Implement initializeChannels method for Android notification channel creation
  - Configure channel properties (importance, vibration, sound)
  - Handle platform-specific channel setup
  - _Requirements: 8.1, 8.2_

- [x] 5.4 Implement NotificationDisplayService - Display Logic
  - Implement displayNotification method with channel assignment
  - Handle notification payload processing
  - Implement platform-specific notification display
  - Add error handling for display failures
  - _Requirements: 1.1, 1.2, 1.5, 2.1, 2.2_

- [x] 5.5 Implement NotificationDisplayService - Tap Handling
  - Implement setNotificationTapHandler method
  - Configure notification tap callback registration
  - Handle notification selection events
  - Pass notification data to callback
  - _Requirements: 1.3, 2.3_

- [x] 5.6 Implement NotificationDisplayService - Badge & Cleanup
  - Implement updateBadgeCount method for iOS badge management
  - Implement clearAllNotifications method
  - Handle platform-specific badge count updates
  - Add cleanup and resource management
  - _Requirements: 10.1, 10.2, 10.3, 10.5_

- [x] 5.7 Write property test for notification payload completeness
  - **Property 1: Notification Payload Completeness**
  - **Validates: Requirements 1.2, 2.2**

- [x] 5.8 Write property test for multiple notification display
  - **Property 3: Multiple Notification Display**
  - **Validates: Requirements 1.5**

- [x] 5.9 Write property test for badge count increment
  - **Property 8: Badge Count Increment**
  - **Validates: Requirements 10.1**

- [x] 5.10 Write property test for badge count decrement
  - **Property 9: Badge Count Decrement**
  - **Validates: Requirements 10.3**

- [x] 5.11 Write property test for badge count update propagation
  - **Property 10: Badge Count Update Propagation**
  - **Validates: Requirements 10.5**

- [x] 5.12 Write unit tests for NotificationDisplayService
  - Test initializeChannels creates all Android channels
  - Test displayNotification shows system notification with correct payload
  - Test setNotificationTapHandler registers callback
  - Test clearAllNotifications removes all notifications
  - Test updateBadgeCount updates iOS badge
  - _Requirements: 1.1, 1.2, 1.3, 1.5, 2.1, 2.2, 2.3, 8.1, 8.2, 10.1, 10.2, 10.3, 10.5_

- [x] 6. Implement NotificationNavigationService
  - Create service class with handleNotificationTap method
  - Implement routing logic for ACTIVITY_CREATED → activity detail
  - Implement routing logic for APPROVAL_REQUIRED → approval detail
  - Implement routing logic for APPROVAL_CONFIRMED → activity detail
  - Implement routing logic for APPROVAL_REJECTED → activity detail
  - Implement fallback routing for missing activityId → notification inbox
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 6.1 Write property test for notification navigation routing
  - **Property 2: Notification Navigation Routing**
  - **Validates: Requirements 1.3, 2.3**

- [x] 6.2 Write unit tests for NotificationNavigationService
  - Test ACTIVITY_CREATED navigates to /activities/:id
  - Test APPROVAL_REQUIRED navigates to /approvals/:id
  - Test APPROVAL_CONFIRMED navigates to /activities/:id
  - Test APPROVAL_REJECTED navigates to /activities/:id
  - Test missing activityId navigates to /notifications
  - Test invalid data navigates to /notifications (fallback)
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 7. Create permission rationale bottom sheet UI
  - Create PermissionRationaleBottomSheet widget
  - Add icon/illustration for visual appeal
  - Add title "Stay Updated"
  - Add benefits list (activity updates, approval requests, important announcements)
  - Add "Allow Notifications" primary button
  - Add "Not Now" text button
  - Wire up onAllow and onNotNow callbacks
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 7.1 Write widget tests for permission rationale bottom sheet
  - Test bottom sheet displays title and benefits
  - Test "Allow Notifications" button is present
  - Test "Not Now" button is present
  - Test onAllow callback fires when "Allow" tapped
  - Test onNotNow callback fires when "Not Now" tapped
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 8. Create consequence explanation bottom sheet UI
  - Create ConsequenceExplanationBottomSheet widget
  - Add warning/info icon
  - Add title "You'll Miss Out On"
  - Add consequences list (activity notifications, approval requests, important updates)
  - Add "Enable in Settings" primary button
  - Add "Continue Without Notifications" text button
  - Wire up onEnableInSettings and onContinueWithout callbacks
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 8.1 Write widget tests for consequence explanation bottom sheet
  - Test bottom sheet displays title and consequences
  - Test "Enable in Settings" button is present
  - Test "Continue Without Notifications" button is present
  - Test onEnableInSettings callback fires when "Enable" tapped
  - Test onContinueWithout callback fires when "Continue" tapped
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 9. Create notification permission banner UI
  - Create NotificationPermissionBanner widget with Riverpod
  - Add permissionStateProvider to watch permission status
  - Hide banner when permission is granted
  - Show banner with icon, text, and "Enable Notifications" button when denied
  - Add dismiss button
  - Wire up enable button to show permission rationale
  - _Requirements: 6.2, 6.3_

- [x] 9.1 Write widget tests for notification permission banner
  - Test banner hidden when permission granted
  - Test banner visible when permission denied
  - Test "Enable Notifications" button present when visible
  - Test dismiss button present when visible
  - Test enable button shows permission rationale
  - _Requirements: 6.2, 6.3_

- [x] 10. Update PusherBeamsMobileService with new functionality
  - Add PermissionManagerService and NotificationDisplayService dependencies
  - Implement initializeWithPermissions method that checks permission state
  - Implement setupForegroundNotificationHandler to display system notifications
  - Update initialize method to work with permission flow
  - Add error handling for permission denial scenarios
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 4.1, 4.4, 4.5_

- [x] 10.1 Write unit tests for updated PusherBeamsMobileService
  - Test initializeWithPermissions shows rationale when not granted
  - Test initializeWithPermissions calls initialize when granted
  - Test setupForegroundNotificationHandler displays system notification
  - Test foreground handler extracts payload correctly
  - Test foreground handler assigns correct channel
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 4.1, 4.4, 4.5_

- [x] 11. Implement background notification handling
  - Configure Android manifest for notification handling
  - Configure iOS Info.plist for notification handling
  - Implement notification tap handler in main.dart for cold start
  - Extract deep link data from notification payload
  - Pass deep link data to NotificationNavigationService
  - Handle app initialization before navigation
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 11.1 Write unit tests for background notification handling
  - Test notification tap extracts deep link data
  - Test cold start navigation waits for initialization
  - Test warm start navigation happens immediately
  - Test dismissal doesn't trigger navigation
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 12. Integrate permission flow into app initialization
  - Update app initialization in main.dart to call initializeWithPermissions
  - Add permission state provider to Riverpod
  - Implement permission re-request logic on sign-in (7-day check)
  - Add app lifecycle listener to detect return from settings
  - Trigger auto-registration when returning from settings with granted permission
  - _Requirements: 4.1, 6.1, 6.5_

- [x] 12.1 Write integration tests for permission flow
  - Test first-time permission request shows rationale
  - Test "Allow" triggers system permission request
  - Test "Not Now" dismisses without requesting
  - Test denial shows consequence explanation
  - Test "Enable in Settings" opens settings
  - Test return from settings triggers registration
  - Test 7-day re-request logic
  - _Requirements: 4.1, 4.4, 4.5, 5.1, 5.4, 5.5, 6.1, 6.5_

- [x] 13. Add notification permission banner to relevant screens
  - Add NotificationPermissionBanner to notification list screen
  - Add NotificationPermissionBanner to settings screen
  - Ensure banner respects permission state
  - Test banner visibility on different screens
  - _Requirements: 6.2, 6.3_

- [x] 14. Implement notification settings screen enhancements
  - Add permission status display
  - Add "Enable Notifications" button when denied
  - Add channel preference toggles (if possible on platform)
  - Add sound/vibration preference toggles
  - Persist settings to NotificationSettingsModel
  - _Requirements: 6.2, 6.3, 9.5_

- [x] 14.1 Write unit tests for notification settings
  - Test settings persistence to Hive
  - Test settings retrieval from Hive
  - Test default settings values
  - _Requirements: 9.5_

- [-] 15. Checkpoint - Ensure all tests pass
- [ ] 15.1 Run property-based tests
  - Run property tests in test/features/notification directory
  - Verify all property tests pass
  - _Requirements: All property test requirements_

- [x] 15.2 Run unit tests for services
  - Run unit tests for PermissionManagerService
  - Run unit tests for NotificationDisplayService
  - Run unit tests for NotificationNavigationService
  - Run unit tests for PusherBeamsMobileService
  - Verify all service unit tests pass
  - _Requirements: Service-related requirements_

- [x] 15.3 Run widget tests
  - Run widget tests for PermissionRationaleBottomSheet
  - Run widget tests for ConsequenceExplanationBottomSheet
  - Run widget tests for NotificationPermissionBanner
  - Verify all widget tests pass
  - _Requirements: UI-related requirements_

- [x] 15.4 Run integration tests
  - Run integration tests for permission flow
  - Run integration tests for notification handling
  - Verify all integration tests pass
  - _Requirements: Integration requirements_

- [x] 15.5 Run background notification tests
  - Run unit tests for background notification handling
  - Verify notification tap handling tests pass
  - _Requirements: Background notification requirements_

- [x] 15.6 Run settings tests
  - Run unit tests for notification settings
  - Verify settings persistence tests pass
  - _Requirements: Settings requirements_

- [ ] 15.7 Final verification
  - Run all tests together if previous subtasks passed
  - Ask user if any questions or issues arise
  - _Requirements: All requirements_

- [x] 16. Test on physical devices
  - Test foreground notifications on Android device
  - Test background notifications on Android device
  - Test notification channels on Android device
  - Test foreground notifications on iOS device
  - Test background notifications on iOS device
  - Test badge count on iOS device
  - Test permission flow on both platforms
  - Test settings navigation on both platforms
  - Verify notification sounds and vibration
  - Verify notification tap navigation

- [ ] 17. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
