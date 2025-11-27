# Implementation Plan

## Overview

This implementation plan documents the current state of the Palakat system and identifies remaining work. Most core infrastructure is already implemented. The tasks focus on completing missing features, adding property-based tests for correctness verification, and ensuring system quality.

## Current Implementation Status

**Completed**:
- Backend: All controllers, services, and database schema
- Shared Package: Models, repositories, services, widgets, utilities
- Mobile App: Authentication, home, approval, song book UI, routing, church request
- Admin Panel: Member, activity, approval, revenue, expense, document, report features
- Common: Pagination, error handling, validation

**Remaining**:
- Song repository backend integration in mobile app
- Admin panel song management UI
- Admin panel church management enhancement
- Property-based tests for correctness verification
- Integration testing for multi-church isolation

---

## Tasks

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
  - Essential: Ensures data integrity for unique phone/email

- [ ]* 3.2 Write property test for member data persistence
  - **Property 5: Member Data Persistence**
  - **Validates: Requirements 3.1, 3.8**

- [ ]* 3.3 Write property test for member update timestamps
  - **Property 6: Member Update Timestamps**
  - **Validates: Requirements 3.4, 20.2**

- [ ] 4. Activity Management Property Tests
- [ ]* 4.1 Write property test for activity creation with required fields
  - **Property 7: Activity Creation with Required Fields**
  - **Validates: Requirements 4.1**

- [x] 4.2 Write property test for automatic approver assignment
  - **Property 8: Automatic Approver Assignment**
  - **Validates: Requirements 4.2, 6.4**
  - Essential: Core business logic for approval workflow

- [ ]* 4.3 Write property test for activity enum validation
  - **Property 9: Activity Enum Validation**
  - **Validates: Requirements 4.8, 4.9**

- [ ]* 4.4 Write property test for activity cascade delete
  - **Property 10: Activity Cascade Delete**
  - **Validates: Requirements 4.7**

- [ ]* 4.5 Write property test for approval status update
  - **Property 11: Approval Status Update**
  - **Validates: Requirements 4.4**

- [ ]* 4.6 Write property test for approval rule active state
  - **Property 12: Approval Rule Active State**
  - **Validates: Requirements 6.3**

- [ ] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Financial Operations Property Tests
- [ ]* 6.1 Write property test for financial record creation
  - **Property 13: Financial Record Creation**
  - **Validates: Requirements 7.1, 7.2, 7.3, 7.6**

- [ ]* 6.2 Write property test for financial record activity association
  - **Property 14: Financial Record Activity Association**
  - **Validates: Requirements 7.5**

- [ ]* 6.3 Write property test for financial aggregation
  - **Property 15: Financial Aggregation**
  - **Validates: Requirements 7.7**

- [ ] 7. Song Book Property Tests
- [ ]* 7.1 Write property test for song index uniqueness
  - **Property 16: Song Index Uniqueness**
  - **Validates: Requirements 8.6**

- [ ]* 7.2 Write property test for song parts ordering
  - **Property 17: Song Parts Ordering**
  - **Validates: Requirements 8.7**

- [ ]* 7.3 Write property test for song search
  - **Property 18: Song Search**
  - **Validates: Requirements 8.3**

- [ ]* 7.4 Write property test for song data transformation
  - **Property 19: Song Data Transformation**
  - **Validates: Requirements 10.10**

- [ ] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 9. Mobile App - Song Book Backend Integration
- [ ] 9.1 Wire SongBook controller to Song Repository
  - Update SongBookController to call SongRepository for search
  - Implement category filtering via repository
  - Add loading and error state handling
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 9.2 Implement song detail fetching
  - Update SongDetailController to fetch complete song data
  - Handle incomplete song data by fetching from API
  - Display song parts in correct order
  - _Requirements: 10.6, 8.2, 8.7_

- [ ] 9.3 Add loading shimmer and error states
  - Implement shimmer placeholder during fetch
  - Add error message with retry option
  - Handle empty state for no results
  - _Requirements: 10.7, 10.8, 9.5_

- [ ] 10. Admin Panel - Song Management Feature
- [ ] 10.1 Implement song list UI
  - Create song list screen with data table
  - Add book filtering (NKB, NNBT, KJ, DSL)
  - Implement search by title or index
  - Display song index, title, and book
  - Add pagination controls
  - _Requirements: 8.1, 8.3, 8.5_

- [ ] 10.2 Implement song form UI
  - Create song creation form with basic info (title, index, book, link)
  - Add dynamic song part fields (add/remove parts)
  - Implement part ordering with index
  - Create song edit form with existing parts
  - Add form validation for required fields
  - _Requirements: 8.5, 8.6, 19.6, 19.7_

- [ ] 10.3 Implement song state management
  - Create SongController with Riverpod
  - Implement SongState with CRUD operations
  - Add song part management logic (create, update, delete, reorder)
  - Implement search and filtering logic
  - _Requirements: 8.1, 8.2, 8.3, 8.5, 8.6, 8.7_

- [ ] 11. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Church and Location Property Tests
- [ ]* 12.1 Write property test for column name uniqueness
  - **Property 20: Column Name Uniqueness**
  - **Validates: Requirements 11.4**

- [ ]* 12.2 Write property test for church location association
  - **Property 21: Church Location Association**
  - **Validates: Requirements 11.2**

- [ ]* 12.3 Write property test for church request uniqueness
  - **Property 22: Church Request Uniqueness**
  - **Validates: Requirements 12.3**

