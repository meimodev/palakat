import 'package:flutter/material.dart';
import 'package:palakat_admin/core/constants/enums.dart';

/// Extension to get display name for MaritalStatus enum
extension MaritalStatusExtension on MaritalStatus {
  String get displayName {
    switch (this) {
      case MaritalStatus.single:
        return 'Single';
      case MaritalStatus.married:
        return 'Married';
    }
  }
}

/// Reusable dropdown widget for selecting marital status
class MaritalStatusDropdown extends StatelessWidget {
  final MaritalStatus value;
  final ValueChanged<MaritalStatus?>? onChanged;
  final bool enabled;

  const MaritalStatusDropdown({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<MaritalStatus>(
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
      items: MaritalStatus.values.map((status) {
        return DropdownMenuItem<MaritalStatus>(
          value: status,
          child: Text(status.displayName),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
