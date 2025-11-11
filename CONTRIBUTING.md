# Contributing to Palakat Monorepo

Thank you for your interest in contributing to the Palakat project! This guide will help you get started with the monorepo setup and development workflow.

## Table of Contents

- [Getting Started](#getting-started)
- [Monorepo Structure](#monorepo-structure)
- [Development Workflow](#development-workflow)
- [Code Generation](#code-generation)
- [Testing](#testing)
- [Commit Conventions](#commit-conventions)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Prerequisites

Ensure you have the following tools installed:

- **Flutter SDK** ^3.8.1 (via [FVM](https://fvm.app/) recommended)
- **Dart SDK** ^3.8.1
- **Node.js** (LTS version)
- **pnpm** - Install via `npm install -g pnpm`
- **Melos** - Install via `dart pub global activate melos`
- **Git**

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd palakat
   ```

2. **Bootstrap Flutter apps**:
   ```bash
   melos bootstrap
   ```
   This installs dependencies for all Flutter apps and links them together.

3. **Set up the backend**:
   ```bash
   cd apps/palakat_backend
   pnpm install
   cd ../..
   ```

4. **Configure environment variables**:
   - Copy `.env.example` to `.env` in each app directory:
     ```bash
     cp .env.example apps/palakat/.env
     cp .env.example apps/palakat_admin/.env
     cp .env.example apps/palakat_backend/.env
     ```
   - Edit each `.env` file with your specific configuration

5. **Set up Firebase** (for Flutter apps):
   - Download `google-services.json` from Firebase Console
   - Place in `apps/palakat/android/app/google-services.json`
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place in `apps/palakat/ios/Runner/GoogleService-Info.plist`

6. **Generate code**:
   ```bash
   melos run build:runner
   ```

## Monorepo Structure

```
palakat/
├── apps/
│   ├── palakat/          # Flutter mobile app
│   ├── palakat_admin/    # Flutter admin app (shared package)
│   └── palakat_backend/  # NestJS backend API
├── packages/             # Shared packages (future)
├── scripts/              # Utility scripts
├── melos.yaml            # Melos configuration
├── pubspec.yaml          # Root pubspec for Flutter workspace
└── pnpm-workspace.yaml   # pnpm workspace configuration
```

### Understanding the Apps

- **palakat**: Main mobile app for church members
- **palakat_admin**: Provides shared models, repositories, and services used by the mobile app
- **palakat_backend**: NestJS REST API that handles data persistence and business logic

## Development Workflow

### Working on Individual Apps

#### Flutter Apps (palakat, palakat_admin)

From the app directory:
```bash
cd apps/palakat

# Run the app
flutter run
# or with FVM
fvm flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

From the monorepo root:
```bash
# Run commands for specific app
melos run test --scope=palakat
melos run analyze --scope=palakat_admin
```

#### Backend (palakat_backend)

From the backend directory:
```bash
cd apps/palakat_backend

# Start development server
pnpm run start:dev

# Run tests
pnpm test

# Run linting
pnpm run lint

# Build for production
pnpm run build
```

### Working Across Multiple Apps

When making changes that affect multiple apps:

1. **Make changes** in the relevant app directories
2. **Test locally** in each affected app
3. **Generate code** if needed:
   ```bash
   melos run build:runner
   ```
4. **Run full test suite**:
   ```bash
   melos run test
   ```

## Code Generation

The Flutter apps use code generation for:
- Riverpod providers (`@riverpod`)
- Freezed models (`@freezed`)
- JSON serialization (`@JsonSerializable`)

### When to Generate Code

Run code generation after:
- Adding or modifying `@riverpod` annotated classes
- Adding or modifying `@freezed` annotated classes
- Adding or modifying `@JsonSerializable` annotated classes
- Pulling changes that include new annotated classes

### How to Generate Code

```bash
# From monorepo root (all apps)
melos run build:runner

# For specific app only
melos run build:runner --scope=palakat

# Watch mode (auto-generates on file changes)
melos run build:runner:watch

# From app directory using derry
cd apps/palakat
derry gen
```

## Testing

### Flutter Tests

```bash
# Run all tests across all Flutter apps
melos run test

# Run tests for specific app
melos run test --scope=palakat

# From app directory
cd apps/palakat
flutter test

# Run specific test file
flutter test test/features/dashboard_test.dart
```

### Backend Tests

```bash
cd apps/palakat_backend

# Run all tests
pnpm test

# Run tests in watch mode
pnpm test:watch

# Run tests with coverage
pnpm test:cov
```

### Testing Requirements

Before submitting a PR:
- All existing tests must pass
- New features should include tests
- Bug fixes should include regression tests
- Aim for meaningful test coverage, not just high percentages

## Commit Conventions

We follow [Conventional Commits](https://www.conventionalcommits.org/) for better changelog generation and semantic versioning.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring without changing functionality
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependency updates
- `ci`: CI/CD configuration changes

### Scopes

Use the app name as scope:
- `palakat`: Changes to the mobile app
- `admin`: Changes to the admin app
- `backend`: Changes to the backend
- `monorepo`: Changes affecting the entire monorepo

### Examples

```bash
feat(palakat): add activity notification feature

fix(backend): resolve authentication token expiration issue

docs(monorepo): update setup instructions in README

chore(palakat): update dependencies to latest versions
```

## Pull Request Guidelines

### Before Creating a PR

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes** following the coding standards

3. **Test thoroughly**:
   ```bash
   melos run test
   melos run analyze
   ```

4. **Generate code** if needed:
   ```bash
   melos run build:runner
   ```

5. **Commit your changes** using conventional commits

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

### PR Checklist

- [ ] Code follows the project's coding standards
- [ ] All tests pass (`melos run test`)
- [ ] Code analysis passes (`melos run analyze`)
- [ ] Generated code is up to date (`melos run build:runner`)
- [ ] Documentation is updated (if applicable)
- [ ] Commit messages follow conventional commits format
- [ ] PR description clearly explains the changes
- [ ] Related issues are linked in the PR description

### PR Scope

- **Single app changes**: PRs affecting only one app are preferred
- **Cross-app changes**: Clearly document which apps are affected and why
- **Breaking changes**: Must be clearly marked and documented

### Review Process

1. Submit PR with detailed description
2. Automated checks will run (tests, linting)
3. Code review by maintainers
4. Address feedback and push updates
5. Once approved, PR will be merged

## Common Tasks

### Adding a New Dependency

#### Flutter App Dependency

```bash
cd apps/palakat
flutter pub add package_name

# Or manually edit pubspec.yaml, then:
flutter pub get

# From monorepo root:
melos bootstrap
```

#### Backend Dependency

```bash
cd apps/palakat_backend
pnpm add package_name

# For dev dependencies:
pnpm add -D package_name
```

### Creating a New Feature

1. **Create feature directory**:
   ```bash
   cd apps/palakat/lib/features
   mkdir my_feature
   mkdir my_feature/presentations
   ```

2. **Create files**:
   - `my_feature_controller.dart`
   - `my_feature_state.dart`
   - `my_feature_screen.dart`

3. **Add annotations** for code generation

4. **Generate code**:
   ```bash
   melos run build:runner --scope=palakat
   ```

5. **Add routes** in `core/routing/app_routing.dart`

### Creating a Shared Package

For code shared across Flutter apps:

```bash
mkdir -p packages/shared_package
cd packages/shared_package

# Create pubspec.yaml
# Create lib/ directory with code
# Update melos.yaml to include the package

melos bootstrap
```

### Running the Full Stack Locally

Terminal 1 (Backend):
```bash
cd apps/palakat_backend
pnpm run start:dev
```

Terminal 2 (Flutter App):
```bash
cd apps/palakat
flutter run
# or
fvm flutter run
```

Or use the provided script:
```bash
./scripts/dev.sh
```

### Database Migrations (Backend)

```bash
cd apps/palakat_backend

# Create a new migration
npx prisma migrate dev --name migration_name

# Apply migrations
npx prisma migrate deploy

# Generate Prisma client
npx prisma generate
```

## Troubleshooting

### Common Issues and Solutions

#### Path Dependency Issues

**Problem**: Flutter can't find `palakat_admin` package

**Solution**:
```bash
# Clean and reinstall
melos clean
melos bootstrap
```

#### Code Generation Conflicts

**Problem**: Build runner fails with conflicts

**Solution**:
```bash
# Delete generated files and regenerate
melos run build:runner
# If that fails, use force flag from app directory:
cd apps/palakat
dart run build_runner build --delete-conflicting-outputs
```

#### pnpm vs npm/yarn Confusion

**Problem**: Backend dependencies not working after using npm

**Solution**:
Always use `pnpm` for the backend:
```bash
cd apps/palakat_backend
rm -rf node_modules package-lock.json yarn.lock
pnpm install
```

#### FVM Version Mismatches

**Problem**: Flutter version conflicts

**Solution**:
```bash
cd apps/palakat
fvm install
fvm flutter pub get
```

#### Melos Command Not Found

**Problem**: `melos` command not recognized

**Solution**:
```bash
# Install Melos globally
dart pub global activate melos

# Ensure Dart global bin is in PATH
export PATH="$PATH:$HOME/.pub-cache/bin"
# Add to ~/.bashrc or ~/.zshrc for persistence
```

#### Backend Database Connection Errors

**Problem**: Cannot connect to PostgreSQL

**Solution**:
1. Ensure PostgreSQL is running
2. Check `.env` file has correct credentials
3. Verify database exists:
   ```bash
   psql -U postgres -c "CREATE DATABASE palakat_db;"
   ```
4. Run migrations:
   ```bash
   cd apps/palakat_backend
   npx prisma migrate deploy
   ```

#### Flutter Build Artifacts Corrupted

**Problem**: Strange build errors or crashes

**Solution**:
```bash
cd apps/palakat
flutter clean
flutter pub get
flutter run
```

### Getting Help

If you encounter issues not covered here:

1. Check the app-specific README files
2. Review recent commits for similar changes
3. Check existing issues in the repository
4. Ask for help in team chat or create an issue

## Code Style Guidelines

### Dart/Flutter

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` to format code (runs automatically via Melos)
- Prefer immutable classes with Freezed
- Use Riverpod for state management
- Document public APIs with dartdoc comments

### TypeScript/NestJS

- Follow the [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- Use ESLint and Prettier (configured in the project)
- Prefer dependency injection
- Use DTOs for API request/response types
- Document APIs with OpenAPI/Swagger decorators

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project. See [LICENSE](LICENSE) for details.

---

Thank you for contributing to Palakat! Your efforts help make this project better for everyone.
