import 'package:flutter/material.dart';
import 'package:palakat_admin/core/widgets/position_chip.dart';

class PositionsCell extends StatelessWidget {
  final List<String> positions;
  const PositionsCell({super.key, required this.positions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (positions.isEmpty) return const Text('-');

    final firstPosition = positions.first;
    final remainingCount = positions.length - 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PositionChip(position: firstPosition),
        if (remainingCount > 0) ...[
          const SizedBox(width: 6),
          Text(
            '+$remainingCount',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
