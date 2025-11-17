# Phone Normalization Test

## Endpoint
`GET /auth/validate?phone={phone}`

## Normalization Logic

```typescript
if (normalizedPhone.startsWith('+62')) {
  normalizedPhone = '0' + normalizedPhone.substring(3);
}
```

## Test Cases

### Case 1: E.164 Format (from Firebase)
**Input:** `+6281234567890`
**Normalized:** `081234567890`
**Expected:** Should find user in database

### Case 2: Already Normalized
**Input:** `081234567890`
**Normalized:** `081234567890`
**Expected:** Should find user in database

### Case 3: With Dashes (from UI)
**Input:** `0812-3456-7890`
**Normalized:** `0812-3456-7890`
**Expected:** Should find user (if database stores with dashes) or needs additional normalization

### Case 4: Missing Phone
**Input:** (empty)
**Response:** `400 Bad Request - Phone number is required`

## Implementation

```typescript
@Get('validate')
async validate(@Query('phone') phone?: string) {
  if (!phone) {
    throw new BadRequestException('Phone number is required');
  }

  // Convert +62 to 0 if phone starts with +62
  let normalizedPhone = phone;
  if (normalizedPhone.startsWith('+62')) {
    normalizedPhone = '0' + normalizedPhone.substring(3);
  }

  return this.authService.validate(normalizedPhone);
}
```

## Testing with cURL

### Test E.164 Format
```bash
curl "http://localhost:3000/auth/validate?phone=%2B6281234567890"
# URL encoded: +6281234567890
# Expected: Converts to 081234567890
```

### Test Already Normalized
```bash
curl "http://localhost:3000/auth/validate?phone=081234567890"
# Expected: Uses as-is
```

### Test Missing Phone
```bash
curl "http://localhost:3000/auth/validate"
# Expected: 400 Bad Request
```

## Database Considerations

### If Database Stores: `081234567890`
✅ E.164 input (`+6281234567890`) → Normalized to `081234567890` → Match
✅ Direct input (`081234567890`) → No change → Match

### If Database Stores: `0812-3456-7890`
⚠️ Need additional normalization to remove dashes before query

### Recommendation
Store phone numbers in database without dashes for consistency:
- Format: `081234567890`
- Display with dashes in UI: `0812-3456-7890`
- Send to Firebase in E.164: `+6281234567890`
- Normalize on backend: `+6281234567890` → `081234567890`

## Additional Normalization (if needed)

If you need to handle dashes from UI:

```typescript
@Get('validate')
async validate(@Query('phone') phone?: string) {
  if (!phone) {
    throw new BadRequestException('Phone number is required');
  }

  // Remove all non-digit characters except leading +
  let normalizedPhone = phone.replace(/[^\d+]/g, '');

  // Convert +62 to 0 if phone starts with +62
  if (normalizedPhone.startsWith('+62')) {
    normalizedPhone = '0' + normalizedPhone.substring(3);
  }

  return this.authService.validate(normalizedPhone);
}
```

This will handle:
- `+6281234567890` → `081234567890`
- `081234567890` → `081234567890`
- `0812-3456-7890` → `081234567890`
- `0812 3456 7890` → `081234567890`

## Verification

### Check Current Implementation
```bash
# Build backend
cd apps/palakat_backend
npm run build

# Expected: ✅ Build successful
```

### Test Normalization
```bash
# Start backend
npm run start:dev

# Test in another terminal
curl "http://localhost:3000/auth/validate?phone=%2B6281234567890"
```

---

**Status:** ✅ Fixed
**Normalization:** `+62` → `0`
**Error Handling:** Added validation for missing phone
**Build:** ✅ Successful
