# Security Review Findings - Task 20.1

## Date: 2025-11-25

## Summary

Comprehensive security review of authentication implementation covering password hashing, account lockout, refresh token rotation, and JWT expiration.

## Test Results

**Total Tests**: 22
**Passed**: 21
**Failed**: 1

### ✅ Verified Security Features

#### 1. Password Hashing with bcryptjs
- ✅ Passwords are hashed using bcryptjs with 10 rounds
- ✅ Plain text passwords are never stored
- ✅ Invalid passwords are properly rejected
- **Implementation**: `auth.service.ts` uses `bcrypt.hash(password, 10)` for new passwords and `bcrypt.hash(refreshToken, 12)` for refresh tokens

#### 2. Account Lockout after Failed Login Attempts
- ✅ Failed login attempts are tracked correctly
- ✅ Account is locked after 5 failed attempts
- ✅ Locked accounts cannot login even with correct password
- ✅ Failed attempts counter is reset on successful login
- **Implementation**: `auth.service.ts` tracks `failedLoginAttempts` and sets `lockUntil` to 5 minutes in the future after 5 failed attempts
- **Configuration**: MAX_ATTEMPTS = 5, LOCK_MINUTES = 5

#### 3. JWT Token Generation and Validation
- ✅ Valid JWT tokens are generated on sign-in
- ✅ Protected routes require valid access token
- ✅ Invalid tokens are rejected
- ✅ Missing tokens are rejected
- ✅ JTI (JWT ID) is included in refresh tokens for tracking
- **Implementation**: Uses `@nestjs/jwt` with JWT strategy via Passport

#### 4. Refresh Token Management
- ✅ New access and refresh tokens are generated on refresh
- ✅ Refresh tokens are stored as bcrypt hashes (12 rounds)
- ✅ Invalid refresh tokens are rejected
- ✅ Expired refresh tokens are rejected
- ✅ Refresh tokens are cleared on sign-out

#### 5. Security Best Practices
- ✅ Password hashes are not returned in API responses
- ✅ Refresh token hashes are not returned in API responses
- ✅ Inactive accounts are rejected
- ✅ Unclaimed accounts without passwords are rejected

### ❌ Security Issue Found

#### Refresh Token Rotation (One-Time Use)

**Issue**: Refresh tokens are NOT properly invalidated after use, allowing reuse of old refresh tokens.

**Expected Behavior**: After using a refresh token to obtain new tokens, the old refresh token should be invalidated and cannot be used again (one-time use).

**Actual Behavior**: The old refresh token can still be used after being refreshed once.

**Root Cause**: The current implementation updates the `refreshTokenHash` in the database with the new token's hash, but the validation logic uses `bcrypt.compare()` which compares the provided token against the stored hash. After the first refresh:
1. Old token hash is replaced with new token hash
2. Old token should fail bcrypt comparison with new hash
3. However, the test shows old token still works

**Potential Explanation**: The test might be using the wrong token, or there's a timing issue. Need to investigate further.

**Security Impact**: Medium - If refresh tokens can be reused, an attacker who obtains a refresh token could continue using it even after the legitimate user has refreshed their session.

**Recommendation**: 
1. Verify the JTI (JWT ID) matches the stored `refreshTokenJti` in addition to hash validation
2. Add explicit check: `if (decoded.jti !== account.refreshTokenJti) throw UnauthorizedException`
3. This ensures that only the most recently issued refresh token is valid

## Requirements Validation

### Requirement 1.3: Account Lockout
✅ **VERIFIED**: Account is locked after 5 failed login attempts for 5 minutes (implementation uses 5 minutes, design doc specifies 30 minutes - minor discrepancy)

**Note**: Design document specifies 30-minute lockout, but implementation uses 5 minutes. This should be aligned.

### Requirement 1.4: Refresh Token Rotation
⚠️ **PARTIAL**: Refresh tokens are rotated (new tokens generated), but old tokens are not properly invalidated for one-time use.

### Requirement 1.5: Sign-out Token Invalidation
✅ **VERIFIED**: Refresh tokens are properly cleared from database on sign-out.

## Code Quality Observations

### Strengths
1. Comprehensive error handling with appropriate HTTP status codes
2. Proper use of bcrypt for password and token hashing
3. Clean separation of concerns (controller, service, strategy)
4. Good use of TypeScript types and NestJS decorators
5. Proper sanitization of response data (removing sensitive fields)

### Areas for Improvement
1. **Lockout Duration Inconsistency**: Code uses 5 minutes, design doc says 30 minutes
2. **Refresh Token JTI Validation**: Not checking JTI for one-time use enforcement
3. **JWT Expiration Configuration**: Access token expiration is not explicitly configured (commented out in auth.module.ts)
4. **Magic Numbers**: Constants like MAX_ATTEMPTS and LOCK_MINUTES should be moved to configuration

## Recommendations

### High Priority
1. **Fix Refresh Token One-Time Use**: Add JTI validation to ensure old refresh tokens cannot be reused
2. **Configure JWT Expiration**: Uncomment and set explicit access token expiration (design doc specifies 15 minutes)
3. **Align Lockout Duration**: Update code to use 30-minute lockout as specified in design doc, or update design doc to match 5-minute implementation

### Medium Priority
1. **Move Constants to Configuration**: Extract MAX_ATTEMPTS, LOCK_MINUTES, JWT expiration to environment variables
2. **Add Rate Limiting**: Consider adding rate limiting to prevent brute force attacks
3. **Add Audit Logging**: Log all authentication events (sign-in, sign-out, failed attempts, lockouts)

### Low Priority
1. **Add Password Complexity Requirements**: Enforce minimum password strength
2. **Add Session Management**: Track active sessions and allow users to revoke sessions
3. **Add Two-Factor Authentication**: Consider adding 2FA for enhanced security

## Test Coverage

The security test suite provides comprehensive coverage of authentication security:
- Password hashing and validation
- Account lockout mechanism
- Refresh token lifecycle
- JWT token validation
- Security best practices

**Test File**: `test/security/auth-security.e2e-spec.ts`
**Lines of Test Code**: ~450 lines
**Test Scenarios**: 22 test cases across 5 categories

## Conclusion

The authentication system has strong security foundations with proper password hashing, account lockout, and token management. However, the refresh token rotation mechanism needs to be fixed to properly enforce one-time use. Additionally, some configuration inconsistencies should be resolved to align with the design document.

**Overall Security Rating**: B+ (Good, with one medium-severity issue to address)
