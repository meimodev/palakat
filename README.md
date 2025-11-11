# Palakat Monorepo

A monorepo containing the Palakat event notifier system for church activity management.

## Repository Structure

This monorepo contains three applications:

- **[apps/palakat/](apps/palakat/)** - Flutter mobile app (event notifier for church activities)
- **[apps/palakat_admin/](apps/palakat_admin/)** - Flutter admin app (provides shared models, repositories, and services)
- **[apps/palakat_backend/](apps/palakat_backend/)** - NestJS backend API (handles data persistence and business logic)
- **packages/** - Shared packages directory (for future shared code)

## Prerequisites

Before getting started, ensure you have the following tools installed:

- **Flutter SDK** ^3.8.1 (via [FVM](https://fvm.app/) recommended)
- **Dart SDK** ^3.8.1
- **Node.js** (LTS version recommended)
- **pnpm** (for backend package management) - Install via `npm install -g pnpm`
- **Melos** (for Flutter workspace management) - Install via `dart pub global activate melos`

## Getting Started

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd palakat
   ```

2. **Set up Flutter apps**:
   ```bash
   melos bootstrap
   ```
   This will run `flutter pub get` on all Flutter apps and link dependencies.

3. **Set up the backend**:
   ```bash
   cd apps/palakat_backend
   pnpm install
   cd ../..
   ```

4. **Configure environment variables**:
   - Copy `.env.example` to `.env` in each app directory
   - Update values for your environment
   - See app-specific READMEs for required variables

5. **Set up Firebase configuration** (for Flutter apps):
   - Add `google-services.json` to `apps/palakat/android/app/`
   - Add `GoogleService-Info.plist` to `apps/palakat/ios/Runner/`
   - Repeat for `apps/palakat_admin/` if needed

6. **Generate code** (for Flutter apps):
   ```bash
   melos run build:runner
   ```

## Common Commands

### Monorepo-Wide Commands

```bash
# Analyze all Flutter apps
melos run analyze

# Test all Flutter apps
melos run test

# Format all Dart code
melos run format

# Check formatting without modifying files
melos run format:check

# Generate code for all Flutter apps
melos run build:runner

# Watch mode for code generation (development)
melos run build:runner:watch

# Clean all Flutter apps
melos clean

# Get dependencies for all Flutter apps
melos run get

# Upgrade dependencies for all Flutter apps
melos run upgrade
```

### Targeting Specific Apps

```bash
# Run a command only for palakat app
melos run analyze --scope=palakat

# Run a command only for palakat_admin app
melos run test --scope=palakat_admin

# Generate code only for palakat
melos run build:runner --scope=palakat
```

## App-Specific Documentation

For detailed information about each application, see their individual README files:

- **Palakat App**: [apps/palakat/README.md](apps/palakat/README.md)
  - Routing conventions
  - App-specific development commands
  - Architecture documentation in `.kiro/steering/`

- **Palakat Admin**: [apps/palakat_admin/README.md](apps/palakat_admin/README.md)
  - Shared models, repositories, and services
  - Package structure and exports

- **Palakat Backend**: [apps/palakat_backend/README.md](apps/palakat_backend/README.md)
  - API documentation
  - Database schema and migrations
  - Environment configuration

## Development Workflow

### Running the Full Stack

To run the complete application stack:

1. **Start the backend**:
   ```bash
   cd apps/palakat_backend
   pnpm run start:dev
   ```

2. **Run the Flutter app** (in a new terminal):
   ```bash
   cd apps/palakat
   flutter run
   # or if using FVM:
   fvm flutter run
   ```

### Making Changes

- **Flutter code changes**: Most changes will auto-reload via hot reload
- **Model/state changes**: Run code generation after modifying `@freezed` or `@riverpod` annotated files
- **Backend changes**: NestJS will auto-reload in development mode
- **Cross-app changes**: Test changes in both apps when modifying shared packages

## Architecture

The Palakat mobile app follows a layered architecture with:
- **Riverpod** for state management
- **Freezed** for immutable models
- **Go Router** for navigation
- **Firebase** for authentication
- **Shared package architecture** via `palakat_admin`

For detailed architecture documentation, see:
- [apps/palakat/.kiro/steering/structure.md](apps/palakat/.kiro/steering/structure.md)
- [apps/palakat/.kiro/steering/tech.md](apps/palakat/.kiro/steering/tech.md)

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Development setup
- Code conventions
- Pull request process
- Testing requirements

## Troubleshooting

### Common Issues

**Dependency conflicts**: Run `melos clean` followed by `melos bootstrap`

**Code generation issues**: Delete all `*.g.dart` and `*.freezed.dart` files, then run `melos run build:runner`

**Backend won't start**: Ensure `.env` file is configured and database is accessible

**FVM version mismatch**: Run `fvm install` in the Flutter app directories

For more troubleshooting tips, see [CONTRIBUTING.md](CONTRIBUTING.md#troubleshooting).

## License

See [LICENSE](LICENSE) for details.
