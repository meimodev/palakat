import 'package:flutter/material.dart';

class TypeChip extends StatelessWidget {
  final String label;

  const TypeChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(label, style: theme.textTheme.labelMedium),
    );
  }
}
