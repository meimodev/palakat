# Requirements Document

## Introduction

This feature transforms the sign-out button in the dashboard screen into a settings button that opens a dedicated settings screen. The settings screen consolidates configurable options including account settings, membership settings, language settings (moved from account screen), sign-out functionality, and app version information. This provides users with a centralized location for all app configuration and preferences.

## Glossary

- **Settings_Screen**: A dedicated screen displaying configurable app settings and user preferences
- **Dashboard_Screen**: The main screen of the mobile app showing membership info, activities, and announcements
- **Account_Screen**: The screen for editing personal information (name, phone, email, DOB, gender, marital status)
- **Membership_Screen**: The screen for viewing and editing church membership details
- **Language_Selector**: A widget allowing users to switch between supported languages (Indonesian/English)
- **App_Version**: The current version number and build information of the mobile application

## Requirements

### Requirement 1

**User Story:** As a user, I want to access app settings from the dashboard, so that I can configure my preferences without navigating through multiple screens.

#### Acceptance Criteria

1. WHEN a user taps the settings button on the dashboard THEN the Settings_Screen SHALL navigate to and display the settings screen
2. WHEN the dashboard loads for a signed-in user THEN the Dashboard_Screen SHALL display a settings icon button in place of the current sign-out button
3. WHEN the settings button is displayed THEN the Dashboard_Screen SHALL use a gear/cog icon with appropriate styling consistent with the app theme

### Requirement 2

**User Story:** As a user, I want to view and access my account settings from the settings screen, so that I can easily update my personal information.

#### Acceptance Criteria

1. WHEN the settings screen is displayed THEN the Settings_Screen SHALL show an "Account Settings" menu item with appropriate icon
2. WHEN a user taps the "Account Settings" menu item THEN the Settings_Screen SHALL navigate to the Account_Screen with the current user's account ID
3. WHEN the Account_Screen is opened from settings THEN the Account_Screen SHALL load the user's existing account data for editing

### Requirement 3

**User Story:** As a user, I want to view and access my membership settings from the settings screen, so that I can easily update my church membership details.

#### Acceptance Criteria

1. WHEN the settings screen is displayed THEN the Settings_Screen SHALL show a "Membership Settings" menu item with appropriate icon
2. WHEN a user taps the "Membership Settings" menu item THEN the Settings_Screen SHALL navigate to the Membership_Screen with the current user's membership ID
3. WHEN the user has no membership THEN the Settings_Screen SHALL either hide the membership option or show it as disabled with appropriate messaging

### Requirement 4

**User Story:** As a user, I want to change the app language from the settings screen, so that I can use the app in my preferred language.

#### Acceptance Criteria

1. WHEN the settings screen is displayed THEN the Settings_Screen SHALL show a "Language" section with the Language_Selector widget
2. WHEN the Language_Selector is displayed THEN the Settings_Screen SHALL show the currently selected language
3. WHEN a user changes the language THEN the Settings_Screen SHALL apply the language change immediately across the app
4. WHEN the language setting is moved to settings screen THEN the Account_Screen SHALL no longer display the Language_Selector widget

### Requirement 5

**User Story:** As a user, I want to sign out from the settings screen, so that I can securely end my session.

#### Acceptance Criteria

1. WHEN the settings screen is displayed THEN the Settings_Screen SHALL show a "Sign Out" button at the bottom of the settings list
2. WHEN a user taps the "Sign Out" button THEN the Settings_Screen SHALL display a confirmation dialog before signing out
3. WHEN the user confirms sign out THEN the Settings_Screen SHALL unregister push notification interests and clear the session
4. WHEN sign out is successful THEN the Settings_Screen SHALL navigate the user to the home screen

### Requirement 6

**User Story:** As a user, I want to see the app version information, so that I can know which version of the app I am using.

#### Acceptance Criteria

1. WHEN the settings screen is displayed THEN the Settings_Screen SHALL show the app version number at the bottom of the screen
2. WHEN displaying version information THEN the Settings_Screen SHALL show both version name and build number in format "Version X.Y.Z (Build N)"
3. WHEN the version information is displayed THEN the Settings_Screen SHALL retrieve version data from the app's package info

### Requirement 7

**User Story:** As a user, I want the settings screen to have a consistent look and feel, so that it matches the rest of the app.

#### Acceptance Criteria

1. WHEN the settings screen is displayed THEN the Settings_Screen SHALL use the app's standard scaffold widget with back navigation
2. WHEN displaying menu items THEN the Settings_Screen SHALL use card-based sections with icons consistent with the app's design system
3. WHEN the settings screen is displayed THEN the Settings_Screen SHALL show a title "Settings" in the app bar
