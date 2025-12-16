# Design Document

## Overview

This design document covers the remaining implementation tasks for the Palakat church management platform. The system is largely complete, with this document focusing on:
- Remaining localization property tests
- Song management UI for admin panel
- Backend and frontend property-based tests
- Performance optimizations

## Architecture

The Palakat platform follows a monorepo architecture:

```
palakat_monorepo/
├── apps/
│   ├── palakat/              # Flutter mobile app (Android/iOS)
│   ├── palakat_admin/        # Flutter web admin panel
│   └── palakat_backend/      # NestJS REST API
└── packages/
    └── palakat_shared/       # Shared Flutter code
```

### Technology Stack

- **Mobile/Web**: Flutter with Riverpod state management
- **Backend**: NestJS with Prisma ORM and PostgreSQL
- **Testing**: kiri_check (Flutter), fast-check (Backend) for property-based testing

## Components and Interfaces

### Admin Panel Song Management

```dart
// Song list screen with data table
class SongScreen extends ConsumerStatefulWidget {
  // Displays songs in filterable data table
  // Supports search, filter by book type
  // Opens drawer for create/edit
}

// Song form with dynamic parts
class SongFormDrawer extends ConsumerWidget {
  // Form fields: title, subtitle, book, index
  // Dynamic list of song parts (verse, chorus, bridge, etc.)
  // Validation and save functionality
}

// Song controller for state management
@riverpod
class SongController extends _$SongController {
  // CRUD operations via SongRepository
  // Filtering and search state
  // Loading and error states
}
```

### Property Test Structure

```dart
// Flutter property tests use kiri_check
property('Property name', () {
  forAll(arbitrary, (input) {
    // Test assertions
  });
});

// Backend property tests use fast-check
fc.assert(
  fc.property(generator, (input) => {
    // Test assertions
  }),
  { numRuns: 100 }
);
```

## Data Models

### Song Model (Existing)

```dart
@freezed
class Song with _$Song {
  const factory Song({
    int? id,
    required String title,
    required String subTitle,
    required String book,
    required int index,
    List<SongPart>? parts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Song;
}

@freezed
class SongPart with _$SongPart {
  const factory SongPart({
    int? id,
    required SongPartType type,
    required String content,
    int? songId,
  }) = _SongPart;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: ARB Key Parity (IMPLEMENTED)

*For any* localization key present in `intl_en.arb`, there SHALL exist a corresponding key with the same name in `intl_id.arb`, and vice versa.

**Validates: Requirements 1.1, 7.1**

**Status:** ✅ Implemented in `packages/palakat_shared/test/l10n/arb_parity_test.dart`

---

### Property 2: Time Pluralization Correctness

*For any* time duration value N and time unit U (seconds, minutes, hours, days), the pluralized string SHALL use the correct plural form based on the value and locale rules.

**Validates: Requirements 1.3, 7.2**

**Status:** ❌ Not implemented

---

### Property 3: Time Unit Selection

*For any* time duration, the system SHALL select the most appropriate time unit (seconds → minutes → hours → days) based on the magnitude of the duration.

**Validates: Requirements 1.3**

**Status:** ❌ Not implemented

---

### Property 4: Settings Navigation from Dashboard (IMPLEMENTED)

*For any* dashboard state where account is not null, the navigation logic should correctly identify that settings navigation should be available.

**Validates: Requirements 5.1**

**Status:** ✅ Implemented in `apps/palakat/test/features/settings/presentations/settings_property_test.dart`

---

### Property 5: Sign Out Confirmation Display (IMPLEMENTED)

*For any* settings screen state, tapping the sign out button should display a confirmation dialog before executing sign out.

**Validates: Requirements 5.4**

**Status:** ✅ Implemented in `apps/palakat/test/features/settings/presentations/settings_property_test.dart`

---

### Property 6: Sign Out Cleanup Execution (IMPLEMENTED)

*For any* confirmed sign out action, the system should unregister push notification interests and clear the session before navigation.

**Validates: Requirements 5.5**

**Status:** ✅ Implemented in `apps/palakat/test/features/settings/presentations/settings_property_test.dart`

---

### Property 7: Sign Out Navigation

*For any* successful sign out, the system SHALL navigate to the home screen.

**Validates: Requirements 5.6**

**Status:** ❌ Not implemented (navigation is tested implicitly but not as explicit property)

---

### Property 8: Version Format Display (IMPLEMENTED)

*For any* version string V and build number B, the displayed version should match the format "Version V (Build B)".

**Validates: Requirements 5.7**

**Status:** ✅ Implemented in `apps/palakat/test/features/settings/presentations/settings_property_test.dart`

---

### Property 9: Authentication Token Lifecycle

*For any* valid credentials, the system SHALL generate a valid JWT token that can be verified.

**Validates: Requirements 6.1**

**Status:** ❌ Not implemented

---

### Property 10: Account Lockout Enforcement

*For any* account that exceeds the maximum failed login attempts, the system SHALL prevent further login attempts.

**Validates: Requirements 6.2**

**Status:** ❌ Not implemented

---

### Property 11: Multi-Church Data Isolation (CRITICAL)

*For any* query from a user in Church A, the results SHALL NOT include data belonging to Church B.

**Validates: Requirements 6.3**

**Status:** ❌ Not implemented

---

### Property 12: Pagination Correctness

*For any* paginated request with page P and size S, the results SHALL contain at most S items and represent the correct offset.

**Validates: Requirements 6.4**

**Status:** ❌ Not implemented

---

### Property 13: Timestamp Management

*For any* created or updated entity, the timestamps SHALL be stored in UTC and formatted consistently.

**Validates: Requirements 6.5**

**Status:** ❌ Not implemented

---

### Property 14: Locale Round-Trip Consistency

*For any* locale change from L1 to L2 and back to L1, the UI state SHALL be identical to the original state.

**Validates: Requirements 7.3**

**Status:** ❌ Not implemented

---

### Property 15: Date/Number Formatting Locale Awareness

*For any* date or number value, the formatted string SHALL respect the current locale settings.

**Validates: Requirements 7.4**

**Status:** ❌ Not implemented

---

### Property 16: Permission State Persistence

*For any* permission state change, the state SHALL persist across app restarts.

**Validates: Requirements 7.5**

**Status:** ❌ Not implemented

---

### Property 17: Notification Channel Assignment (IMPLEMENTED)

*For any* notification type, the notification SHALL be assigned to the correct channel with appropriate settings.

**Validates: Requirements 7.6**

**Status:** ✅ Implemented in `apps/palakat/test/core/constants/notification_channels_property_test.dart`

---

## Error Handling

### API Errors
- Network errors display retry option
- Validation errors show field-specific messages
- Authentication errors redirect to login

### Form Validation
- Required fields show error on empty submission
- Format validation (email, phone) shows specific messages
- Server-side validation errors mapped to form fields

## Testing Strategy

### Dual Testing Approach

The project uses both unit tests and property-based tests:

1. **Unit Tests**: Verify specific examples and edge cases
2. **Property Tests**: Verify universal properties across generated inputs

### Property-Based Testing Libraries

- **Flutter**: `kiri_check` package
- **Backend**: `fast-check` ^4.3.0

### Test Configuration

- Minimum 100 iterations per property test
- Each property test tagged with design document reference
- Format: `**Feature: {feature_name}, Property {number}: {property_text}**`

### Test File Locations

- Flutter: `test/**/*_property_test.dart`
- Backend: `test/property/*.property.spec.ts`

