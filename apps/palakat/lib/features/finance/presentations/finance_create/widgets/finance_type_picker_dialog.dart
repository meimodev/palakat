import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/models.dart' hide Column;

/// Shows a dialog for selecting finance type (Revenue or Expense).
/// Returns the selected [FinanceType] or null if dismissed.
/// Requirements: 1.2
Future<FinanceType?> showFinanceTypePickerDialog({
  required BuildContext context,
}) {
  return showDialogCustomWidget<FinanceType?>(
    context: context,
    title: 'Select Finance Type',
    content: const _FinanceTypePickerContent(),
  );
}

class _FinanceTypePickerContent extends StatelessWidget {
  const _FinanceTypePickerContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Revenue option
        _FinanceTypeCard(
          financeType: FinanceType.revenue,
          onTap: () => context.pop<FinanceType>(FinanceType.revenue),
        ),
        Gap.h12,
        // Expense option
        _FinanceTypeCard(
          financeType: FinanceType.expense,
          onTap: () => context.pop<FinanceType>(FinanceType.expense),
        ),
      ],
    );
  }
}

/// Card widget for displaying a finance type option.
class _FinanceTypeCard extends StatelessWidget {
  const _FinanceTypeCard({required this.financeType, required this.onTap});

  final FinanceType financeType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: Container(
        padding: EdgeInsets.all(BaseSize.w16),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(color: config.borderColor),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: BaseSize.w48,
              height: BaseSize.w48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: config.iconBackgroundColor,
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: FaIcon(
                financeType.icon,
                size: BaseSize.w24,
                color: config.iconColor,
              ),
            ),
            Gap.w16,
            // Label and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    financeType.displayName,
                    style: BaseTypography.titleMedium.copyWith(
                      color: config.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    config.description,
                    style: BaseTypography.bodySmall.copyWith(
                      color: config.descriptionColor,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            FaIcon(
              AppIcons.forward,
              size: BaseSize.w24,
              color: config.chevronColor,
            ),
          ],
        ),
      ),
    );
  }

  _FinanceTypeConfig _getConfig() {
    switch (financeType) {
      case FinanceType.revenue:
        return _FinanceTypeConfig(
          description: 'Record income from church activities',
          backgroundColor: BaseColor.teal[50]!,
          borderColor: BaseColor.teal[200]!,
          iconBackgroundColor: BaseColor.teal[100]!,
          iconColor: BaseColor.teal[600]!,
          textColor: BaseColor.teal[800]!,
          descriptionColor: BaseColor.teal[600]!,
          chevronColor: BaseColor.teal[400]!,
        );
      case FinanceType.expense:
        return _FinanceTypeConfig(
          description: 'Record expenditure for church activities',
          backgroundColor: BaseColor.red[50]!,
          borderColor: BaseColor.red[200]!,
          iconBackgroundColor: BaseColor.red[100]!,
          iconColor: BaseColor.red[600]!,
          textColor: BaseColor.red[800]!,
          descriptionColor: BaseColor.red[600]!,
          chevronColor: BaseColor.red[400]!,
        );
    }
  }
}

class _FinanceTypeConfig {
  final String description;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color descriptionColor;
  final Color chevronColor;

  _FinanceTypeConfig({
    required this.description,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.descriptionColor,
    required this.chevronColor,
  });
}
