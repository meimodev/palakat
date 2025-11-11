# Palakat - Event Notifier App

A Flutter mobile application for church event notifications and activity management.

## Description

This app provides a mobile interface for church members to:
- View upcoming church activities and events
- Receive notifications about church events
- Access the digital song book
- Submit and track activity approvals
- View church finances and operations

## Dependencies

This app depends on the `palakat_admin` package (located at `../palakat_admin/` in the monorepo) which provides:
- Shared models (Activity, Church, Membership, etc.)
- Repositories (AuthRepository, ActivityRepository, etc.)
- Services (ApiService, LocalStorageService, etc.)
- Reusable widgets (AppTable, PaginationBar, etc.)
- Extensions and utilities
- Constants and enums

The backend API is provided by `palakat_backend` (located at `../palakat_backend/` in the monorepo).

## Development

### Running the App

From this directory (`apps/palakat/`):

```bash
# Run on connected device
flutter run

# Or if using FVM (recommended)
fvm flutter run

# Run on specific device
flutter run -d <device-id>

# Run on Chrome (web)
flutter run -d chrome
```

From the monorepo root:

```bash
# Run Melos commands scoped to this app
melos run analyze --scope=palakat
melos run test --scope=palakat
```

### Code Generation

This app uses code generation for:
- Riverpod providers (`@riverpod`)
- Freezed models (`@freezed`)
- JSON serialization (`@JsonSerializable`)

After modifying annotated files:

```bash
# Using derry (from this directory)
derry gen

# Or manually
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
derry watch
# or
dart run build_runner watch -d
```

From the monorepo root:

```bash
# Generate code for all apps
melos run build:runner

# Generate only for this app
melos run build:runner --scope=palakat
```

### Build & Clean

```bash
# Using derry scripts
derry build    # Clean, get dependencies, and generate code

# Manual commands
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/quick_test.dart

# From monorepo root
melos run test --scope=palakat
```

## Routing Conventions

We use `go_router` for all navigation with specific patterns:

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

### Applied Updates

- `ApprovalDetailScreen` now accepts a full `Approval` model via `extra`
- `SongDetailScreen` route now reads a `Song` model via `extra`, and the list passes the full `Song` model

## Environment Setup

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Update `.env` with your configuration:
   - `BASE_URL`: Backend API endpoint (prefer local IP over localhost)
   - `GOOGLE_MAPS_URL`, `GOOGLE_API_KEY`: For Google Maps integration
   - Firebase configuration variables
   - Social auth tokens

3. Add Firebase configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

## Architecture

### Feature Structure

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

### State Management Pattern

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

### Tech Stack

For a complete tech stack overview, see [.kiro/steering/tech.md](.kiro/steering/tech.md)

Key technologies:
- Flutter ^3.8.1
- Riverpod (state management)
- Freezed (immutable models)
- Go Router (navigation)
- Firebase (authentication)
- Hive (local storage)
- Google Maps
- Material 3 design

## Documentation

Detailed documentation is available in the `.kiro/steering/` directory:

- **[structure.md](.kiro/steering/structure.md)**: Codebase structure and organization
- **[tech.md](.kiro/steering/tech.md)**: Complete tech stack and tooling
- **[CLAUDE.md](CLAUDE.md)**: AI assistant guidance for working with this codebase

## Contributing

For contribution guidelines, see the monorepo-level [CONTRIBUTING.md](../../CONTRIBUTING.md).

## License

See the monorepo [LICENSE](../../LICENSE) file.
