# Requirements Document

## Introduction

This document specifies the requirements for consolidating the core folder from `palakat_admin` into the `palakat_shared` package. The goal is to eliminate code duplication between the admin app and the shared package, creating a single source of truth for shared functionality that both `palakat` (mobile) and `palakat_admin` (web) applications can use. App-specific code (themes, routing, layouts) will remain in their respective applications.

## Glossary

- **palakat_shared**: The shared Flutter package containing common code used by both mobile and admin applications
- **palakat_admin**: The Flutter web admin panel application
- **palakat**: The Flutter mobile application for church members
- **Core folder**: The `lib/core` directory containing shared utilities, models, services, repositories, widgets, and extensions
- **Barrel export**: A Dart file that re-exports multiple files from a single import point

## Requirements

### Requirement 1

**User Story:** As a developer, I want to remove duplicate code from palakat_admin's core folder, so that I maintain only one version of shared functionality in palakat_shared.

#### Acceptance Criteria

1. WHEN the consolidation is complete THEN the palakat_admin core folder SHALL contain only app-specific code (theme, navigation/routing, layout)
2. WHEN shared code exists in both palakat_admin and palakat_shared THEN the system SHALL use the palakat_shared version and remove the palakat_admin duplicate
3. WHEN palakat_admin imports core functionality THEN the system SHALL import from palakat_shared package instead of local core folder
4. IF code differences exist between palakat_admin and palakat_shared versions THEN the system SHALL merge functionality to support both use cases

### Requirement 2

**User Story:** As a developer, I want palakat_admin to import shared code from palakat_shared, so that both apps use the same codebase.

#### Acceptance Criteria

1. WHEN palakat_admin needs models, repositories, services, extensions, utils, validation, or widgets THEN the system SHALL import them from palakat_shared
2. WHEN palakat_admin's pubspec.yaml is updated THEN the system SHALL include palakat_shared as a dependency
3. WHEN barrel exports are updated THEN the system SHALL re-export palakat_shared components for backward compatibility

### Requirement 3

**User Story:** As a developer, I want app-specific code to remain in palakat_admin, so that web-specific functionality is not mixed into the shared package.

#### Acceptance Criteria

1. WHEN the consolidation is complete THEN the palakat_admin core folder SHALL retain theme configuration specific to web admin
2. WHEN the consolidation is complete THEN the palakat_admin core folder SHALL retain navigation/routing specific to web admin
3. WHEN the consolidation is complete THEN the palakat_admin core folder SHALL retain layout components specific to web admin (e.g., app_scaffold.dart if web-specific)
4. WHEN widgets are admin-specific (sidebar, side_drawer for web navigation) THEN the system SHALL keep them in palakat_admin

### Requirement 4

**User Story:** As a developer, I want the mobile app (palakat) to continue working with its existing core structure, so that mobile-specific code remains separate.

#### Acceptance Criteria

1. WHEN the consolidation is complete THEN the palakat mobile app core folder SHALL remain unchanged
2. WHEN palakat needs shared functionality THEN the system SHALL import from palakat_shared
3. WHEN palakat has mobile-specific widgets, routing, or themes THEN the system SHALL keep them in the palakat core folder

### Requirement 5

**User Story:** As a developer, I want the codebase to compile and run after consolidation, so that both applications remain functional.

#### Acceptance Criteria

1. WHEN all changes are applied THEN the palakat_admin application SHALL compile without errors
2. WHEN all changes are applied THEN the palakat mobile application SHALL compile without errors
3. WHEN all changes are applied THEN the palakat_shared package SHALL compile without errors
4. WHEN code generation is run THEN the system SHALL generate all required .g.dart and .freezed.dart files

### Requirement 6

**User Story:** As a developer, I want clear barrel exports in palakat_shared, so that importing shared code is simple and consistent.

#### Acceptance Criteria

1. WHEN importing models THEN the system SHALL provide a single models.dart barrel export
2. WHEN importing repositories THEN the system SHALL provide a single repositories.dart barrel export
3. WHEN importing services THEN the system SHALL provide a single services.dart barrel export
4. WHEN importing extensions THEN the system SHALL provide a single extensions.dart barrel export
5. WHEN importing widgets THEN the system SHALL provide a single widgets.dart barrel export
6. WHEN importing validation THEN the system SHALL provide a single validation.dart barrel export
7. WHEN importing utils THEN the system SHALL provide a single utils.dart barrel export
