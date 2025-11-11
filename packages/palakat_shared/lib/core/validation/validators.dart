import 'validation_result.dart';

/// Type definition for validator functions
typedef Validator<T> = ValidationResult Function(T? value);

/// Collection of common validators for form inputs
class Validators {
  Validators._();

  /// Validator that requires a non-null, non-empty value
  static Validator<String> required([String? message]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return ValidationError(message ?? 'This field is required');
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks minimum length
  static Validator<String> minLength(int minLength, [String? message]) {
    return (String? value) {
      if (value != null && value.length < minLength) {
        return ValidationError(
          message ?? 'Must be at least $minLength characters long',
        );
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks maximum length
  static Validator<String> maxLength(int maxLength, [String? message]) {
    return (String? value) {
      if (value != null && value.length > maxLength) {
        return ValidationError(
          message ?? 'Must be no more than $maxLength characters long',
        );
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks email format
  static Validator<String> email([String? message]) {
    return (String? value) {
      if (value != null && value.isNotEmpty) {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return ValidationError(message ?? 'Please enter a valid email address');
        }
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks phone number format
  static Validator<String> phoneNumber([String? message]) {
    return (String? value) {
      if (value != null && value.isNotEmpty) {
        final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
        if (!phoneRegex.hasMatch(value)) {
          return ValidationError(message ?? 'Please enter a valid phone number');
        }
      }
      return const ValidationSuccess();
    };
  }

  /// Optional phone validator that enforces a minimum number of digits when provided
  static Validator<String> optionalPhoneMinDigits(int minDigits, [String? message]) {
    return (String? value) {
      final raw = (value ?? '').trim();
      if (raw.isEmpty) return const ValidationSuccess();
      final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length < minDigits) {
        return ValidationError(
          message ?? 'Phone number must contain at least $minDigits digits',
        );
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks numeric values
  static Validator<String> numeric([String? message]) {
    return (String? value) {
      if (value != null && value.isNotEmpty) {
        if (double.tryParse(value) == null) {
          return ValidationError(message ?? 'Please enter a valid number');
        }
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks minimum numeric value
  static Validator<String> minValue(double minValue, [String? message]) {
    return (String? value) {
      if (value != null && value.isNotEmpty) {
        final numValue = double.tryParse(value);
        if (numValue != null && numValue < minValue) {
          return ValidationError(
            message ?? 'Value must be at least $minValue',
          );
        }
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks maximum numeric value
  static Validator<String> maxValue(double maxValue, [String? message]) {
    return (String? value) {
      if (value != null && value.isNotEmpty) {
        final numValue = double.tryParse(value);
        if (numValue != null && numValue > maxValue) {
          return ValidationError(
            message ?? 'Value must be no more than $maxValue',
          );
        }
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that uses a custom pattern (regex)
  static Validator<String> pattern(RegExp pattern, [String? message]) {
    return (String? value) {
      if (value != null && value.isNotEmpty) {
        if (!pattern.hasMatch(value)) {
          return ValidationError(message ?? 'Invalid format');
        }
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks if value matches another value (e.g., password confirmation)
  static Validator<String> matches(String otherValue, [String? message]) {
    return (String? value) {
      if (value != otherValue) {
        return ValidationError(message ?? 'Values do not match');
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks if value is in a list of allowed values
  static Validator<String> oneOf(List<String> allowedValues, [String? message]) {
    return (String? value) {
      if (value != null && !allowedValues.contains(value)) {
        return ValidationError(
          message ?? 'Please select a valid option',
        );
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks date format and validity
  static Validator<String> date([String? message]) {
    return (String? value) {
      if (value != null && value.isNotEmpty) {
        try {
          DateTime.parse(value);
        } catch (e) {
          return ValidationError(message ?? 'Please enter a valid date');
        }
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks if date is in the future
  static Validator<String> futureDate([String? message]) {
    return (String? value) {
      if (value != null && value.isNotEmpty) {
        try {
          final date = DateTime.parse(value);
          if (date.isBefore(DateTime.now())) {
            return ValidationError(message ?? 'Date must be in the future');
          }
        } catch (e) {
          return ValidationError('Please enter a valid date');
        }
      }
      return const ValidationSuccess();
    };
  }

  /// Validator that checks if date is in the past
  static Validator<String> pastDate([String? message]) {
    return (String? value) {
      if (value != null && value.isNotEmpty) {
        try {
          final date = DateTime.parse(value);
          if (date.isAfter(DateTime.now())) {
            return ValidationError(message ?? 'Date must be in the past');
          }
        } catch (e) {
          return ValidationError('Please enter a valid date');
        }
      }
      return const ValidationSuccess();
    };
  }

  /// Combines multiple validators into one
  static Validator<T> combine<T>(List<Validator<T>> validators) {
    return (T? value) {
      final errors = <ValidationError>[];
      
      for (final validator in validators) {
        final result = validator(value);
        if (result is ValidationError) {
          errors.add(result);
        } else if (result is ValidationErrors) {
          errors.addAll(result.errors);
        }
      }
      
      if (errors.isEmpty) {
        return const ValidationSuccess();
      } else if (errors.length == 1) {
        return errors.first;
      } else {
        return ValidationErrors(errors);
      }
    };
  }

  /// Conditional validator - only validates if condition is true
  static Validator<T> when<T>(bool condition, Validator<T> validator) {
    return (T? value) {
      if (condition) {
        return validator(value);
      }
      return const ValidationSuccess();
    };
  }
}

/// Adapter to convert a Validators.Validator into Flutter's FormFieldValidator
extension FlutterFormValidator on Validator<String> {
  String? asFormFieldValidator(String? value) {
    final res = this(value);
    return res.errorMessage;
  }
}

/// Authentication-specific validators
class AuthValidators {
  AuthValidators._();

  /// Accepts either a valid email or a local phone (digits only, 12-13 digits)
  static Validator<String> identifier([String? message]) {
    return Validators.combine<String>([
      Validators.required('Please enter your email or phone number'),
      (v) {
        final value = (v ?? '').trim();
        final isEmail = Validators.email().isValidFor(value);
        final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
        final isLocalPhone = RegExp(r'^[0-9]{12,13}$').hasMatch(digitsOnly);
        if (isEmail || isLocalPhone) return const ValidationSuccess();
        return ValidationError(message ?? 'Enter a valid email address or phone number');
      },
    ]);
  }
}

/// Small helper so we can reuse Validators.* in custom lambdas above
extension _ValidatorUtils on Validator<String> {
  bool isValidFor(String? value) => this(value).isValid;
}

/// Church-specific validators
class ChurchValidators {
  ChurchValidators._();

  /// Validator for member ID format
  static Validator<String> memberId([String? message]) {
    return Validators.pattern(
      RegExp(r'^MEM-\d{4,}$'),
      message ?? 'Member ID must be in format MEM-XXXX',
    );
  }

  /// Validator for activity ID format
  static Validator<String> activityId([String? message]) {
    return Validators.pattern(
      RegExp(r'^ACT-\d{4,}$'),
      message ?? 'Activity ID must be in format ACT-XXXX',
    );
  }

  /// Validator for donation amount
  static Validator<String> donationAmount([String? message]) {
    return Validators.combine([
      Validators.required('Donation amount is required'),
      Validators.numeric('Please enter a valid amount'),
      Validators.minValue(0.01, 'Donation amount must be greater than 0'),
    ]);
  }

  /// Validator for church name
  static Validator<String> churchName([String? message]) {
    return Validators.combine([
      Validators.required('Church name is required'),
      Validators.minLength(2, 'Church name must be at least 2 characters'),
      Validators.maxLength(100, 'Church name must be no more than 100 characters'),
    ]);
  }

  /// Validator for pastor name
  static Validator<String> pastorName([String? message]) {
    return Validators.combine([
      Validators.required('Pastor name is required'),
      Validators.minLength(2, 'Pastor name must be at least 2 characters'),
      Validators.maxLength(50, 'Pastor name must be no more than 50 characters'),
    ]);
  }

  /// Validator for column name
  static Validator<String> columnName([String? message]) {
    return Validators.combine([
      Validators.required('Column name is required'),
      Validators.minLength(3, 'Minimum 3 characters'),
      Validators.maxLength(20, 'Maximum 20 characters'),
      (v) {
        final value = (v ?? '').trim();
        if (!RegExp(r'^[A-Za-z]').hasMatch(value)) {
          return const ValidationError('Must start with a letter');
        }
        if (!RegExp(r'^[A-Za-z0-9 ]+$').hasMatch(value)) {
          return const ValidationError('Only letters and numbers are allowed');
        }
        return const ValidationSuccess();
      },
    ]);
  }

  /// Validator for position name
  static Validator<String> positionName([String? message]) {
    return Validators.combine([
      Validators.required('Position name is required'),
      Validators.minLength(3, 'Minimum 3 characters'),
      Validators.maxLength(20, 'Maximum 20 characters'),
      (v) {
        final value = (v ?? '').trim();
        if (!RegExp(r'^[A-Za-z]').hasMatch(value)) {
          return const ValidationError('Must start with a letter');
        }
        if (!RegExp(r'^[A-Za-z0-9 ]+$').hasMatch(value)) {
          return const ValidationError('Only letters and numbers are allowed');
        }
        return const ValidationSuccess();
      },
    ]);
  }

  /// Validator for address (required, non-empty)
  static Validator<String> address([String? message]) {
    return Validators.required(message ?? 'Address is required');
  }

  /// Validator for latitude: required, numeric, range -90..90
  static Validator<String> latitude([String? message]) {
    return Validators.combine([
      Validators.required('Latitude is required'),
      Validators.numeric('Latitude must be a number'),
      (v) {
        final d = double.tryParse((v ?? '').trim());
        if (d == null) return const ValidationError('Latitude must be a number');
        if (d < -90 || d > 90) return const ValidationError('Latitude must be between -90 and 90');
        return const ValidationSuccess();
      },
    ]);
  }

  /// Validator for longitude: required, numeric, range -180..180
  static Validator<String> longitude([String? message]) {
    return Validators.combine([
      Validators.required('Longitude is required'),
      Validators.numeric('Longitude must be a number'),
      (v) {
        final d = double.tryParse((v ?? '').trim());
        if (d == null) return const ValidationError('Longitude must be a number');
        if (d < -180 || d > 180) return const ValidationError('Longitude must be between -180 and 180');
        return const ValidationSuccess();
      },
    ]);
  }
}
