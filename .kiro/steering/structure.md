# Project Structure

## Root
```
/
├── apps/
│   ├── palakat/          # Mobile app (iOS + Android)
│   ├── palakat_admin/    # Web admin panel
│   ├── palakat_super_admin/  # Web super admin panel
│   └── palakat_backend/  # Backend service
├── packages/
│   ├── palakat_shared/   # Shared Flutter package (models, repos, widgets, theme)
│   └── pusher_beams_web_stub/  # Web stub for Pusher Beams
├── scripts/              # Shell scripts for build/deploy tasks
├── docs/                 # Documentation and API specs
├── melos.yaml            # Monorepo script definitions
└── pubspec.yaml          # Dart workspace root
```

## Mobile App (`apps/palakat/lib`)
```
lib/
├── main.dart             # App entry point, Firebase + provider setup
├── firebase_options.dart # Generated Firebase config
├── core/
│   ├── assets/           # Generated asset references (flutter_gen)
│   ├── constants/        # App-wide constants
│   ├── models/           # App-specific models
│   ├── routing/          # go_router configuration
│   ├── services/         # App-level services (notifications, permissions, etc.)
│   ├── utils/            # Utility functions
│   └── widgets/          # Shared UI widgets
└── features/
    ├── <feature>/
    │   ├── data/         # Repositories, data sources, data models
    │   └── presentations/ # Controllers (Riverpod), states (Freezed), screens, widgets
    ├── application.dart  # Feature application layer exports
    ├── domain.dart       # Feature domain exports
    └── presentation.dart # Feature presentation exports
```

## Shared Package (`packages/palakat_shared/lib`)
```
lib/
├── core/
│   ├── config/           # App config (API URLs, env)
│   ├── constants/        # Shared constants
│   ├── extension/        # Dart extensions
│   ├── models/           # Shared domain models (Account, Result, Failure, etc.)
│   ├── repositories/     # Abstract + concrete repositories
│   ├── services/         # Shared services (LocalStorage, Socket, etc.)
│   ├── theme/            # App theme, colors, typography
│   ├── utils/            # Shared utilities
│   ├── validation/       # Validation logic
│   └── widgets/          # Shared UI components
└── l10n/                 # Localization (Indonesian + English)
```

## Feature Structure Convention
Each feature under `lib/features/<feature>/` follows this pattern:
- `data/` — repositories, remote/local data sources, feature-specific models
- `presentations/` — Riverpod controllers (`@riverpod` annotated), Freezed state classes, screen widgets

## Key Conventions
- State classes use `@Freezed` with `copyWith`, `toJson`/`fromJson`
- Controllers extend `_$ControllerName` via `@riverpod` code generation
- Repositories return `Result<T, Failure>` from `palakat_shared`
- Never edit `*.g.dart` or `*.freezed.dart` files — regenerate with `derry gen`
- Assets are referenced via generated classes in `lib/core/assets/` (flutter_gen)
- Environment variables loaded from `.env` via `flutter_dotenv`
