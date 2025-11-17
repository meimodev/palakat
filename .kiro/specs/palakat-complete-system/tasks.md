# Implementation Plan

## Overview

This implementation plan reflects the current state of the Palakat system. Most core infrastructure is already implemented. The remaining tasks focus on completing missing features, adding song repository support, and completing admin panel features.

## Completed Infrastructure

✅ Backend: All controllers, services, and database schema implemented
✅ Shared Package: Models, repositories (except Song), services, widgets, utilities
✅ Mobile App: Authentication, home, approval, song book UI, routing
✅ Admin Panel: Member, activity, approval, revenue, expense, document, report features
✅ Common: Pagination, error handling, validation

## Remaining Tasks

- [ ] 1. Shared Package - Song Repository
- [ ] 1.1 Create SongRepository with Riverpod
  - Implement getSongs with pagination and filtering by book
  - Add searchSongs by title or index
  - Implement getSongById with parts
  - _Requirements: 6.1, 6.2, 6.3_

- [ ] 2. Admin Panel - Song Management Feature
- [ ] 2.1 Implement song list UI
  - Create song list screen with data table
  - Add book filtering (NKB, NNBT, KJ, DSL)
  - Implement search by title or index
  - Display song index, title, and book
  - Add pagination controls
  - _Requirements: 6.1, 6.3, 6.5_

- [ ] 2.2 Implement song form UI
  - Create song creation form with basic info
  - Add dynamic song part fields (add/remove parts)
  - Implement part ordering with drag-and-drop or index
  - Create song edit form with existing parts
  - Add form validation for required fields
  - _Requirements: 6.5, 6.6, 13.6, 13.7_

- [ ] 2.3 Implement song state management
  - Create SongController with Riverpod
  - Implement SongState with CRUD operations
  - Add song part management logic (create, update, delete, reorder)
  - Implement search and filtering logic
  - Handle cascade deletion of parts when song is deleted
  - _Requirements: 6.1, 6.2, 6.3, 6.5, 6.6, 6.7_

- [ ] 3. Admin Panel - Church Management Enhancement
- [ ] 3.1 Implement church list UI
  - Create church list screen with data table
  - Display church name, contact info, and location
  - Add edit and view actions
  - Implement pagination if needed
  - _Requirements: 7.1_

- [ ] 3.2 Implement church form UI
  - Create church creation form with all fields
  - Implement church edit form
  - Add location input with latitude/longitude
  - Integrate map picker for location selection
  - Add form validation
  - _Requirements: 7.1, 7.2, 7.5, 13.6, 13.7_

- [ ] 3.3 Implement column management UI
  - Create column list within church detail view
  - Add column creation dialog/form
  - Implement column editing
  - Add column deletion with confirmation
  - Ensure column name uniqueness within church
  - _Requirements: 7.3, 7.4_

- [ ] 3.4 Implement church state management
  - Create ChurchController with Riverpod
  - Implement ChurchState with CRUD operations
  - Add column management logic within church context
  - Implement location association and updates
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7_

- [ ] 4. Backend - Approval Rule Auto-Assignment Logic
- [ ] 4.1 Enhance activity creation with auto-assignment
  - Verify ApprovalRuleService evaluates active rules
  - Ensure automatic approver assignment based on activity type and BIPRA
  - Query membership positions associated with matching rules
  - Create approver records for members with those positions
  - Test complete workflow from activity creation to approver assignment
  - _Requirements: 3.2, 4.1, 4.2, 4.3, 4.4_

- [ ] 5. System Integration Testing
- [ ] 5.1 Test multi-church data isolation
  - Verify church filtering in all backend queries
  - Test church-based authorization in JWT claims
  - Ensure data isolation between different churches
  - Verify admin panel only shows data for user's church
  - Verify mobile app only shows data for user's church
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6_

- [ ] 5.2 Test audit trail functionality
  - Verify createdAt and updatedAt timestamps on all entities
  - Test timestamp display in admin panel
  - Verify timezone conversion in mobile app
  - Ensure timestamps update correctly on modifications
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_

- [ ] 5.3 Test end-to-end activity approval workflow
  - Create activity and verify automatic approver assignment
  - Test approval status updates (APPROVED/REJECTED)
  - Test complete workflow from creation to final approval
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 6. Performance Optimization
- [ ] 6.1 Optimize database queries
  - Review and optimize Prisma queries with select/include
  - Verify indexes on frequently queried fields
  - Add composite indexes where needed
  - Test query performance with large datasets
  - _Requirements: 12.6_

- [ ] 6.2 Optimize mobile app performance
  - Implement lazy loading for activity lists
  - Optimize image loading with caching
  - Review and optimize widget rebuilds
  - Test app performance on low-end devices
  - _Requirements: 12.4_

- [ ] 7. Security Enhancements
- [ ] 7.1 Review authentication security
  - Verify password hashing with bcryptjs
  - Test account lockout after failed login attempts
  - Verify refresh token rotation
  - Test JWT expiration and refresh flow
  - _Requirements: 1.3, 1.4, 1.5_

- [ ] 7.2 Review authorization and data isolation
  - Verify role-based access control
  - Test church-level data isolation
  - Ensure protected routes require valid JWT
  - Test admin-only endpoints
  - _Requirements: 1.7, 14.1, 14.2_

## Notes

- Most backend infrastructure is complete and functional
- Shared package has comprehensive models, services, and widgets
- Mobile app has core features implemented (auth, home, approval, song book)
- Admin panel has most management features implemented
- Key remaining work: Song repository, church management UI, approval rule verification, and integration testing
- Firebase (FCM) and offline data caching have been completely removed from the codebase
