# Project Structure

## Root Organization

```
lib/
├── core/              # Shared utilities and infrastructure
│   ├── assets/        # Generated asset references
│   ├── constants/     # App-wide constants and themes
│   ├── routing/       # go_router configuration
│   └── widgets/       # Reusable UI components
├── features/          # Feature modules (main app logic)
└── main.dart          # App entry point

assets/
├── fonts/             # OpenSans font family
├── icons/             # SVG icons (fill, line, tint variants)
└── images/            # PNG/JPG images

android/               # Android platform code
ios/                   # iOS platform code
test/                  # Test files
```

## Feature Module Structure

Each feature follows a presentation-focused architecture:

```
lib/features/<feature_name>/
└── presentations/
    ├── <feature_name>_controller.dart       # Riverpod controller
    ├── <feature_name>_controller.g.dart     # Generated provider code
    ├── <feature_name>_screen.dart           # UI screen
    ├── <feature_name>_state.dart            # Freezed state class
    ├── <feature_name>_state.freezed.dart    # Generated Freezed code
    └── widgets/                              # Feature-specific widgets
```

**Note:** Domain and application layers are commented out in barrel files but may exist for some features. Current architecture emphasizes presentation layer with direct repository access.

## Key Features

- `authentication/` - Login and auth flows
- `dashboard/` - Main activity feed and home
- `home/` - Home navigation
- `account/` - User profile and membership
- `song_book/` - Song browsing
- `song_detail/` - Individual song view
- `publishing/` - Activity creation and maps
- `approval/` - Activity approval workflows
- `operations/` - Operational screens
- `splash/` - App initialization

## Barrel Files

Three main barrel exports in `lib/features/`:
- `presentation.dart` - Exports all presentation layer components
- `domain.dart` - Domain models (mostly commented out)
- `application.dart` - Services and mappers (mostly commented out)

## Routing Conventions

- All routes defined in `lib/core/routing/app_routing.dart`
- Use `go_router` for navigation
- Pass complex objects via `extra` parameter using `RouteParam` wrapper
- Serialize Freezed models with `toJson()` when pushing, deserialize with `fromJson()` in routes
- Avoid query parameters for large payloads; use `extra` instead

Example:
```dart
// Push
context.pushNamed(AppRoute.detail, extra: RouteParam(params: {'model': myModel.toJson()}));

// Read in route
final params = (state.extra as RouteParam?)?.params;
final model = MyModel.fromJson(params?['model']);
```

## State Management Pattern

Controllers use `@riverpod` annotation:
```dart
@riverpod
class FeatureController extends _$FeatureController {
  @override
  FeatureState build() {
    // Initialize and return initial state
    return const FeatureState();
  }
}
```

States use `@freezed` for immutability:
```dart
@freezed
abstract class FeatureState with _$FeatureState {
  const factory FeatureState({
    @Default(false) bool loading,
    String? errorMessage,
  }) = _FeatureState;
}
```

## External Dependencies

The app depends on `palakat_admin` package (local path dependency) which provides:
- Core models
- Repositories
- Services
- Extensions
- Constants

Import from `palakat_admin` for shared business logic and data access.
