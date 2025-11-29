# Requirements Document

## Introduction

This feature adds a "Supervised Activities" section to the Operations screen in the Palakat mobile app. Users with supervisory roles can view activities they supervise directly from the Operations screen. The section displays the 3 most recent supervised activities with a link to a dedicated screen showing all supervised activities with filtering capabilities.

## Glossary

- **Supervised Activity**: An Activity record where the current user's membership ID matches the `supervisorId` field
- **Operations Screen**: The main screen for operational tasks in the mobile app, displaying user positions and available operations
- **Activity**: A church event, service, or announcement that requires supervision and approval
- **Membership**: A user's membership record within a church, containing their ID and positions
- **Filter**: A UI control that allows users to narrow down the list of activities based on specific criteria

## Requirements

### Requirement 1

**User Story:** As a church supervisor, I want to see my most recent supervised activities on the Operations screen, so that I can quickly monitor activities under my responsibility.

#### Acceptance Criteria

1. WHEN the Operations screen loads AND the user has supervised activities THEN the System SHALL display a "Supervised Activities" section showing the 3 most recent activities
2. WHEN the user has no supervised activities THEN the System SHALL hide the "Supervised Activities" section entirely
3. WHEN displaying supervised activities THEN the System SHALL show the activity title, date, and activity type for each item
4. WHEN the user taps on a supervised activity item THEN the System SHALL navigate to the activity detail screen

### Requirement 2

**User Story:** As a church supervisor, I want to access a full list of all my supervised activities, so that I can review and manage all activities under my supervision.

#### Acceptance Criteria

1. WHEN the "Supervised Activities" section is visible THEN the System SHALL display a "See All" button
2. WHEN the user taps the "See All" button THEN the System SHALL navigate to the Supervised Activities List screen
3. WHEN the Supervised Activities List screen loads THEN the System SHALL display all activities supervised by the current user with pagination support
4. WHEN displaying the activity list THEN the System SHALL show activity title, date, activity type, and approval status for each item

### Requirement 3

**User Story:** As a church supervisor, I want to filter my supervised activities, so that I can find specific activities more easily.

#### Acceptance Criteria

1. WHEN the Supervised Activities List screen is displayed THEN the System SHALL provide filter options for activity type
2. WHEN the Supervised Activities List screen is displayed THEN the System SHALL provide filter options for date range (start date and end date)
3. WHEN the user applies filters THEN the System SHALL update the activity list to show only matching activities
4. WHEN the user clears filters THEN the System SHALL display all supervised activities
5. WHEN filters are active THEN the System SHALL indicate the active filter state visually

### Requirement 4

**User Story:** As a church supervisor, I want the supervised activities section to load efficiently, so that I can access my activities without delays.

#### Acceptance Criteria

1. WHEN fetching supervised activities THEN the System SHALL display a loading indicator
2. WHEN the fetch operation fails THEN the System SHALL display an error message with a retry option
3. WHEN the supervised activities list is empty after filtering THEN the System SHALL display an appropriate empty state message
