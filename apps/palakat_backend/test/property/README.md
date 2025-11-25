# Property-Based Testing Setup

This directory contains the property-based testing framework setup using fast-check for the Palakat backend.

## Overview

Property-based testing (PBT) is used to verify that the system satisfies correctness properties across a wide range of inputs. This approach complements traditional unit tests by automatically generating test cases and finding edge cases.

## Structure

```
test/property/
├── README.md                    # This file
├── index.ts                     # Main exports
├── jest-property.json           # Jest configuration for property tests
├── generators/
│   └── index.ts                 # Test data generators (arbitraries)
├── utils/
│   └── test-helpers.ts          # Helper functions for tests
└── setup.property.spec.ts       # Setup verification tests
```

## Configuration

### Jest Configuration

Property tests use a separate Jest configuration (`jest-property.json`) with:
- Test pattern: `*.property.spec.ts`
- Timeout: 30 seconds (for longer-running property tests)
- Minimum 100 iterations per property test (as per design document)

### Running Tests

```bash
# Run all property tests
pnpm run test:property

# Run property tests in watch mode
pnpm run test:property:watch

# Run specific property test file
pnpm run test:property -- setup.property.spec.ts
```

## Generators

The `generators/index.ts` file provides fast-check arbitraries for generating valid test data:

### Enum Generators
- `genderArb` - MALE | FEMALE
- `maritalStatusArb` - MARRIED | SINGLE
- `bipraArb` - PKB | WKI | PMD | RMJ | ASM
- `activityTypeArb` - SERVICE | EVENT | ANNOUNCEMENT
- `approvalStatusArb` - UNCONFIRMED | APPROVED | REJECTED
- `bookArb` - NKB | NNBT | KJ | DSL
- `paymentMethodArb` - CASH | CASHLESS
- `requestStatusArb` - TODO | DOING | DONE

### Primitive Generators
- `phoneArb` - Indonesian phone numbers (08xxxxxxxxxx)
- `emailArb` - Valid email addresses
- `nameArb` - Valid names (2-50 characters)
- `passwordArb` - Valid passwords (8-20 characters)
- `dobArb` - Date of birth (18-100 years ago)
- `latitudeArb` - Latitude values (-90 to 90)
- `longitudeArb` - Longitude values (-180 to 180)
- `amountArb` - Positive integers for amounts
- `accountNumberArb` - Numeric account numbers
- `songIndexArb` - Song indices (1-999)
- `pageArb` - Page numbers (1-1000)
- `pageSizeArb` - Page sizes (1-100)

### Model Generators
- `accountDataArb` - Complete account creation data
- `locationDataArb` - Location with coordinates
- `activityDataArb` - Activity data
- `financialRecordDataArb` - Revenue/expense data
- `songDataArb` - Song data
- `churchRequestDataArb` - Church registration request data
- `paginationParamsArb` - Pagination parameters

## Test Helpers

The `utils/test-helpers.ts` file provides:

### Configuration
- `TEST_CONFIG.NUM_RUNS` - Number of iterations (100)
- `TEST_CONFIG.HASH_ROUNDS` - Password hash rounds (10)
- `TEST_CONFIG.DEFAULT_PASSWORD` - Default test password
- `TEST_CONFIG.JWT_SECRET` - JWT secret for tests

### Database Helpers
- `createTestPrismaClient()` - Create Prisma client
- `cleanupTestData()` - Clean test data from database
- `createTestAccount()` - Create test account
- `createTestChurch()` - Create test church with location
- `createTestMembership()` - Create test membership

### Utility Functions
- `generateTestId()` - Generate unique test identifier
- `delay()` - Wait for specified duration
- `assertInRange()` - Assert value is within range
- `assertDatesClose()` - Assert dates are close within tolerance

## Writing Property Tests

### Basic Structure

```typescript
import * as fc from 'fast-check';
import { generators, TEST_CONFIG } from '../property';

describe('Feature Property Tests', () => {
  it('should satisfy property', () => {
    fc.assert(
      fc.property(generators.phoneArb, (phone: string) => {
        // Test the property
        return phone.startsWith('08');
      }),
      { numRuns: TEST_CONFIG.NUM_RUNS }
    );
  });
});
```

### Tagging Property Tests

Each property test MUST be tagged with a comment referencing the design document:

```typescript
// **Feature: palakat-system-overview, Property 1: Authentication Token Generation**
// **Validates: Requirements 1.1**
it('should generate valid JWT tokens for valid credentials', () => {
  fc.assert(
    fc.property(generators.accountDataArb, (data) => {
      // Test implementation
    }),
    { numRuns: TEST_CONFIG.NUM_RUNS }
  );
});
```

## Best Practices

1. **Run Minimum 100 Iterations**: Always use `TEST_CONFIG.NUM_RUNS` (100) as per design document
2. **Smart Generators**: Constrain generators to valid input space
3. **Clear Properties**: Write properties that are easy to understand and verify
4. **Cleanup**: Use test helpers to clean up test data after tests
5. **Isolation**: Ensure tests don't depend on each other
6. **Documentation**: Tag each property test with its design document reference

## Example Property Tests

See `setup.property.spec.ts` for examples of:
- Framework configuration verification
- Enum generator validation
- Primitive generator validation
- Model generator validation

## Dependencies

- `fast-check` ^4.3.0 - Property-based testing library
- `@prisma/client` - Database access
- `bcryptjs` - Password hashing
- `jest` - Test runner

## Next Steps

After setup verification, implement property tests for:
1. Authentication (Properties 1-4)
2. Account Management (Properties 5-7)
3. Activity Management (Properties 8-13)
4. Approval Rules (Properties 14-15)
5. Financial Operations (Properties 16-18)
6. Song Management (Properties 19-21)
7. Church Management (Properties 22-23)
8. Church Requests (Properties 24-25)
9. Multi-Church Isolation (Property 26)
10. Pagination and Validation (Properties 27-29)

Refer to `.kiro/specs/palakat-system-overview/design.md` for complete property definitions.
