import 'package:flutter/material.dart';

class PositionChip extends StatelessWidget {
  final String position;
  const PositionChip({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Text(
        position,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
