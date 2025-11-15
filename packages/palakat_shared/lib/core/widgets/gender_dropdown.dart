import 'package:flutter/material.dart';
import 'package:palakat_shared/core/constants/enums.dart';

/// Extension to get display name for Gender enum
extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }
}

/// Reusable dropdown widget for selecting gender
class GenderDropdown extends StatelessWidget {
  final Gender value;
  final ValueChanged<Gender?>? onChanged;
  final bool enabled;

  const GenderDropdown({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<Gender>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: !enabled
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
      ),
      items: Gender.values.map((gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(gender.displayName),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
