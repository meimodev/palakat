# Design Document: Core Folder Consolidation

## Overview

This design document outlines the approach for consolidating the `palakat_admin/lib/core` folder into the `palakat_shared` package. The goal is to eliminate code duplication by having both `palakat` (mobile) and `palakat_admin` (web) applications import shared functionality from a single source of truth.

After analysis, the shared package (`palakat_shared`) already contains most of the core code. The consolidation primarily involves:
1. Removing duplicate folders from `palakat_admin/lib/core`
2. Updating imports in `palakat_admin` to use `palakat_shared`
3. Keeping only app-specific code in `palakat_admin/lib/core` (theme, layout, navigation)

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        palakat_shared                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    lib/core/                             │   │
│  │  ├── config/      (app config, endpoints)               │   │
│  │  ├── constants/   (app constants, enums)                │   │
│  │  ├── extension/   (dart extensions)                     │   │
│  │  ├── models/      (freezed data models)                 │   │
│  │  ├── repositories/(data access layer)                   │   │
│  │  ├── services/    (http, local storage)                 │   │
│  │  ├── utils/       (date utils, debouncer, etc)          │   │
│  │  ├── validation/  (form validation)                     │   │
│  │  └── widgets/     (reusable UI components)              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│     palakat_admin       │     │        palakat          │
│  ┌───────────────────┐  │     │  ┌───────────────────┐  │
│  │   lib/core/       │  │     │  │   lib/core/       │  │
│  │  ├── theme/       │  │     │  │  ├── assets/      │  │
│  │  ├── layout/      │  │     │  │  ├── constants/   │  │
│  │  └── navigation/  │  │     │  │  ├── routing/     │  │
│  │  (admin-specific) │  │     │  │  └── widgets/     │  │
│  └───────────────────┘  │     │  │  (mobile-specific)│  │
│                         │     │  └───────────────────┘  │
│  imports from           │     │  imports from           │
│  palakat_shared         │     │  palakat_shared         │
└─────────────────────────┘     └─────────────────────────┘
```

## Components and Interfaces

### Folders to Remove from palakat_admin/lib/core

These folders are duplicates of what exists in `palakat_shared` and should be deleted:

| Folder | Reason for Removal |
|--------|-------------------|
| `config/` | Identical to palakat_shared/lib/core/config |
| `constants/` | Identical to palakat_shared/lib/core/constants |
| `extension/` | Identical to palakat_shared/lib/core/extension |
| `models/` | Identical to palakat_shared/lib/core/models |
| `repositories/` | Identical to palakat_shared/lib/core/repositories |
| `services/` | Identical to palakat_shared/lib/core/services |
| `utils/` | Identical to palakat_shared/lib/core/utils |
| `validation/` | Identical to palakat_shared/lib/core/validation |
| `widgets/` | Identical to palakat_shared/lib/core/widgets |

### Folders to Keep in palakat_admin/lib/core

| Folder | Reason to Keep |
|--------|---------------|
| `theme/` | Admin uses indigo color scheme (different from shared's teal) |
| `layout/` | AppScaffold has admin-specific auth integration |
| `navigation/` | Page transitions specific to web admin |

### Barrel Export Updates

The barrel export files in `palakat_admin/lib/` need to be updated to re-export from `palakat_shared`:

```dart
// apps/palakat_admin/lib/models.dart
export 'package:palakat_shared/models.dart';

// apps/palakat_admin/lib/repositories.dart
export 'package:palakat_shared/repositories.dart';

// apps/palakat_admin/lib/services.dart
export 'package:palakat_shared/services.dart';

// apps/palakat_admin/lib/extensions.dart
export 'package:palakat_shared/extensions.dart';

// apps/palakat_admin/lib/utils.dart
export 'package:palakat_shared/utils.dart';

// apps/palakat_admin/lib/validation.dart
export 'package:palakat_shared/validation.dart';

// apps/palakat_admin/lib/widgets.dart
export 'package:palakat_shared/widgets.dart';
```

## Data Models

No changes to data models are required. All models are already defined in `palakat_shared/lib/core/models/` and will be used by both applications.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Since this is a refactoring task focused on file organization and import updates, the correctness properties are structural verification examples rather than property-based tests:

**Property 1: Admin core folder contains only app-specific code**
*For any* file in `palakat_admin/lib/core/` after consolidation, the file SHALL be in one of the allowed folders: `theme/`, `layout/`, or `navigation/`.
**Validates: Requirements 1.1, 3.1, 3.2, 3.3**

**Property 2: No duplicate code exists**
*For any* shared functionality (models, repositories, services, extensions, utils, validation, widgets), there SHALL be exactly one implementation in `palakat_shared`.
**Validates: Requirements 1.2**

**Property 3: Import paths use palakat_shared**
*For any* import of shared functionality in `palakat_admin`, the import path SHALL reference `package:palakat_shared/` instead of local `core/` paths.
**Validates: Requirements 1.3, 2.1**

**Property 4: Applications compile successfully**
*For any* of the three packages (palakat_shared, palakat_admin, palakat), running `flutter analyze` SHALL complete with no errors.
**Validates: Requirements 5.1, 5.2, 5.3**

**Property 5: Mobile app remains unchanged**
*For any* file in `palakat/lib/core/`, the file SHALL remain unmodified after consolidation.
**Validates: Requirements 4.1, 4.3**

## Error Handling

### Potential Issues and Mitigations

1. **Import conflicts**: If a file imports from both local core and palakat_shared, there may be naming conflicts.
   - Mitigation: Update all imports to use palakat_shared exclusively

2. **Missing exports**: If palakat_shared doesn't export something that palakat_admin needs.
   - Mitigation: Add missing exports to palakat_shared barrel files

3. **Build failures**: Generated files (.g.dart, .freezed.dart) may need regeneration.
   - Mitigation: Run `melos run build:runner` after changes

## Testing Strategy

### Verification Approach

Since this is a refactoring task, testing focuses on:

1. **Static Analysis**: Run `flutter analyze` on all three packages to verify no compilation errors
2. **Build Verification**: Run `melos run build:runner` to ensure code generation works
3. **Manual Verification**: Check that the admin app runs correctly after changes

### Test Commands

```bash
# Verify shared package
cd packages/palakat_shared && flutter analyze

# Verify admin app
cd apps/palakat_admin && flutter analyze

# Verify mobile app
cd apps/palakat && flutter analyze

# Regenerate code
melos run build:runner
```

### Property-Based Testing

This refactoring task does not require property-based tests as it involves file organization and import updates rather than business logic changes. The correctness properties are verified through static analysis and build verification.