- [ ]* 12.4 Write property test for church request status enum
  - **Property 23: Church Request Status Enum**
  - **Validates: Requirements 12.4**

- [ ] 13. Admin Panel - Church Management Enhancement
- [ ] 13.1 Implement church list UI
  - Create church list screen with data table
  - Display church name, contact info, and location
  - Add edit and view actions
  - Implement pagination if needed
  - _Requirements: 11.1_

- [ ] 13.2 Implement church form UI
  - Create church creation form with all fields
  - Implement church edit form
  - Add location input with latitude/longitude
  - Add form validation
  - _Requirements: 11.1, 11.2, 19.6, 19.7_

- [ ] 13.3 Implement column management UI
  - Create column list within church detail view
  - Add column creation dialog/form
  - Implement column editing
  - Add column deletion with confirmation
  - _Requirements: 11.3, 11.4_

- [ ] 13.4 Implement church state management
  - Create ChurchController with Riverpod
  - Implement ChurchState with CRUD operations
  - Add column management logic within church context
  - Implement location association and updates
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.7_

- [ ] 14. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 15. Multi-Church Data Isolation Tests
- [ ] 15.1 Write property test for multi-church data isolation
  - **Property 24: Multi-Church Data Isolation**
  - **Validates: Requirements 14.1, 14.2, 14.4, 14.5, 14.6**
  - Essential: Critical security requirement for multi-tenant system

- [ ] 15.2 Verify church filtering in all backend queries
  - Review all service methods for church-scoped queries
  - Test church-based authorization in JWT claims
  - Ensure data isolation between different churches
  - _Requirements: 14.1, 14.2, 14.3, 14.4_

- [ ] 16. System Quality Property Tests
- [ ]* 16.1 Write property test for pagination correctness
  - **Property 25: Pagination Correctness**
  - **Validates: Requirements 18.1, 18.2, 18.5**

- [ ]* 16.2 Write property test for validation error response
  - **Property 26: Validation Error Response**
  - **Validates: Requirements 19.2**

- [ ]* 16.3 Write property test for timestamp management
  - **Property 27: Timestamp Management**
  - **Validates: Requirements 20.1, 20.2, 20.4**

- [ ] 17. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 18. Mobile App - Create Activity Screen
- [ ] 18.1 Implement create activity screen navigation
  - Add navigation from operations screen publishing cards
  - Pass activity type as route parameter
  - Display activity type in screen title
  - _Requirements: 5.1, 5.2, 5.3_

- [ ] 18.2 Implement activity form by type
  - Create form fields for SERVICE/EVENT type
  - Create form fields for ANNOUNCEMENT type
  - Implement conditional field display based on type
  - _Requirements: 5.4, 5.5, 5.6_

- [ ] 18.3 Implement form validation
  - Add validation for required fields
  - Display error messages for empty fields
  - Enable/disable submit button based on validation
  - _Requirements: 5.7, 5.8, 5.9_

- [ ] 18.4 Implement location picker integration
  - Navigate to map screen on pinpoint field tap
  - Receive and display selected location
  - _Requirements: 5.10, 5.11_

- [ ] 18.5 Implement date and time pickers
  - Add date picker dialog
  - Add time picker dialog
  - Format and display selected values
  - _Requirements: 5.12, 5.13, 5.14, 5.15_

- [ ] 18.6 Implement form submission
  - Send create activity request to backend
  - Display loading indicator during submission
  - Handle success and error responses
  - _Requirements: 5.16, 5.17, 5.18, 5.19_

- [ ] 18.7 Display author information
  - Show signed-in member name as publisher
  - Display church name and current date
  - _Requirements: 5.20_

- [ ] 18.8 Implement file upload for announcements
  - Add file picker for announcement type
  - Display selected file name
  - _Requirements: 5.21_

- [ ] 19. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 20. Performance Optimization
- [ ] 20.1 Optimize database queries
  - Review and optimize Prisma queries with select/include
  - Verify indexes on frequently queried fields
  - Add composite indexes where needed
  - Test query performance with large datasets
  - _Requirements: 18.6_

- [ ] 20.2 Optimize mobile app performance
  - Implement lazy loading for activity lists
  - Optimize image loading with caching
  - Review and optimize widget rebuilds
  - _Requirements: 18.4_

- [x] 21. Security Review
- [x] 21.1 Review authentication security
  - Verify password hashing with bcryptjs
  - Test account lockout after failed login attempts
  - Verify refresh token rotation
  - Test JWT expiration and refresh flow
  - _Requirements: 1.3, 1.4, 1.5_

- [x] 21.2 Review authorization and data isolation
  - Verify role-based access control
  - Test church-level data isolation
  - Ensure protected routes require valid JWT
  - _Requirements: 1.7, 14.1, 14.2_

- [ ] 22. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Most backend infrastructure is complete and functional
- Shared package has comprehensive models, services, and widgets
- Mobile app has core features implemented (auth, home, approval, song book, church request)
- Admin panel has most management features implemented
- Key remaining work: Song backend integration, church management UI, create activity screen, and property-based tests
- Property tests marked with * are optional for faster MVP
- Essential property tests (without *) are required: account uniqueness, automatic approver assignment, multi-church data isolation
- Firebase Phone Auth is integrated for mobile authentication
- This spec consolidates all previous specs: create-activity-screen, palakat-design-rehaul, songbook-backend-integration, songbook-navbar-redesign
