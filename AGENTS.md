# Project Overview

**Palakat** is a church management platform designed for Indonesian churches, specifically the HKBP denomination. The platform provides comprehensive tools to manage church membership, activities, finances, documents, and organizational structure.

## Purpose
Manage church membership, activities, finances, documents, and organizational structure through a unified platform.

## Target Users
- **Church Administrators**: Use the web admin panel for management tasks
- **Church Members**: Use the mobile app for engagement and participation
- **Church Leadership**: Handle approval workflows for activities and finances

## Key Features
- Church membership and organizational structure management
- Activities and events with approval workflows
- Financial tracking (revenues, expenses) with account numbers
- Song books (NKB, NNBT, KJ, DSL hymnals)
- Documents and reports management
- Church registration requests
- Push notifications via Pusher Beams
- Phone-based authentication via Firebase Auth

## Domain Concepts
| Concept | Description |
|---------|-------------|
| Church | Organization with members, columns (groups), and positions |
| Membership | Church member with baptism/sidi status, linked to account |
| Column | Organizational group within a church |
| Activity | Events/services requiring supervisor and approver workflow |
| Bipra | Church organizational divisions (PKB, WKI, PMD, RMJ, ASM) |
| ApprovalRule | Configurable rules linking activity types, financial types, and positions |
| FinancialAccountNumber | Chart of accounts for revenue/expense categorization |
| Song | Hymnal songs from NKB, NNBT, KJ, DSL books |
| Notification | Push notifications for activity updates and approvals |

---

# Technology Stack

## Languages
| Language | Version |
|----------|---------|
| Dart | ^3.8.1 |
| TypeScript | ^5.1.3 |

## Frameworks
| Framework | Version | Type |
|-----------|---------|------|
| Flutter | 3.32.4 | Mobile/Web |
| NestJS | ^10.0.0 | Backend |

## Databases
| Database | ORM/Type | Version |
|----------|----------|---------|
| PostgreSQL | Prisma | ^6.19.0 |
| Hive | Local Storage | - |

## Package Managers
| Manager | Version | Scope |
|---------|---------|-------|
| Melos | ^6.2.0 | Dart monorepo |
| pnpm | 10.17.0 | Node.js |

## State Management
- **Riverpod** (flutter_riverpod, riverpod_annotation, riverpod_generator) - Main state management
- **hooks_riverpod** - Admin panel specific

## Routing
- **go_router** ^16.3.0 - Navigation for Flutter apps

## Code Generation
| Tool | Purpose |
|------|---------|
| build_runner | Code generation orchestration |
| freezed | Immutable models |
| json_serializable | JSON serialization |
| riverpod_generator | Provider generation |

## Authentication
- **Firebase Auth** - Phone-based authentication
- **Passport.js** with JWT strategy - Backend authentication

## Push Notifications
- **Pusher Beams** - Push notification service
- **firebase_messaging** - FCM integration
- **flutter_local_notifications** - Local notifications

## HTTP Client
- **Dio** ^5.9.0 - HTTP client (admin panel)
- **talker_dio_logger** - Request/response logging

## Maps & Location
- **google_maps_flutter** - Map integration
- **geolocator** - Location services

## Validation
- **class-validator** - Backend DTO validation
- **class-transformer** - Backend data transformation

## Testing
| Library | Scope | Purpose |
|---------|-------|---------|
| Jest | Backend | Unit/E2E testing |
| fast-check ^4.3.0 | Backend | Property-based testing |
| mocktail | Flutter | Mocking |
| kiri_check | Flutter | Property-based testing |

---

# Coding Standards

## Naming Conventions

### Flutter
- Files use `snake_case.dart` naming
- Generated files: `*.g.dart`, `*.freezed.dart`

### Backend (TypeScript)
- Files use `kebab-case.ts` naming
- DTOs: `create-*.dto.ts`, `update-*.dto.ts`
- Tests: `*.spec.ts` (unit), `*.e2e-spec.ts` (e2e), `*.property.spec.ts` (property)

## Architecture

