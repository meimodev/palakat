# Implementation Plan

## Overview

This implementation plan documents the current state of the Palakat system and identifies remaining work. Most core infrastructure is already implemented. The tasks focus on completing missing features, adding property-based tests for correctness verification, and ensuring system quality.

## Current Implementation Status

**Completed**:
- ✅ Backend: All controllers, services, and database schema
- ✅ Shared Package: Models, repositories, services, widgets, utilities
- ✅ Mobile App: Authentication, home, approval, song book UI, routing, church request
- ✅ Admin Panel: Member, activity, approval, revenue, expense, document, report features
- ✅ Common: Pagination, error handling, validation

**Remaining**:
- Song repository in shared package
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

- [ ]* 1.2 Write property test for authentication token generation
  - **Property 1: Authentication Token Generation**
  - **Validates: Requirements 1.1**

- [ ]* 1.3 Write property test for invalid credentials rejection
  - **Property 2: Invalid Credentials Rejection**
  - **Validates: Requirements 1.2**

- [ ]* 1.4 Write property test for account lockout enforcement
  - **Property 3: Account Lockout Enforcement**
  - **Validates: Requirements 1.3**

- [ ]* 1.5 Write property test for refresh token rotation
  - **Property 4: Refresh Token Rotation**
  - **Validates: Requirements 1.4, 1.5**

- [ ] 2. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 3. Account and Member Property Tests
- [x] 3.1 Write property test for account uniqueness constraints
  - **Property 5: Account Uniqueness Constraints**
  - **Validates: Requirements 3.6, 3.7**
  - Essential: Ensures data integrity for unique phone/email

- [ ]* 3.2 Write property test for member data persistence
  - **Property 6: Member Data Persistence**
  - **Validates: Requirements 3.1, 3.8**

- [ ]* 3.3 Write property test for member update timestamps
  - **Property 7: Member Update Timestamps**
  - **Validates: Requirements 3.4, 14.2**

- [ ] 4. Activity Management Property Tests
- [ ]* 4.1 Write property test for activity creation with required fields
  - **Property 8: Activity Creation with Required Fields**
  - **Validates: Requirements 4.1**

- [x] 4.2 Write property test for automatic approver assignment
  - **Property 9: Automatic Approver Assignment**
  - **Validates: Requirements 4.2, 5.4**
  - Essential: Core business logic for approval workflow

- [ ]* 4.3 Write property test for activity enum validation
  - **Property 10: Activity Enum Validation**
  - **Validates: Requirements 4.8, 4.9**

- [ ]* 4.4 Write property test for activity cascade delete
  - **Property 11: Activity Cascade Delete**
  - **Validates: Requirements 4.7**

- [ ]* 4.5 Write property test for approval status update
  - **Property 12: Approval Status Update**
  - **Validates: Requirements 4.4**

- [ ]* 4.6 Write property test for activity filtering
  - **Property 13: Activity Filtering**
  - **Validates: Requirements 4.6**

- [ ] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Approval Rule Property Tests
- [ ]* 6.1 Write property test for approval rule position assignment
  - **Property 14: Approval Rule Position Assignment**
  - **Validates: Requirements 5.1, 5.2**

- [ ]* 6.2 Write property test for approval rule active state
  - **Property 15: Approval Rule Active State**
  - **Validates: Requirements 5.3**

- [ ] 7. Financial Operations Property Tests
- [ ]* 7.1 Write property test for financial record creation
  - **Property 16: Financial Record Creation**
  - **Validates: Requirements 6.1, 6.2, 6.3, 6.6**

- [ ]* 7.2 Write property test for financial record activity association
  - **Property 17: Financial Record Activity Association**
  - **Validates: Requirements 6.5**

- [ ]* 7.3 Write property test for financial aggregation
  - **Property 18: Financial Aggregation**
  - **Validates: Requirements 6.7**

- [ ] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Shared Package - Song Repository
- [x] 9.1 Create SongRepository with Riverpod
  - Implement getSongs with pagination and filtering by book
  - Add searchSongs by title or index
  - Implement getSongById with parts
  - _Requirements: 7.1, 7.2, 7.3_

- [ ]* 9.2 Write property test for song index uniqueness
  - **Property 19: Song Index Uniqueness**
  - **Validates: Requirements 7.6**

- [ ]* 9.3 Write property test for song parts ordering
  - **Property 20: Song Parts Ordering**
  - **Validates: Requirements 7.7**

- [ ]* 9.4 Write property test for song search
  - **Property 21: Song Search**
  - **Validates: Requirements 7.3**

- [ ] 10. Admin Panel - Song Management Feature
- [ ] 10.1 Implement song list UI
  - Create song list screen with data table
  - Add book filtering (NKB, NNBT, KJ, DSL)
  - Implement search by title or index
  - Display song index, title, and book
  - Add pagination controls
  - _Requirements: 7.1, 7.3, 7.5_

