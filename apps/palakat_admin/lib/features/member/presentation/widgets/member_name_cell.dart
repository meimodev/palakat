import 'package:flutter/material.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

/// Widget for displaying member name with status badges in table cells
/// Shows name, column, and badges for baptized, sidi, and app linked status
class MemberNameCell extends StatelessWidget {
  final Account account;

  const MemberNameCell({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membership = account.membership;
    final column = membership?.column;
    final isBaptized = membership?.baptize ?? false;
    final isSidi = membership?.sidi ?? false;
    final isLinked = account.claimed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: SelectableText(
                account.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBaptized)
                  StatusBadge(
                    icon: Icons.water_drop,
                    color: Colors.blue.shade600,
                    backgroundColor: Colors.blue.shade50,
                    tooltip: context.l10n.tooltip_baptized,
                  ),
                if (isSidi)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: StatusBadge(
                      icon: Icons.emoji_people,
                      color: Colors.green.shade600,
                      backgroundColor: Colors.green.shade50,
                      tooltip: context.l10n.tooltip_sidi,
                    ),
                  ),
                if (isLinked)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: StatusBadge(
                      icon: Icons.phone_android,
                      color: Colors.purple.shade600,
                      backgroundColor: Colors.purple.shade50,
                      tooltip: context.l10n.tooltip_appLinked,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        SelectableText(
          column?.name ?? '',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
