typedef StringValidationCallback = String? Function(String? value);

typedef Action<T> = Function(T builder);

class ValidationBuilder {
  ValidationBuilder({
    required this.label,
  });

  final String label;
  final List<StringValidationCallback> validations = [];

  final RegExp _defaultEmailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9\-\_]+(\.[a-zA-Z]+)*$");

  /// Clears validation list
  ValidationBuilder reset() {
    validations.clear();
    return this;
  }

  /// Adds new item to [validations] list, returns this instance
  ValidationBuilder add(StringValidationCallback validator) {
    validations.add(validator);
    return this;
  }

  /// Tests [value] against defined [validations]
  String? test(String? value) {
    for (var validate in validations) {
      // Otherwise execute validations
      final result = validate(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Returns a validator function for FormInput
  StringValidationCallback build() => test;

  /// Throws error only if [left] and [right] validators throw error same time.
  /// If [reverse] is true left builder's error will be displayed otherwise
  /// right builder's error. Because this is default behaviour on most of the
  /// programming languages.
  ValidationBuilder or(
    Action<ValidationBuilder> left,
    Action<ValidationBuilder> right, {
    bool reverse = false,
  }) {
    // Create
    final v1 = ValidationBuilder(label: label);
    final v2 = ValidationBuilder(label: label);

    // Configure
    left(v1);
    right(v2);

    // Build
    final v1cb = v1.build();
    final v2cb = v2.build();

    // Test
    return add((value) {
      final leftResult = v1cb(value);
      if (leftResult == null) {
        return null;
      }
      final rightResult = v2cb(value);
      if (rightResult == null) {
        return null;
      }
      return reverse == true ? leftResult : rightResult;
    });
  }

  static const String validationRequiredMessage = 'Cannot be empty';
  static const String validationMinLengthMessage = 'Cannot be less than';
  static const String validationMaxLengthMessage = 'Cannot be more than';
  static const String validationEmailMessage = 'Email not valid';
  static const String validationIdenticalMessage = 'Field Must be the same';

  /// Value must not be null
  ValidationBuilder required([String? message]) => add((v) =>
      v == null || v.isEmpty ? message ?? validationRequiredMessage : null);

  /// Value length must be greater than or equal to [minLength]
  ValidationBuilder minLength(int minLength, [String? message]) =>
      add((v) => v!.length < minLength
          ? message ?? "$validationMinLengthMessage $minLength"
          : null);

  /// Value length must be less than or equal to [maxLength]
  ValidationBuilder maxLength(int maxLength, [String? message]) =>
      add((v) => v!.length > maxLength
          ? message ?? "$validationMaxLengthMessage $maxLength"
          : null);

  /// Value must match [regExp]
  ValidationBuilder regExp(RegExp regExp, String message) =>
      add((v) => regExp.hasMatch(v!) ? null : message);

  /// Value must be a well formatted email
  ValidationBuilder email([String? message]) => add(
        (v) => _defaultEmailRegExp.hasMatch(v!)
            ? null
            : message ?? validationEmailMessage,
      );

  /// Value must be same value
  ValidationBuilder same(String? compare, [String? message]) => add(
        (v) => v != compare
            ? message ?? validationIdenticalMessage
            : null,
      );

// ADD ANOTHER VALIDATION HERE
}
