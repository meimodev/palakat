# Implementation Plan

## Overview

This implementation plan documents the current state of the Palakat system and identifies remaining work. Most core infrastructure is already implemented. The tasks focus on completing missing features, adding property-based tests for correctness verification, and ensuring system quality.

This spec consolidates all previous specs:
- activity-finance
- activity-reminder
- core-consolidation
- financial-account-number
- palakat-system-overview
- supervised-activities
- widget-consolidation-financial-constraint
- financial-account-picker-fix
- activity-approver-linking

## Current Implementation Status

**Completed**:
- Backend: All controllers, services, and database schema including FinancialAccountNumber
- Shared Package: Models, repositories, services, widgets, utilities
- Mobile App: Authentication, home, approval, song book UI, routing, church request, activity finance, supervised activities
- Admin Panel: Member, activity, approval, revenue, expense, document, report, financial account number features
- Common: Pagination, error handling, validation
- Core Consolidation: palakat_admin now imports from palakat_shared
- Widget Consolidation: All widgets migrated to palakat_shared
- Financial Account Unique Constraint: Backend validation and frontend filtering
- Activity Approver Linking: Automatic approver assignment based on approval rules
- Searchable Pickers: Financial account and position pickers with search
- Self-Approval: Supervisor can approve their own activities

**Remaining**:
- Song repository backend integration in mobile app
- Admin panel song management UI
- Admin panel church management enhancement
- Property-based tests for correctness verification
- Integration testing for multi-church isolation

---

## Completed Tasks Summary

The following major features have been fully implemented:

### Activity Finance Feature (Complete)
- Finance models (Revenue, Expense, FinanceType, FinanceData) and repositories
- FinanceCreateScreen with validation and submission logic
- Integration with ActivityPublishScreen for combined activity+finance creation
- Standalone finance creation via Operations screen
- All UI components (ActivityPicker, PaymentMethodPicker, FinanceSummaryCard, etc.)

### Activity Reminder Feature (Complete)
- Backend Prisma schema with Reminder enum
- DTOs and service updates for reminder handling
- Shared package model updates with JSON serialization
- Mobile app controller integration
- Database seeding with reminder data

### Financial Account Number Feature (Complete)
- Backend FinancialAccountNumber model with CRUD operations
- Admin panel Financial menu with account number management
- Mobile app AccountNumberPicker widget
- Integration with Finance Create Screen

### Supervised Activities Feature (Complete)
- Operations screen extension with supervised activities section
- SupervisedActivitiesListScreen with filtering
- State management and pagination support

### Core Consolidation (Complete)
- Barrel exports updated to re-export from palakat_shared
- Duplicate folders removed from palakat_admin
- Feature imports updated across all admin features

### Widget Consolidation (Complete)
- All button, card, dialog, input, loading, error widgets migrated
- Mobile-specific widgets (appbar, bottom navbar, scaffold) in mobile subdirectory
- Chips, output, screen_title, segment_title, info_box, image_network migrated
- Account number picker merged with financial account picker
- Barrel exports updated in shared package

### Financial Account Unique Constraint (Complete)
- Database schema updated with unique constraint on financialAccountNumberId
- Backend validation for uniqueness on create/update
- Available accounts endpoint filtering out linked accounts
- Seed script updated for unique assignments
- Frontend picker shows only available accounts

### Financial Type Requires Account Number (Complete)
- Backend validation requiring account when financial type is set
- Frontend validation and required indicator
- Error messages for missing account

### Searchable Pickers (Complete)
- FinancialAccountPicker with search by description/account number
- PositionSelector with search by name
- Scrollable filtered results

### Financial Account Table Updates (Complete)
- Removed created date column
- Added linked approval rule column
- Backend includes approval rule in response

### Activity Approver Linking (Complete)
- Prisma schema updated with activityType, financialType, financialAccountNumberId
- ApproverResolverService implemented with resolution algorithm
- Activity service creates approvers automatically
- Admin panel approval rule form with new fields
- Mobile app self-approval functionality

### Create Activity Screen (Complete)
- Navigation from operations screen
- Form fields by activity type
- Validation and error messages
- Location, date, time pickers
- Form submission with loading states
- File upload for announcements

### Security Review (Complete)
- Authentication security verified
- Authorization and data isolation reviewed

---

## Remaining Tasks

