# Project Structure

```
palakat_monorepo/
├── apps/
│   ├── palakat/              # Mobile app (Android/iOS)
│   ├── palakat_admin/        # Web admin panel
│   └── palakat_backend/      # NestJS REST API
├── packages/
│   └── palakat_shared/       # Shared Flutter code
├── melos.yaml                # Monorepo configuration
└── pubspec.yaml              # Workspace root
```

## Mobile App (`apps/palakat/lib`)

Feature-based architecture with data/presentation layers:

```
lib/
├── core/
│   ├── assets/          # Generated asset references
│   ├── constants/       # App constants
│   ├── routing/         # go_router configuration
│   └── widgets/         # App-specific widgets
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── models/           # Feature-specific models
│       │   └── *_repository.dart # Data access
│       └── presentations/
│           ├── widgets/          # Feature widgets
│           ├── *_controller.dart # Riverpod controllers
│           ├── *_state.dart      # Freezed state classes
│           └── *_screen.dart     # UI screens
└── main.dart
```

## Admin Panel (`apps/palakat_admin/lib`)

Similar feature-based structure:

```
lib/
├── core/
│   ├── layout/          # Responsive layout components
│   ├── navigation/      # Router configuration
│   └── theme/           # Theme configuration
├── features/
│   └── <feature>/
│       ├── application/         # Controllers (*.g.dart generated)
│       └── presentation/screens/
└── main.dart
```

## Backend (`apps/palakat_backend/src`)

NestJS modular architecture:

```
src/
├── <module>/
│   ├── dto/                    # Request/response DTOs
│   ├── <module>.controller.ts  # HTTP endpoints
│   ├── <module>.service.ts     # Business logic
│   └── <module>.module.ts      # Module definition
├── prisma.module.ts            # Database module
├── prisma.service.ts           # Prisma client wrapper
├── exception.filter.ts         # Global exception handling
└── main.ts                     # Application entry
```

## Shared Package (`packages/palakat_shared/lib`)

```
lib/
├── core/
│   ├── config/          # Configuration (not exported)
│   ├── constants/       # Enums, presets
│   ├── extension/       # Dart extensions
│   ├── models/          # Shared data models
│   ├── repositories/    # Repository interfaces
│   ├── services/        # Service interfaces
│   ├── theme/           # Theme definitions
│   ├── utils/           # Helper functions
│   ├── validation/      # Form validators
│   └── widgets/         # Reusable UI components
└── palakat_shared.dart  # Library exports
```

## Naming Conventions

- Flutter files: `snake_case.dart`
- Generated files: `*.g.dart`, `*.freezed.dart`
- TypeScript files: `kebab-case.ts`
- DTOs: `create-*.dto.ts`, `update-*.dto.ts`
- Tests: `*.spec.ts` (unit), `*.e2e-spec.ts` (e2e), `*.property.spec.ts` (property)
