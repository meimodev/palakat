# Project Structure

## Monorepo Organization

```
palakat_monorepo/
├── apps/                           # Application packages
│   ├── palakat/                    # Flutter mobile app
│   ├── palakat_admin/              # Flutter admin web/desktop app
│   └── palakat_backend/            # NestJS backend API
├── packages/                       # Shared packages
│   └── palakat_shared/             # Shared Flutter code
├── scripts/                        # Build and utility scripts
├── melos.yaml                      # Monorepo configuration
└── pnpm-workspace.yaml             # pnpm workspace config
```

## Flutter App Structure (palakat & palakat_admin)

### Standard Layout
```
app/
├── lib/
│   ├── core/                       # Core utilities and infrastructure
│   │   ├── assets/                 # Asset path constants
│   │   ├── constants/              # App-wide constants
│   │   ├── routing/                # Navigation and routes
│   │   └── widgets/                # Reusable widgets App-wide
│   ├── features/                   # Feature modules
│   │   ├── feature_name/
│   │   │   ├── data/               # Data layer
│   │   │   │   ├── *_repository.dart
│   │   │   │   └── *_repository.g.dart
│   │   │   └── presentations/      # Presentation layer
│   │   │       ├── *_controller.dart
│   │   │       ├── *_controller.g.dart
│   │   │       ├── *_state.dart
│   │   │       ├── *_state.freezed.dart
│   │   │       ├── *_screen.dart
│   │   │       └── widgets/        # Feature-specific widgets
│   │   ├── application.dart        # Application layer exports
│   │   ├── domain.dart             # Domain layer exports
│   │   └── presentation.dart       # Presentation layer exports
│   ├── firebase_options.dart       # Firebase configuration
│   └── main.dart                   # App entry point
├── assets/
│   ├── fonts/                      # OpenSans font files
│   ├── icons/                      # SVG/PNG icons
│   └── images/                     # Image assets
├── .env                            # Environment variables
├── pubspec.yaml                    # Dependencies
├── derry.yaml                      # Script shortcuts
└── build.yaml                      # Build configuration
```

### Feature Module Pattern

Each feature follows a layered architecture:

**Data Layer** (`data/`)
- Repositories with `@riverpod` annotation
- API integration and data transformation
- Generated code: `*.g.dart`

**Presentation Layer** (`presentations/`)
- Controllers: Business logic with `@riverpod`
- States: Immutable state classes with `@freezed`
- Screens: UI components
- Widgets: Feature-specific reusable widgets
- Generated code: `*.g.dart`, `*.freezed.dart`

### Key Features
- `authentication/` - Login, registration, OTP verification
- `dashboard/` - Main dashboard and navigation
- `home/` - Home screen and activity feed
- `account/` - User profile and settings
- `approval/` - Activity approval workflows
- `operations/` - Financial operations
- `publishing/` - Content publishing
- `song_book/` - Digital hymnal
- `song_detail/` - Individual song view
- `splash/` - App initialization

## Shared Package (palakat_shared)

Provides reusable code for both Flutter apps:

```
palakat_shared/lib/
├── core/
│   ├── config/                     # App configuration
│   ├── constants/                  # Shared constants and enums
│   ├── extension/                  # Dart extensions
│   ├── layout/                     # Layout components
│   ├── models/                     # Freezed data models
│   ├── navigation/                 # Routing utilities
│   ├── repositories/               # Data repositories
│   ├── services/                   # Core services (API, storage)
│   ├── theme/                      # Material theme
│   ├── utils/                      # Utility functions
│   ├── validation/                 # Form validators
│   └── widgets/                    # Reusable UI components
├── constants.dart                  # Barrel export
├── extensions.dart                 # Barrel export
├── models.dart                     # Barrel export
├── repositories.dart               # Barrel export
├── services.dart                   # Barrel export
├── theme.dart                      # Barrel export
├── utils.dart                      # Barrel export
├── validation.dart                 # Barrel export
├── widgets.dart                    # Barrel export
└── palakat_shared.dart             # Main export
```

## Backend Structure (NestJS)

```
palakat_backend/
├── src/
│   ├── account/                    # Account management
│   ├── activity/                   # Activity CRUD
│   ├── approval-rule/              # Approval workflow rules
│   ├── auth/                       # Authentication
│   │   ├── dto/                    # Data transfer objects
│   │   └── strategies/             # Passport strategies
│   ├── church/                     # Church management
│   ├── column/                     # Church columns/groups
│   ├── document/                   # Document management
│   ├── expense/                    # Expense tracking
│   ├── file/                       # File upload/management
│   ├── location/                   # Location data
│   ├── membership/                 # Member management
│   ├── membership-position/        # Member positions/roles
│   ├── report/                     # Reporting
│   ├── revenue/                    # Revenue tracking
│   ├── song/                       # Song book management
│   ├── song-part/                  # Song sections
│   ├── utils/                      # Utility functions
│   ├── app.module.ts               # Root module
│   ├── main.ts                     # Entry point
│   └── exception.filter.ts         # Global exception handling
├── common/                         # Shared utilities
│   ├── helper/                     # Helper services
│   └── pagination/                 # Pagination utilities
├── prisma/
│   ├── schema.prisma               # Database schema
│   ├── seed.ts                     # Database seeding
│   └── generated/                  # Generated Prisma Client
├── test/                           # E2E tests
├── postman_collections/            # API documentation
├── docker-compose.yaml             # PostgreSQL container
└── nest-cli.json                   # NestJS CLI config
```

### Module Pattern

Each feature module follows NestJS conventions:
- `*.controller.ts` - HTTP endpoints and routing
- `*.service.ts` - Business logic and data access
- `*.module.ts` - Dependency injection configuration
- `dto/*.dto.ts` - Request/response validation

## Naming Conventions

### Flutter
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Private members: `_leadingUnderscore`
- Generated files: `*.g.dart`, `*.freezed.dart`
- Riverpod providers: `camelCaseProvider`

### Backend (TypeScript)
- Files: `kebab-case.ts`
- Classes: `PascalCase`
- Interfaces: `PascalCase` (no `I` prefix)
- Variables/functions: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- DTOs: `PascalCaseDto`

## Import Organization

### Flutter
Use barrel exports for cleaner imports:
```dart
// Prefer
import 'package:palakat_shared/models.dart';
import 'package:palakat_shared/services.dart';

// Over
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/services/api_service.dart';
```

### Backend
Use relative imports within modules, absolute for cross-module:
```typescript
// Within module
import { CreateActivityDto } from './dto/create-activity.dto';

// Cross-module
import { AuthService } from '../auth/auth.service';
```

## Configuration Files

- `.env` - Environment variables (gitignored)
- `.env.example` - Environment template (committed)
- `analysis_options.yaml` - Dart analyzer rules
- `build.yaml` - Build runner configuration
- `derry.yaml` - Script shortcuts for Flutter apps
- `melos.yaml` - Monorepo workspace configuration
- `nest-cli.json` - NestJS CLI configuration
- `tsconfig.json` - TypeScript compiler options
