# Tech Stack

## Framework & Language
- **Flutter** (SDK: ^3.8.1)
- **Dart** programming language
- **FVM** for Flutter version management (v3.32.4)

## State Management & Architecture
- **Riverpod** (flutter_riverpod ^3.0.3) - primary state management
- **riverpod_annotation** + **riverpod_generator** - code generation for providers
- **Freezed** - immutable state classes and unions
- **json_serializable** - JSON serialization

## Key Dependencies
- **go_router** (^16.3.0) - declarative routing
- **firebase_core** + **firebase_auth** - authentication
- **hive_flutter** (^1.1.0) - local storage
- **google_maps_flutter** - maps integration
- **flutter_screenutil** (^5.9.3) - responsive UI
- **jiffy** (^6.4.3) - date/time manipulation
- **cached_network_image** - image caching
- **flutter_svg** - SVG rendering
- **flutter_dotenv** - environment variables

## Code Generation Tools
- **build_runner** - runs code generators
- **custom_lint** + **riverpod_lint** - custom linting rules

## Common Commands

### Build & Code Generation
```bash
# Clean and rebuild with code generation
derry build

# Run code generation only
derry gen

# Watch mode for continuous code generation
derry watch

# Manual build_runner commands
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch -d
```

### Standard Flutter Commands
```bash
# Get dependencies
flutter pub get
dart pub get

# Run the app
flutter run

# Build for platforms
flutter build apk
flutter build ios

# Analyze code
flutter analyze

# Run tests
flutter test
```

## Environment Setup
- Requires `.env` file for configuration
- Firebase configuration files:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- Uses FVM - run `fvm flutter` instead of `flutter` if FVM is active
