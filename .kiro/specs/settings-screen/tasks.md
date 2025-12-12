# Implementation Plan

- [x] 1. Set up settings feature structure
  - [x] 1.1 Create settings feature directory structure
    - Create `apps/palakat/lib/features/settings/` directory
    - Create `presentations/` subdirectory
    - _Requirements: 7.1_

- [x] 2. Create SettingsState freezed class
  - [x] 2.1 Create settings_state.dart file
    - Define SettingsState with account, membership, appVersion, buildNumber, isSigningOut, errorMessage fields
    - Add freezed annotations
    - _Requirements: 2.1, 3.1, 6.1_
  - [x] 2.2 Run build_runner for SettingsState
    - Generate settings_state.freezed.dart
    - _Requirements: 2.1, 3.1, 6.1_

- [x] 3. Create SettingsController
  - [x] 3.1 Create settings_controller.dart file
    - Implement AsyncNotifier with @riverpod annotation
    - Add loadSettings method stub
    - Add signOut method stub
    - Add hasMembership getter
    - _Requirements: 2.2, 3.2, 5.3, 6.3_
  - [x] 3.2 Run build_runner for SettingsController
    - Generate settings_controller.g.dart
    - _Requirements: 2.2, 3.2, 5.3, 6.3_

- [x] 4. Create SettingsScreen UI - Basic Structure
  - [x] 4.1 Create settings_screen.dart with scaffold
    - Use ScaffoldWidget with back navigation
    - Add "Settings" title in app bar
    - _Requirements: 7.1, 7.3_

- [x] 5. Add settings menu items
  - [x] 5.1 Add account settings menu item
    - Add card with person icon and "Account Settings" label
    - _Requirements: 2.1_
  - [x] 5.2 Add membership settings menu item
    - Add card with group icon and "Membership Settings" label
    - Handle null membership case (disable or show message)
    - _Requirements: 3.1, 3.3_
  - [x] 5.3 Add language section
    - Add card with language icon and LanguageSelector widget
    - _Requirements: 4.1_
  - [x] 5.4 Add sign out button
    - Add red-styled sign out button at bottom
    - _Requirements: 5.1_
  - [x] 5.5 Add version info display
    - Add version text at bottom of screen
    - Format as "Version X.Y.Z (Build N)"
    - _Requirements: 6.1, 6.2_

- [x] 6. Implement sign out confirmation dialog
  - [x] 6.1 Create sign out confirmation bottom sheet
    - Create bottom sheet with warning icon, title, message
    - Add cancel and confirm buttons
    - _Requirements: 5.2_
  - [x] 6.2 Connect confirmation to controller
    - Call controller.signOut() on confirmation
    - _Requirements: 5.2_

- [x] 7. Implement navigation handlers
  - [x] 7.1 Add account settings navigation
    - Navigate to AccountScreen with accountId on tap
    - _Requirements: 2.2, 2.3_
  - [x] 7.2 Add membership settings navigation
    - Navigate to MembershipScreen with membershipId on tap
    - _Requirements: 3.2_

- [x] 8. Add settings routing
  - [x] 8.1 Add settings route constant
    - Add `static const String settings = 'settings'` to AppRoute class
    - _Requirements: 1.1_
  - [x] 8.2 Create settings_routing.dart
    - Create GoRoute for settings screen
    - _Requirements: 1.1_
  - [x] 8.3 Register settings route
    - Export in routing.dart and add to goRouter routes list
    - _Requirements: 1.1_

- [x] 9. Modify DashboardScreen - Replace button
  - [x] 9.1 Change sign out button to settings button
    - Change icon from AppIcons.logout to AppIcons.settings
    - Change background color from red to primary
    - Update tooltip text
    - _Requirements: 1.2, 1.3_
  - [x] 9.2 Update button navigation
    - Navigate to settings screen on tap
    - _Requirements: 1.1_
  - [x] 9.3 Clean up unused sign out code
    - Remove or relocate _showSignOutConfirmation function
    - _Requirements: 1.1_

