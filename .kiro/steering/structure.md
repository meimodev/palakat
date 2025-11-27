# Project Structure

## Monorepo Layout
```
palakat_monorepo/
├── apps/
│   ├── palakat/           # Flutter mobile app
│   ├── palakat_admin/     # Flutter web admin panel
│   └── palakat_backend/   # NestJS backend API
├── packages/
│   └── palakat_shared/    # Shared Flutter code
├── scripts/               # Development helper scripts
├── melos.yaml             # Melos workspace config
└── pubspec.yaml           # Root workspace pubspec
```

## Flutter App Structure (palakat, palakat_admin)

### Feature-Based Architecture
```
lib/
├── core/
│   ├── assets/            # Generated asset references
│   ├── constants/         # App constants, theme
│   ├── routing/           # GoRouter configuration
│   └── widgets/           # Shared UI components
├── features/
│   └── <feature>/
│       ├── data/
│       │   └── *_repository.dart    # Data access layer
│       └── presentations/
│           ├── *_controller.dart    # Riverpod controller
│           ├── *_state.dart         # Freezed state class
│           ├── *_screen.dart        # UI screen
│           └── widgets/             # Feature-specific widgets
└── main.dart
```

### Code Generation Files
- `*.g.dart` - Riverpod/JSON serialization generated
- `*.freezed.dart` - Freezed generated immutable classes

## Shared Package (palakat_shared)
```
lib/
├── core/
│   ├── models/            # Freezed data models
│   ├── repositories/      # Base repository interfaces
│   ├── services/          # API, storage services
│   └── widgets/           # Reusable UI components
├── models.dart            # Barrel export for models
├── services.dart          # Barrel export for services
├── repositories.dart      # Barrel export for repositories
└── widgets.dart           # Barrel export for widgets
```

## Backend Structure (NestJS)
```
src/
├── <module>/
│   ├── <module>.controller.ts   # HTTP endpoints
│   ├── <module>.service.ts      # Business logic
│   ├── <module>.module.ts       # NestJS module
│   └── dto/                     # Request/response DTOs
├── prisma.service.ts            # Prisma client wrapper
├── prisma.module.ts             # Prisma module
├── app.module.ts                # Root module
└── main.ts                      # Entry point

prisma/
├── schema.prisma                # Database schema
└── seed.ts                      # Database seeding

common/
├── helper/                      # Utility services
└── pagination/                  # Pagination utilities
```

## Key Modules (Backend)
- `auth` - Authentication (JWT, phone verification)
- `account` - User accounts
- `church` - Church management
- `membership` - Member management
- `activity` - Events and activities
- `approval-rule` - Approval workflows
- `song` / `song-part` - Hymnal management
- `revenue` / `expense` - Financial tracking
- `document` / `report` - Document management

## Configuration Files
- `.env` - Environment variables (copy from `.env.example`)
- `analysis_options.yaml` - Dart linting rules
- `build.yaml` - Build runner configuration
- `derry.yaml` - Derry script shortcuts
- `prisma/schema.prisma` - Database schema