### Flutter Apps
- Feature-based architecture with data/presentation layers
- Each feature contains:
  - `data/` - Models and repositories
  - `presentations/` - Widgets, controllers, states, screens

### Backend (NestJS)
- Modular architecture with controller/service/module pattern
- Each module contains:
  - `dto/` - Data transfer objects
  - `*.controller.ts` - HTTP endpoints
  - `*.service.ts` - Business logic
  - `*.module.ts` - Module definition

### Shared Package
- Exports reusable widgets, models, services, repositories
- Used by both mobile app and admin panel

## Code Generation Rules
- Run `melos run build:runner` after modifying annotated classes
- Riverpod providers use `@riverpod` annotation
- Models use `@freezed` annotation for immutability
- JSON serialization uses `@JsonSerializable` annotation

## State Management Rules
- Use Riverpod for state management in Flutter apps
- Controllers extend `AsyncNotifier` or `Notifier`
- State classes use Freezed for immutability

## Backend Rules
- Use DTOs for request/response validation
- Services contain business logic
- Controllers handle HTTP endpoints only
- Use Prisma for database operations

---

# Project Structure

```
palakat_monorepo/
├── apps/
│   ├── palakat/                    # Mobile app (Android/iOS)
│   │   ├── lib/
│   │   │   ├── core/
│   │   │   │   ├── assets/         # Generated asset references
│   │   │   │   ├── constants/      # App constants
│   │   │   │   ├── routing/        # go_router configuration
│   │   │   │   └── widgets/        # App-specific widgets
│   │   │   ├── features/
│   │   │   │   └── <feature>/
│   │   │   │       ├── data/
│   │   │   │       │   ├── models/
│   │   │   │       │   └── *_repository.dart
│   │   │   │       └── presentations/
│   │   │   │           ├── widgets/
│   │   │   │           ├── *_controller.dart
│   │   │   │           ├── *_state.dart
│   │   │   │           └── *_screen.dart
│   │   │   └── main.dart
│   │   ├── android/
│   │   ├── ios/
│   │   ├── assets/
│   │   └── test/
│   ├── palakat_admin/              # Web admin panel
│   │   ├── lib/
│   │   │   ├── core/
│   │   │   │   ├── layout/         # Responsive layout
│   │   │   │   ├── navigation/     # Router config
│   │   │   │   └── theme/          # Theme config
│   │   │   ├── features/
│   │   │   │   └── <feature>/
│   │   │   │       ├── application/
│   │   │   │       └── presentation/screens/
│   │   │   └── main.dart
│   │   └── web/
│   └── palakat_backend/            # NestJS REST API
│       ├── src/
│       │   ├── <module>/
│       │   │   ├── dto/
│       │   │   ├── <module>.controller.ts
│       │   │   ├── <module>.service.ts
│       │   │   └── <module>.module.ts
│       │   ├── prisma.module.ts
│       │   ├── prisma.service.ts
│       │   ├── exception.filter.ts
│       │   └── main.ts
│       ├── prisma/
│       │   ├── schema.prisma
│       │   └── seed.ts
│       └── test/
├── packages/
│   └── palakat_shared/             # Shared Flutter code
│       └── lib/
│           ├── core/
│           │   ├── config/
│           │   ├── constants/
│           │   ├── extension/
│           │   ├── models/
│           │   ├── repositories/
│           │   ├── services/
│           │   ├── theme/
│           │   ├── utils/
│           │   ├── validation/
│           │   └── widgets/
│           └── palakat_shared.dart
├── scripts/
├── melos.yaml
├── pubspec.yaml
└── pnpm-workspace.yaml
```

---

# External Resources

## Services
| Service | Purpose |
|---------|---------|
| Firebase | Authentication (phone), Cloud Messaging |
| Pusher Beams | Push notifications |
| Google Maps | Location services |
| PostgreSQL | Primary database |

## Documentation
| Resource | URL |
|----------|-----|
| Flutter | https://flutter.dev/docs |
| Riverpod | https://riverpod.dev |
| NestJS | https://docs.nestjs.com |
| Prisma | https://www.prisma.io/docs |
| go_router | https://pub.dev/packages/go_router |
| Freezed | https://pub.dev/packages/freezed |
| Pusher Beams | https://pusher.com/docs/beams |

