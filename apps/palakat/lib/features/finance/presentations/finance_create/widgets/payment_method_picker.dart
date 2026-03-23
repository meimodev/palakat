import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';

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
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColors.neutral,
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
            padding: EdgeInsets.only(top: 3),
            child: Text(
              errorText!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.error),
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
    final l10n = context.l10n;
    final config = _getMethodConfig(l10n);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? config.selectedBgColor : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected
                ? config.selectedBorderColor
                : AppColors.neutral,
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
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isSelected ? config.iconBgColor : AppColors.neutral,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? config.selectedBorderColor.withValues(alpha: 0.24)
                      : AppColors.ghostBorder(0.08),
                ),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
              ),
              alignment: Alignment.center,
              child: FaIcon(
                config.icon,
                size: 20.0,
                color: isSelected ? config.iconColor : AppColors.neutral,
              ),
            ),
            Gap.h8,
            // Label
            Text(
              config.label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isSelected ? config.textColor : AppColors.neutral,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            Gap.h4,
            // Description
            Text(
              config.description,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isSelected
                    ? config.textColor.withValues(alpha: 0.8)
                    : AppColors.neutral,
              ),
              textAlign: TextAlign.center,
            ),
            // Selected indicator
            if (isSelected) ...[
              Gap.h8,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: config.selectedBorderColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      AppIcons.successSolid,
                      size: 12.0,
                      color: AppColors.surfaceContainerLowest,
                    ),
                    Gap.w4,
                    Text(
                      l10n.lbl_selected,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.surfaceContainerLowest,
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

  _PaymentMethodConfig _getMethodConfig(AppLocalizations l10n) {
    switch (method) {
      case PaymentMethod.cash:
        return _PaymentMethodConfig(
          icon: AppIcons.cash,
          label: l10n.paymentMethod_cash,
          description: l10n.paymentMethod_cash_desc,
          selectedBgColor: AppColors.secondary,
          selectedBorderColor: AppColors.secondary,
          iconBgColor: AppColors.secondary,
          iconColor: AppColors.secondary,
          textColor: AppColors.secondary,
        );
      case PaymentMethod.cashless:
        return _PaymentMethodConfig(
          icon: AppIcons.payment,
          label: l10n.paymentMethod_cashless,
          description: l10n.paymentMethod_cashless_desc,
          selectedBgColor: AppColors.primary,
          selectedBorderColor: AppColors.primary,
          iconBgColor: AppColors.primary,
          iconColor: AppColors.primary,
          textColor: AppColors.primary,
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
  AppLocalizations _l10n() {
    final localeName = intl.Intl.getCurrentLocale();
    final languageCode = localeName.split(RegExp('[_-]')).first;
    return lookupAppLocalizations(
      Locale(languageCode.isEmpty ? 'en' : languageCode),
    );
  }

  String get displayName {
    final l10n = _l10n();
    switch (this) {
      case PaymentMethod.cash:
        return l10n.paymentMethod_cash;
      case PaymentMethod.cashless:
        return l10n.paymentMethod_cashless;
    }
  }
}
