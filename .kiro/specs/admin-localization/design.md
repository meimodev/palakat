# Design Document: Admin Localization

## Overview

This design document outlines the approach for completing the localization of the Palakat Admin web application. The implementation will add approximately 200+ new localization keys to the existing ARB files in `packages/palakat_shared/lib/l10n/` and update all hardcoded strings in the `apps/palakat_admin/lib/` directory to use these localized strings via `context.l10n`.

The existing localization infrastructure uses Flutter's built-in localization system with ARB files, supporting English (en) and Indonesian (id) languages. The admin panel already uses this system for some strings (navigation, dashboard, authentication), but many UI elements still contain hardcoded English text.

## Architecture

### Current Localization Architecture

```
packages/palakat_shared/
└── lib/
    └── l10n/
        ├── intl_en.arb          # English translations
        ├── intl_id.arb          # Indonesian translations
        └── generated/
            ├── app_localizations.dart      # Generated base class
            ├── app_localizations_en.dart   # Generated English
            └── app_localizations_id.dart   # Generated Indonesian
```

### Access Pattern

```dart
// In any widget with BuildContext
final l10n = context.l10n;
Text(l10n.admin_billing_title)
```

### Localization Key Naming Convention

Keys will follow a hierarchical naming pattern:
- `admin_<feature>_<element>` - Admin-specific strings
- `lbl_<name>` - Labels for form fields
- `btn_<action>` - Button labels
- `msg_<context>` - Messages (success, error, info)
- `dlg_<context>_<element>` - Dialog titles and content
- `hint_<field>` - Input hints and placeholders
- `tbl_<feature>_<column>` - Table column headers
- `time_<unit>` - Time-relative strings

## Components and Interfaces

### 1. ARB File Updates

Both `intl_en.arb` and `intl_id.arb` will be updated with new keys organized by category:

#### Admin Screen Titles
```json
{
  "admin_billing_title": "Billing Management",
  "admin_approval_title": "Approvals",
  "admin_account_title": "Account",
  "admin_activity_title": "Activity",
  "admin_revenue_title": "Revenue",
  "admin_member_title": "Member",
  "admin_financial_title": "Financial Account Numbers"
}
```

#### Card Titles and Subtitles
```json
{
  "card_accountNumbers_title": "Account Numbers",
  "card_accountNumbers_subtitle": "List of all financial account numbers for your church.",
  "card_approvalRules_title": "Approval Rules",
  "card_approvalRules_subtitle": "Configure approval routing rules and requirements"
}
```

#### Button Labels
```json
{
  "btn_addAccountNumber": "Add Account Number",
  "btn_recordPayment": "Record Payment",
  "btn_exportReceipt": "Export Receipt",
  "btn_create": "Create",
  "btn_update": "Update",
  "btn_addRule": "Add Rule"
}
```

#### Time-Relative Strings (with pluralization)
```json
{
  "time_justNow": "Just now",
  "time_minutesAgo": "{count, plural, =1{1 minute ago} other{{count} minutes ago}}",
  "time_hoursAgo": "{count, plural, =1{1 hour ago} other{{count} hours ago}}",
  "time_daysAgo": "{count, plural, =1{1 day ago} other{{count} days ago}}"
}
```

### 2. Widget Updates

Each widget file containing hardcoded strings will be updated to:
1. Import the l10n extension if not already imported
2. Access `context.l10n` in the build method
3. Replace hardcoded strings with localized equivalents

#### Example Transformation

**Before:**
```dart
Text('Financial Account Numbers', style: theme.textTheme.headlineMedium)
```

**After:**
```dart
Text(context.l10n.admin_financial_title, style: theme.textTheme.headlineMedium)
```

### 3. Time Formatting Utility

A new utility function will be created to handle time-relative string formatting with proper localization:

```dart
String formatRelativeTime(BuildContext context, DateTime timestamp) {
  final l10n = context.l10n;
  final now = DateTime.now();
  final diff = now.difference(timestamp);

  if (diff.inDays > 0) {
    return l10n.time_daysAgo(diff.inDays);
  } else if (diff.inHours > 0) {
    return l10n.time_hoursAgo(diff.inHours);
  } else if (diff.inMinutes > 0) {
    return l10n.time_minutesAgo(diff.inMinutes);
  } else {
    return l10n.time_justNow;
  }
}
```

## Data Models

No new data models are required. The localization system uses Flutter's built-in `AppLocalizations` class which is auto-generated from ARB files.

### ARB File Structure

Each ARB file follows the standard format:
```json
{
  "@@locale": "en",
  "keyName": "Translated text",
  "@keyName": {
    "description": "Description for translators",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, the following testable properties have been identified:

### Property 1: ARB Key Parity
*For any* localization key present in `intl_en.arb`, there SHALL exist a corresponding key with the same name in `intl_id.arb`
**Validates: Requirements 19.1**

### Property 2: Time Pluralization Correctness
*For any* positive integer count representing days, the `time_daysAgo` function SHALL return a string containing the correct singular form ("day") when count equals 1, and the plural form ("days") when count is greater than 1
**Validates: Requirements 18.1, 18.3**

### Property 3: Time Unit Selection
*For any* timestamp within the past year, the `formatRelativeTime` function SHALL return a string that correctly identifies the largest applicable time unit (days > hours > minutes > just now)
**Validates: Requirements 18.1**

## Error Handling

### Missing Localization Keys

If a localization key is missing from an ARB file:
1. The Flutter localization system will throw an error during code generation
2. The `melos run build:runner` command will fail
3. Developers must add the missing key to both ARB files before proceeding

### Invalid Placeholder Usage

If a placeholder is used incorrectly in a localized string:
1. The generated Dart code will have type mismatches
2. Static analysis will catch the error
3. The application will fail to compile

## Testing Strategy

### Dual Testing Approach

The implementation will use both unit tests and property-based tests:

1. **Unit Tests**: Verify specific examples and edge cases
2. **Property-Based Tests**: Verify universal properties across all inputs

### Property-Based Testing Framework

The project will use `kiri_check` (already available in the Flutter ecosystem) for property-based testing of the localization system.

### Test Categories

#### 1. ARB File Validation Tests
- Property test: All keys in English ARB exist in Indonesian ARB
- Unit test: Specific critical keys are present in both files

#### 2. Time Formatting Tests
- Property test: Pluralization correctness for all positive integers
- Property test: Time unit selection for various timestamps
- Unit test: Edge cases (0 minutes, exactly 1 hour, etc.)

#### 3. Integration Tests (Manual)
- Visual verification that all screens display correctly in both languages
- Verification that no hardcoded strings remain visible

### Test File Structure

```
packages/palakat_shared/test/
└── l10n/
    ├── arb_parity_test.dart           # Property test for ARB key parity
    └── time_formatting_test.dart      # Property tests for time formatting
```

### Property-Based Test Configuration

Each property-based test will be configured to run a minimum of 100 iterations to ensure adequate coverage of the input space.

### Test Annotations

Each property-based test will be annotated with a comment referencing the correctness property:
```dart
// **Feature: admin-localization, Property 1: ARB Key Parity**
// **Validates: Requirements 19.1**
```
