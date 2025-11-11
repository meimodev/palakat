/// Result of a validation operation
sealed class ValidationResult {
  const ValidationResult();
}

/// Validation passed successfully
class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();
}

/// Validation failed with error message
class ValidationError extends ValidationResult {
  final String message;
  final String? field;
  
  const ValidationError(this.message, {this.field});
  
  @override
  String toString() => message;
}

/// Multiple validation errors
class ValidationErrors extends ValidationResult {
  final List<ValidationError> errors;
  
  const ValidationErrors(this.errors);
  
  /// Get all error messages
  List<String> get messages => errors.map((e) => e.message).toList();
  
  /// Get errors for a specific field
  List<ValidationError> getFieldErrors(String field) {
    return errors.where((e) => e.field == field).toList();
  }
  
  /// Check if there are errors for a specific field
  bool hasFieldErrors(String field) {
    return errors.any((e) => e.field == field);
  }
  
  /// Get the first error message for a field
  String? getFirstFieldError(String field) {
    final fieldErrors = getFieldErrors(field);
    return fieldErrors.isNotEmpty ? fieldErrors.first.message : null;
  }
  
  @override
  String toString() => messages.join(', ');
}

/// Extension methods for ValidationResult
extension ValidationResultExtensions on ValidationResult {
  /// Check if validation was successful
  bool get isValid => this is ValidationSuccess;
  
  /// Check if validation failed
  bool get isInvalid => !isValid;
  
  /// Get error message if validation failed
  String? get errorMessage {
    return switch (this) {
      ValidationError error => error.message,
      ValidationErrors errors => errors.messages.join(', '),
      ValidationSuccess _ => null,
    };
  }
  
  /// Get all error messages
  List<String> get errorMessages {
    return switch (this) {
      ValidationError error => [error.message],
      ValidationErrors errors => errors.messages,
      ValidationSuccess _ => [],
    };
  }
}
