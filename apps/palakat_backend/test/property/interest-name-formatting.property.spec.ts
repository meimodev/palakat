/**
 * Property-Based Tests for Interest Name Formatting
 *
 * **Feature: push-notification, Property 4: Interest Name Formatting - BIPRA**
 * **Feature: push-notification, Property 5: Interest Name Formatting - Membership**
 *
 * This test suite verifies correctness properties for the
 * Pusher Beams interest name formatting functions.
 *
 * **Validates: Requirements 2.2, 2.3, 5.1, 6.1**
 */

import * as fc from 'fast-check';
import { TEST_CONFIG } from './utils/test-helpers';
import { bipraArb } from './generators';
import { PusherBeamsService } from '../../src/notification/pusher-beams.service';
import { ConfigService } from '@nestjs/config';

// Generator for positive church IDs
const churchIdArb = fc.integer({ min: 1, max: 1000000 });

// Generator for positive membership IDs
const membershipIdArb = fc.integer({ min: 1, max: 1000000 });

// Generator for positive column IDs
const columnIdArb = fc.integer({ min: 1, max: 1000000 });

// Create a mock ConfigService that returns undefined for Pusher credentials
// This allows us to test the formatting functions without actual Pusher connection
const mockConfigService = {
  get: jest.fn().mockReturnValue(undefined),
} as unknown as ConfigService;

// Create an instance of PusherBeamsService for testing
const pusherBeamsService = new PusherBeamsService(mockConfigService);

// Use the actual service methods for formatting
const formatBipraInterest = (churchId: number, bipra: string) =>
  pusherBeamsService.formatBipraInterest(churchId, bipra);

const formatMembershipInterest = (membershipId: number) =>
  pusherBeamsService.formatMembershipInterest(membershipId);

const formatChurchInterest = (churchId: number) =>
  pusherBeamsService.formatChurchInterest(churchId);

const formatColumnInterest = (churchId: number, columnId: number) =>
  pusherBeamsService.formatColumnInterest(churchId, columnId);

const formatColumnBipraInterest = (
  churchId: number,
  columnId: number,
  bipra: string,
) => pusherBeamsService.formatColumnBipraInterest(churchId, columnId, bipra);

