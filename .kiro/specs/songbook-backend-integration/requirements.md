# Requirements Document

## Introduction

This feature integrates the Palakat mobile app's songbook screen with the backend API. Currently, the songbook feature uses mock data generated locally. This integration will wire the existing UI to fetch real song data from the NestJS backend via the existing `SongRepository` in `palakat_shared`, enabling search functionality, pagination, and song detail retrieval from the PostgreSQL database.

## Glossary

- **SongBook_Screen**: The Flutter screen displaying the list of songs with search and category filtering capabilities
- **SongBook_Controller**: The Riverpod controller managing songbook state and business logic
- **Song_Repository**: The shared repository in `palakat_shared` that handles HTTP requests to the song API endpoints
- **Song**: A hymn entity containing title, book type (KJ, NNBT, NKB, DSL), index number, and song parts
- **SongPart**: A section of a song (verse, chorus, bridge) with content text
- **Backend_API**: The NestJS REST API providing song CRUD operations at `/song` endpoints
- **Pagination**: The mechanism for loading songs in batches with skip/take parameters

## Requirements

### Requirement 1

**User Story:** As a church member, I want to search for songs by title or content, so that I can quickly find hymns for worship.

#### Acceptance Criteria

1. WHEN a user enters a search query in the search field, THE SongBook_Controller SHALL call the Song_Repository to fetch matching songs from the Backend_API
2. WHEN the Backend_API returns search results, THE SongBook_Controller SHALL update the state with the fetched songs
3. WHEN the search query is empty, THE SongBook_Controller SHALL clear the filtered songs list and show the default category view
4. WHEN the Backend_API returns an error during search, THE SongBook_Controller SHALL update the state with an appropriate error message

### Requirement 2

**User Story:** As a church member, I want to browse songs by category (KJ, NNBT, NKB, DSL), so that I can find hymns from my preferred songbook.

#### Acceptance Criteria

1. WHEN a user selects a song category, THE SongBook_Controller SHALL call the Song_Repository with the category as a search filter
2. WHEN the Backend_API returns category results, THE SongBook_Controller SHALL display the filtered songs in the list view
3. WHEN no songs match the selected category, THE SongBook_Controller SHALL display an empty state message

### Requirement 3

**User Story:** As a church member, I want to view the full details of a song including all verses and choruses, so that I can read the complete lyrics.

#### Acceptance Criteria

1. WHEN a user selects a song from the list, THE SongDetail_Controller SHALL receive the song data with all song parts
2. WHEN the song data includes song parts, THE SongDetail_Controller SHALL render each part in the correct composition order
3. WHEN the song data is incomplete, THE SongDetail_Controller SHALL fetch the complete song from the Backend_API using the song ID

### Requirement 4

**User Story:** As a church member, I want the songbook to handle loading states gracefully, so that I have a smooth user experience.

#### Acceptance Criteria

1. WHILE the SongBook_Controller is fetching songs, THE SongBook_Screen SHALL display a loading shimmer placeholder
2. WHEN the fetch operation completes successfully, THE SongBook_Screen SHALL display the song list
3. WHEN the fetch operation fails, THE SongBook_Screen SHALL display an error message with a retry option
4. WHEN the user triggers a retry, THE SongBook_Controller SHALL re-fetch the songs from the Backend_API

### Requirement 5

**User Story:** As a developer, I want the songbook integration to follow existing codebase patterns, so that the code is maintainable and consistent.

#### Acceptance Criteria

1. THE SongBook_Controller SHALL use the Song_Repository from `palakat_shared` for all API calls
2. THE SongBook_Controller SHALL use the `Result` type for handling success and failure responses
3. THE Song model mapping SHALL correctly transform Backend_API response format to the Flutter Song model
4. THE integration SHALL use the existing `HttpService` with authentication token handling
