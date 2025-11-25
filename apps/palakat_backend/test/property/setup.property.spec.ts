/**
 * Property-Based Testing Setup Verification
 *
 * This test file verifies that the fast-check testing framework
 * is properly configured and all generators work correctly.
 */

import * as fc from 'fast-check';
import * as generators from './generators';
import { TEST_CONFIG } from './utils/test-helpers';

describe('Property-Based Testing Setup', () => {
  describe('Framework Configuration', () => {
    it('fast-check is properly installed and configured', () => {
      fc.assert(
        fc.property(fc.integer(), (n: number) => {
          return typeof n === 'number';
        }),
        { numRuns: 10 },
      );
    });

    it('runs minimum 100 iterations by default', () => {
      let count = 0;
      fc.assert(
        fc.property(fc.integer(), () => {
          count++;
          return true;
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
      expect(count).toBeGreaterThanOrEqual(TEST_CONFIG.NUM_RUNS);
    });
  });

  describe('Enum Generators', () => {
    it('genderArb generates valid gender values', () => {
      fc.assert(
        fc.property(generators.genderArb, (gender: string) => {
          return gender === 'MALE' || gender === 'FEMALE';
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('maritalStatusArb generates valid marital status values', () => {
      fc.assert(
        fc.property(generators.maritalStatusArb, (status: string) => {
          return status === 'MARRIED' || status === 'SINGLE';
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('bipraArb generates valid BIPRA values', () => {
      fc.assert(
        fc.property(generators.bipraArb, (bipra: string) => {
          return ['PKB', 'WKI', 'PMD', 'RMJ', 'ASM'].includes(bipra);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('activityTypeArb generates valid activity type values', () => {
      fc.assert(
        fc.property(generators.activityTypeArb, (type: string) => {
          return ['SERVICE', 'EVENT', 'ANNOUNCEMENT'].includes(type);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('approvalStatusArb generates valid approval status values', () => {
      fc.assert(
        fc.property(generators.approvalStatusArb, (status: string) => {
          return ['UNCONFIRMED', 'APPROVED', 'REJECTED'].includes(status);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('bookArb generates valid book values', () => {
      fc.assert(
        fc.property(generators.bookArb, (book: string) => {
          return ['NKB', 'NNBT', 'KJ', 'DSL'].includes(book);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('paymentMethodArb generates valid payment method values', () => {
      fc.assert(
        fc.property(generators.paymentMethodArb, (method: string) => {
          return method === 'CASH' || method === 'CASHLESS';
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('requestStatusArb generates valid request status values', () => {
      fc.assert(
        fc.property(generators.requestStatusArb, (status: string) => {
          return ['TODO', 'DOING', 'DONE'].includes(status);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  describe('Primitive Generators', () => {
    it('phoneArb generates valid Indonesian phone numbers', () => {
      fc.assert(
        fc.property(generators.phoneArb, (phone: string) => {
          return (
            phone.startsWith('08') &&
            phone.length >= 10 &&
            phone.length <= 14 &&
            /^\d+$/.test(phone)
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('emailArb generates valid email addresses', () => {
      fc.assert(
        fc.property(generators.emailArb, (email: string) => {
          return email.includes('@') && email.includes('.');
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('nameArb generates valid names', () => {
      fc.assert(
        fc.property(generators.nameArb, (name: string) => {
          return name.trim().length >= 2 && name.length <= 50;
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('passwordArb generates valid passwords', () => {
      fc.assert(
        fc.property(generators.passwordArb, (password: string) => {
          const hasLetters = /[a-z]/i.test(password);
          const hasNumbers = /\d/.test(password);
          const hasSpecial = /[!@#$%^&*]/.test(password);
          return password.length >= 7 && hasLetters && hasNumbers && hasSpecial;
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('dobArb generates valid dates of birth (18-100 years ago)', () => {
      fc.assert(
        fc.property(generators.dobArb, (dob: Date) => {
          const now = Date.now();
          const minAge = 18 * 365 * 24 * 60 * 60 * 1000;
          const maxAge = 100 * 365 * 24 * 60 * 60 * 1000;
          const age = now - dob.getTime();
          return age >= minAge && age <= maxAge;
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('latitudeArb generates valid latitude values', () => {
      fc.assert(
        fc.property(generators.latitudeArb, (lat: number) => {
          return lat >= -90 && lat <= 90 && !isNaN(lat);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('longitudeArb generates valid longitude values', () => {
      fc.assert(
        fc.property(generators.longitudeArb, (lng: number) => {
          return lng >= -180 && lng <= 180 && !isNaN(lng);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('amountArb generates positive integers', () => {
      fc.assert(
        fc.property(generators.amountArb, (amount: number) => {
          return (
            amount >= 1 && amount <= 1000000000 && Number.isInteger(amount)
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('accountNumberArb generates valid account numbers', () => {
      fc.assert(
        fc.property(generators.accountNumberArb, (accNum: string) => {
          return (
            accNum.length >= 6 && accNum.length <= 20 && /^\d+$/.test(accNum)
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('songIndexArb generates valid song indices', () => {
      fc.assert(
        fc.property(generators.songIndexArb, (index: number) => {
          return index >= 1 && index <= 999 && Number.isInteger(index);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('pageArb generates valid page numbers', () => {
      fc.assert(
        fc.property(generators.pageArb, (page: number) => {
          return page >= 1 && page <= 1000 && Number.isInteger(page);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('pageSizeArb generates valid page sizes (1-100)', () => {
      fc.assert(
        fc.property(generators.pageSizeArb, (size: number) => {
          return size >= 1 && size <= 100 && Number.isInteger(size);
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });

  describe('Model Generators', () => {
    it('accountDataArb generates valid account data', () => {
      fc.assert(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fc.property(generators.accountDataArb, (data: any) => {
          return (
            String(data.name).trim().length >= 2 &&
            String(data.phone).startsWith('08') &&
            String(data.password).length >= 7 &&
            ['MALE', 'FEMALE'].includes(data.gender) &&
            ['MARRIED', 'SINGLE'].includes(data.maritalStatus) &&
            data.dob instanceof Date
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('locationDataArb generates valid location data', () => {
      fc.assert(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fc.property(generators.locationDataArb, (data: any) => {
          return (
            String(data.name).trim().length >= 2 &&
            data.latitude >= -90 &&
            data.latitude <= 90 &&
            data.longitude >= -180 &&
            data.longitude <= 180
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('activityDataArb generates valid activity data', () => {
      fc.assert(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fc.property(generators.activityDataArb, (data: any) => {
          return (
            String(data.title).trim().length >= 2 &&
            ['PKB', 'WKI', 'PMD', 'RMJ', 'ASM'].includes(data.bipra) &&
            ['SERVICE', 'EVENT', 'ANNOUNCEMENT'].includes(data.activityType)
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('financialRecordDataArb generates valid financial record data', () => {
      fc.assert(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fc.property(generators.financialRecordDataArb, (data: any) => {
          return (
            String(data.accountNumber).length >= 6 &&
            data.amount >= 1 &&
            ['CASH', 'CASHLESS'].includes(data.paymentMethod)
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('songDataArb generates valid song data', () => {
      fc.assert(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fc.property(generators.songDataArb, (data: any) => {
          return (
            String(data.title).trim().length >= 2 &&
            data.index >= 1 &&
            data.index <= 999 &&
            ['NKB', 'NNBT', 'KJ', 'DSL'].includes(data.book) &&
            String(data.link).startsWith('http')
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('churchRequestDataArb generates valid church request data', () => {
      fc.assert(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fc.property(generators.churchRequestDataArb, (data: any) => {
          return (
            String(data.churchName).trim().length >= 2 &&
            String(data.churchAddress).length >= 10 &&
            String(data.contactPerson).trim().length >= 2 &&
            String(data.contactPhone).startsWith('08')
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });

    it('paginationParamsArb generates valid pagination parameters', () => {
      fc.assert(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fc.property(generators.paginationParamsArb, (params: any) => {
          return (
            params.page >= 1 &&
            params.page <= 1000 &&
            params.pageSize >= 1 &&
            params.pageSize <= 100
          );
        }),
        { numRuns: TEST_CONFIG.NUM_RUNS },
      );
    });
  });
});
