import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/models.dart' hide Column;

/// Shows a dialog for selecting finance type (Revenue or Expense).
/// Returns the selected [FinanceType] or null if dismissed.
/// Requirements: 1.2
Future<FinanceType?> showFinanceTypePickerDialog({
  required BuildContext context,
}) {
  return showDialogCustomWidget<FinanceType?>(
    context: context,
    title: context.l10n.dlg_selectFinanceType_title,
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
    final config = _getConfig(context);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        side: BorderSide(color: config.borderColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: config.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  ),
                  child: FaIcon(
                    financeType.icon,
                    size: 20.0,
                    color: config.iconColor,
                  ),
                ),
                Gap.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        financeType.displayName,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: config.textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Gap.h4,
                      Text(
                        config.description,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: config.descriptionColor,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.w12,
                Container(
                  width: 32.0,
                  height: 32.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: config.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  ),
                  child: FaIcon(
                    AppIcons.forward,
                    size: 16.0,
                    color: config.chevronColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _FinanceTypeConfig _getConfig(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    switch (financeType) {
      case FinanceType.revenue:
        return _FinanceTypeConfig(
          description: l10n.operationsItem_add_income_desc,
          backgroundColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.secondary.withValues(alpha: 0.18),
          iconBackgroundColor: AppColors.secondary.withValues(alpha: 0.12),
          iconColor: AppColors.secondary,
          textColor: AppColors.onSurface,
          descriptionColor: theme.colorScheme.onSurfaceVariant,
          chevronColor: AppColors.secondary,
        );
      case FinanceType.expense:
        return _FinanceTypeConfig(
          description: l10n.operationsItem_add_expense_desc,
          backgroundColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.error.withValues(alpha: 0.18),
          iconBackgroundColor: AppColors.error.withValues(alpha: 0.12),
          iconColor: AppColors.error,
          textColor: AppColors.onSurface,
          descriptionColor: theme.colorScheme.onSurfaceVariant,
          chevronColor: AppColors.error,
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
