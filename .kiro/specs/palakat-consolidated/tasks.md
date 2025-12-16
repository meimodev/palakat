# Palakat Consolidated Implementation Plan

## Overview

This consolidated implementation plan combines all previous specs into a single comprehensive document. It covers the complete Palakat church management system including:
- Admin panel localization (admin-localization spec)
- Complete system implementation (palakat-complete spec)  
- Settings screen implementation (settings-screen spec)

## Current Implementation Status

### COMPLETED Features

**Backend (apps/palakat_backend)**:
- All controllers, services, database schema
- Authentication with JWT and Firebase validation
- Activity management with automatic approver assignment
- Financial account number CRUD with unique constraints
- Notification module with Pusher Beams integration
- Approver module with full CRUD operations
- All API endpoints for members, activities, approvals, finances, songs, documents, reports
- Property tests: setup, generators, activity, approval, financial, notification tests

**Shared Package (packages/palakat_shared)**:
- All models with Freezed/JSON serialization
- Repositories for all entities
- Services (HTTP, local storage, Pusher Beams interface)
- Localization infrastructure (ARB files, AppLocalizations)
- LocaleController with persistence
- InterestBuilder utility for notification interests
- All widgets consolidated from mobile and admin apps
- Theme configuration and color system
- PaymentMethod with localized displayName extension

**Mobile App (apps/palakat)**:
- Firebase Phone Authentication flow
- Home, Dashboard, Operations screens
- Activity creation with finance attachment
- Approval workflow with status updates
- Song book browsing and search (with backend integration)
- Church request submission
- Push notification registration/unregistration
- Permission flow with rationale bottom sheets
- Notification channels (Android) and badge count (iOS)
- Multi-language support with language selector
- Supervised activities section
- Settings screen with account/membership navigation
- Sign out flow with confirmation dialog
- Property tests: settings (Properties 1-6, 8), song book, approval, notification

**Admin Panel (apps/palakat_admin)**:
- Authentication flow
- Member management with CRUD
- Activity management with filtering
- Approval rule configuration (activity type, financial type, positions)
- Financial account number management
- Revenue and expense tracking (with localized PaymentMethod)
- Document and report management
- Push notification registration
- Multi-language support (COMPLETE)
- Dashboard with statistics
- Church management with columns and positions (COMPLETE)
- All screens fully localized with Indonesian/English support

**Property Tests (COMPLETED)**:
- ✅ Property 1: ARB Key Parity (`packages/palakat_shared/test/l10n/arb_parity_test.dart`)
- ✅ Property 4: Settings Navigation from Dashboard
- ✅ Property 5: Sign Out Confirmation Display
- ✅ Property 6: Sign Out Cleanup Execution
- ✅ Property 8: Version Format Display
- ✅ Property 17: Notification Channel Assignment

---

## REMAINING Tasks

### 1. Admin Panel Localization - Property Tests

- [ ] 1.1 Write property test for time pluralization
  - **Property 2: Time Pluralization Correctness**
  - **Validates: Requirements 1.3, 7.2**
  - Test that pluralized time strings use correct plural forms based on value and locale
  - Create test file: `packages/palakat_shared/test/l10n/time_pluralization_property_test.dart`

- [ ] 1.2 Write property test for time unit selection
  - **Property 3: Time Unit Selection**
  - **Validates: Requirements 1.3**
  - Test that time durations select appropriate units (seconds → minutes → hours → days)
  - Add to: `packages/palakat_shared/test/l10n/time_pluralization_property_test.dart`

### 2. Settings Screen - Final Property Test

- [ ] 2.1 Write property test for sign out navigation
  - **Property 7: Sign Out Navigation**
  - **Validates: Requirements 5.6**
  - Test that successful sign out navigates to home screen
  - Add to: `apps/palakat/test/features/settings/presentations/settings_property_test.dart`

### 3. Admin Panel Song Management

- [ ] 3.1 Implement song list UI with data table and filtering
  - Create `apps/palakat_admin/lib/features/song/presentation/screens/song_screen.dart`
  - Add data table with columns: ID, Title, Book, Index
  - Add filter by book type (NKB, NNBT, KJ, DSL)
  - Add search functionality
  - _Requirements: 3.1_

