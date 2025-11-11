extension MapExtension on Map<String, dynamic> {
  /// Returns a new map containing only the fields that have changed
  /// compared to [original]. Removes fields with identical values.
  /// Supports deep comparison of nested maps and lists with recursive stripping.
  /// Automatically removes 'updatedAt' and 'createdAt' fields at any nesting level.
  /// 
  /// Behavior:
  /// - Only includes fields present in the current map (not fields only in original)
  /// - Includes new fields (present in current but not in original)
  /// - Includes changed fields (different values between current and original)
  /// - Excludes unchanged fields (identical values)
  /// - Excludes removed fields (present in original but not in current)
  /// - Excludes timestamp fields (updatedAt, createdAt) at all levels
  /// - For nested objects, recursively strips unchanged fields even if parent differs
  Map<String, dynamic> stripUnchangedFields(Map<String, dynamic> original) {
    final result = <String, dynamic>{};
    
    for (final entry in entries) {
      final key = entry.key;
      final newValue = entry.value;
      final originalValue = original[key];

      // Skip 'updatedAt' and 'createdAt' fields at any level
      if (key == 'updatedAt' || key == 'createdAt') {
        continue;
      }

      // Include the field if:
      // 1. It doesn't exist in original
      if (!original.containsKey(key)) {
        result[key] = _removeTimestampFields(newValue);
        continue;
      }
      
      // 2. The value has changed
      // For nested maps, recursively strip unchanged fields
      if (newValue is Map<String, dynamic> && originalValue is Map<String, dynamic>) {
        final nestedChanges = newValue.stripUnchangedFields(originalValue);
        if (nestedChanges.isNotEmpty) {
          result[key] = nestedChanges;
        }
      } else if (!_deepEquals(newValue, originalValue)) {
        result[key] = _removeTimestampFields(newValue);
      }
    }
    
    return result;
  }

  /// Removes all 'updatedAt' and 'createdAt' timestamp fields from the map
  /// at any nesting level (surface, nested maps, and lists).
  /// 
  /// This is useful for cleaning data before sending to API endpoints
  /// that don't accept or need timestamp fields.
  /// 
  /// Example:
  /// ```dart
  /// final data = {
  ///   'name': 'John',
  ///   'createdAt': '2025-01-01',
  ///   'profile': {
  ///     'bio': 'Developer',
  ///     'updatedAt': '2025-01-02',
  ///   }
  /// };
  /// final cleaned = data.stripTimestampFields();
  /// // Result: {'name': 'John', 'profile': {'bio': 'Developer'}}
  /// ```
  Map<String, dynamic> stripTimestampFields() {
    return _removeTimestampFields(this) as Map<String, dynamic>;
  }

  /// Recursively removes 'updatedAt' and 'createdAt' keys from nested structures
  dynamic _removeTimestampFields(dynamic value) {
    if (value is Map<String, dynamic>) {
      final cleaned = <String, dynamic>{};
      for (final entry in value.entries) {
        if (entry.key != 'updatedAt' && entry.key != 'createdAt') {
          cleaned[entry.key] = _removeTimestampFields(entry.value);
        }
      }
      return cleaned;
    } else if (value is List) {
      return value.map((item) => _removeTimestampFields(item)).toList();
    }
    return value;
  }
  
  /// Deep equality comparison for nested structures
  bool _deepEquals(dynamic value1, dynamic value2) {
    // Both null or same reference
    if (identical(value1, value2)) return true;
    
    // One is null, the other isn't
    if (value1 == null || value2 == null) return false;
    
    // Both are maps - recursively compare
    if (value1 is Map<String, dynamic> && value2 is Map<String, dynamic>) {
      if (value1.length != value2.length) return false;
      
      for (final key in value1.keys) {
        if (!value2.containsKey(key)) return false;
        if (!_deepEquals(value1[key], value2[key])) return false;
      }
      return true;
    }
    
    // Both are lists - compare element by element
    if (value1 is List && value2 is List) {
      if (value1.length != value2.length) return false;
      
      for (var i = 0; i < value1.length; i++) {
        if (!_deepEquals(value1[i], value2[i])) return false;
      }
      return true;
    }
    
    // Primitive values - direct comparison
    return value1 == value2;
  }
}
