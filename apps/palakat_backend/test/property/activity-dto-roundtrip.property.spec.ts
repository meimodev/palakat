/**
 * Property-Based Tests for ActivityListQueryDto Round-Trip Consistency
 *
 * **Feature: activity-financial-filter, Property 5: DTO round-trip consistency**
 * **Validates: Requirements 2.5**
 *
 * This test suite verifies that for any valid ActivityListQueryDto with financial
 * filter values, serializing to query string and parsing back produces an equivalent
 * DTO that results in the same filter behavior.
 */

import * as fc from 'fast-check';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { ActivityListQueryDto } from '../../src/activity/dto/activity-list.dto';
import { TEST_CONFIG } from './utils/test-helpers';

describe('ActivityListQueryDto Round-Trip Property Tests', () => {
  /**
   * **Feature: activity-financial-filter, Property 5: DTO round-trip consistency**
   * **Validates: Requirements 2.5**
   *
   * Property: For any valid ActivityListQueryDto with financial filter values,
   * serializing to query string and parsing back SHALL produce an equivalent DTO
   * that results in the same filter behavior.
   */
  describe('Property 5: DTO round-trip consistency', () => {
    // Generator for hasExpense/hasRevenue boolean values (including undefined)
    const optionalBooleanArb = fc.constantFrom(true, false, undefined);

    // Generator for valid ActivityListQueryDto financial filter combinations
    const financialFilterArb = fc.record({
      hasExpense: optionalBooleanArb,
      hasRevenue: optionalBooleanArb,
    });

    it('should produce equivalent filter behavior after round-trip serialization', async () => {
      await fc.assert(
        fc.asyncProperty(financialFilterArb, async (filters) => {
          // Step 1: Create original DTO with financial filters
          const originalDto = new ActivityListQueryDto();
          if (filters.hasExpense !== undefined) {
            originalDto.hasExpense = filters.hasExpense;
          }
          if (filters.hasRevenue !== undefined) {
            originalDto.hasRevenue = filters.hasRevenue;
          }

          // Step 2: Simulate serialization to query string format
          // Query strings represent booleans as 'true'/'false' strings
          const queryParams: Record<string, string> = {};
          if (filters.hasExpense !== undefined) {
            queryParams.hasExpense = String(filters.hasExpense);
          }
          if (filters.hasRevenue !== undefined) {
            queryParams.hasRevenue = String(filters.hasRevenue);
          }

          // Step 3: Parse back using class-transformer (simulating NestJS behavior)
          const parsedDto = plainToInstance(ActivityListQueryDto, queryParams);

          // Step 4: Verify round-trip consistency
          // The parsed DTO should have the same boolean values after transformation
          expect(parsedDto.hasExpense).toBe(originalDto.hasExpense);
          expect(parsedDto.hasRevenue).toBe(originalDto.hasRevenue);

          // Step 5: Validate the parsed DTO is still valid
          const errors = await validate(parsedDto);
          expect(errors.length).toBe(0);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should handle string "true" and "false" values correctly', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.constantFrom('true', 'false'),
          fc.constantFrom('true', 'false'),
          async (hasExpenseStr, hasRevenueStr) => {
            // Simulate query params as they come from HTTP request
            const queryParams = {
              hasExpense: hasExpenseStr,
              hasRevenue: hasRevenueStr,
            };

            // Parse using class-transformer
            const parsedDto = plainToInstance(
              ActivityListQueryDto,
              queryParams,
            );

            // Verify transformation to boolean
            const expectedHasExpense = hasExpenseStr === 'true';
            const expectedHasRevenue = hasRevenueStr === 'true';

            expect(parsedDto.hasExpense).toBe(expectedHasExpense);
            expect(parsedDto.hasRevenue).toBe(expectedHasRevenue);

            // Validate the DTO
            const errors = await validate(parsedDto);
            expect(errors.length).toBe(0);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should preserve undefined values when parameters are omitted', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.constantFrom(
            {},
            { hasExpense: 'true' },
            { hasRevenue: 'false' },
            { hasExpense: 'false', hasRevenue: 'true' },
          ),
          async (queryParams) => {
            // Parse using class-transformer
            const parsedDto = plainToInstance(
              ActivityListQueryDto,
              queryParams,
            );

            // Verify that omitted parameters remain undefined
            if (!('hasExpense' in queryParams)) {
              expect(parsedDto.hasExpense).toBeUndefined();
            }
            if (!('hasRevenue' in queryParams)) {
              expect(parsedDto.hasRevenue).toBeUndefined();
            }

            // Validate the DTO
            const errors = await validate(parsedDto);
            expect(errors.length).toBe(0);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should maintain filter equivalence with other query parameters', async () => {
      await fc.assert(
        fc.asyncProperty(
          optionalBooleanArb,
          optionalBooleanArb,
          fc.integer({ min: 1, max: 100 }),
          fc.integer({ min: 1, max: 50 }),
          async (hasExpense, hasRevenue, page, pageSize) => {
            // Create query params with financial filters and pagination
            const queryParams: Record<string, string> = {
              page: String(page),
              pageSize: String(pageSize),
            };
            if (hasExpense !== undefined) {
              queryParams.hasExpense = String(hasExpense);
            }
            if (hasRevenue !== undefined) {
              queryParams.hasRevenue = String(hasRevenue);
            }

            // Parse using class-transformer
            const parsedDto = plainToInstance(
              ActivityListQueryDto,
              queryParams,
            );

            // Verify financial filters are correctly parsed
            if (hasExpense !== undefined) {
              expect(parsedDto.hasExpense).toBe(hasExpense);
            } else {
              expect(parsedDto.hasExpense).toBeUndefined();
            }

            if (hasRevenue !== undefined) {
              expect(parsedDto.hasRevenue).toBe(hasRevenue);
            } else {
              expect(parsedDto.hasRevenue).toBeUndefined();
            }

            // Verify pagination is also correctly parsed
            expect(parsedDto.page).toBe(page);
            expect(parsedDto.pageSize).toBe(pageSize);

            // Validate the DTO
            const errors = await validate(parsedDto);
            expect(errors.length).toBe(0);
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
