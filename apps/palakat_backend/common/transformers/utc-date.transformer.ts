import { Transform } from 'class-transformer';

/**
 * Parses a date string as UTC.
 * If the string doesn't have timezone info, appends 'Z' to treat it as UTC.
 */
function parseAsUtc(value: string): Date {
  const trimmed = value.trim();

  // Check if the string already has timezone info
  const hasTimezone =
    trimmed.endsWith('Z') ||
    /[+-]\d{2}:\d{2}$/.test(trimmed) ||
    /[+-]\d{4}$/.test(trimmed);

  if (hasTimezone) {
    return new Date(trimmed);
  }

  // No timezone info - treat as UTC by appending Z
  return new Date(trimmed + 'Z');
}

/**
 * Sets a date to the start of day in UTC (00:00:00.000)
 */
function setStartOfDayUtc(date: Date): Date {
  const result = new Date(date);
  result.setUTCHours(0, 0, 0, 0);
  return result;
}

/**
 * Sets a date to the end of day in UTC (23:59:59.999)
 */
function setEndOfDayUtc(date: Date): Date {
  const result = new Date(date);
  result.setUTCHours(23, 59, 59, 999);
  return result;
}

/**
 * Helper to get raw value and parse as UTC date
 */
function getRawDateValue(obj: any, key: string): Date | undefined {
  const rawValue = obj[key];

  if (rawValue === null || rawValue === undefined || rawValue === '') {
    return undefined;
  }

  if (typeof rawValue === 'string') {
    return parseAsUtc(rawValue);
  }

  if (rawValue instanceof Date) {
    return rawValue;
  }

  return new Date(rawValue);
}

/**
 * Custom transformer that treats incoming date strings as UTC.
 * This ensures consistent date handling regardless of server timezone.
 *
 * If the input doesn't have a timezone indicator (Z or +/-offset),
 * it will be treated as UTC by appending 'Z'.
 *
 * This transformer accesses the raw object value to bypass implicit conversion.
 */
export function TransformToUtcDate() {
  return Transform(({ obj, key }) => getRawDateValue(obj, key), {
    toClassOnly: true,
  });
}

/**
 * Transformer for start date filters.
 * Parses the date as UTC and sets time to start of day (00:00:00.000 UTC).
 */
export function TransformToStartOfDayUtc() {
  return Transform(
    ({ obj, key }) => {
      const date = getRawDateValue(obj, key);
      return date ? setStartOfDayUtc(date) : undefined;
    },
    { toClassOnly: true },
  );
}

/**
 * Transformer for end date filters.
 * Parses the date as UTC and sets time to end of day (23:59:59.999 UTC).
 */
export function TransformToEndOfDayUtc() {
  return Transform(
    ({ obj, key }) => {
      const date = getRawDateValue(obj, key);
      return date ? setEndOfDayUtc(date) : undefined;
    },
    { toClassOnly: true },
  );
}
