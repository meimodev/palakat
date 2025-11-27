# Tech Stack

## Monorepo Management
- **Melos** for Flutter workspace management
- **pnpm** for Node.js package management
- Dart SDK ^3.8.1, Flutter ^3.8.1

## Flutter Apps (Mobile & Admin)

### State Management
- **Riverpod** with `riverpod_annotation` for code generation
- `@riverpod` annotated controllers and providers

### Data Models
- **Freezed** for immutable data classes (`@freezed`)
- **json_serializable** for JSON serialization

### Navigation
- **go_router** for declarative routing
- Pass Freezed models via `extra` with `RouteParam` wrapper

### Local Storage
- **Hive** for key-value storage
- `LocalStorageService` for auth tokens and cached data

### UI
- Material 3 design
- **flutter_screenutil** for responsive sizing (mobile)
- OpenSans font family

### Authentication
- **Firebase Auth** (phone-based) for mobile app
- JWT tokens for API authentication

### Other Key Dependencies
- `dio` for HTTP client
- `jiffy` for date/time utilities (Indonesian locale)
- `google_maps_flutter` for maps
- `flutter_dotenv` for environment variables

## Backend (NestJS)

### Framework
- **NestJS** ^10.x
- TypeScript ^5.x

### Database
- **PostgreSQL** via Docker
- **Prisma** ^6.x ORM with `@prisma/client`

### Authentication
- **Passport** with JWT strategy
- `bcryptjs` for password hashing

### Validation
- `class-validator` and `class-transformer`

### Testing
- **Jest** for unit/e2e tests
- **fast-check** for property-based testing

## Common Commands

### Monorepo (from root)
```bash
melos bootstrap          # Install all Flutter dependencies
melos run analyze        # Lint all Flutter packages
melos run test           # Test all Flutter packages
melos run format         # Format all Dart code
melos run build:runner   # Generate code (Freezed, Riverpod)
```

### Flutter Apps
```bash
derry build              # Clean, get deps, generate code
derry gen                # Generate code only
derry watch              # Watch mode for code generation
flutter run              # Run app
```

### Backend
```bash
pnpm install             # Install dependencies
pnpm run start:dev       # Start dev server (watch mode)
pnpm run build           # Build for production
pnpm run test            # Run unit tests
pnpm run test:e2e        # Run e2e tests
pnpm run prisma:generate # Generate Prisma client
pnpm run db:migrate      # Run migrations
pnpm run db:push         # Push schema (dev)
pnpm run db:seed         # Seed database
pnpm run prisma:studio   # Open Prisma Studio
```

### Helper Scripts
```bash
./scripts/backend.sh     # Start Docker + DB + backend
./scripts/admin.sh       # Run admin app
./scripts/android.sh     # Run mobile app on Android
```
