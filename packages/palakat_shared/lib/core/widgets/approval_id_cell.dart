import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApprovalIdCell extends StatelessWidget {
  final DateTime? approvedAt;
  final String approvalId;
  const ApprovalIdCell({
    super.key,
    required this.approvedAt,
    required this.approvalId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Text(
            approvalId,
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          approvedAt != null ? DateFormat('y-MM-dd').format(approvedAt!) : '—',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
