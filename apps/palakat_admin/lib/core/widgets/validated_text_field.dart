import 'package:flutter/material.dart';
import '../validation/validation_result.dart';
import '../validation/validators.dart';

/// A text field widget with built-in validation support
class ValidatedTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final List<Validator<String>> validators;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool validateOnChange;
  final bool showValidationIcon;

  const ValidatedTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.validators = const [],
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.focusNode,
    this.validateOnChange = true,
    this.showValidationIcon = true,
  });

  @override
  State<ValidatedTextField> createState() => ValidatedTextFieldState();
}

class ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  ValidationResult _validationResult = const ValidationSuccess();
  bool _hasBeenFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.validateOnChange && _hasBeenFocused) {
      _validate();
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && !_hasBeenFocused) {
      _hasBeenFocused = true;
    }
    if (!_focusNode.hasFocus && _hasBeenFocused) {
      _validate();
    }
  }

  void _validate() {
    if (widget.validators.isEmpty) return;

    final combinedValidator = Validators.combine(widget.validators);
    final result = combinedValidator(_controller.text);
    
    if (mounted) {
      setState(() {
        _validationResult = result;
      });
    }
  }

  /// Validate the field and return the result
  ValidationResult validate() {
    _validate();
    return _validationResult;
  }

  /// Get the current value
  String get value => _controller.text;

  /// Clear the field
  void clear() {
    _controller.clear();
    setState(() {
      _validationResult = const ValidationSuccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _validationResult.isInvalid;
    
    Widget? suffixIcon = widget.suffixIcon;
    if (widget.showValidationIcon && _hasBeenFocused) {
      if (hasError) {
        suffixIcon = Icon(
          Icons.error_outline,
          color: theme.colorScheme.error,
        );
      } else if (_controller.text.isNotEmpty) {
        suffixIcon = Icon(
          Icons.check_circle_outline,
          color: theme.colorScheme.primary,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: suffixIcon,
            errorText: hasError ? _validationResult.errorMessage : null,
            border: const OutlineInputBorder(),
            enabled: widget.enabled,
          ),
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onSubmitted: widget.onSubmitted,
        ),
      ],
    );
  }
}

/// A dropdown field widget with built-in validation support
class ValidatedDropdownField<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final List<Validator<T>> validators;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final Widget? prefixIcon;

  const ValidatedDropdownField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    required this.items,
    this.validators = const [],
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<ValidatedDropdownField<T>> createState() => ValidatedDropdownFieldState<T>();
}

class ValidatedDropdownFieldState<T> extends State<ValidatedDropdownField<T>> {
  T? _value;
  ValidationResult _validationResult = const ValidationSuccess();
  bool _hasBeenTouched = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _validate() {
    if (widget.validators.isEmpty) return;

    final combinedValidator = Validators.combine(widget.validators);
    final result = combinedValidator(_value);
    
    if (mounted) {
      setState(() {
        _validationResult = result;
      });
    }
  }

  /// Validate the field and return the result
  ValidationResult validate() {
    _validate();
    return _validationResult;
  }

  /// Get the current value
  T? get value => _value;

  @override
  Widget build(BuildContext context) {
    final hasError = _validationResult.isInvalid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<T>(
          value: _value,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            errorText: hasError ? _validationResult.errorMessage : null,
            border: const OutlineInputBorder(),
            enabled: widget.enabled,
          ),
          items: widget.items,
          onChanged: widget.enabled ? (T? newValue) {
            setState(() {
              _value = newValue;
              _hasBeenTouched = true;
            });
            if (_hasBeenTouched) {
              _validate();
            }
            widget.onChanged?.call(newValue);
          } : null,
        ),
      ],
    );
  }
}

/// A form widget that manages validation for multiple fields
class ValidatedForm extends StatefulWidget {
  final Widget child;
  final VoidCallback? onValidationChanged;

  const ValidatedForm({
    super.key,
    required this.child,
    this.onValidationChanged,
  });

  @override
  State<ValidatedForm> createState() => ValidatedFormState();
}

class ValidatedFormState extends State<ValidatedForm> {
  final List<GlobalKey<ValidatedTextFieldState>> _textFieldKeys = [];
  final List<GlobalKey<ValidatedDropdownFieldState>> _dropdownKeys = [];

  /// Register a text field for validation
  void registerTextField(GlobalKey<ValidatedTextFieldState> key) {
    _textFieldKeys.add(key);
  }

  /// Register a dropdown field for validation
  void registerDropdownField(GlobalKey<ValidatedDropdownFieldState> key) {
    _dropdownKeys.add(key);
  }

  /// Validate all fields in the form
  bool validateAll() {
    bool isValid = true;
    
    for (final key in _textFieldKeys) {
      final result = key.currentState?.validate();
      if (result?.isInvalid == true) {
        isValid = false;
      }
    }
    
    for (final key in _dropdownKeys) {
      final result = key.currentState?.validate();
      if (result?.isInvalid == true) {
        isValid = false;
      }
    }
    
    widget.onValidationChanged?.call();
    return isValid;
  }

  /// Clear all fields in the form
  void clearAll() {
    for (final key in _textFieldKeys) {
      key.currentState?.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