describe('Interest Name Formatting Property Tests', () => {
  // **Feature: push-notification, Property 4: Interest Name Formatting - BIPRA**
  // **Validates: Requirements 2.2, 5.1**
  describe('Property 4: Interest Name Formatting - BIPRA', () => {
    it('should format BIPRA interest as church.{churchId}_bipra.{BIPRA} with BIPRA in uppercase', () => {
      fc.assert(
        fc.property(
          churchIdArb,
          bipraArb,
          (churchId: number, bipra: string) => {
            const interest = formatBipraInterest(churchId, bipra);

            // Verify the pattern matches exactly
            const expectedPattern = `church.${churchId}_bipra.${bipra.toUpperCase()}`;
            expect(interest).toBe(expectedPattern);

            // Verify BIPRA is uppercase in the result
            expect(interest).toContain(`_bipra.${bipra.toUpperCase()}`);

            // Verify the interest starts with church.{churchId}
            expect(interest.startsWith(`church.${churchId}_`)).toBe(true);

            // Verify the interest contains the correct separator
            expect(interest).toMatch(/^church\.\d+_bipra\.[A-Z]+$/);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('should handle lowercase BIPRA input by converting to uppercase', () => {
      fc.assert(
        fc.property(
          churchIdArb,
          fc.constantFrom('pkb', 'wki', 'pmd', 'rmj', 'asm'),
          (churchId: number, lowercaseBipra: string) => {
            const interest = formatBipraInterest(churchId, lowercaseBipra);

            // Verify BIPRA is converted to uppercase
            expect(interest).toContain(
              `_bipra.${lowercaseBipra.toUpperCase()}`,
            );
            expect(interest).not.toContain(lowercaseBipra);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // **Feature: push-notification, Property 5: Interest Name Formatting - Membership**
  // **Validates: Requirements 2.3, 6.1**
  describe('Property 5: Interest Name Formatting - Membership', () => {
    it('should format membership interest as membership.{membershipId}', () => {
      fc.assert(
        fc.property(membershipIdArb, (membershipId: number) => {
          const interest = formatMembershipInterest(membershipId);

          // Verify the pattern matches exactly
          const expectedPattern = `membership.${membershipId}`;
          expect(interest).toBe(expectedPattern);

          // Verify the interest starts with membership.
          expect(interest.startsWith('membership.')).toBe(true);

          // Verify the interest matches the expected regex pattern
          expect(interest).toMatch(/^membership\.\d+$/);

          return true;
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // Additional property tests for other interest formatters
  describe('Church Interest Formatting', () => {
    it('should format church interest as church.{churchId}', () => {
      fc.assert(
        fc.property(churchIdArb, (churchId: number) => {
          const interest = formatChurchInterest(churchId);

          // Verify the pattern matches exactly
          expect(interest).toBe(`church.${churchId}`);

          // Verify the interest matches the expected regex pattern
          expect(interest).toMatch(/^church\.\d+$/);

          return true;
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  describe('Column Interest Formatting', () => {
    it('should format column interest as church.{churchId}_column.{columnId}', () => {
      fc.assert(
        fc.property(
          churchIdArb,
          columnIdArb,
          (churchId: number, columnId: number) => {
            const interest = formatColumnInterest(churchId, columnId);

            // Verify the pattern matches exactly
            expect(interest).toBe(`church.${churchId}_column.${columnId}`);

            // Verify the interest matches the expected regex pattern
            expect(interest).toMatch(/^church\.\d+_column\.\d+$/);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  describe('Column BIPRA Interest Formatting', () => {
    it('should format column BIPRA interest as church.{churchId}_column.{columnId}_bipra.{BIPRA}', () => {
      fc.assert(
        fc.property(
          churchIdArb,
          columnIdArb,
          bipraArb,
          (churchId: number, columnId: number, bipra: string) => {
            const interest = formatColumnBipraInterest(
              churchId,
              columnId,
              bipra,
            );

            // Verify the pattern matches exactly
            expect(interest).toBe(
              `church.${churchId}_column.${columnId}_bipra.${bipra.toUpperCase()}`,
            );

            // Verify BIPRA is uppercase
            expect(interest).toContain(`_bipra.${bipra.toUpperCase()}`);

            // Verify the interest matches the expected regex pattern
            expect(interest).toMatch(/^church\.\d+_column\.\d+_bipra\.[A-Z]+$/);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  // Consistency property: formatters should be deterministic
  describe('Formatter Determinism', () => {
    it('should produce the same output for the same input', () => {
      fc.assert(
        fc.property(
          churchIdArb,
          membershipIdArb,
          columnIdArb,
          bipraArb,
          (
            churchId: number,
            membershipId: number,
            columnId: number,
            bipra: string,
          ) => {
            // Call each formatter twice with the same input
            const bipraInterest1 = formatBipraInterest(churchId, bipra);
            const bipraInterest2 = formatBipraInterest(churchId, bipra);
            expect(bipraInterest1).toBe(bipraInterest2);

            const membershipInterest1 = formatMembershipInterest(membershipId);
            const membershipInterest2 = formatMembershipInterest(membershipId);
            expect(membershipInterest1).toBe(membershipInterest2);

            const churchInterest1 = formatChurchInterest(churchId);
            const churchInterest2 = formatChurchInterest(churchId);
            expect(churchInterest1).toBe(churchInterest2);

            const columnInterest1 = formatColumnInterest(churchId, columnId);
            const columnInterest2 = formatColumnInterest(churchId, columnId);
            expect(columnInterest1).toBe(columnInterest2);

            const columnBipraInterest1 = formatColumnBipraInterest(
              churchId,
              columnId,
              bipra,
            );
            const columnBipraInterest2 = formatColumnBipraInterest(
              churchId,
              columnId,
              bipra,
            );
            expect(columnBipraInterest1).toBe(columnBipraInterest2);

            return true;
          },
        ),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
