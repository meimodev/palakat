import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/core/models/financial_account_number.dart';

import 'account_number_picker_dialog.dart';

/// A picker widget for selecting financial account numbers.
///
/// This is a palakat-specific wrapper that shows the
/// [AccountNumberPickerDialog] when tapped. The dialog uses Riverpod providers
/// for data fetching and pagination.
class AccountNumberPicker extends StatelessWidget {
  const AccountNumberPicker({
    super.key,
    required this.financeType,
    this.selectedAccount,
    required this.onSelected,
    this.errorText,
    this.label,
  });

  /// The type of financial account to filter by
  final FinanceType financeType;

  /// The currently selected financial account number
  final FinancialAccountNumber? selectedAccount;

  /// Callback when an account number is selected
  final ValueChanged<FinancialAccountNumber> onSelected;

  /// Error text to display below the picker
  final String? errorText;

  /// Optional label to display above the picker
  final String? label;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final hasSelection = selectedAccount != null;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium!.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap.h6,
        ],
        GestureDetector(
          onTap: () => _showPickerDialog(context),
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: hasSelection
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.5)
                    : hasSelection
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.outlineVariant,
              ),
            ),
            child: hasSelection
                ? _SelectedAccountContent(account: selectedAccount!)
                : _EmptyAccountPlaceholder(financeType: financeType),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text(
              errorText!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showPickerDialog(BuildContext context) async {
    final result = await showAccountNumberPickerDialog(
      context: context,
      financeType: financeType,
      initialSelection: selectedAccount,
    );

    if (result != null) {
      onSelected(result);
    }
  }
}

class _EmptyAccountPlaceholder extends StatelessWidget {
  const _EmptyAccountPlaceholder({required this.financeType});

  final FinanceType financeType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border.all(color: AppColors.ghostBorder(0.08)),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Icon(
            AppIcons.accountBalanceWalletOutlined,
            size: 20.0,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            context.l10n.lbl_selectAccount(financeType.displayName),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        Icon(AppIcons.forward, size: 20.0, color: AppColors.onSurfaceVariant),
      ],
    );
  }
}

class _SelectedAccountContent extends StatelessWidget {
  const _SelectedAccountContent({required this.account});

  final FinancialAccountNumber account;

  @override
  Widget build(BuildContext context) {
    final hasDescription =
        account.description != null && account.description!.trim().isNotEmpty;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Icon(
            AppIcons.accountBalanceWalletOutlined,
            size: 20.0,
            color: AppColors.primary,
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.accountNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (hasDescription) ...[
                Gap.h4,
                Text(
                  account.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        Icon(AppIcons.edit, size: 20.0, color: AppColors.primary),
      ],
    );
  }
}
