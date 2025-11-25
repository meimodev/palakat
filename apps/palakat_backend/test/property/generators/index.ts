import * as fc from 'fast-check';

export const genderArb = fc.constantFrom('MALE', 'FEMALE');
export const maritalStatusArb = fc.constantFrom('MARRIED', 'SINGLE');
export const bipraArb = fc.constantFrom('PKB', 'WKI', 'PMD', 'RMJ', 'ASM');
export const activityTypeArb = fc.constantFrom(
  'SERVICE',
  'EVENT',
  'ANNOUNCEMENT',
);
export const approvalStatusArb = fc.constantFrom(
  'UNCONFIRMED',
  'APPROVED',
  'REJECTED',
);
export const bookArb = fc.constantFrom('NKB', 'NNBT', 'KJ', 'DSL');
export const paymentMethodArb = fc.constantFrom('CASH', 'CASHLESS');
export const requestStatusArb = fc.constantFrom('TODO', 'DOING', 'DONE');

export const phoneArb = fc
  .integer({ min: 100000000, max: 9999999999 })
  .map((n) => '08' + n);
export const emailArb = fc.emailAddress();
export const nameArb = fc.string({ minLength: 2, maxLength: 50 });
export const passwordArb = fc.string({ minLength: 8, maxLength: 20 });
export const dobArb = fc.date({
  min: new Date(Date.now() - 100 * 365 * 24 * 60 * 60 * 1000),
  max: new Date(Date.now() - 18 * 365 * 24 * 60 * 60 * 1000),
});
export const latitudeArb = fc.double({ min: -90, max: 90, noNaN: true });
export const longitudeArb = fc.double({ min: -180, max: 180, noNaN: true });
export const amountArb = fc.integer({ min: 1, max: 1000000000 });
export const accountNumberArb = fc
  .integer({ min: 100000, max: 99999999999999999999 })
  .map((n) => String(n));
export const songIndexArb = fc.integer({ min: 1, max: 999 });
export const pageArb = fc.integer({ min: 1, max: 1000 });
export const pageSizeArb = fc.integer({ min: 1, max: 100 });

export const accountDataArb = fc.record({
  name: nameArb,
  phone: phoneArb,
  email: fc.option(emailArb, { nil: undefined }),
  password: passwordArb,
  gender: genderArb,
  maritalStatus: maritalStatusArb,
  dob: dobArb,
});
export const locationDataArb = fc.record({
  name: nameArb,
  latitude: latitudeArb,
  longitude: longitudeArb,
});
export const activityDataArb = fc.record({
  title: nameArb,
  bipra: bipraArb,
  activityType: activityTypeArb,
});
export const financialRecordDataArb = fc.record({
  accountNumber: accountNumberArb,
  amount: amountArb,
  paymentMethod: paymentMethodArb,
});
export const songDataArb = fc.record({
  title: nameArb,
  index: songIndexArb,
  book: bookArb,
  link: fc.webUrl(),
});
export const churchRequestDataArb = fc.record({
  churchName: nameArb,
  churchAddress: fc.string({ minLength: 10, maxLength: 200 }),
  contactPerson: nameArb,
  contactPhone: phoneArb,
});
export const paginationParamsArb = fc.record({
  page: pageArb,
  pageSize: pageSizeArb,
});