- [ ] 10.2 Implement song form UI
  - Create song creation form with basic info (title, index, book, link)
  - Add dynamic song part fields (add/remove parts)
  - Implement part ordering with index
  - Create song edit form with existing parts
  - Add form validation for required fields
  - _Requirements: 7.5, 7.6, 13.6, 13.7_

- [ ] 10.3 Implement song state management
  - Create SongController with Riverpod
  - Implement SongState with CRUD operations
  - Add song part management logic (create, update, delete, reorder)
  - Implement search and filtering logic
  - _Requirements: 7.1, 7.2, 7.3, 7.5, 7.6, 7.7_

- [ ] 11. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Church and Location Property Tests
- [ ]* 12.1 Write property test for column name uniqueness
  - **Property 22: Column Name Uniqueness**
  - **Validates: Requirements 8.4**

- [ ]* 12.2 Write property test for church location association
  - **Property 23: Church Location Association**
  - **Validates: Requirements 8.2**

- [ ] 13. Admin Panel - Church Management Enhancement
- [ ] 13.1 Implement church list UI
  - Create church list screen with data table
  - Display church name, contact info, and location
  - Add edit and view actions
  - Implement pagination if needed
  - _Requirements: 8.1_

- [ ] 13.2 Implement church form UI
  - Create church creation form with all fields
  - Implement church edit form
  - Add location input with latitude/longitude
  - Add form validation
  - _Requirements: 8.1, 8.2, 13.6, 13.7_

- [ ] 13.3 Implement column management UI
  - Create column list within church detail view
  - Add column creation dialog/form
  - Implement column editing
  - Add column deletion with confirmation
  - _Requirements: 8.3, 8.4_

- [ ] 13.4 Implement church state management
  - Create ChurchController with Riverpod
  - Implement ChurchState with CRUD operations
  - Add column management logic within church context
  - Implement location association and updates
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.7_

- [ ] 14. Church Request Property Tests
- [ ]* 14.1 Write property test for church request uniqueness
  - **Property 24: Church Request Uniqueness**
  - **Validates: Requirements 9.3, 9.10**

- [ ]* 14.2 Write property test for church request status messages
  - **Property 25: Church Request Status Messages**
  - **Validates: Requirements 9.7**

- [ ] 15. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 16. Multi-Church Data Isolation Tests
- [ ] 16.1 Write property test for multi-church data isolation
  - **Property 26: Multi-Church Data Isolation**
  - **Validates: Requirements 11.1, 11.2, 11.4, 11.5, 11.6**
  - Essential: Critical security requirement for multi-tenant system

- [ ] 16.2 Verify church filtering in all backend queries
  - Review all service methods for church-scoped queries
  - Test church-based authorization in JWT claims
  - Ensure data isolation between different churches
  - _Requirements: 11.1, 11.2, 11.3, 11.4_

- [ ] 17. Pagination and Validation Property Tests
- [ ]* 17.1 Write property test for pagination correctness
  - **Property 27: Pagination Correctness**
  - **Validates: Requirements 12.1, 12.2, 12.5**

- [ ]* 17.2 Write property test for validation error response
  - **Property 28: Validation Error Response**
  - **Validates: Requirements 13.2**

- [ ]* 17.3 Write property test for timestamp management
  - **Property 29: Timestamp Management**
  - **Validates: Requirements 14.1, 14.2, 14.4**

- [ ] 18. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 19. Performance Optimization
- [ ] 19.1 Optimize database queries
  - Review and optimize Prisma queries with select/include
  - Verify indexes on frequently queried fields
  - Add composite indexes where needed
  - Test query performance with large datasets
  - _Requirements: 12.6_

- [ ] 19.2 Optimize mobile app performance
  - Implement lazy loading for activity lists
  - Optimize image loading with caching
  - Review and optimize widget rebuilds
  - _Requirements: 12.4_

- [x] 20. Security Review
- [x] 20.1 Review authentication security
  - Verify password hashing with bcryptjs
  - Test account lockout after failed login attempts
  - Verify refresh token rotation
  - Test JWT expiration and refresh flow
  - _Requirements: 1.3, 1.4, 1.5_

- [x] 20.2 Review authorization and data isolation
  - Verify role-based access control
  - Test church-level data isolation
  - Ensure protected routes require valid JWT
  - _Requirements: 1.7, 11.1, 11.2_

- [ ] 21. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Most backend infrastructure is complete and functional
- Shared package has comprehensive models, services, and widgets
- Mobile app has core features implemented (auth, home, approval, song book, church request)
- Admin panel has most management features implemented
- Key remaining work: Song repository, church management UI, and property-based tests
- Property tests marked with * are optional for faster MVP
- Essential property tests (without *) are required: account uniqueness, automatic approver assignment, multi-church data isolation
- Firebase Phone Auth is integrated for mobile authentication
