import 'package:flutter/material.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// Extension to get display name for Gender enum
extension GenderExtension on Gender {
  String l10n(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case Gender.male:
        return l10n.gender_male;
      case Gender.female:
        return l10n.gender_female;
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: !enabled
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
      ),
      items: Gender.values.map((gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(gender.l10n(context)),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
