# Requirements Document

## Introduction

This feature adds reminder functionality to the activity management system in Palakat. Currently, the mobile app allows users to select a reminder time when creating SERVICE or EVENT activities, but this data is not persisted to the backend or utilized for notifications. This feature will extend the backend to store reminder preferences and ensure the full CRUD flow properly handles reminder data from the mobile app through to the database.

## Glossary

- **Activity**: A church event, service, or announcement created by a supervisor
- **Reminder**: A time-based notification preference indicating when users should be reminded before an activity (e.g., 10 minutes, 30 minutes, 1 hour, 2 hours before)
- **Reminder Enum**: An enumeration type with values: TEN_MINUTES, THIRTY_MINUTES, ONE_HOUR, TWO_HOURS
- **Supervisor**: A church member with permission to create and manage activities
- **Bipra**: Demographic group classification (PKB, WKI, PMD, RMJ, ASM)
- **SERVICE/EVENT Activity**: Activity types that require date, time, location, and reminder fields
- **ANNOUNCEMENT Activity**: Activity type that does not require reminder field

## Requirements

### Requirement 1

**User Story:** As a supervisor, I want to set a reminder time when creating a SERVICE or EVENT activity, so that members can be notified before the activity starts.

#### Acceptance Criteria

1. WHEN a supervisor creates a SERVICE or EVENT activity with a reminder selection THEN the Backend SHALL persist the reminder value to the database
2. WHEN a supervisor creates an ANNOUNCEMENT activity THEN the Backend SHALL accept the request without requiring a reminder field
3. WHEN the reminder field is provided THEN the Backend SHALL validate that the value is one of the allowed enum values (TEN_MINUTES, THIRTY_MINUTES, ONE_HOUR, TWO_HOURS)
4. IF an invalid reminder value is provided THEN the Backend SHALL return a validation error with a descriptive message

### Requirement 2

**User Story:** As a mobile app user, I want to view the reminder setting for an activity, so that I know when I will be notified.

#### Acceptance Criteria

1. WHEN retrieving a single activity THEN the Backend SHALL include the reminder field in the response
2. WHEN retrieving a list of activities THEN the Backend SHALL include the reminder field for each activity in the response
3. WHEN an activity has no reminder set THEN the Backend SHALL return null for the reminder field

### Requirement 3

**User Story:** As a supervisor, I want to update the reminder setting for an existing activity, so that I can adjust notification timing as needed.

#### Acceptance Criteria

1. WHEN a supervisor updates an activity with a new reminder value THEN the Backend SHALL persist the updated reminder value
2. WHEN a supervisor updates an activity to remove the reminder THEN the Backend SHALL set the reminder field to null
3. WHEN updating with an invalid reminder value THEN the Backend SHALL return a validation error

### Requirement 4

**User Story:** As a mobile app developer, I want the CreateActivityRequest model to include the reminder field, so that the app can send reminder data to the backend.

#### Acceptance Criteria

1. WHEN the CreateActivityRequest is serialized THEN the System SHALL include the reminder field with the correct enum value format
2. WHEN the CreateActivityRequest is deserialized from JSON THEN the System SHALL correctly parse the reminder enum value
3. WHEN serializing and then deserializing a CreateActivityRequest THEN the System SHALL produce an equivalent object (round-trip consistency)

### Requirement 5

**User Story:** As a mobile app developer, I want the Activity model to include the reminder field, so that the app can display reminder information to users.

#### Acceptance Criteria

1. WHEN the Activity model is deserialized from the backend response THEN the System SHALL correctly parse the reminder enum value
2. WHEN the Activity model has a null reminder THEN the System SHALL handle the null value without errors
3. WHEN serializing and then deserializing an Activity model THEN the System SHALL produce an equivalent object (round-trip consistency)

### Requirement 6

**User Story:** As a supervisor, I want the activity creation form to send the selected reminder to the backend, so that my reminder preference is saved.

#### Acceptance Criteria

1. WHEN submitting the activity creation form with a selected reminder THEN the Mobile App SHALL include the reminder value in the API request
2. WHEN the backend returns a successful response THEN the Mobile App SHALL confirm the activity was created with the reminder
3. IF the backend returns a validation error for the reminder THEN the Mobile App SHALL display the error message to the user

### Requirement 7

**User Story:** As a developer, I want the database seed to include activities with reminder values, so that I can test the reminder functionality with realistic data.

#### Acceptance Criteria

1. WHEN seeding SERVICE or EVENT activities THEN the Seed Script SHALL assign a random reminder value from the valid enum options
2. WHEN seeding ANNOUNCEMENT activities THEN the Seed Script SHALL set the reminder field to null
3. WHEN the seed script completes THEN the Database SHALL contain activities with varied reminder values for testing purposes