- [ ] 1. Backend Property-Based Testing Setup
  - [x] 1.1 Set up fast-check testing framework
    - Install fast-check package for property-based testing
    - Configure Jest to support property tests
    - Create test utilities for generating valid test data
    - _Requirements: Testing Strategy_
  - [ ]* 1.2 Write property test for authentication token lifecycle
    - **Property 1: Authentication Token Lifecycle**
    - **Validates: Requirements 1.1, 1.2**
  - [ ]* 1.3 Write property test for account lockout enforcement
    - **Property 2: Account Lockout Enforcement**
    - **Validates: Requirements 1.3**
  - [ ]* 1.4 Write property test for refresh token rotation
    - **Property 3: Refresh Token Rotation**
    - **Validates: Requirements 1.4, 1.5**

- [ ] 2. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 3. Account and Member Property Tests
  - [x] 3.1 Write property test for account uniqueness constraints
    - **Property 4: Account Uniqueness Constraints**
    - **Validates: Requirements 3.6, 3.7**
  - [ ]* 3.2 Write property test for member data persistence
    - **Property 5: Member Data Persistence**
    - **Validates: Requirements 3.1, 3.8**
  - [ ]* 3.3 Write property test for member update timestamps
    - **Property 6: Member Update Timestamps**
    - **Validates: Requirements 3.4, 22.2**

- [ ] 4. Activity Management Property Tests
  - [ ]* 4.1 Write property test for activity creation with required fields
    - **Property 7: Activity Creation with Required Fields**
    - **Validates: Requirements 4.1**
  - [x] 4.2 Write property test for automatic approver assignment
    - **Property 8: Automatic Approver Assignment**
    - **Validates: Requirements 4.2, 8.4**
  - [ ]* 4.3 Write property test for activity enum validation
    - **Property 9: Activity Enum Validation**
    - **Validates: Requirements 4.8, 4.9**
  - [ ]* 4.4 Write property test for activity cascade delete
    - **Property 10: Activity Cascade Delete**
    - **Validates: Requirements 4.7**
  - [ ]* 4.5 Write property test for approval status update
    - **Property 11: Approval Status Update**
    - **Validates: Requirements 4.4**

- [ ] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Activity Reminder Property Tests
  - [x] 6.1 Write property test for reminder persistence on create
    - **Property 12: Reminder Persistence on Create**
    - **Validates: Requirements 6.1, 6.5**
  - [ ]* 6.2 Write property test for reminder validation
    - **Property 13: Reminder Validation**
    - **Validates: Requirements 6.3, 6.4**
  - [ ]* 6.3 Write property test for CreateActivityRequest round-trip
    - **Property 14: CreateActivityRequest Round-Trip Serialization**
    - **Validates: Requirements 6.10, 6.11**

- [ ] 7. Financial Account Number Property Tests
  - [x] 7.1 Write property test for create-read round trip
    - **Property 15: Create-Read Round Trip**
    - **Validates: Requirements 9.3, 9.7**
  - [x] 7.2 Write property test for delete removes record
    - **Property 16: Delete Removes Record**
    - **Validates: Requirements 9.5**
  - [x] 7.3 Write property test for uniqueness within church
    - **Property 17: Uniqueness Within Church**
    - **Validates: Requirements 9.9**
  - [x] 7.4 Write property test for search filter correctness
    - **Property 18: Search Filter Correctness**
    - **Validates: Requirements 9.10**

- [ ] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Activity Finance Property Tests
  - [ ]* 9.1 Write property test for financial section visibility
    - **Property 19: Financial Section Visibility by Activity Type**
    - **Validates: Requirements 10.1**
  - [ ]* 9.2 Write property test for amount validation
    - **Property 20: Amount Validation Correctness**
    - **Validates: Requirements 10.7**
  - [ ]* 9.3 Write property test for currency formatting
    - **Property 21: Currency Formatting Correctness**
    - **Validates: Requirements 10.19**
  - [ ]* 9.4 Write property test for combined creation order
    - **Property 22: Combined Creation Order and ID Passing**
    - **Validates: Requirements 10.15, 10.16**

- [ ] 10. Supervised Activities Property Tests
  - [ ]* 10.1 Write property test for recent activities limit
    - **Property 23: Recent Activities Limit**
    - **Validates: Requirements 7.1**
  - [ ]* 10.2 Write property test for filter application correctness
    - **Property 24: Filter Application Correctness**
    - **Validates: Requirements 7.11**
  - [ ]* 10.3 Write property test for active filter indicator
    - **Property 25: Active Filter Indicator Consistency**
    - **Validates: Requirements 7.13**

