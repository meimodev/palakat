# Hive Serialization Fix for AuthResponse

## Problem
```
HiveError: Cannot write, unknown type: _AuthTokens. 
Did you forget to register an adapter?
```

## Root Cause
The `AuthResponse.toJson()` method was NOT properly serializing nested objects (`AuthTokens` and `Account`). 

### Before (Broken)
```dart
Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{
      'tokens': instance.tokens,      // ❌ Storing object directly
      'account': instance.account,    // ❌ Storing object directly
    };
```

When Hive tried to store this Map, it encountered the raw `_AuthTokens` and `_Account` objects, which it couldn't serialize.

## Solution
Added explicit `@JsonKey(toJson: ...)` annotations to ensure nested objects are properly converted to JSON.

### Changes Made

**File**: `packages/palakat_shared/lib/core/models/auth_response.dart`

```dart
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(toJson: _authTokensToJson) required AuthTokens tokens,
    @JsonKey(toJson: _accountToJson) required Account account,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

// Helper functions to ensure proper JSON serialization
Map<String, dynamic> _authTokensToJson(AuthTokens tokens) => tokens.toJson();
Map<String, dynamic> _accountToJson(Account account) => account.toJson();
```

### After (Fixed)
```dart
Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{
      'tokens': _authTokensToJson(instance.tokens),    // ✅ Calls toJson()
      'account': _accountToJson(instance.account),     // ✅ Calls toJson()
    };
```

Now when `auth.toJson()` is called, it properly converts all nested objects to JSON Maps.

## How It Works

### Storage Flow
```dart
// 1. Create AuthResponse with nested objects
final auth = AuthResponse(
  tokens: AuthTokens(accessToken: '...', refreshToken: '...'),
  account: Account(id: '...', name: '...'),
);

// 2. Convert to JSON (now works correctly)
final json = auth.toJson();
// Result: {
//   'tokens': {'accessToken': '...', 'refreshToken': '...'},  // ✅ JSON Map
//   'account': {'id': '...', 'name': '...'}                   // ✅ JSON Map
// }

// 3. Store in Hive (now works)
await box.put('auth', json);  // ✅ Hive can store Map<String, dynamic>
```

### Loading Flow
```dart
// 1. Load from Hive
final json = box.get('auth') as Map<String, dynamic>;

// 2. Convert from JSON
final auth = AuthResponse.fromJson(json);  // ✅ Works

// 3. Access nested objects
print(auth.tokens.accessToken);  // ✅ Works
print(auth.account.name);        // ✅ Works
```

## Why This Was Needed

By default, `json_serializable` doesn't always call `toJson()` on nested Freezed objects. The `@JsonKey(toJson: ...)` annotation explicitly tells the generator to use our helper functions, which call the proper `toJson()` methods.

## Testing

To verify the fix:

```dart
// Test serialization
final auth = AuthResponse(
  tokens: AuthTokens(accessToken: 'test', refreshToken: 'test'),
  account: Account(id: '1', name: 'Test'),
);

final json = auth.toJson();
print(json['tokens'] is Map);  // Should be true
print(json['account'] is Map);  // Should be true

// Test Hive storage
await box.put('test', json);  // Should work without error
final loaded = box.get('test');
final restored = AuthResponse.fromJson(loaded);
print(restored.tokens.accessToken);  // Should print 'test'
```

## Related Files

- `packages/palakat_shared/lib/core/models/auth_response.dart` - Fixed model
- `packages/palakat_shared/lib/core/models/auth_response.g.dart` - Generated JSON code
- `packages/palakat_shared/lib/core/models/auth_tokens.dart` - Nested model (already had toJson)
- `packages/palakat_shared/lib/core/models/account.dart` - Nested model (already had toJson)
- `packages/palakat_shared/lib/core/services/local_storage_service.dart` - Uses auth.toJson()

## Analyzer Warnings

You may see these warnings:
```
Warning: The annotation 'JsonKey.new' can only be used on fields or getters.
```

These are false positives from the Dart analyzer. The code generation works correctly, and using `@JsonKey` on constructor parameters is the correct pattern for Freezed classes. The warnings can be safely ignored.

## Summary

The fix ensures that when `AuthResponse.toJson()` is called, it properly converts all nested objects (`AuthTokens` and `Account`) to JSON Maps, which Hive can then store without errors. This is done by explicitly telling json_serializable to call the `toJson()` methods on nested objects using `@JsonKey(toJson: ...)` annotations.
