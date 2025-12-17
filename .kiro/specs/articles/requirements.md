# Requirements Document

## Introduction

This document defines the requirements for the Articles feature in the Palakat church management platform. Articles allow church administrators to publish content such as preaching materials and game instructions through the admin panel, which church members can then browse, search, and interact with via the mobile app. This feature enhances member engagement by providing easy access to educational and recreational church content.

## Glossary

- **Article**: A published content piece containing either preaching material or game instruction with detailed explanation
- **ArticleType**: Classification of article content - either PREACHING (sermon/devotional material) or GAME (game instructions)
- **Mobile_App**: The Flutter mobile application used by church members (apps/palakat)
- **Admin_Panel**: The Flutter web application used by church administrators (apps/palakat_admin)
- **Backend**: The NestJS REST API server (apps/palakat_backend)
- **Like**: A user interaction indicating appreciation for an article
- **Church**: The organization entity that owns and publishes articles

---

## Requirements

### Requirement 1: Article Data Model

**User Story:** As a developer, I want a well-structured article data model, so that articles can be stored, retrieved, and managed efficiently.

#### Acceptance Criteria

1. WHEN an article is created THEN the Backend SHALL store the article with title, content, type, thumbnail URL, and church reference
2. WHEN an article is created THEN the Backend SHALL automatically set createdAt and updatedAt timestamps in UTC
3. WHEN an article is retrieved THEN the Backend SHALL include the like count for that article
4. WHEN an article is deleted THEN the Backend SHALL remove all associated likes

---

### Requirement 2: Article Management (Admin Panel)

**User Story:** As a church administrator, I want to create, edit, and delete articles, so that I can publish content for church members.

#### Acceptance Criteria

1. WHEN an administrator views the article list THEN the Admin_Panel SHALL display articles in a data table with title, type, like count, and creation date
2. WHEN an administrator creates an article THEN the Admin_Panel SHALL provide a form with title, content (rich text), type selection, and optional thumbnail upload
3. WHEN an administrator edits an article THEN the Admin_Panel SHALL pre-populate the form with existing article data
4. WHEN an administrator deletes an article THEN the Admin_Panel SHALL display a confirmation dialog before deletion
5. WHEN an administrator filters articles THEN the Admin_Panel SHALL support filtering by article type (PREACHING/GAME)

---

### Requirement 3: Article Listing (Mobile App)

**User Story:** As a church member, I want to browse articles published by my church, so that I can access preaching materials and game instructions.

#### Acceptance Criteria

1. WHEN a user opens the articles screen THEN the Mobile_App SHALL fetch articles from the Backend API with pagination
2. WHEN articles are loading THEN the Mobile_App SHALL display loading indicators
3. WHEN articles fail to load THEN the Mobile_App SHALL display an error state with retry option
4. WHEN displaying an article card THEN the Mobile_App SHALL show thumbnail, title, type badge, like count, and publication date
5. WHEN a user scrolls to the bottom THEN the Mobile_App SHALL load more articles automatically (infinite scroll)
6. WHEN a user pulls down on the list THEN the Mobile_App SHALL refresh the article list

---

### Requirement 4: Article Search (Mobile App)

**User Story:** As a church member, I want to search for articles, so that I can quickly find specific content.

#### Acceptance Criteria

1. WHEN a user enters a search term THEN the Mobile_App SHALL query the Backend with the search term
2. WHEN searching THEN the Backend SHALL match articles by title containing the search term (case-insensitive)
3. WHEN search results are empty THEN the Mobile_App SHALL display an empty state with appropriate message
4. WHEN a user clears the search THEN the Mobile_App SHALL return to the full article list

---

### Requirement 5: Article Filtering (Mobile App)

**User Story:** As a church member, I want to filter articles by type, so that I can view only preaching materials or game instructions.

#### Acceptance Criteria

1. WHEN a user selects a filter option THEN the Mobile_App SHALL display only articles matching the selected type
2. WHEN filtering by PREACHING THEN the Mobile_App SHALL show only preaching material articles
3. WHEN filtering by GAME THEN the Mobile_App SHALL show only game instruction articles
4. WHEN a user selects "All" filter THEN the Mobile_App SHALL display articles of all types

---

### Requirement 6: Article Detail View (Mobile App)

**User Story:** As a church member, I want to view the full content of an article, so that I can read preaching materials or game instructions in detail.

#### Acceptance Criteria

1. WHEN a user taps an article card THEN the Mobile_App SHALL navigate to the article detail screen
2. WHEN the detail screen loads THEN the Mobile_App SHALL display the full article content with title, thumbnail, type, content, like count, and publication date
3. WHEN the article content contains formatted text THEN the Mobile_App SHALL render the formatting correctly
4. WHEN the detail screen fails to load THEN the Mobile_App SHALL display an error state with retry option

---

### Requirement 7: Article Like Feature (Mobile App)

**User Story:** As a church member, I want to like articles, so that I can show appreciation for helpful content.

#### Acceptance Criteria

1. WHEN a user taps the like button on an article THEN the Mobile_App SHALL send a like request to the Backend
2. WHEN a user has already liked an article THEN the Mobile_App SHALL display the like button in an active state
3. WHEN a user taps the like button on an already-liked article THEN the Mobile_App SHALL remove the like (unlike)
4. WHEN a like action succeeds THEN the Mobile_App SHALL update the like count immediately
5. WHEN a like action fails THEN the Mobile_App SHALL display an error message and revert the UI state

---

### Requirement 8: Article API Endpoints (Backend)

**User Story:** As a developer, I want comprehensive API endpoints for articles, so that the mobile app and admin panel can interact with article data.

#### Acceptance Criteria

1. WHEN the Backend receives a GET request to /articles THEN the Backend SHALL return a paginated list of articles for the specified church
2. WHEN the Backend receives a GET request to /articles/:id THEN the Backend SHALL return the full article details including like status for the requesting user
3. WHEN the Backend receives a POST request to /articles THEN the Backend SHALL create a new article and return the created article
4. WHEN the Backend receives a PATCH request to /articles/:id THEN the Backend SHALL update the article and return the updated article
5. WHEN the Backend receives a DELETE request to /articles/:id THEN the Backend SHALL delete the article and return success status
6. WHEN the Backend receives a POST request to /articles/:id/like THEN the Backend SHALL toggle the like status for the requesting user
7. WHEN the Backend receives a GET request to /articles with search parameter THEN the Backend SHALL filter articles by title

---

### Requirement 9: Article Data Isolation

**User Story:** As a system administrator, I want articles to be isolated by church, so that each church only sees their own content.

#### Acceptance Criteria

1. WHEN a user requests articles THEN the Backend SHALL return only articles belonging to the user's church
2. WHEN an administrator creates an article THEN the Backend SHALL associate the article with the administrator's church
3. WHEN a user attempts to access an article from another church THEN the Backend SHALL return a 403 Forbidden response