- [x] 10. Modify AccountScreen - Remove language selector
  - [x] 10.1 Remove Language Settings section
    - Remove Material card containing LanguageSelector (lines ~270-300)
    - _Requirements: 4.4_
  - [x] 10.2 Clean up unused imports
    - Remove FontAwesomeIcons.language import if unused
    - _Requirements: 4.4_

- [x] 11. Implement sign out flow
  - [x] 11.1 Implement signOut method in controller
    - Set isSigningOut to true
    - Unregister push notification interests
    - Call authRepository.signOut()
    - _Requirements: 5.3_
  - [x] 11.2 Handle sign out navigation
    - Navigate to home screen on success
    - _Requirements: 5.4_
  - [x] 11.3 Handle sign out errors
    - Set error message on failure
    - Continue sign out even if push unregister fails
    - _Requirements: 5.3_

- [x] 12. Implement version info retrieval
  - [x] 12.1 Add package_info_plus dependency
    - Add to pubspec.yaml if not present
    - Run melos bootstrap
    - _Requirements: 6.3_
  - [x] 12.2 Implement loadSettings in controller
    - Use PackageInfo.fromPlatform() to get version
    - Update state with version and buildNumber
    - _Requirements: 6.1, 6.2, 6.3_
  - [x] 12.3 Handle version loading errors
    - Set "unknown" values on error
    - _Requirements: 6.3_

- [x] 13. Checkpoint - Verify core functionality
  - Ensure all tests pass, ask the user if questions arise.

- [x] 14. Write property test - Settings button visibility
  - [x] 14.1 Create settings_property_test.dart file
    - Set up test file with kiri_check imports
    - _Requirements: 1.2_
  - [x] 14.2 Implement Property 2 test
    - **Property 2: Settings button visibility**
    - Test that settings button visible iff account is not null
    - **Validates: Requirements 1.2**

- [x] 15. Write property test - Version format display
  - [x] 15.1 Implement Property 8 test
    - **Property 8: Version format display**
    - Test format "Version X.Y.Z (Build N)" for any version/build
    - **Validates: Requirements 6.2**

- [x] 16. Write property test - Settings navigation
  - [x] 16.1 Implement Property 1 test
    - **Property 1: Settings navigation from dashboard**
    - Test navigation triggers for signed-in users
    - **Validates: Requirements 1.1**

- [x] 17. Write property test - Account navigation
  - [x] 17.1 Implement Property 3 test
    - **Property 3: Account navigation with ID**
    - Test account ID passed correctly in navigation
    - **Validates: Requirements 2.2**

- [x] 18. Write property test - Membership navigation
  - [x] 18.1 Implement Property 4 test
    - **Property 4: Membership navigation with ID**
    - Test membership ID passed correctly in navigation
    - **Validates: Requirements 3.2**

- [-] 19. Write property test - Sign out confirmation
  - [x] 19.1 Implement Property 5 test
    - **Property 5: Sign out confirmation display**
    - Test confirmation dialog appears on sign out tap
    - **Validates: Requirements 5.2**

- [x] 20. Write property test - Sign out cleanup
  - [x] 20.1 Implement Property 6 test
    - **Property 6: Sign out cleanup execution**
    - Test push notification unregister and session clear
    - **Validates: Requirements 5.3**

- [-] 21. Write property test - Sign out navigation
  - [x] 21.1 Implement Property 7 test
    - **Property 7: Sign out navigation**
    - Test navigation to home after successful sign out
    - **Validates: Requirements 5.4**

- [x] 22. Write widget test - Language selector removal
  - [x] 22.1 Create account_screen_test.dart updates
    - Verify LanguageSelector not in AccountScreen widget tree
    - _Requirements: 4.4_

- [ ] 23. Final Checkpoint - All tests pass
  - Ensure all tests pass, ask the user if questions arise.
