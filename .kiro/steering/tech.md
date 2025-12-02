# Technology Stack

## Monorepo Structure

- **Melos** for Dart/Flutter workspace management
- **pnpm** for Node.js package management
- Dart SDK ^3.8.1, Flutter 3.32.4

## Frontend - Mobile App (`apps/palakat`)

- Flutter with Riverpod (riverpod_annotation + riverpod_generator)
- go_router for navigation
- freezed + json_serializable for immutable models
- Firebase Auth for phone authentication
- Hive for local storage
- Google Maps integration
- flutter_screenutil for responsive design

## Frontend - Admin Panel (`apps/palakat_admin`)

- Flutter Web with Riverpod (hooks_riverpod)
- Dio for HTTP client with talker_dio_logger
- go_router for navigation
- freezed + json_serializable for models
- Hive for local storage

## Backend (`apps/palakat_backend`)

- NestJS 10 with TypeScript
- Prisma ORM with PostgreSQL
- Passport.js with JWT authentication
- class-validator + class-transformer for DTOs
- fast-check for property-based testing

## Shared Package (`packages/palakat_shared`)

- Reusable widgets, models, services, repositories
- Theme configuration
- Validation utilities
- Extension methods

## Common Commands

### Flutter (run from monorepo root)
```bash
melos bootstrap          # Install all dependencies
melos run analyze        # Run flutter analyze
melos run format         # Format all code
melos run test           # Run all tests
melos run build:runner   # Generate code (freezed, riverpod, json)
melos run clean          # Clean all packages
```

### Backend (run from apps/palakat_backend)
```bash
pnpm install             # Install dependencies
pnpm run start:dev       # Start dev server with watch
pnpm run build           # Build for production
pnpm run test            # Run unit tests
pnpm run test:e2e        # Run e2e tests
pnpm run test:property   # Run property-based tests
pnpm run lint            # Lint and fix
pnpm run format          # Format code

# Database
pnpm run prisma:generate # Generate Prisma client
pnpm run db:migrate      # Run migrations
pnpm run db:push         # Push schema (dev only, resets DB)
pnpm run db:seed         # Seed database
pnpm run prisma:studio   # Open Prisma Studio
```

## Code Generation

Flutter apps use build_runner for:
- Riverpod providers (`*.g.dart`)
- Freezed classes (`*.freezed.dart`)
- JSON serialization (`*.g.dart`)

Run `melos run build:runner` after modifying annotated classes.
