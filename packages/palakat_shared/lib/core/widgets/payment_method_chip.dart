import 'package:flutter/material.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/billing.dart';

/// A chip widget that displays a payment method with its icon and label
class PaymentMethodChip extends StatelessWidget {
  final PaymentMethod method;
  final double iconSize;
  final double fontSize;
  final EdgeInsets padding;

  const PaymentMethodChip({
    super.key,
    required this.method,
    this.iconSize = 18,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final icon = method.icon;
    final color = method.color;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            method.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
