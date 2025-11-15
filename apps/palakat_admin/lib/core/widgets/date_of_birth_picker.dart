import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable date picker widget for selecting date of birth
class DateOfBirthPicker extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final bool enabled;
  final String? errorText;

  const DateOfBirthPicker({
    super.key,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );
    
    if (picked != null && picked != value && onChanged != null) {
      onChanged!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled ? () => _selectDate(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          filled: true,
          fillColor: !enabled
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surface,
          suffixIcon: Icon(
            Icons.calendar_today,
            color: !enabled ? theme.colorScheme.onSurfaceVariant : null,
          ),
          errorText: errorText,
          errorStyle: const TextStyle(fontSize: 12),
        ),
        child: Text(
          value != null
              ? DateFormat('MMM dd, yyyy').format(value!)
              : 'Select date of birth',
          style: TextStyle(
            color: value != null
                ? theme.textTheme.bodyLarge?.color
                : theme.hintColor,
          ),
        ),
      ),
    );
  }
}
