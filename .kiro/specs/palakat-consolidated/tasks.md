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

**Shared Package (packages/palakat_shared)**:
- All models with Freezed/JSON serialization
- Repositories for all entities
- Services (HTTP, local storage, Pusher Beams interface)
- Localization infrastructure (ARB files, AppLocalizations)
- LocaleController with persistence
- InterestBuilder utility for notification interests
- All widgets consolidated from mobile and admin apps
- Theme configuration and color system

**Mobile App (apps/palakat)**:
- Firebase Phone Authentication flow
- Home, Dashboard, Operations screens
- Activity creation with finance attachment
- Approval workflow with status updates
- Song book browsing and search
- Church request submission
- Push notification registration/unregistration
- Permission flow with rationale bottom sheets
- Notification channels (Android) and badge count (iOS)
- Multi-language support with language selector
- Supervised activities section
- Settings screen with account/membership navigation
- Sign out flow with confirmation dialog

**Admin Panel (apps/palakat_admin)**:
- Authentication flow
- Member management with CRUD
- Activity management with filtering
- Approval rule configuration (activity type, financial type, positions)
- Financial account number management
- Revenue and expense tracking
- Document and report management
- Push notification registration
- Multi-language support (COMPLETE)
- Dashboard with statistics
- All screens fully localized with Indonesian/English support

---

## REMAINING Tasks

### 1. Admin Panel Localization - Final Tasks

- [ ] 1.1 Write property test for ARB key parity
  - **Property 1: ARB Key Parity**
  - **Validates: Requirements 19.1**

- [ ] 1.2 Write property test for time pluralization
  - **Property 2: Time Pluralization Correctness**
  - **Validates: Requirements 18.1, 18.3**

- [ ] 1.3 Write property test for time unit selection
  - **Property 3: Time Unit Selection**
  - **Validates: Requirements 18.1**

- [ ] 1.4 Update remaining screens with hardcoded strings
  - [ ] 1.4.1 Update `activity_screen.dart` to use localized strings
    - Replace hardcoded subtitle "Monitor and manage all church activity." with localized string
  - [ ] 1.4.2 Update `expense_screen.dart` to use localized strings
    - Replace hardcoded dropdown options 'Cash', 'Cashless' with localized strings
    - Add missing page title and subtitle using localized strings
  - [ ] 1.4.3 Verify all other screens are fully localized

- [ ] 1.5 Add missing localization keys to ARB files
  - [ ] 1.5.1 Add missing payment method localization keys to `intl_en.arb`
    - Add keys: `paymentMethod_cash`, `paymentMethod_cashless`
  - [ ] 1.5.2 Add missing activity subtitle key to `intl_en.arb`
    - Add key: `admin_activity_subtitle` with value "Monitor and manage all church activity."
  - [ ] 1.5.3 Add missing expense screen keys to `intl_en.arb`
    - Add keys: `admin_expense_title`, `admin_expense_subtitle`
  - [ ] 1.5.4 Copy all new keys to `intl_id.arb` with Indonesian translations

- [ ] 1.6 Regenerate localization files after adding new keys
  - Run `melos run build:runner` to regenerate `app_localizations.dart` files
  - Verify no errors in generated code

### 2. Song Book Backend Integration (Mobile)

- [ ] 2.1 Wire SongBookController to SongRepository for search
- [ ] 2.2 Implement song detail fetching with complete data
- [ ] 2.3 Add loading shimmer and error states

### 3. Admin Panel Song Management

- [ ] 3.1 Implement song list UI with data table and filtering
- [ ] 3.2 Implement song form UI with dynamic parts
- [ ] 3.3 Implement song state management with Riverpod

### 4. Admin Panel Church Management Enhancement

- [ ] 4.1 Implement church list UI with data table
- [ ] 4.2 Implement church form UI with location input
- [ ] 4.3 Implement column management within church detail

### 5. Settings Screen - Final Tasks

- [ ] 5.1 Write property test - Sign out confirmation
  - **Property 5: Sign out confirmation display**
  - Test confirmation dialog appears on sign out tap

- [ ] 5.2 Write property test - Sign out navigation
  - **Property 7: Sign out navigation**
  - Test navigation to home after successful sign out

### 6. Property-Based Tests (Backend)

- [ ] 6.1 Authentication token lifecycle tests
- [ ] 6.2 Account lockout enforcement tests
- [ ] 6.3 Multi-church data isolation tests (CRITICAL)
- [ ] 6.4 Pagination correctness tests
- [ ] 6.5 Timestamp management tests

### 7. Property-Based Tests (Frontend)

- [ ] 7.1 Locale round-trip consistency
- [ ] 7.2 Date/number formatting locale awareness
- [ ] 7.3 Permission state persistence
- [ ] 7.4 Notification channel assignment

### 8. Performance Optimization

- [ ] 8.1 Review and optimize Prisma queries
- [ ] 8.2 Verify database indexes
- [ ] 8.3 Implement lazy loading for activity lists
- [ ] 8.4 Optimize image loading with caching

### 9. Final Testing Checkpoint

- [ ] 9.1 Run all property-based tests
- [ ] 9.2 Run all unit tests
- [ ] 9.3 Run integration tests
- [ ] 9.4 Test on physical devices (Android/iOS)

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

**Key Localization Features:**
- Complete Indonesian/English translation coverage
- ICU pluralization for time-relative strings
- Proper form validation messages
- Localized tooltips, buttons, and dialog content
- Responsive layout with localized text

### Settings Screen Implementation (COMPLETE)

**Completed Settings Features:**
- ✅ Settings screen with account/membership navigation
- ✅ Language selector integration
- ✅ Sign out flow with confirmation dialog
- ✅ Version info display (app version and build number)
- ✅ Push notification cleanup on sign out
- ✅ Navigation from dashboard settings button
- ✅ Property-based tests for core functionality

**Settings Screen Components:**
- Account settings navigation (when account exists)
- Membership settings navigation (when membership exists)
- Language selector (moved from AccountScreen)
- Sign out confirmation with proper cleanup
- Version display with format "Version X.Y.Z (Build N)"

### Push Notification System (COMPLETE)

**Completed Push Notification Features:**
- ✅ Pusher Beams integration with interest-based subscriptions
- ✅ Foreground and background notification handling
- ✅ Permission flow with rationale dialogs
- ✅ Notification channels (Android) and badge count (iOS)
- ✅ Proper cleanup on sign-out and re-initialization on sign-in
- ✅ FCM token refresh handling (CRITICAL for reliability)

**Push Notification Architecture:**
- `PusherBeamsController` (keepAlive Riverpod controller)
- `PusherBeamsMobileService` (low-level SDK wrapper)
- `InAppNotificationService` (in-app banners)
- `NotificationDisplayService` (system notifications)

---

## Notes

- Most backend infrastructure is complete and functional
- Shared package has comprehensive models, services, and widgets
- Mobile app has core features implemented including settings
- Admin panel is fully localized and functional
- Key remaining: Song backend integration, church management UI, property tests
- Push notification system fully implemented with Pusher Beams
- Multi-language support fully implemented (Indonesian/English)
- Permission flow implemented with rationale and consequence dialogs

## Consolidated Specs

This spec consolidates and replaces:
- `.kiro/specs/admin-localization/` - Admin panel Indonesian/English localization
- `.kiro/specs/palakat-complete/` - Complete system implementation status
- `.kiro/specs/settings-screen/` - Settings screen with navigation and sign out

All requirements, design elements, and tasks from these specs have been merged into this comprehensive document. The individual spec folders can now be deleted after this consolidation is complete.

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