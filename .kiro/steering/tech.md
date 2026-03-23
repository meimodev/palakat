# Tech Stack

## Monorepo
- Managed with [Melos](https://melos.invertase.dev/) (`melos.yaml` at root)
- Flutter workspace (`pubspec.yaml` at root defines workspace members)
- Node.js packages managed with pnpm (`pnpm-workspace.yaml`)

## Flutter / Dart
- Flutter SDK pinned via FVM (see `apps/palakat/.fvm/fvm_config.json`) — use `fvm flutter` instead of `flutter` directly
- Dart SDK: `^3.8.1`
- State management: `flutter_riverpod` + `riverpod_annotation` (code-gen style with `@riverpod`)
- Navigation: `go_router`
- Data classes: `freezed` + `json_serializable`
- Local storage: `hive_flutter`
- Networking: `dio`
- UI utilities: `flutter_screenutil` (design size 360×640), `flutter_svg`, `cached_network_image`, `auto_size_text`
- Firebase: `firebase_core`, `firebase_auth`, `firebase_messaging`, `firebase_storage`
- Push notifications: `pusher_beams`, `flutter_local_notifications`
- Maps: `google_maps_flutter`, `geolocator`
- Linting: `flutter_lints` + `custom_lint` + `riverpod_lint`
- Testing: `mocktail`, `kiri_check` (property-based)

## Code Generation
Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from the analyzer and should never be edited manually.

## Common Commands

### Monorepo (run from root)
```sh
# Bootstrap all packages
melos bootstrap

# Get dependencies across all packages
melos run get

# Run code generation across all packages
melos run build:runner

# Analyze all packages
melos run analyze

# Format all packages
melos run format

# Run tests across all packages
melos run test

# Clean all packages
melos run clean
```

### Single app (run from `apps/palakat`)
```sh
# Get dependencies + run build_runner
derry build

# Run code generation only
derry gen

# Watch mode for code generation
derry watch

# Run app
fvm flutter run

# Run tests
fvm flutter test

# Analyze
fvm flutter analyze
```
