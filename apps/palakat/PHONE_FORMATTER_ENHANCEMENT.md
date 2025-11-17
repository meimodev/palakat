# PhoneNumberFormatter Enhancement

## Enhancement Summary

Added optional `convertPlusToZero` parameter to `PhoneNumberFormatter.format()` and `PhoneNumberFormatter.mask()` methods to convert E.164 format (+62) phone numbers to local format (0) for better user experience.

## Changes Made

### 1. Enhanced `format()` Method

**File**: `apps/palakat/lib/features/authentication/data/utils/phone_number_formatter.dart`

**New Signature**:
```dart
static String format(String phone, {bool convertPlusToZero = false})
```

**Behavior**:
- When `convertPlusToZero = true`: Converts `+62` prefix to `0` before formatting
- When `convertPlusToZero = false` (default): Keeps original format

**Examples**:
```dart
// Without conversion (default)
PhoneNumberFormatter.format('+6281234567890')
// Output: "6281-2345-6789-0"

// With conversion
PhoneNumberFormatter.format('+6281234567890', convertPlusToZero: true)
// Output: "0812-3456-7890"
```

### 2. Enhanced `mask()` Method

**New Signature**:
```dart
static String mask(String fullPhoneNumber, {bool convertPlusToZero = false})
```

**Behavior**:
- When `convertPlusToZero = true`: Converts `+62` prefix to `0` before masking
- When `convertPlusToZero = false` (default): Keeps original format

**Examples**:
```dart
// Without conversion (default)
PhoneNumberFormatter.mask('+6281234567890')
// Output: "6281-****-6789-0"

// With conversion
PhoneNumberFormatter.mask('+6281234567890', convertPlusToZero: true)
// Output: "0812-****-7890"
```

### 3. Updated OTP Verification Screen

**File**: `apps/palakat/lib/features/authentication/presentations/otp_verification_screen.dart`

Updated the phone number display to use the new parameter:

```dart
Text(
  PhoneNumberFormatter.format(
    fullPhoneNumber,
    convertPlusToZero: true,
  ),
  // ...
)
```

**Before**: Displayed as `6281-2345-6789-0` (confusing for users)
**After**: Displays as `0812-3456-7890` (familiar local format)

### 4. Comprehensive Test Coverage

**File**: `apps/palakat/test/features/authentication/data/utils/phone_number_formatter_test.dart`

Added 9 new test cases:

**format() tests**:
- ✅ Converts +62 to 0 when convertPlusToZero is true
- ✅ Keeps +62 format when convertPlusToZero is false
- ✅ Converts +62 with spaces when convertPlusToZero is true
- ✅ Handles +62 with 13 digits when convertPlusToZero is true
- ✅ Does not affect non-+62 numbers when convertPlusToZero is true

**mask() tests**:
- ✅ Converts +62 to 0 when convertPlusToZero is true
- ✅ Keeps +62 format when convertPlusToZero is false
- ✅ Converts +62 with 13 digits when convertPlusToZero is true

## Use Cases

### 1. Display Phone Numbers to Users
When showing phone numbers in the UI, users expect to see the familiar local format:
```dart
// User sees: 0812-3456-7890 (familiar)
PhoneNumberFormatter.format(e164Phone, convertPlusToZero: true)
```

### 2. Store/Send to Backend
When storing or sending to backend, keep E.164 format:
```dart
// Backend receives: +6281234567890 (international standard)
PhoneNumberFormatter.toE164(localPhone)
```

### 3. Privacy Display
When masking phone numbers for privacy:
```dart
// User sees: 0812-****-7890 (familiar and private)
PhoneNumberFormatter.mask(e164Phone, convertPlusToZero: true)
```

## Benefits

1. **Better UX**: Users see phone numbers in the format they're familiar with (0812-xxx-xxxx)
2. **Backward Compatible**: Default behavior unchanged (convertPlusToZero defaults to false)
3. **Flexible**: Can choose format based on context (display vs storage)
4. **Consistent**: Both format() and mask() support the same parameter
5. **Well Tested**: Comprehensive test coverage ensures reliability

## Migration Guide

### For Existing Code
No changes required - the parameter is optional and defaults to `false`, maintaining existing behavior.

### For New Code
When displaying phone numbers to users, use:
```dart
PhoneNumberFormatter.format(phone, convertPlusToZero: true)
```

When storing or sending to backend, use:
```dart
PhoneNumberFormatter.toE164(phone)
```

## Technical Details

### Implementation
The conversion happens before any other processing:
1. Check if phone starts with `+62`
2. If yes and `convertPlusToZero = true`, replace `+62` with `0`
3. Continue with normal formatting/masking logic

### Edge Cases Handled
- ✅ Phone numbers with spaces: `+62 812 3456 7890`
- ✅ Phone numbers with dashes: `+62-812-3456-7890`
- ✅ 12-digit numbers: `+6281234567890`
- ✅ 13-digit numbers: `+62812345678901`
- ✅ Non-+62 numbers: Unaffected by the flag
- ✅ Empty strings: Handled gracefully
