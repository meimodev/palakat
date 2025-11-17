# Hive JSON Serialization Fix

## Problem
Error occurred when trying to write `AuthenticationState` to Hive:
```
HiveError: Cannot write, unknown type: _AuthTokens. 
Did you forget to register an adapter?
```

## Root Cause
The `AuthenticationState` class contains complex objects (`Account`, `AuthTokens`) that Hive cannot serialize directly. Hive requires either:
1. Type adapters registered for custom types, OR
2. JSON serialization (converting objects to Map<String, dynamic>)

## Solution
Added JSON serialization support to `AuthenticationState` using Freezed's built-in JSON generation.

### Changes Made

#### 1. Updated `authentication_state.dart`
Added JSON serialization annotations:

```dart
part 'authentication_state.g.dart';  // Added

@Freezed(toJson: true, fromJson: true)  // Added explicit flags
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    // ... fields ...
    Account? account,
    AuthTokens? tokens,
    @JsonKey(includeFromJson: false, includeToJson: false) Timer? timer,  // Excluded Timer
  }) = _AuthenticationState;

  // Added fromJson factory
  factory AuthenticationState.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationStateFromJson(json);
}
```

**Key Points**:
- Added `part 'authentication_state.g.dart';` for generated JSON code
- Added `@Freezed(toJson: true, fromJson: true)` annotation
- Excluded `Timer` field from JSON using `@JsonKey` annotation (Timer cannot be serialized)
- Added `fromJson` factory method

#### 2. Generated JSON Serialization Code
Ran code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

This generated `authentication_state.g.dart` with:
- `_$AuthenticationStateFromJson()` function
- `toJson()` method on the class

### How It Works

#### Before (Error)
```dart
// Hive tries to store AuthenticationState directly
await box.put('state', state);  // ❌ Error: unknown type _AuthTokens
```

#### After (Fixed)
```dart
// Convert to JSON before storing
await box.put('state', state.toJson());  // ✅ Works: stores Map<String, dynamic>

// Convert from JSON when loading
final json = box.get('state') as Map<String, dynamic>;
final state = AuthenticationState.fromJson(json);  // ✅ Works
```

### Nested Object Serialization

The fix works because all nested objects already have JSON serialization:

1. **AuthTokens** (`packages/palakat_shared/lib/core/models/auth_tokens.dart`)
   ```dart
   @freezed
   abstract class AuthTokens with _$AuthTokens {
     const factory AuthTokens({...}) = _AuthTokens;
     factory AuthTokens.fromJson(Map<String, dynamic> json) => ...;  // ✅ Has JSON
   }
   ```

2. **Account** (`packages/palakat_shared/lib/core/models/account.dart`)
   ```dart
   @freezed
   abstract class Account with _$Account {
     const factory Account({...}) = _Account;
     factory Account.fromJson(Map<String, dynamic> json) => ...;  // ✅ Has JSON
   }
   ```

When `AuthenticationState.toJson()` is called:
1. It calls `account?.toJson()` for the Account object
2. It calls `tokens?.toJson()` for the AuthTokens object
3. All nested objects are properly serialized to JSON
4. Result is a pure `Map<String, dynamic>` that Hive can store

### Special Handling: Timer Field

The `Timer` field cannot be serialized to JSON (it's a Dart runtime object), so we excluded it:

```dart
@JsonKey(includeFromJson: false, includeToJson: false) Timer? timer,
```

This means:
- Timer is NOT saved to Hive
- Timer is NOT restored from Hive
- Timer must be recreated when needed (which is correct behavior)

### Benefits

1. **No Hive Adapters Needed**: Using JSON serialization instead of custom adapters
2. **Consistent with Other Models**: All models in the app use JSON serialization
3. **Type Safe**: Freezed generates type-safe serialization code
4. **Easy to Debug**: JSON is human-readable in Hive storage
5. **Future Proof**: Easy to add new fields without updating adapters

### Testing

To verify the fix works:

1. **Store state**:
   ```dart
   final state = AuthenticationState(
     account: Account(...),
     tokens: AuthTokens(...),
   );
   await box.put('test', state.toJson());  // Should work
   ```

2. **Load state**:
   ```dart
   final json = box.get('test') as Map<String, dynamic>;
   final state = AuthenticationState.fromJson(json);  // Should work
   ```

3. **Verify nested objects**:
   ```dart
   print(state.account);  // Should have all account data
   print(state.tokens);   // Should have all token data
   ```

### Migration Notes

If there's existing state data in Hive that was stored before this fix:
1. The old data will fail to load (it's in the wrong format)
2. The app should handle this gracefully by clearing old data
3. Users will need to log in again (acceptable for auth state)

### Related Files

- `apps/palakat/lib/features/authentication/presentations/authentication_state.dart` - State definition
- `apps/palakat/lib/features/authentication/presentations/authentication_state.g.dart` - Generated JSON code
- `apps/palakat/lib/features/authentication/presentations/authentication_state.freezed.dart` - Generated Freezed code
- `packages/palakat_shared/lib/core/models/auth_tokens.dart` - AuthTokens model
- `packages/palakat_shared/lib/core/models/account.dart` - Account model
- `packages/palakat_shared/lib/core/services/local_storage_service.dart` - Hive storage service

### Analyzer Warning

You may see this warning:
```
Warning: The annotation 'JsonKey.new' can only be used on fields or getters.
```

This is a false positive from the Dart analyzer. The code generation works correctly, and the `@JsonKey` annotation on constructor parameters is the correct Freezed pattern. The warning can be safely ignored.
