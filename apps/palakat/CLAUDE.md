# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Palakat is a Flutter mobile event notifier application for church activity management. The app uses a shared package architecture where common code (models, repositories, services, widgets) is centralized in the `palakat_admin` package located at `../palakat_admin`.

## Build & Development Commands

### Code Generation
```bash
# Run build_runner to generate code (freezed, riverpod, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation during development
dart run build_runner watch -d
```

### Using Derry Scripts
The project uses `derry` for script management (see `derry.yaml`):
```bash
# Clean, get dependencies, and run code generation
derry build

# Run code generation only
derry gen

# Watch mode
derry watch
```

### Running the App
```bash
flutter run

# Run on specific device
flutter run -d <device-id>
```

### Testing
```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/quick_test.dart
```

## Architecture

### Package Structure
- **palakat_admin** (local package at `../palakat_admin`): Shared code package containing:
  - Models: Account, Activity, Church, Column, Membership, Song, Revenue, Expense, etc.
  - Repositories: AuthRepository, ActivityRepository, ChurchRepository, MemberRepository, etc.
  - Services: ApiService, HttpService, LocalStorageService, ApproverService
  - Widgets: AppTable, PaginationBar, ValidatedTextField, StatusChip, DateRangePicker, etc.
  - Utilities: Debouncer, date formatting extensions, error mapping
  - Extensions: AccountExtension, StringExtension, number/map extensions
  - Theme: Material 3 theme builder
  - Constants & Enums: ActivityType, Gender, MaritalStatus, Bipra, PaymentMethod, etc.

### App Structure
```
lib/
├── core/
│   ├── constants/      # Re-exports from palakat_admin + local enums
│   ├── models/         # Re-exports from palakat_admin + ActivityOverview
│   ├── routing/        # go_router configuration
│   ├── themes/         # App-specific themes
│   ├── utils/          # Utilities and extensions
│   └── widgets/        # App-specific reusable widgets
└── features/
    ├── account/        # User account & membership
    ├── approval/       # Approval workflows
    ├── authentication/ # Firebase authentication
    ├── dashboard/      # Home dashboard with activities
    ├── operations/     # Operations management
    ├── publishing/     # Activity publishing & maps
    ├── song_book/      # Song book listing
    └── splash/         # Splash screen
```

### Feature Architecture
Each feature follows a layered structure:
```
feature/
├── data/
│   ├── *_repository.dart        # Riverpod-generated repository
│   └── *_repository.g.dart      # Generated code
└── presentations/
    ├── *_controller.dart        # Riverpod controller with business logic
    ├── *_controller.g.dart      # Generated code
    ├── *_state.dart             # Freezed state classes
    ├── *_state.freezed.dart     # Generated code
    ├── *_screen.dart            # UI screens
    └── widgets/                 # Feature-specific widgets
```

### State Management
- **Riverpod**: Primary state management using `@riverpod` annotations
- **Freezed**: Immutable state classes with `@freezed` annotation
- **Controllers**: Extend `_$*Controller` and manage feature state
- **Repositories**: Handle data access, use `Result<T, Failure>` for error handling

Example pattern:
```dart
// Controller
@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardState build() {
    // Initialize state
  }
}

// State
@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(true) bool loading,
    @Default([]) List<Activity> activities,
  }) = _DashboardState;
}
```

## Routing Conventions

Navigation uses `go_router` with specific patterns:

### Passing Data Between Screens
- **For Freezed models**: Use `extra` with `RouteParam` wrapper, serialize with `toJson`, reconstruct with `fromJson`
  ```dart
  // Pushing to route
  context.pushNamed(
    AppRoute.someDetail,
    extra: RouteParam(params: {'model': myModel.toJson()})
  );

  // Reading in route
  final params = (state.extra as RouteParam?)?.params;
  final model = MyModel.fromJson(params?['model'] as Map<String, dynamic>);
  ```
- **Query parameters**: Only use for deep links, not for large JSON payloads in normal flows
- **Route constants**: Defined in `AppRoute` class in `core/routing/app_routing.dart`

### Route Organization
- Main routes: `app_routing.dart`
- Feature routes: `dashboard_routing.dart`, `publishing_routing.dart`, etc.
- Global navigator key: `navigatorKey` in `app_routing.dart`

## Code Generation Dependencies

The project uses several code generators that require running `build_runner`:
- **riverpod_generator**: Generates `*.g.dart` for Riverpod providers
- **freezed**: Generates `*.freezed.dart` for immutable state classes
- **json_serializable**: Generates `*.g.dart` for JSON serialization

After modifying files with `@riverpod`, `@freezed`, or `@JsonSerializable` annotations, run:
```bash
derry gen
```

## Shared Package Usage

### Importing from palakat_admin
Use specific imports based on what you need:
```dart
import 'package:palakat_admin/models.dart';        // Models only
import 'package:palakat_admin/repositories.dart';  // Repositories
import 'package:palakat_admin/services.dart';      // Services
import 'package:palakat_admin/widgets.dart';       // Widgets
import 'package:palakat_admin/constants.dart';     // Enums & constants
import 'package:palakat_admin/utils.dart';         // Utilities
```

Or import everything:
```dart
import 'package:palakat_admin/palakat_admin.dart';
```

### Local Re-exports
Core barrel files re-export from palakat_admin:
```dart
import 'package:palakat/core/models/models.dart';      // Includes admin models
import 'package:palakat/core/constants/constants.dart'; // Includes admin constants
```

### Key Changes from Migration (see MIGRATION_TO_ADMIN_PACKAGE.md)
- `Debounce(duration)` → `Debouncer(delay: duration)`
- `account.ageYears` → `account.calculateAge.years`
- Extensions like `AccountExtension.calculateBipra` now from admin package

## Configuration

### Environment Variables
The app uses `flutter_dotenv` with `.env` file. See `.env.example` for required variables:
- `BASE_URL`: API endpoint (prefer local IP over localhost)
- `GOOGLE_MAPS_URL`, `GOOGLE_API_KEY`: Google Maps integration
- Firebase config variables
- Social auth tokens

### Firebase
- Initialized in `main.dart` using `firebase_core`
- Configuration in `firebase_options.dart`
- Used for authentication in `features/authentication`

### Localization
- Locale: Indonesian (`id_ID`)
- Date library: Jiffy with Indonesian locale
- Screen adaptation: ScreenUtil with design size 360x640

## Important Notes

- **Hive**: Local storage initialized via `hiveInit()` in main.dart
- **Theme**: Uses `BaseTheme.appTheme` defined in core/constants
- **Asset organization**: Icons split into fill/, line/, tint/ subdirectories
- **Font**: OpenSans with weights 300-800

## Current State

Based on recent git history, the project is actively working on:
- Approval screen improvements (`approval_screen.dart`, `approval_detail_controller.dart`)
- Dashboard screen updates
- Migration to palakat_admin package (mostly complete, see MIGRATION_TO_ADMIN_PACKAGE.md)
