# Design Document

## Overview

The Palakat system is a three-tier application with clear separation of concerns:

1. **Mobile Application Layer** - Flutter mobile app for church members (iOS/Android)
2. **Admin Application Layer** - Flutter web app for church administrators  
3. **Backend API Layer** - NestJS REST API with PostgreSQL database

The monorepo structure uses Melos (Flutter) and pnpm (Node.js), enabling code sharing through `palakat_shared`.

### Design Principles

- **Separation of Concerns**: Clear boundaries between presentation, business logic, and data
- **Code Reusability**: Shared package for common models, services, widgets
- **Scalability**: Multi-tenant architecture supporting multiple churches
- **Security**: JWT-based authentication with refresh token rotation
- **Performance**: Database indexing, pagination, efficient queries

## Architecture

### Mobile App Architecture

Feature-based layered architecture:
- **Data Layer**: Repositories handling API communication
- **Presentation Layer**: Controllers (Riverpod), States (Freezed), Screens, Widgets
- **Domain Layer**: Models, Services, Constants via palakat_shared

**State Management**: Riverpod with code generation (@riverpod annotation)
**Navigation**: go_router with declarative routing
**Local Storage**: Hive for key-value storage

### Backend API Architecture

NestJS modular architecture:
- **Controller Layer**: HTTP endpoints, request validation, response formatting
- **Service Layer**: Business logic, data transformation, orchestration
- **Repository Layer**: Prisma database queries, transactions
- **Common Layer**: Guards, Interceptors, Filters, Utilities


## Components and Interfaces

### 1. Authentication System

**Components**:
- `AuthController` - Sign-in, sign-out, token refresh, validation
- `AuthService` - Authentication logic, token generation
- `JwtStrategy` - JWT token validation for protected routes

**Security Features**:
- Password hashing with bcryptjs (10 rounds)
- Failed login tracking with account lockout (5 attempts, 30 min)
- Refresh token rotation (one-time use)
- JWT expiration (15 min access, 7 days refresh)

### 2. Activity Management System

**Components**:
- `ActivityController` - CRUD endpoints for activities
- `ActivityService` - Business logic for activity operations
- `ApproverService` - Approver status management
- `ApproverResolverService` - Automatic approver assignment

**Approval States**: UNCONFIRMED, APPROVED, REJECTED

### 3. Notification System (Pusher Beams)

**Backend Components**:
- `NotificationModule` - Module structure
- `PusherBeamsService` - Pusher Beams client wrapper
- `NotificationService` - Notification business logic
- `NotificationController` - CRUD endpoints

**Device Interest Patterns**:
- `palakat` - Global interest for all users
- `church.{churchId}` - Church-wide notifications
- `church.{churchId}_bipra.{BIPRA}` - BIPRA division within church
- `membership.{membershipId}` - Individual membership notifications

**Flutter Components**:
- `InterestBuilder` - Utility for building interest names
- `PusherBeamsService` - Abstract interface for SDK operations
- `PusherBeamsMobileService` - Mobile implementation
- `PusherBeamsWebService` - Web implementation for admin panel

### 4. Localization System

**Components**:
- `LocaleService` - Persistence of locale preference to Hive
- `LocaleController` - Riverpod state management for locale
- `AppLocalizations` - Generated class for type-safe translations
- `LanguageSelector` - Widget for language selection

**Supported Locales**: Indonesian (id), English (en)

### 5. Permission Management (Mobile)

**Components**:
- `PermissionManagerService` - Permission state and UI flows
- `NotificationDisplayService` - System notification display
- `NotificationNavigationService` - Deep link navigation handling
- `PermissionRationaleBottomSheet` - Permission explanation UI
- `ConsequenceExplanationBottomSheet` - Denial consequence UI

**Android Notification Channels**:
- `activity_updates` - DEFAULT importance
- `approval_requests` - HIGH importance  
- `general_announcements` - LOW importance


## Data Models

### Core Entities

**Account**: id, name, phone, email, gender, maritalStatus, dob, isActive, claimed, membership
**Activity**: id, supervisorId, bipra, title, description, locationId, date, note, activityType, reminder, timestamps, supervisor, approvers, location
**Approver**: id, membershipId, activityId, status, timestamps
**FinancialAccountNumber**: id, accountNumber, description, churchId, timestamps
**Notification**: id, title, body, type, recipient, activityId, isRead, timestamps

### Enumerations

- Gender: MALE, FEMALE
- MaritalStatus: MARRIED, SINGLE
- Bipra: PKB, WKI, PMD, RMJ, ASM
- ActivityType: SERVICE, EVENT, ANNOUNCEMENT
- ApprovalStatus: UNCONFIRMED, APPROVED, REJECTED
- Book: NKB, NNBT, KJ, DSL
- PaymentMethod: CASH, CASHLESS
- RequestStatus: TODO, DOING, DONE
- Reminder: TEN_MINUTES, THIRTY_MINUTES, ONE_HOUR, TWO_HOURS
- FinanceType: REVENUE, EXPENSE
- NotificationType: ACTIVITY_CREATED, APPROVAL_REQUIRED, APPROVAL_CONFIRMED, APPROVAL_REJECTED
- PermissionStatus: notDetermined, granted, denied, permanentlyDenied

## Correctness Properties

### Authentication Properties
- **Property 1**: Valid credentials return JWT tokens; invalid credentials rejected
- **Property 2**: Account lockout after 5 failed attempts for 30 minutes
- **Property 3**: Refresh token rotation invalidates old token

### Activity Properties
- **Property 4**: Activity creation stores all required fields correctly
- **Property 5**: Automatic approver assignment based on active approval rules
- **Property 6**: Activity cascade delete removes all approver records

### Financial Properties
- **Property 7**: Financial account uniqueness within church
- **Property 8**: Create-read round trip preserves data
- **Property 9**: Search filter returns matching accounts

### Notification Properties
- **Property 10**: Notification persistence round-trip
- **Property 11**: Read status state transition
- **Property 12**: Interest name formatting correctness

### Localization Properties
- **Property 13**: Locale round-trip consistency (serialize/deserialize)
- **Property 14**: Locale persistence consistency
- **Property 15**: Date/number formatting locale awareness

### Permission Properties
- **Property 16**: Permission state persistence
- **Property 17**: Permission denial retry timing (7 days)
- **Property 18**: Notification channel assignment correctness

## Error Handling

### Backend Error Handling
- Global exception filter catches all unhandled exceptions
- Prisma errors transformed to HTTP errors
- Standardized error response format with statusCode, message, error, timestamp, path

### Frontend Error Handling
- Error mapper transforms API errors to user-friendly messages
- Toast messages for transient errors
- Dialog boxes for critical errors
- Inline validation for form errors

## Testing Strategy

### Dual Testing Approach
- **Unit tests**: Specific examples, edge cases, error conditions
- **Property tests**: Universal properties across all inputs

### Backend Testing
- Jest for unit tests, Supertest for E2E, fast-check for property-based
- Service layer: 80%+ coverage, Controllers: 70%+, Critical paths: 100%

### Frontend Testing
- Flutter test framework with Mockito
- kiri_check for property-based testing
- Widget tests for reusable components