## Tools
| Tool | Purpose | URL |
|------|---------|-----|
| Melos | Dart/Flutter monorepo management | https://melos.invertase.dev |
| build_runner | Code generation | - |
| Prisma Studio | Database GUI | - |
| Docker | Local PostgreSQL via docker-compose | - |

---

# Additional Context

## Database Models
| Model | Description |
|-------|-------------|
| Church | Core entity with location, columns, memberships |
| Account | User account with phone auth, gender, marital status |
| Membership | Links account to church with baptize/sidi status |
| Activity | Events with supervisor, approvers, location, type (SERVICE/EVENT/ANNOUNCEMENT) |
| ApprovalRule | Configurable approval workflows per activity/financial type |
| Revenue/Expense | Financial transactions with account numbers |
| Song/SongPart | Hymnal songs with parts (verses, chorus) |
| Notification | Push notification records |

## Enums
| Enum | Values |
|------|--------|
| Gender | MALE, FEMALE |
| Bipra | PKB, WKI, PMD, RMJ, ASM |
| ActivityType | SERVICE, EVENT, ANNOUNCEMENT |
| Book | NKB, NNBT, KJ, DSL |
| ApprovalStatus | UNCONFIRMED, APPROVED, REJECTED |
| PaymentMethod | CASH, CASHLESS |
| FinancialType | REVENUE, EXPENSE |
| NotificationType | ACTIVITY_CREATED, APPROVAL_REQUIRED, APPROVAL_CONFIRMED, APPROVAL_REJECTED |

---

# Testing Instructions

## Flutter Tests
```bash
# Run all Flutter tests from monorepo root
melos run test
```

## Backend Tests
```bash
# Navigate to backend directory
cd apps/palakat_backend

# Run unit tests
pnpm run test

# Run e2e tests
pnpm run test:e2e

# Run property-based tests
pnpm run test:property

# Run tests with coverage
pnpm run test:cov
```

---

# Build Steps

## Initial Setup

### 1. Install Dependencies
```bash
# From monorepo root - install Flutter dependencies
melos bootstrap

# For backend - navigate and install
cd apps/palakat_backend
pnpm install
```

### 2. Environment Configuration
- Copy `.env.example` to `.env` in each app directory
- Configure required environment variables (Firebase, Pusher Beams, Database URL)

### 3. Database Setup (Backend)
```bash
cd apps/palakat_backend

# Generate Prisma client
pnpm run prisma:generate

# Run migrations (development)
pnpm run db:migrate

# Or push schema directly (resets DB)
pnpm run db:push

# Seed database
pnpm run db:seed
```

### 4. Code Generation (Flutter)
```bash
# From monorepo root
melos run build:runner
```

## Development

### Flutter Mobile App
```bash
cd apps/palakat
flutter run
```

### Flutter Admin Panel (Web)
```bash
cd apps/palakat_admin
flutter run -d chrome
```

### Backend
```bash
cd apps/palakat_backend
pnpm run start:dev
```

## Common Commands

### Flutter (from monorepo root)
| Command | Description |
|---------|-------------|
| `melos bootstrap` | Install all dependencies |
| `melos run analyze` | Run flutter analyze |
| `melos run format` | Format all code |
| `melos run test` | Run all tests |
| `melos run build:runner` | Generate code (freezed, riverpod, json) |
| `melos run clean` | Clean all packages |

### Backend (from apps/palakat_backend)
| Command | Description |
|---------|-------------|
| `pnpm install` | Install dependencies |
| `pnpm run start:dev` | Start dev server with watch |
| `pnpm run build` | Build for production |
| `pnpm run test` | Run unit tests |
| `pnpm run test:e2e` | Run e2e tests |
| `pnpm run test:property` | Run property-based tests |
| `pnpm run prisma:generate` | Generate Prisma client |
| `pnpm run db:migrate` | Run migrations |
| `pnpm run db:push` | Push schema (dev only) |
| `pnpm run db:seed` | Seed database |
| `pnpm run prisma:studio` | Open Prisma Studio |
