# Requirements Document

## Introduction

This document specifies the requirements for the Create Activity Screen feature in the Palakat mobile app. The screen enables signed-in church members to create new activities (services, events, or announcements) for their church. The screen is accessed from the Operations screen by tapping on publishing cards, which pre-configure the activity type based on the selected card.

## Glossary

- **Activity**: A church-related item that can be a service, event, or announcement, authored by a church member
- **ActivityType**: An enumeration with values: SERVICE, EVENT, ANNOUNCEMENT
- **Bipra**: Church demographic groups (PKB, WKI, PMD, RMJ, ASM) that the activity targets
- **Supervisor**: The membership record of the signed-in member who creates the activity
- **Location**: A geographic point with name, latitude, and longitude for pinpointing activity venues
- **Operations Screen**: The parent screen containing publishing cards that navigate to the Create Activity Screen
- **Publishing Card**: A tappable card in the Operations screen that opens the Create Activity Screen with a pre-configured activity type

## Requirements

### Requirement 1

**User Story:** As a church member, I want to access the create activity screen from the operations screen, so that I can quickly create activities based on the type I selected.

#### Acceptance Criteria

1. WHEN a user taps a publishing card in the Operations screen THEN the Create Activity Screen SHALL open with the activity type pre-configured according to the tapped card
2. WHEN the Create Activity Screen opens THEN the Create Activity Screen SHALL display the activity type name in the screen title
3. WHEN the user taps the back button THEN the Create Activity Screen SHALL navigate back to the Operations screen without saving any data

### Requirement 2

**User Story:** As a church member, I want to fill in activity details through a form, so that I can provide all necessary information for the activity.

#### Acceptance Criteria

1. WHEN the Create Activity Screen loads THEN the Create Activity Screen SHALL display a form with fields appropriate for the selected activity type
2. WHEN the activity type is SERVICE or EVENT THEN the Create Activity Screen SHALL display fields for: Bipra selection, Title, Location, Pinpoint Location (map), Date, Time, Reminder, and Note
3. WHEN the activity type is ANNOUNCEMENT THEN the Create Activity Screen SHALL display fields for: Bipra selection, Title, Description, and File upload
4. WHEN the user interacts with a form field THEN the Create Activity Screen SHALL update the corresponding state value immediately

### Requirement 3

**User Story:** As a church member, I want the form to validate my inputs, so that I can ensure all required information is provided before submission.

#### Acceptance Criteria

1. WHEN the user attempts to submit the form with empty required fields THEN the Create Activity Screen SHALL display validation error messages for each empty required field
2. WHEN the user provides valid input for a previously invalid field THEN the Create Activity Screen SHALL clear the error message for that field
3. WHEN all required fields contain valid data THEN the Create Activity Screen SHALL enable the submit button
4. WHEN the Bipra field is empty THEN the Create Activity Screen SHALL display "Must be selected" error message
5. WHEN the Title field is empty THEN the Create Activity Screen SHALL display "Title is required" error message

### Requirement 4

**User Story:** As a church member, I want to select a location on a map, so that I can pinpoint where the activity will take place.

#### Acceptance Criteria

1. WHEN the user taps the Pinpoint Location field THEN the Create Activity Screen SHALL navigate to the Map screen in pinpoint mode
2. WHEN the user selects a location on the map and returns THEN the Create Activity Screen SHALL display the selected location name in the Pinpoint Location field
3. WHEN the activity type is ANNOUNCEMENT THEN the Create Activity Screen SHALL NOT display the Pinpoint Location field

### Requirement 5

**User Story:** As a church member, I want to select date and time for the activity, so that attendees know when the activity occurs.

#### Acceptance Criteria

1. WHEN the user taps the Date field THEN the Create Activity Screen SHALL display a date picker dialog
2. WHEN the user selects a date THEN the Create Activity Screen SHALL display the selected date in formatted text (EEEE, dd MMM yyyy)
3. WHEN the user taps the Time field THEN the Create Activity Screen SHALL display a time picker dialog
4. WHEN the user selects a time THEN the Create Activity Screen SHALL display the selected time in HH:mm format
5. WHEN the activity type is ANNOUNCEMENT THEN the Create Activity Screen SHALL NOT display Date and Time fields

### Requirement 6

**User Story:** As a church member, I want to submit the activity for creation, so that it can be published to the church community.

#### Acceptance Criteria

1. WHEN the user taps the Submit button with valid form data THEN the Create Activity Screen SHALL send a create activity request to the backend API
2. WHILE the create activity request is in progress THEN the Create Activity Screen SHALL display a loading indicator and disable user interaction
3. WHEN the create activity request succeeds THEN the Create Activity Screen SHALL navigate back to the Operations screen and display a success message
4. IF the create activity request fails THEN the Create Activity Screen SHALL display an error message and allow the user to retry

### Requirement 7

**User Story:** As a church member, I want to see my author information displayed, so that I can confirm who is creating the activity.

#### Acceptance Criteria

1. WHEN the Create Activity Screen loads THEN the Create Activity Screen SHALL display the signed-in member's name as the publisher
2. WHEN the Create Activity Screen loads THEN the Create Activity Screen SHALL display the member's church name
3. WHEN the Create Activity Screen loads THEN the Create Activity Screen SHALL display the current date

### Requirement 8

**User Story:** As a church member, I want to upload files for announcements, so that I can attach relevant documents or images.

#### Acceptance Criteria

1. WHEN the activity type is ANNOUNCEMENT and the user taps the File upload field THEN the Create Activity Screen SHALL open a file picker dialog
2. WHEN the user selects a file THEN the Create Activity Screen SHALL display the file name in the File upload field
3. WHEN the activity type is SERVICE or EVENT THEN the Create Activity Screen SHALL NOT display the File upload field
