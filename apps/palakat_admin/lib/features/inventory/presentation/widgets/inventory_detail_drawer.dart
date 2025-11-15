import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/inventory/inventory.dart';

class InventoryDetailDrawer extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onClose;

  const InventoryDetailDrawer({
    super.key,
    required this.item,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SideDrawer(
      title: 'Inventory Details',
      subtitle: 'View detailed information about this item',
      onClose: onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          InfoSection(
            title: 'Basic Information',
            children: [
              InfoRow(
                label: 'Item Name',
                value: item.itemName,
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              InfoRow(
                label: 'Location',
                value: item.location,
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              InfoRow(
                label: 'Condition',
                value: item.condition.displayName,
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: _ConditionBadge(condition: item.condition),
                ),
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              InfoRow(
                label: 'Quantity',
                value: '${item.quantity}',
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Update Information
          InfoSection(
            title: 'Last Update',
            children: [
              InfoRow(
                label: 'Date',
                value: DateFormat('yyyy-MM-dd HH:mm').format(item.lastUpdate),
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              InfoRow(
                label: 'Updated By',
                value: item.updatedBy,
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              InfoRow(
                label: 'Time Ago',
                value: _formatTimeAgo(item.lastUpdate),
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Item Status
          InfoSection(
            title: 'Item Status',
            children: [_StatusCard(item: item)],
          ),
        ],
      ),
      footer: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Inventory management can be managed through mobile app',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1 day ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} days ago';
      } else {
        return 'about 1 month ago';
      }
    } else if (difference.inHours > 0) {
      return 'about ${difference.inHours} hours ago';
    } else {
      return 'just now';
    }
  }
}

class _ConditionBadge extends StatelessWidget {
  const _ConditionBadge({required this.condition});

  final InventoryCondition condition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;

    switch (condition) {
      case InventoryCondition.good:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
      case InventoryCondition.used:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
      case InventoryCondition.new_:
        backgroundColor = Colors.black;
        textColor = Colors.white;
        break;
      case InventoryCondition.notApplicable:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        condition.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final InventoryItem item;

  const _StatusCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine status based on quantity and condition
    Color backgroundColor;
    Color foregroundColor;
    IconData icon;
    String statusText;

    if (item.quantity == 0) {
      backgroundColor = Colors.red.shade50;
      foregroundColor = Colors.red.shade700;
      icon = Icons.warning;
      statusText = 'Out of Stock';
    } else if (item.quantity < 10) {
      backgroundColor = Colors.orange.shade50;
      foregroundColor = Colors.orange.shade700;
      icon = Icons.info;
      statusText = 'Low Stock';
    } else {
      backgroundColor = Colors.green.shade50;
      foregroundColor = Colors.green.shade700;
      icon = Icons.check_circle;
      statusText = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${item.quantity} items available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foregroundColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