- [ ] 3.2 Implement song form UI with dynamic parts
  - Create `apps/palakat_admin/lib/features/song/presentation/widgets/song_form_drawer.dart`
  - Form fields: title, subtitle, book, index
  - Dynamic list for song parts (verse, chorus, bridge, etc.)
  - Add/remove part functionality
  - _Requirements: 3.2_

- [ ] 3.3 Implement song state management with Riverpod
  - Create `apps/palakat_admin/lib/features/song/application/song_controller.dart`
  - CRUD operations via SongRepository
  - Filtering and search state
  - Loading and error states
  - _Requirements: 3.3_

- [ ] 3.4 Write unit tests for song management
  - Test song controller state transitions
  - Test form validation
  - _Requirements: 3.1, 3.2, 3.3_

### 4. Backend Property-Based Tests

- [ ] 4.1 Write property test for authentication token lifecycle
  - **Property 9: Authentication Token Lifecycle**
  - **Validates: Requirements 6.1**
  - Test JWT generation and validation
  - Add to: `apps/palakat_backend/test/property/auth-token.property.spec.ts`

- [ ] 4.2 Write property test for account lockout enforcement
  - **Property 10: Account Lockout Enforcement**
  - **Validates: Requirements 6.2**
  - Test failed login attempt tracking and lockout
  - Add to: `apps/palakat_backend/test/property/account-lockout.property.spec.ts`

- [ ] 4.3 Write property test for multi-church data isolation (CRITICAL)
  - **Property 11: Multi-Church Data Isolation**
  - **Validates: Requirements 6.3**
  - Test that queries from Church A never return Church B data
  - Add to: `apps/palakat_backend/test/property/multi-church-isolation.property.spec.ts`

- [ ] 4.4 Write property test for pagination correctness
  - **Property 12: Pagination Correctness**
  - **Validates: Requirements 6.4**
  - Test page boundaries and data ordering
  - Add to: `apps/palakat_backend/test/property/pagination.property.spec.ts`

- [ ] 4.5 Write property test for timestamp management
  - **Property 13: Timestamp Management**
  - **Validates: Requirements 6.5**
  - Test UTC storage and consistent formatting
  - Add to: `apps/palakat_backend/test/property/timestamp.property.spec.ts`

### 5. Frontend Property-Based Tests

- [ ] 5.1 Write property test for locale round-trip consistency
  - **Property 14: Locale Round-Trip Consistency**
  - **Validates: Requirements 7.3**
  - Test locale change L1 → L2 → L1 preserves state
  - Add to: `packages/palakat_shared/test/l10n/locale_roundtrip_property_test.dart`

- [ ] 5.2 Write property test for date/number formatting locale awareness
  - **Property 15: Date/Number Formatting Locale Awareness**
  - **Validates: Requirements 7.4**
  - Test formatted strings respect locale settings
  - Add to: `packages/palakat_shared/test/core/utils/formatting_property_test.dart`

- [ ] 5.3 Write property test for permission state persistence
  - **Property 16: Permission State Persistence**
  - **Validates: Requirements 7.5**
  - Test permission state persists across app restarts
  - Add to: `apps/palakat/test/features/notification/presentations/permission_persistence_property_test.dart`

### 6. Performance Optimization

- [ ] 6.1 Review and optimize Prisma queries
  - Analyze slow queries using Prisma query logging
  - Add appropriate `select` and `include` clauses
  - _Requirements: 8.3_

- [ ] 6.2 Verify database indexes
  - Review schema for missing indexes on frequently queried columns
  - Add indexes for foreign keys and filter columns
  - _Requirements: 8.3_

- [ ] 6.3 Implement lazy loading for activity lists
  - Add pagination to activity list screens
  - Implement infinite scroll or load more button
  - _Requirements: 8.1_

- [ ] 6.4 Optimize image loading with caching
  - Configure cached_network_image for all image widgets
  - Set appropriate cache duration and size limits
  - _Requirements: 8.2_

