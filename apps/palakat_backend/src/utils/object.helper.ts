/**
 * Recursively strips specified keys from an object or array.
 * @param data - The object or array to process
 * @param keysToStrip - Array of key names to remove (default: ['id', 'updatedAt'])
 * @param parentKey - Internal parameter to track parent key (used to skip stripping in 'set' contexts)
 * @returns A new object/array with specified keys removed
 */
export function stripKeys<T = any>(
  data: T,
  keysToStrip: string[] = ['id', 'updatedAt'],
  parentKey?: string,
): T {
  // Handle null or undefined
  if (data === null || data === undefined) {
    return data;
  }

  // Handle arrays
  if (Array.isArray(data)) {
    return data.map((item) => stripKeys(item, keysToStrip, parentKey)) as T;
  }

  // Handle objects
  if (typeof data === 'object' && data !== null) {
    const result: any = {};

    for (const [key, value] of Object.entries(data)) {
      // Skip keys that should be stripped, UNLESS parent key is 'set' or 'connect'
      // This preserves { set: [{ id: 1 }, { id: 2 }] } and { connect: [{ id: 1 }, { id: 2 }] } in Prisma relations
      if (
        keysToStrip.includes(key) &&
        parentKey !== 'set' &&
        parentKey !== 'connect'
      ) {
        continue;
      }

      // Recursively process nested objects and arrays, passing current key as parent
      result[key] = stripKeys(value, keysToStrip, key);
    }

    return result as T;
  }

  // Return primitive values as-is
  return data;
}

/**
 * Recursively transforms object fields with 'id' into simplified ID references.
 * - Single objects: { column: { id: 1, name: "..." } } -> { columnId: 1 }
 * - Arrays of objects: { positions: [{ id: 1 }, { id: 2 }] } -> { positionIds: [1, 2] }
 * Processes nested objects and arrays deeply.
 * @param data - The object or array to process
 * @param fieldsToTransform - Array of field names to transform (default: ['membershipPositions'])
 * @returns A new object/array with specified fields transformed to ID references
 */
export function transformToIdArrays<T = any>(
  data: T,
  fieldsToTransform: string[] = ['membershipPositions'],
): T {
  // Handle null or undefined
  if (data === null || data === undefined) {
    return data;
  }

  // Handle arrays - recursively process each item
  if (Array.isArray(data)) {
    return data.map((item) =>
      transformToIdArrays(item, fieldsToTransform),
    ) as T;
  }

  // Handle objects
  if (typeof data === 'object' && data !== null) {
    const result: any = {};

    for (const [key, value] of Object.entries(data)) {
      // Check if this field should be transformed
      if (fieldsToTransform.includes(key)) {
        // Handle array of objects -> transform to array of IDs
        if (Array.isArray(value)) {
          // Check if all items in array are objects with numeric id property
          const allHaveNumericIds =
            value.length > 0 &&
            value.every(
              (item) =>
                typeof item === 'object' &&
                item !== null &&
                'id' in item &&
                typeof item.id === 'number',
            );

          if (allHaveNumericIds) {
            const ids = value.map((item) => item.id);
            // Use plural form: fieldName -> fieldNameIds
            const newKey = key.endsWith('s')
              ? `${key.slice(0, -1)}Ids`
              : `${key}Ids`;
            result[newKey] = ids;
          } else {
            // Keep original if not all items have numeric IDs
            result[key] = transformToIdArrays(value, fieldsToTransform);
          }
        }
        // Handle single object -> transform to single ID
        else if (
          typeof value === 'object' &&
          value !== null &&
          'id' in value &&
          typeof value.id === 'number'
        ) {
          // Use singular form: fieldName -> fieldNameId
          const newKey = `${key}Id`;
          result[newKey] = value.id;
        }
        // If value doesn't have a numeric id, keep as-is and recurse
        else {
          result[key] = transformToIdArrays(value, fieldsToTransform);
        }
      } else {
        // Recursively process nested values
        result[key] = transformToIdArrays(value, fieldsToTransform);
      }
    }

    return result as T;
  }

  // Return primitive values as-is
  return data;
}

/**
 * Transforms arrays of objects with 'id' into Prisma relation format for relation updates.
 * Supports both 'set' (replace all) and 'connect' (add to existing) formats.
 * Example with 'set': [{ id: 1, name: "..." }, { id: 2, ... }] -> { set: [{ id: 1 }, { id: 2 }] }
 * Example with 'connect': [{ id: 1, name: "..." }, { id: 2, ... }] -> { connect: [{ id: 1 }, { id: 2 }] }
 * @param data - The object or array to process
 * @param fieldsToTransform - Array of field names to transform (default: ['membershipPositions'])
 * @param format - Relation format to use: 'set' or 'connect' (default: 'set')
 * @returns A new object with specified fields transformed to Prisma relation format
 */
export function transformToSetFormat<T = any>(
  data: T,
  fieldsToTransform: string[] = ['membershipPositions'],
  format: 'set' | 'connect' = 'set',
): T {
  // Handle null or undefined
  if (data === null || data === undefined) {
    return data;
  }

  // Handle arrays - recursively process each item
  if (Array.isArray(data)) {
    return data.map((item) =>
      transformToSetFormat(item, fieldsToTransform, format),
    ) as T;
  }

  // Handle objects
  if (typeof data === 'object' && data !== null) {
    const result: any = {};

    for (const [key, value] of Object.entries(data)) {
      // Check if this field should be transformed
      if (fieldsToTransform.includes(key)) {
        // Handle array of objects -> transform to { set: [...] } or { connect: [...] }
        if (Array.isArray(value)) {
          const relationArray = value
            .map((item) => {
              if (typeof item === 'object' && item !== null && 'id' in item) {
                return { id: item.id };
              }
              return null;
            })
            .filter((item) => item !== null);

          result[key] = { [format]: relationArray };
        }
        // Handle single object -> keep as-is or transform if needed
        else if (typeof value === 'object' && value !== null && 'id' in value) {
          result[key] = { id: value.id };
        }
        // If value doesn't have an id, keep as-is
        else {
          result[key] = transformToSetFormat(value, fieldsToTransform, format);
        }
      } else {
        // Recursively process nested values
        result[key] = transformToSetFormat(value, fieldsToTransform, format);
      }
    }

    return result as T;
  }

  // Return primitive values as-is
  return data;
}
