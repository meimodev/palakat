import 'package:flutter/material.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/core/models/financial_account_number.dart';
import 'package:palakat_shared/core/widgets/financial_account_picker.dart';

import 'account_number_picker_dialog.dart';

/// A picker widget for selecting financial account numbers.
///
/// This is a palakat-specific wrapper around [FinancialAccountPicker] that
/// shows the [AccountNumberPickerDialog] when tapped. The dialog uses Riverpod
/// providers for data fetching and pagination.
///
/// For a simpler picker without dialog (e.g., with pre-loaded accounts),
/// use [FinancialAccountPicker] directly from palakat_shared.
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
    return FinancialAccountPicker(
      financeType: financeType,
      selectedAccount: selectedAccount,
      onSelected: onSelected,
      errorText: errorText,
      label: label,
      // When onTap is provided, the picker is enabled regardless of accounts list.
      // Accounts are fetched in the dialog, not passed here.
      accounts: const [],
      onTap: () => _showPickerDialog(context),
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
