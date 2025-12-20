import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/finance/presentations/finance_create/finance_create_controller.dart';
import 'package:palakat/features/finance/presentations/finance_create/finance_create_state.dart';
import 'package:palakat/features/finance/presentations/finance_create/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/finance_data.dart';
import 'package:palakat_shared/core/models/finance_type.dart';

/// Screen for creating revenue or expense records.
/// Supports both standalone mode (with activity picker) and embedded mode.
/// Requirements: 1.1, 1.2, 1.3, 2.1, 3.1, 4.1, 6.1, 6.2, 6.3
class FinanceCreateScreen extends ConsumerStatefulWidget {
  const FinanceCreateScreen({
    required this.financeType,
    required this.isStandalone,
    this.initialData,
    super.key,
  });

  final FinanceType financeType;
  final bool isStandalone;

  /// Optional initial data for pre-populating the form when editing.
  /// Requirements: 1.1, 1.2, 1.3
  final FinanceData? initialData;

  @override
  ConsumerState<FinanceCreateScreen> createState() =>
      _FinanceCreateScreenState();
}

class _FinanceCreateScreenState extends ConsumerState<FinanceCreateScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = financeCreateControllerProvider(
      widget.financeType,
      widget.isStandalone,
      widget.initialData,
    );
    final controller = ref.read(provider.notifier);
    final state = ref.watch(provider);

    return ScaffoldWidget(
      loading: state.loading,
      disablePadding: true,
      disableSingleChildScrollView: true,
      persistBottomWidget: _buildSubmitButton(state, controller),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(state),
            Gap.h16,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFinanceTypeIndicator(),
                  Gap.h16,
                  _buildFormSection(state, controller),
                  if (widget.isStandalone) ...[
                    Gap.h16,
                    _buildActivityPickerSection(state, controller),
                  ],
                  Gap.h24,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FinanceCreateState state) {
    final l10n = context.l10n;
    final title = '${l10n.btn_create} ${widget.financeType.displayName}';

    return ScreenTitleWidget.titleSecondary(
      title: title,
      subTitle: l10n.approvalDetail_financialData_title,
    );
  }

  Widget _buildFinanceTypeIndicator() {
    final isRevenue = widget.financeType == FinanceType.revenue;
    final backgroundColor = isRevenue
        ? BaseColor.teal[50]!
        : BaseColor.red[50]!;
    final borderColor = isRevenue ? BaseColor.teal[200]! : BaseColor.red[200]!;
    final iconColor = isRevenue ? BaseColor.teal[700]! : BaseColor.red[700]!;
    final textColor = isRevenue ? BaseColor.teal[700]! : BaseColor.red[700]!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.financeType.icon, size: BaseSize.w18, color: iconColor),
          Gap.w8,
          Text(
            widget.financeType.displayName,
            style: BaseTypography.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: BaseColor.neutral[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Container(
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: BaseColor.neutral[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseSize.radiusMd),
                topRight: Radius.circular(BaseSize.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(BaseSize.w6),
                  decoration: BoxDecoration(
                    color: BaseColor.primary[50],
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: BaseSize.w16,
                    color: BaseColor.primary[600],
                  ),
                ),
                Gap.w8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: BaseTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BaseColor.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        Gap.h4,
                        Text(
                          subtitle,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.neutral[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Section content
          Padding(
            padding: EdgeInsets.all(BaseSize.w12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(
    FinanceCreateState state,
    FinanceCreateController controller,
  ) {
    final l10n = context.l10n;
    return _buildSectionCard(
      title: l10n.section_financialRecord,
      icon: AppIcons.wallet,
      children: [
        // Amount input with Rupiah formatting
        CurrencyInputWidget(
          label: l10n.lbl_amount,
          hint: l10n.lbl_amount,
          currentValue: state.amount,
          errorText: state.errorAmount,
          onChanged: controller.onChangedAmount,
        ),
        Gap.h16,
        // Account number picker (replaces text input)
        // Requirements: 3.1, 3.4
        // Filters by financeType to show only revenue or expense accounts
        AccountNumberPicker(
          financeType: widget.financeType,
          label: l10n.lbl_accountNumber,
          selectedAccount: state.selectedFinancialAccountNumber,
          errorText: state.errorAccountNumber,
          onSelected: controller.onSelectedFinancialAccountNumber,
        ),
        Gap.h16,
        // Payment method picker
        PaymentMethodPicker(
          label: l10n.tbl_paymentMethod,
          selectedMethod: state.paymentMethod,
          errorText: state.errorPaymentMethod,
          onSelected: controller.onSelectedPaymentMethod,
        ),
      ],
    );
  }

  Widget _buildActivityPickerSection(
    FinanceCreateState state,
    FinanceCreateController controller,
  ) {
    final l10n = context.l10n;
    return _buildSectionCard(
      title: l10n.tbl_activity,
      icon: AppIcons.event,
      children: [
        ActivityPickerWidget(
          selectedActivity: state.selectedActivity,
          onActivitySelected: controller.onSelectedActivity,
          errorText: state.errorActivity,
        ),
      ],
    );
  }

  /// Builds the submit button with clear labeling for embedded mode.
  /// Requirements: 4.1, 4.4
  Widget _buildSubmitButton(
    FinanceCreateState state,
    FinanceCreateController controller,
  ) {
    final l10n = context.l10n;
    // Clear button text that indicates the action
    // In embedded mode: "Add Revenue" or "Add Expense" to indicate attaching to activity
    // In standalone mode: "Create Revenue" or "Create Expense"
    final buttonText = widget.isStandalone
        ? '${l10n.btn_create} ${widget.financeType.displayName}'
        : '${l10n.btn_add} ${widget.financeType.displayName}';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + BaseSize.h12,
        left: BaseSize.w12,
        right: BaseSize.w12,
        top: BaseSize.h12,
      ),
      decoration: BoxDecoration(
        color: BaseColor.white,
        boxShadow: [
          BoxShadow(
            color: BaseColor.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Helper text for embedded mode to clarify the action
            // Requirements: 4.4
            if (!widget.isStandalone) ...[
              Text(
                l10n.publish_financialRecordSubtitle,
                style: BaseTypography.bodySmall.copyWith(
                  color: BaseColor.neutral60,
                ),
                textAlign: TextAlign.center,
              ),
              Gap.h8,
            ],
            // Prominent button with clear labeling
            // Requirements: 4.1
            ButtonWidget.primary(
              text: buttonText,
              isLoading: state.loading,
              onTap: () => _handleSubmit(controller),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(FinanceCreateController controller) async {
    final l10n = context.l10n;
    if (widget.isStandalone) {
      // Standalone mode: create via API
      final success = await controller.submit();
      if (!mounted) return;

      if (success) {
        // Invalidate operations controller to refresh supervised activities list
        ref.invalidate(operationsControllerProvider);
        context.pop();
        _showSnackBar(l10n.msg_created);
      } else {
        final state = ref.read(
          financeCreateControllerProvider(
            widget.financeType,
            widget.isStandalone,
            widget.initialData,
          ),
        );
        _showSnackBar(state.errorMessage ?? l10n.publish_fillAllRequiredFields);
      }
    } else {
      // Embedded mode: validate and return data
      await controller.validateForm();
      final financeData = controller.getFinanceData();

      if (!mounted) return;

      if (financeData != null) {
        context.pop(financeData);
      } else {
        _showSnackBar(l10n.publish_fillAllRequiredFields);
      }
    }
  }

  void _showSnackBar(String message) {
    if (message.trim().isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