- [ ] 11. Song Book Property Tests
  - [ ]* 11.1 Write property test for song index uniqueness
    - **Property 26: Song Index Uniqueness**
    - **Validates: Requirements 12.6**
  - [ ]* 11.2 Write property test for song parts ordering
    - **Property 27: Song Parts Ordering**
    - **Validates: Requirements 12.7**
  - [ ]* 11.3 Write property test for song search
    - **Property 28: Song Search**
    - **Validates: Requirements 12.3**

- [ ] 12. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 13. Multi-Church and System Property Tests
  - [ ] 13.1 Write property test for multi-church data isolation
    - **Property 29: Multi-Church Data Isolation**
    - **Validates: Requirements 16.1, 16.2, 16.4, 16.5, 16.6**
    - Essential: Critical security requirement for multi-tenant system
  - [ ]* 13.2 Write property test for pagination correctness
    - **Property 30: Pagination Correctness**
    - **Validates: Requirements 20.1, 20.2, 20.5**
  - [ ]* 13.3 Write property test for validation error response
    - **Property 31: Validation Error Response**
    - **Validates: Requirements 21.2**
  - [ ]* 13.4 Write property test for timestamp management
    - **Property 32: Timestamp Management**
    - **Validates: Requirements 22.1, 22.2, 22.4**

- [ ] 14. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 15. Widget Consolidation Property Tests
  - [ ]* 15.1 Write property test for financial account uniqueness constraint
    - **Property 33: Financial Account Uniqueness Constraint**
    - **Validates: Requirements 27.1, 27.2, 27.3, 27.4**
  - [ ]* 15.2 Write property test for seed data uniqueness
    - **Property 34: Seed Data Financial Account Uniqueness**
    - **Validates: Requirements 28.1, 28.2, 28.3**
  - [ ]* 15.3 Write property test for available accounts filtering
    - **Property 35: Available Accounts Filtering**
    - **Validates: Requirements 29.1**
  - [ ]* 15.4 Write property test for financial type requires account
    - **Property 36: Financial Type Requires Account Number**
    - **Validates: Requirements 30.1, 30.2**
  - [ ]* 15.5 Write property test for financial account search
    - **Property 37: Financial Account Search by Description**
    - **Property 38: Financial Account Search Fallback to Account Number**
    - **Validates: Requirements 31.2, 31.3**
  - [ ]* 15.6 Write property test for position search
    - **Property 39: Position Search by Name**
    - **Validates: Requirements 32.2**
  - [ ]* 15.7 Write property test for linked approval rule display
    - **Property 40: Linked Approval Rule Display**
    - **Validates: Requirements 9.13**

- [ ] 16. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 17. Activity Approver Linking Property Tests
  - [x] 17.1 Write property test for activity type rule matching
    - **Property 41: Activity Type Rule Matching**
    - **Validates: Requirements 33.2, 33.3, 33.4**
  - [x] 17.2 Write property test for financial type filtering
    - **Property 42: Financial Type Filtering**
    - **Validates: Requirements 34.2, 34.3, 34.4**
  - [ ]* 17.3 Write property test for financial account number matching
    - **Property 43: Financial Account Number Matching**
    - **Validates: Requirements 35.2, 35.3, 35.4**
  - [ ]* 17.4 Write property test for approver deduplication
    - **Property 44: Approver Deduplication**
    - **Validates: Requirements 36.5**
  - [ ]* 17.5 Write property test for supervisor self-approval inclusion
    - **Property 45: Supervisor Self-Approval Inclusion**
    - **Validates: Requirements 36.8**
  - [ ]* 17.6 Write property test for approver-rule consistency
    - **Property 46: Approver-Rule Consistency**
    - **Validates: Requirements 36.2, 36.4, 36.6, 36.7**
  - [ ]* 17.7 Write property test for self-approval capability
    - **Property 47: Self-Approval Capability**
    - **Validates: Requirements 38.2, 38.3, 38.4**

