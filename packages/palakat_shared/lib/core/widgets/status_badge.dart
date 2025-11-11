import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String tooltip;

  const StatusBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
