# Requirements Document

## Introduction

This document consolidates all requirements for the Palakat church management platform. Palakat is a comprehensive system designed for Indonesian churches (HKBP denomination) to manage membership, activities, finances, documents, and organizational structure. The platform consists of a mobile app for church members, a web admin panel for administrators, and a NestJS backend API.

## Glossary

- **Palakat**: The church management platform name
- **Church**: An organization entity with members, columns (groups), and positions
- **Membership**: A church member record with baptism/sidi status, linked to an account
- **Column**: An organizational group within a church (e.g., geographic area)
- **Activity**: Events/services requiring supervisor and approver workflow
- **Bipra**: Church organizational divisions (PKB, WKI, PMD, RMJ, ASM)
- **ApprovalRule**: Configurable rules linking activity types, financial types, and positions
- **FinancialAccountNumber**: Chart of accounts for revenue/expense categorization
- **Song**: Hymnal songs from NKB, NNBT, KJ, DSL books
- **ARB**: Application Resource Bundle - localization file format
- **PBT**: Property-Based Testing - testing methodology using generated inputs

---

## Requirements

### Requirement 1: Admin Panel Localization

**User Story:** As an administrator, I want the admin panel to support Indonesian and English languages, so that I can use the system in my preferred language.

#### Acceptance Criteria

1. WHEN a user selects a language preference THEN the Admin_Panel SHALL display all UI text in the selected language
2. WHEN the Admin_Panel displays any user-facing text THEN the text SHALL be retrieved from localization files rather than hardcoded
3. WHEN displaying time-relative strings (e.g., "5 minutes ago") THEN the Admin_Panel SHALL use correct pluralization rules for the selected language

---

### Requirement 2: Song Book Backend Integration (Mobile)

**User Story:** As a church member, I want to browse and search hymnal songs, so that I can find songs for worship services.

#### Acceptance Criteria

1. WHEN a user opens the song book THEN the Mobile_App SHALL fetch songs from the backend API
2. WHEN a user searches for a song THEN the Mobile_App SHALL query the backend with the search term
3. WHEN song data is loading THEN the Mobile_App SHALL display loading indicators
4. WHEN song data fails to load THEN the Mobile_App SHALL display an error state with retry option

---

### Requirement 3: Admin Panel Song Management

**User Story:** As an administrator, I want to manage hymnal songs, so that I can add, edit, and organize the church's song collection.

#### Acceptance Criteria

1. WHEN an administrator views the song list THEN the Admin_Panel SHALL display songs in a data table with filtering options
2. WHEN an administrator creates or edits a song THEN the Admin_Panel SHALL provide a form with dynamic song parts (verses, chorus, etc.)
3. WHEN song data changes THEN the Admin_Panel SHALL update the UI state using Riverpod

---

### Requirement 4: Admin Panel Church Management

**User Story:** As an administrator, I want to manage church information, columns, and positions, so that I can maintain the organizational structure.

#### Acceptance Criteria

1. WHEN an administrator views church details THEN the Admin_Panel SHALL display church information, location, columns, and positions
2. WHEN an administrator edits church information THEN the Admin_Panel SHALL provide forms for updating basic info and location
3. WHEN an administrator manages columns THEN the Admin_Panel SHALL allow creating, editing, and deleting columns
4. WHEN an administrator manages positions THEN the Admin_Panel SHALL allow creating, editing, and deleting positions

---

### Requirement 5: Settings Screen (Mobile)

**User Story:** As a church member, I want to access settings from the dashboard, so that I can manage my account, membership, and sign out.

#### Acceptance Criteria

1. WHEN a signed-in user taps the settings button THEN the Mobile_App SHALL navigate to the settings screen
2. WHEN the settings screen loads THEN the Mobile_App SHALL display account settings option if account exists
3. WHEN the settings screen loads THEN the Mobile_App SHALL display membership settings option if membership exists
4. WHEN a user taps sign out THEN the Mobile_App SHALL display a confirmation dialog
5. WHEN a user confirms sign out THEN the Mobile_App SHALL unregister push notification interests and clear the session
6. WHEN sign out completes THEN the Mobile_App SHALL navigate to the home screen
7. WHEN the settings screen loads THEN the Mobile_App SHALL display the app version in format "Version X.Y.Z (Build N)"

---

### Requirement 6: Backend Property-Based Testing

**User Story:** As a developer, I want comprehensive property-based tests for the backend, so that I can verify system correctness across many inputs.

#### Acceptance Criteria

1. WHEN testing authentication THEN the Backend SHALL verify token generation and validation properties
2. WHEN testing account management THEN the Backend SHALL verify uniqueness and lockout properties
3. WHEN testing multi-church scenarios THEN the Backend SHALL verify data isolation between churches
4. WHEN testing pagination THEN the Backend SHALL verify correct page boundaries and data ordering
5. WHEN testing timestamps THEN the Backend SHALL verify UTC storage and consistent formatting

---

### Requirement 7: Frontend Property-Based Testing

**User Story:** As a developer, I want comprehensive property-based tests for the frontend, so that I can verify UI correctness across many inputs.

#### Acceptance Criteria

1. WHEN testing localization THEN the Frontend SHALL verify ARB key parity between language files
2. WHEN testing time pluralization THEN the Frontend SHALL verify correct plural forms for all time units
3. WHEN testing locale changes THEN the Frontend SHALL verify round-trip consistency
4. WHEN testing date/number formatting THEN the Frontend SHALL verify locale-aware formatting
5. WHEN testing permission state THEN the Frontend SHALL verify persistence across app restarts
6. WHEN testing notifications THEN the Frontend SHALL verify correct channel assignment

---

### Requirement 8: Performance Optimization

**User Story:** As a user, I want the application to be responsive and efficient, so that I can complete tasks quickly.

#### Acceptance Criteria

1. WHEN loading activity lists THEN the Mobile_App SHALL use lazy loading to minimize initial load time
2. WHEN loading images THEN the Mobile_App SHALL use caching to reduce network requests
3. WHEN querying the database THEN the Backend SHALL use optimized queries with appropriate indexes