### 7. Checkpoint - Ensure All Tests Pass

- [ ] 7.1 Run all property-based tests
  - Run `melos run test` for Flutter tests
  - Run `pnpm run test:property` for backend tests
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7.2 Run all unit tests
  - Run `melos run test` for Flutter tests
  - Run `pnpm run test` for backend tests
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7.3 Run integration tests
  - Run `pnpm run test:e2e` for backend e2e tests
  - Test on physical devices (Android/iOS)
  - _Requirements: All_

---

## Completed Implementation Details

### Admin Panel Localization (COMPLETE)

All admin panel screens have been fully localized with Indonesian/English support:

**Completed Localization Tasks:**
- ✅ Added 200+ localization keys to ARB files (English and Indonesian)
- ✅ Updated all billing, approval, account, activity, revenue, expense screens
- ✅ Updated all member, financial, church, document, report screens
- ✅ Updated dashboard with time-relative strings and pluralization
- ✅ Updated core layout, navigation, and authentication screens
- ✅ Fixed import conflicts with Column widget
- ✅ Regenerated localization files successfully
- ✅ PaymentMethod enum has localized displayName extension

### Settings Screen Implementation (COMPLETE)

**Completed Settings Features:**
- ✅ Settings screen with account/membership navigation
- ✅ Language selector integration
- ✅ Sign out flow with confirmation dialog
- ✅ Version info display (app version and build number)
- ✅ Push notification cleanup on sign out
- ✅ Navigation from dashboard settings button
- ✅ Property-based tests for core functionality (Properties 1-6, 8)

### Church Management (COMPLETE)

**Completed Church Features:**
- ✅ Church information display and editing
- ✅ Location management with coordinates
- ✅ Column management (create, edit, delete)
- ✅ Position management (create, edit, delete)
- ✅ All screens fully localized

### Song Book Backend Integration (COMPLETE)

**Completed Song Book Features:**
- ✅ SongBookController with SongRepository integration
- ✅ Song search via backend API
- ✅ Category-based filtering
- ✅ Loading and error states
- ✅ Property tests for song book controller

### Push Notification System (COMPLETE)

**Completed Push Notification Features:**
- ✅ Pusher Beams integration with interest-based subscriptions
- ✅ Foreground and background notification handling
- ✅ Permission flow with rationale dialogs
- ✅ Notification channels (Android) and badge count (iOS)
- ✅ Proper cleanup on sign-out and re-initialization on sign-in
- ✅ FCM token refresh handling (CRITICAL for reliability)

---

## Notes

- Most backend infrastructure is complete and functional
- Shared package has comprehensive models, services, and widgets
- Mobile app has core features implemented including settings
- Admin panel is fully localized and functional
- Key remaining: Song management UI, property tests, performance optimization
- Push notification system fully implemented with Pusher Beams
- Multi-language support fully implemented (Indonesian/English)
- Permission flow implemented with rationale and consequence dialogs

## Consolidated Specs

This spec consolidates and replaces:
- `.kiro/specs/admin-localization/` - Admin panel Indonesian/English localization
- `.kiro/specs/palakat-complete/` - Complete system implementation status
- `.kiro/specs/settings-screen/` - Settings screen with navigation and sign out

All requirements, design elements, and tasks from these specs have been merged into this comprehensive document.

---

## Quick Reference - Key Commands

### Flutter (from monorepo root)
```bash
melos bootstrap          # Install all dependencies
melos run analyze        # Run flutter analyze
melos run format         # Format all code
melos run test           # Run all tests
melos run build:runner   # Generate code (freezed, riverpod, json)
melos run clean          # Clean all packages
```

### Backend (from apps/palakat_backend)
```bash
pnpm install             # Install dependencies
pnpm run start:dev       # Start dev server with watch
pnpm run test            # Run unit tests
pnpm run test:e2e        # Run e2e tests
pnpm run test:property   # Run property-based tests
pnpm run prisma:generate # Generate Prisma client
pnpm run db:migrate      # Run migrations
pnpm run db:seed         # Seed database
```
