/**
 * Property-Based Testing Module
 *
 * This module exports all generators and utilities for property-based testing
 * using fast-check library.
 *
 * Usage:
 * ```typescript
 * import * as fc from 'fast-check';
 * import { generators, utils, TEST_CONFIG } from '../property';
 *
 * describe('My Property Tests', () => {
 *   it('should satisfy property', () => {
 *     fc.assert(
 *       fc.property(generators.phoneArb, (phone) => {
 *         // Test property
 *         return phone.startsWith('08');
 *       }),
 *       { numRuns: TEST_CONFIG.NUM_RUNS }
 *     );
 *   });
 * });
 * ```
 */

export * as generators from './generators';
export * as utils from './utils/test-helpers';
