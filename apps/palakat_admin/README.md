# Palakat Admin

A Flutter-based church management admin panel with reusable widgets, utilities, and models that can be used in other Flutter projects.

## Features

This project provides:
- **Reusable UI Widgets**: Tables, drawers, cards, chips, form fields, and more
- **Utilities**: Date helpers, debouncer, error mapper, validators
- **Data Models**: Freezed-based models for church management (accounts, activities, approvals, etc.)
- **Extensions**: String, number, map, and domain-specific extensions
- **Theme**: Pre-configured Material theme
- **State Management**: Riverpod-based architecture

## Using as a Dependency

You can use this project as a Git dependency in your Flutter application to access the reusable components.

### 1. Add to pubspec.yaml

```yaml
dependencies:
  palakat_admin:
    git:
      url: https://github.com/meimodev/palakat_admin.git
      # Optional: specify a branch or tag
      # ref: main
```

### 2. Import the library

You can import everything at once:
```dart
import 'package:palakat_admin/palakat_admin.dart';
```

Or import specific modules for better tree-shaking:
```dart
// Import only what you need
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/validation.dart';
import 'package:palakat_admin/services.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/theme.dart';
```

### 3. Use the components

```dart
// Use reusable widgets
AppTable(
  columns: [...],
  rows: [...],
  onRowTap: (index) {},
)

// Use utilities
final formattedDate = AppDateUtils.formatDate(DateTime.now());

// Use models
final error = AppError.network(message: 'Connection failed');
```

## What's Exported

This library uses per-folder barrel exports for easy maintenance and selective imports:

### ✅ Exported Modules

- **`widgets.dart`** - 30+ reusable UI widgets (AppTable, SideDrawer, ApproverCard, chips, cards, etc.)
- **`models.dart`** - Freezed data models (Activity, Account, Church, Membership, AppError, etc.)
- **`utils.dart`** - Utilities (DateUtils, Debouncer, ErrorMapper)
- **`constants.dart`** - Enums and presets (DateRangePreset, ActivityType, ApprovalStatus, etc.)
- **`extensions.dart`** - Extension methods (String, Number, Map, Approver, Account)
- **`validation.dart`** - Form validators and validation results
- **`services.dart`** - Core services (ApiService, HttpService, ApproverService, LocalStorageService)
- **`repositories.dart`** - Data repositories (Activities, Approval, Auth, Church, Members)
- **`theme.dart`** - Material theme configuration

### ❌ Not Exported (App-Specific)

- Config (endpoints, app config)
- Navigation (router, routes)
- Layout (app layout, scaffolds)

## Development

### Running the App

```bash
flutter run
```

### Code Generation

This project uses code generation for Riverpod and Freezed models:

```bash
# Generate once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Dependencies

Key dependencies:
- `flutter_riverpod` & `riverpod_annotation` - State management
- `freezed` - Immutable data classes
- `dio` - HTTP client
- `go_router` - Navigation
- `hive` - Local storage

See [pubspec.yaml](pubspec.yaml) for full dependency list.
