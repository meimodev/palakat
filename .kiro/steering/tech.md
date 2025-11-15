# Technology Stack

## Build System

**Monorepo Management**: Melos for Flutter workspace coordination
**Package Manager**: pnpm for Node.js backend, pub for Flutter apps
**Version Control**: Git with monorepo structure

## Flutter Apps (Mobile & Admin)

### Core Framework
- Flutter SDK ^3.8.1
- Dart SDK ^3.8.1
- FVM (Flutter Version Management) recommended for version consistency

### State Management
- Riverpod 3.x (flutter_riverpod, hooks_riverpod, riverpod_annotation)
- Riverpod code generation via riverpod_generator

### Data Layer
- Freezed for immutable models with code generation
- JSON serialization (json_annotation, json_serializable)
- Hive for local key-value storage

### Navigation
- go_router ^16.x for declarative routing
- Route data passed via `extra` parameter with `RouteParam` wrapper

### HTTP & API
- Dio ^5.x for HTTP client
- talker_dio_logger for request/response logging

### UI Components
- Material 3 design system
- flutter_screenutil for responsive sizing
- cached_network_image for image loading
- shimmer for loading states
- Custom font: OpenSans (weights 300-800)

### Firebase Integration
- firebase_core for initialization
- firebase_auth for authentication
- Google Maps integration (google_maps_flutter)

### Utilities
- Jiffy for date/time manipulation
- flutter_dotenv for environment variables
- device_info_plus for device information
- file_picker for file selection

### Code Quality
- flutter_lints ^6.x
- custom_lint with riverpod_lint
- Dart formatter

## Backend (NestJS)

### Core Framework
- NestJS ^10.x (Node.js framework)
- TypeScript ^5.x
- Express platform

### Database
- PostgreSQL (primary database)
- Prisma ORM 6.x for database access
- Prisma Client code generation
- Database migrations via Prisma Migrate

### Authentication
- Passport.js with JWT strategy
- bcryptjs for password hashing
- @nestjs/jwt for token management

### Validation & Transformation
- class-validator for DTO validation
- class-transformer for object mapping

### Development Tools
- ESLint with TypeScript support
- Prettier for code formatting
- Jest for testing
- Docker Compose for local PostgreSQL

## Common Commands

### Monorepo (from root)
```bash
# Bootstrap all Flutter apps
melos bootstrap

# Analyze all apps
melos run analyze

# Format all Dart code
melos run format

# Run tests
melos run test

# Generate code (Riverpod, Freezed, JSON)
melos run build:runner

# Watch mode for code generation
melos run build:runner:watch

# Clean all apps
melos clean

# Target specific app
melos run analyze --scope=palakat
melos run build:runner --scope=palakat_admin
```

### Flutter Apps (from app directory)
```bash
# Run app
flutter run
# or with FVM
fvm flutter run

# Code generation
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch -d

# Build
flutter build apk
flutter build ios
flutter build web

# Clean
flutter clean
flutter pub get
```

### Backend (from apps/palakat_backend)
```bash
# Install dependencies
pnpm install

# Development server (with hot reload)
pnpm run start:dev

# Production build
pnpm run build
pnpm run start:prod

# Database operations
pnpm run prisma:generate    # Generate Prisma Client
pnpm run db:migrate          # Run migrations (dev)
pnpm run db:deploy           # Deploy migrations (prod)
pnpm run db:push             # Push schema without migration
pnpm run db:seed             # Seed database

# Testing
pnpm run test                # Unit tests
pnpm run test:e2e            # E2E tests
pnpm run test:cov            # Coverage

# Code quality
pnpm run lint                # ESLint
pnpm run format              # Prettier

# Docker
docker-compose up            # Start PostgreSQL
```

## Environment Setup

Each app requires a `.env` file (copy from `.env.example`):

**Flutter Apps**: API endpoints, Firebase config, Google Maps API keys
**Backend**: Database URL, JWT secrets, port configuration

## Code Generation

Flutter apps use extensive code generation:
- Run after modifying `@riverpod`, `@freezed`, or `@JsonSerializable` annotations
- Generated files: `*.g.dart`, `*.freezed.dart`
- Always use `--delete-conflicting-outputs` flag
