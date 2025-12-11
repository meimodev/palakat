import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/approver.dart';
import 'package:palakat_shared/core/repositories/approver_repository.dart';
import 'package:palakat_shared/core/utils/date_utils.dart';

/// Compact approver card for displaying in table cells (wrapped layout)
class ApproverCardCompact extends ConsumerWidget {
  final Approver approver;
  final DateTime? fallbackDate;

  const ApproverCardCompact({
    super.key,
    required this.approver,
    this.fallbackDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final approverRepository = ref.watch(approverRepositoryProvider);

    final approverName = approver.membership?.account?.name ?? 'Unknown';
    final status = approver.status;
    final statusDisplay = approverRepository.getStatusDisplay(status);
    final statusColor = Color(statusDisplay.colorValue);
    final lastUpdate = approver.updatedAt ?? approver.createdAt ?? fallbackDate;
    final statusIcon = status.icon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                approverName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (lastUpdate != null) ...[
                const SizedBox(height: 1),
                Text(
                  lastUpdate.toCustomFormat("MMM dd, yyyy"),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Full-width approver card for displaying in detail views (stacked layout)
class ApproverCardFull extends ConsumerWidget {
  final Approver approver;
  final DateTime? fallbackDate;

  const ApproverCardFull({
    super.key,
    required this.approver,
    this.fallbackDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final approverRepository = ref.watch(approverRepositoryProvider);

    final approverName = approver.membership?.account?.name ?? 'Unknown';
    final status = approver.status;
    final statusDisplay = approverRepository.getStatusDisplay(status);
    final statusColor = Color(statusDisplay.colorValue);
    final lastUpdate = approver.updatedAt ?? approver.createdAt ?? fallbackDate;
    final positions = approver.membership?.membershipPositions ?? [];
    final statusIcon = status.icon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  approverName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (positions.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    direction: Axis.horizontal,
                    children: positions.map((position) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          position.name,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                if (lastUpdate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    lastUpdate.toCustomFormat("MMM dd, yyyy"),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapped display of multiple approvers (for table cells)
class ApproversWrapDisplay extends StatelessWidget {
  final List<Approver> approvers;
  final DateTime? fallbackDate;

  const ApproversWrapDisplay({
    super.key,
    required this.approvers,
    this.fallbackDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (approvers.isEmpty) {
      return Text(
        'No approvers',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      direction: Axis.vertical,
      children: approvers
          .map(
            (approver) => ApproverCardCompact(
              approver: approver,
              fallbackDate: fallbackDate,
            ),
          )
          .toList(),
    );
  }
}

/// Stacked display of multiple approvers (for detail views)
class ApproversStackDisplay extends StatelessWidget {
  final List<Approver> approvers;
  final DateTime? fallbackDate;

  const ApproversStackDisplay({
    super.key,
    required this.approvers,
    this.fallbackDate,
  });

  @override
  Widget build(BuildContext context) {
    if (approvers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: approvers
          .map(
            (approver) => ApproverCardFull(
              approver: approver,
              fallbackDate: fallbackDate,
            ),
          )
          .toList(),
    );
  }
}
