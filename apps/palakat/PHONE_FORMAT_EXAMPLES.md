# Phone Format Examples

## Before vs After

### Phone Input Screen

**Before:**
```
┌─────────────────────────────────┐
│ Country                         │
│ 🇮🇩 Indonesia (+62)       ▼    │
├─────────────────────────────────┤
│ Phone Number                    │
│ 81234567890                     │
└─────────────────────────────────┘
```

**After:**
```
┌─────────────────────────────────┐
│ Phone Number                    │
│ 0812-3456-7890                  │
└─────────────────────────────────┘
```

### Phone Number Formatting

| Input | Old Format | New Format |
|-------|-----------|------------|
| `081234567890` | `+62 812 3456 7890` | `0812-3456-7890` |
| `0812345678901` | `+62 812 3456 78901` | `0812-3456-7890-1` |

### Masked Display (OTP Screen)

| Full Number | Old Masked | New Masked |
|-------------|-----------|------------|
| `081234567890` | `+62 812 **** 7890` | `0812-****-7890` |
| `0812345678901` | `+62 812 **** 8901` | `0812-****-8901` |

### E.164 Conversion (for Firebase)

| Input | E.164 Output |
|-------|-------------|
| `081234567890` | `+6281234567890` |
| `0812-3456-7890` | `+6281234567890` |
| `0812 3456 7890` | `+6281234567890` |

### Validation Rules

**Old Rules:**
- Country-specific validation
- Indonesia: 9-13 digits after country code
- Malaysia: 9-11 digits
- Singapore: 8 digits
- Philippines: 10 digits

**New Rules:**
- ✅ Must start with `0`
- ✅ Total length: 12-13 digits
- ✅ Format: `XXXX-XXXX-XXXX` or `XXXX-XXXX-XXXXX`

### Valid Examples

✅ `081234567890` (12 digits)
✅ `0812-3456-7890` (12 digits with dashes)
✅ `0812345678901` (13 digits)
✅ `0812-3456-7890-1` (13 digits with dashes)

### Invalid Examples

❌ `81234567890` (doesn't start with 0)
❌ `08123456789` (only 11 digits)
❌ `08123456789012` (14 digits, too long)
❌ `000000000000` (all zeros)

## App Flow Changes

### Before (with Splash Screen)

```
App Start
    ↓
Splash Screen (1 second delay)
    ↓
Check Authentication
    ↓
    ├─→ Authenticated → Home Screen
    └─→ Not Authenticated → Phone Input Screen
```

### After (no Splash Screen)

```
App Start
    ↓
Check Authentication (immediate)
    ↓
    ├─→ Authenticated → Home Screen
    └─→ Not Authenticated → Phone Input Screen
```

## Code Examples

### Using PhoneNumberFormatter

```dart
// Format for display
final formatted = PhoneNumberFormatter.format('081234567890');
// Result: "0812-3456-7890"

// Convert to E.164 for Firebase
final e164 = PhoneNumberFormatter.toE164('081234567890');
// Result: "+6281234567890"

// Mask for privacy
final masked = PhoneNumberFormatter.mask('081234567890');
// Result: "0812-****-7890"
```

### Validation in Controller

```dart
// Phone must start with 0 and be 12-13 digits
controller.onPhoneNumberChanged('081234567890');
final isValid = controller.validatePhoneNumber();
// Result: true

controller.onPhoneNumberChanged('81234567890');
final isValid = controller.validatePhoneNumber();
// Result: false (doesn't start with 0)
```
