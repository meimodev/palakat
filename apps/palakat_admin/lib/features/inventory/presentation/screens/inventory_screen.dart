import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(48),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Soon you will be able to:',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _BulletPoint('Manage inventory across congregation'),
                    _BulletPoint('Centralize data and tracking'),
                    _BulletPoint('Monitor item location'),
                    _BulletPoint('Assign responsibility for items'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
