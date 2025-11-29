import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

/// A widget for selecting payment method (CASH or CASHLESS).
/// Displays options as selectable cards with visual feedback.
/// Requirements: 2.4, 3.4
class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.label,
    required this.onSelected,
    this.selectedMethod,
    this.errorText,
  });

  final String label;
  final PaymentMethod? selectedMethod;
  final String? errorText;
  final void Function(PaymentMethod? method) onSelected;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BaseTypography.titleMedium.copyWith(
            color: BaseColor.neutral[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.h8,
        // Payment method options
        Row(
          children: [
            Expanded(
              child: _PaymentMethodCard(
                method: PaymentMethod.cash,
                isSelected: selectedMethod == PaymentMethod.cash,
                onTap: () => onSelected(PaymentMethod.cash),
              ),
            ),
            Gap.w12,
            Expanded(
              child: _PaymentMethodCard(
                method: PaymentMethod.cashless,
                isSelected: selectedMethod == PaymentMethod.cashless,
                onTap: () => onSelected(PaymentMethod.cashless),
              ),
            ),
          ],
        ),
        // Error message
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: BaseSize.customHeight(3)),
            child: Text(
              errorText!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: BaseTypography.bodySmall.copyWith(color: BaseColor.error),
            ),
          ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final config = _getMethodConfig();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(BaseSize.w12),
        decoration: BoxDecoration(
          color: isSelected ? config.selectedBgColor : BaseColor.white,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(
            color: isSelected
                ? config.selectedBorderColor
                : BaseColor.neutral[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: config.selectedBorderColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Icon
            Container(
              width: BaseSize.w40,
              height: BaseSize.w40,
              decoration: BoxDecoration(
                color: isSelected ? config.iconBgColor : BaseColor.neutral[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                size: BaseSize.w20,
                color: isSelected ? config.iconColor : BaseColor.neutral[500],
              ),
            ),
            Gap.h8,
            // Label
            Text(
              config.label,
              style: BaseTypography.bodyMedium.copyWith(
                color: isSelected ? config.textColor : BaseColor.neutral[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            Gap.h4,
            // Description
            Text(
              config.description,
              style: BaseTypography.bodySmall.copyWith(
                color: isSelected
                    ? config.textColor.withValues(alpha: 0.8)
                    : BaseColor.neutral[500],
              ),
              textAlign: TextAlign.center,
            ),
            // Selected indicator
            if (isSelected) ...[
              Gap.h8,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w8,
                  vertical: BaseSize.h4,
                ),
                decoration: BoxDecoration(
                  color: config.selectedBorderColor,
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: BaseSize.w12,
                      color: Colors.white,
                    ),
                    Gap.w4,
                    Text(
                      'Selected',
                      style: BaseTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _PaymentMethodConfig _getMethodConfig() {
    switch (method) {
      case PaymentMethod.cash:
        return _PaymentMethodConfig(
          icon: Icons.payments_outlined,
          label: 'Cash',
          description: 'Physical currency',
          selectedBgColor: BaseColor.teal[50]!,
          selectedBorderColor: BaseColor.teal[500]!,
          iconBgColor: BaseColor.teal[100]!,
          iconColor: BaseColor.teal[600]!,
          textColor: BaseColor.teal[700]!,
        );
      case PaymentMethod.cashless:
        return _PaymentMethodConfig(
          icon: Icons.credit_card_outlined,
          label: 'Cashless',
          description: 'Digital payment',
          selectedBgColor: BaseColor.blue[50]!,
          selectedBorderColor: BaseColor.blue[500]!,
          iconBgColor: BaseColor.blue[100]!,
          iconColor: BaseColor.blue[600]!,
          textColor: BaseColor.blue[700]!,
        );
    }
  }
}

class _PaymentMethodConfig {
  final IconData icon;
  final String label;
  final String description;
  final Color selectedBgColor;
  final Color selectedBorderColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color textColor;

  _PaymentMethodConfig({
    required this.icon,
    required this.label,
    required this.description,
    required this.selectedBgColor,
    required this.selectedBorderColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.textColor,
  });
}

/// Extension to get display name for PaymentMethod enum.
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.cashless:
        return 'Cashless';
    }
  }
}
