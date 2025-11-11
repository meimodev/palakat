import 'package:flutter/material.dart';

class InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double titleSpacing;
  final Widget? trailing;
  final Widget? action;

  const InfoSection({
    super.key,
    required this.title,
    required this.children,
    this.titleSpacing = 12,
    this.trailing,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 8),
                  action!,
                ],
              ],
            ),
            if (trailing != null) trailing!,
          ],
        ),
        SizedBox(height: titleSpacing),
        ...children,
      ],
    );
  }
}

class LabeledField extends StatelessWidget {
  final String? label;
  final Widget child;

  const LabeledField({super.key,  this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;
  final bool isMultiline;
  final double labelWidth;
  final double spacing;
  final EdgeInsets? contentPadding;
  final TextStyle? valueStyle;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.isMultiline = false,
    this.labelWidth = 120,
    this.spacing = 16,
    this.contentPadding,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: valueWidget ??
                Text(
                  value,
                  style: valueStyle ?? theme.textTheme.bodyMedium,
                ),
          ),
        ],
      ),
    );
  }
}