- [ ] 18. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 19. InputWidget Migration Property Tests
  - [ ]* 19.1 Write property test for theme-based styling
    - **Property 48: Theme-based styling adaptation**
    - **Validates: Requirements 39.1**
  - [ ]* 19.2 Write property test for custom display builder
    - **Property 49: Custom display builder invocation**
    - **Validates: Requirements 39.3**
  - [ ]* 19.3 Write property test for backward compatibility
    - **Property 50: InputWidget backward compatibility**
    - **Validates: Requirements 40.1, 40.2, 40.3**
  - [ ]* 19.4 Write property test for account number format
    - **Property 51: Account number format validation**
    - **Property 52: Income account prefix**
    - **Property 53: Expense account prefix**
    - **Validates: Requirements 41.1, 41.2, 41.3**
  - [ ]* 19.5 Write property test for approval rule name from financial account
    - **Property 54: Approval Rule Name from Financial Account**
    - **Validates: Requirements 42.1, 42.2, 42.3**

- [ ] 20. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 21. Mobile App - Song Book Backend Integration
  - [ ] 21.1 Wire SongBook controller to Song Repository
    - Update SongBookController to call SongRepository for search
    - Implement category filtering via repository
    - Add loading and error state handling
    - _Requirements: 12.11, 12.12_
  - [ ] 21.2 Implement song detail fetching
    - Update SongDetailController to fetch complete song data
    - Handle incomplete song data by fetching from API
    - Display song parts in correct order
    - _Requirements: 12.13, 12.2, 12.7_
  - [ ] 21.3 Add loading shimmer and error states
    - Implement shimmer placeholder during fetch
    - Add error message with retry option
    - Handle empty state for no results
    - _Requirements: 12.14, 12.15_

- [ ] 22. Admin Panel - Song Management Feature
  - [ ] 22.1 Implement song list UI
    - Create song list screen with data table
    - Add book filtering (NKB, NNBT, KJ, DSL)
    - Implement search by title or index
    - Display song index, title, and book
    - Add pagination controls
    - _Requirements: 12.1, 12.3, 12.5_
  - [ ] 22.2 Implement song form UI
    - Create song creation form with basic info (title, index, book, link)
    - Add dynamic song part fields (add/remove parts)
    - Implement part ordering with index
    - Create song edit form with existing parts
    - Add form validation for required fields
    - _Requirements: 12.5, 12.6, 21.6, 21.7_
  - [ ] 22.3 Implement song state management
    - Create SongController with Riverpod
    - Implement SongState with CRUD operations
    - Add song part management logic
    - Implement search and filtering logic
    - _Requirements: 12.1, 12.2, 12.3, 12.5, 12.6, 12.7_

- [ ] 23. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 24. Admin Panel - Church Management Enhancement
  - [ ] 24.1 Implement church list UI
    - Create church list screen with data table
    - Display church name, contact info, and location
    - Add edit and view actions
    - Implement pagination if needed
    - _Requirements: 13.1_
  - [ ] 24.2 Implement church form UI
    - Create church creation form with all fields
    - Implement church edit form
    - Add location input with latitude/longitude
    - Add form validation
    - _Requirements: 13.1, 13.2, 21.6, 21.7_
  - [ ] 24.3 Implement column management UI
    - Create column list within church detail view
    - Add column creation dialog/form
    - Implement column editing
    - Add column deletion with confirmation
    - _Requirements: 13.3, 13.4_
  - [ ] 24.4 Implement church state management
    - Create ChurchController with Riverpod
    - Implement ChurchState with CRUD operations
    - Add column management logic within church context
    - Implement location association and updates
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.7_

- [ ] 25. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 26. Performance Optimization
  - [ ] 26.1 Optimize database queries
    - Review and optimize Prisma queries with select/include
    - Verify indexes on frequently queried fields
    - Add composite indexes where needed
    - Test query performance with large datasets
    - _Requirements: 20.6_
  - [ ] 26.2 Optimize mobile app performance
    - Implement lazy loading for activity lists
    - Optimize image loading with caching
    - Review and optimize widget rebuilds
    - _Requirements: 20.4_

- [ ] 27. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Most backend infrastructure is complete and functional
- Shared package has comprehensive models, services, and widgets
- Mobile app has core features implemented (auth, home, approval, song book, church request, activity finance, supervised activities)
- Admin panel has most management features implemented including financial account numbers
- Key remaining work: Song backend integration, church management UI, and property-based tests
- Property tests marked with * are optional for faster MVP
- Essential property tests (without *) are required: account uniqueness, automatic approver assignment, multi-church data isolation
- Firebase Phone Auth is integrated for mobile authentication
- Widget consolidation is complete - all widgets now in palakat_shared
- Financial account unique constraint is enforced at database and application level
- Activity approver linking automatically assigns approvers based on approval rules
- Searchable pickers implemented for financial accounts and positions
- Self-approval functionality allows supervisors to approve their own activities
