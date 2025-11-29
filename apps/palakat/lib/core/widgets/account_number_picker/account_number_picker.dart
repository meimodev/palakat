import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/divider/divider_widget.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/core/models/financial_account_number.dart';

import 'account_number_picker_dialog.dart';

/// A picker widget for selecting financial account numbers.
/// Displays the selected account number prominently with description below.
/// Filters accounts by [financeType] (revenue or expense).
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
    final borderColor = hasError ? BaseColor.error : BaseColor.neutral30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BaseTypography.titleMedium.copyWith(
              color: BaseColor.neutral[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap.h6,
        ],
        IntrinsicHeight(
          child: Material(
            clipBehavior: Clip.hardEdge,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(BaseSize.radiusLg),
              side: BorderSide(color: borderColor, width: 1.5),
            ),
            color: BaseColor.white,
            shadowColor: Colors.black.withValues(alpha: 0.04),
            elevation: 1,
            child: InkWell(
              onTap: () => _showPickerDialog(context),
              child: Padding(
                padding: EdgeInsets.all(BaseSize.w12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildDisplayContent()),
                    Gap.w8,
                    const DividerWidget(height: double.infinity),
                    Gap.w8,
                    Assets.icons.line.chevronDownOutline.svg(
                      width: BaseSize.w12,
                      height: BaseSize.w12,
                      colorFilter: ColorFilter.mode(
                        BaseColor.neutral60,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          Padding(
            padding: EdgeInsets.only(top: BaseSize.customHeight(3)),
            child: Text(
              errorText!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: BaseTypography.bodySmall.toError,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDisplayContent() {
    if (selectedAccount == null) {
      return Text(
        'Select account number',
        style: BaseTypography.titleMedium.copyWith(
          color: BaseColor.neutral50,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          selectedAccount!.accountNumber,
          style: BaseTypography.titleMedium.copyWith(
            color: BaseColor.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (selectedAccount!.description != null &&
            selectedAccount!.description!.isNotEmpty) ...[
          Gap.h4,
          Text(
            selectedAccount!.description!,
            style: BaseTypography.bodySmall.copyWith(
              color: BaseColor.neutral60,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
