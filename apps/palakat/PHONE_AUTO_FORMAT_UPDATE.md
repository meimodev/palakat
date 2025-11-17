# Phone Auto-Format Update

## Changes Made

### 1. Auto-Formatting Phone Input

**New Component:**
- `lib/features/authentication/presentations/widgets/phone_input_formatter.dart`
  - Custom `TextInputFormatter` that automatically adds dashes every 4 digits
  - Limits input to 13 digits maximum
  - Handles cursor positioning when dashes are auto-inserted
  - Format: `XXXX-XXXX-XXXX` or `XXXX-XXXX-XXXXX`

**Updated Components:**
- `lib/core/widgets/input/input_widget.dart`
  - Added `inputFormatters` parameter to support custom formatters
  - Updated all constructors (text, dropdown, binaryOption)
  
- `lib/core/widgets/input/input_variant_text_widget.dart`
  - Added `inputFormatters` parameter
  - Passes formatters to `TextFormField`

- `lib/features/authentication/presentations/phone_input_screen.dart`
  - Added `PhoneInputFormatter` to phone input field
  - Added `FilteringTextInputFormatter.digitsOnly` to ensure only digits
  - Auto-formats as user types

### 2. Backend Phone Format Handling

**Updated:**
- `apps/palakat_backend/src/auth/auth.controller.ts`
  - `/auth/validate` endpoint now converts `+62` prefix to `0`
  - Example: `+6281234567890` → `081234567890`
  - Ensures compatibility with database phone format

## User Experience

### Before
User types: `081234567890`
Display shows: `081234567890` (no formatting)

### After
User types: `081234567890`
Display shows: `0812-3456-7890` (auto-formatted with dashes)

### Typing Experience

| User Input | Display |
|------------|---------|
| `0` | `0` |
| `08` | `08` |
| `081` | `081` |
| `0812` | `0812` |
| `08123` | `0812-3` |
| `081234` | `0812-34` |
| `0812345` | `0812-345` |
| `08123456` | `0812-3456` |
| `081234567` | `0812-3456-7` |
| `0812345678` | `0812-3456-78` |
| `08123456789` | `0812-3456-789` |
| `081234567890` | `0812-3456-7890` |
| `0812345678901` | `0812-3456-7890-1` |

### Features

✅ **Auto-formatting**: Dashes added automatically as user types
✅ **Smart cursor**: Cursor position adjusts when dashes are inserted
✅ **Digit-only input**: Only numeric characters allowed
✅ **Length limit**: Maximum 13 digits enforced
✅ **Backspace friendly**: Dashes removed automatically when deleting

## Backend Integration

### Phone Format Conversion

The backend `/auth/validate` endpoint now handles both formats:

**Input from Firebase (E.164):**
```
+6281234567890
```

**Converted to Database Format:**
```
081234567890
```

**Conversion Logic:**
```typescript
if (phone.startsWith('+62')) {
  phone = '0' + phone.substring(3);
}
```

This ensures:
- Firebase sends phone in E.164 format (`+62...`)
- Backend converts to Indonesian format (`0...`)
- Database stores consistent format
- No breaking changes to existing data

## Code Examples

### Using PhoneInputFormatter

```dart
InputWidget.text(
  currentInputValue: phoneNumber,
  onChanged: controller.onPhoneNumberChanged,
  hint: '0812-3456-7890',
  label: 'Phone Number',
  textInputType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    PhoneInputFormatter(),
  ],
)
```

### Backend Phone Validation

```typescript
@Get('validate')
async validate(@Query('phone') phone?: string) {
  // Convert +62 to 0 if phone starts with +62
  let normalizedPhone = phone as string;
  if (normalizedPhone && normalizedPhone.startsWith('+62')) {
    normalizedPhone = '0' + normalizedPhone.substring(3);
  }
  return this.authService.validate(normalizedPhone);
}
```

## Testing

### Manual Testing Steps

1. **Phone Input Screen**
   - Open phone input screen
   - Start typing: `081234567890`
   - Verify dashes appear automatically: `0812-3456-7890`
   - Try backspace - dashes should be removed automatically
   - Try typing more than 13 digits - should be limited

2. **Backend Validation**
   - Send request: `GET /auth/validate?phone=+6281234567890`
   - Verify backend converts to: `081234567890`
   - Check database query uses correct format

### Edge Cases Handled

✅ User pastes formatted number: `0812-3456-7890`
✅ User pastes unformatted number: `081234567890`
✅ User types with spaces: `0812 3456 7890`
✅ User deletes in middle of number
✅ User tries to type non-numeric characters
✅ User tries to exceed 13 digits

## Migration Notes

**No Breaking Changes:**
- Existing phone numbers in database remain unchanged
- Backend handles both `+62` and `0` prefixes
- Frontend displays formatted version
- Firebase still receives E.164 format

**Backward Compatibility:**
- Old app versions can still send unformatted numbers
- Backend normalizes all formats
- Database queries work with both formats
