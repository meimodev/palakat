import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/finance/presentations/finance_create/finance_create_controller.dart';
import 'package:palakat/features/finance/presentations/finance_create/finance_create_state.dart';
import 'package:palakat/features/finance/presentations/finance_create/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
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
      persistBottomWidget: OperationsReveal(
        delay: const Duration(milliseconds: 140),
        child: _buildSubmitButton(state, controller),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OperationsReveal(child: _buildHeader(state)),
            Gap.h12,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OperationsReveal(
                    delay: const Duration(milliseconds: 40),
                    child: _buildFinanceTypeIndicator(),
                  ),
                  Gap.h12,
                  OperationsReveal(
                    delay: const Duration(milliseconds: 80),
                    child: _buildFormSection(state, controller),
                  ),
                  if (widget.isStandalone) ...[
                    Gap.h12,
                    OperationsReveal(
                      delay: const Duration(milliseconds: 120),
                      child: _buildActivityPickerSection(state, controller),
                    ),
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
    final theme = Theme.of(context);
    final isRevenue = widget.financeType == FinanceType.revenue;
    final accentColor = isRevenue ? AppColors.secondary : AppColors.error;
    final borderColor = isRevenue ? AppColors.secondary : AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        border: Border.all(color: borderColor.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.financeType.icon,
              size: 18.0,
              color: accentColor,
            ),
          ),
          Gap.w8,
          Expanded(
            child: Text(
              widget.financeType.displayName,
              style: theme.textTheme.titleMedium!.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
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
    return FormSectionWidget(
      title: l10n.section_financialRecord,
      icon: AppIcons.wallet,
      style: FormSectionWidgetStyle.compact,
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
    return FormSectionWidget(
      title: l10n.tbl_activity,
      icon: AppIcons.event,
      style: FormSectionWidgetStyle.compact,
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
    final theme = Theme.of(context);
    // Clear button text that indicates the action
    // In embedded mode: "Add Revenue" or "Add Expense" to indicate attaching to activity
    // In standalone mode: "Create Revenue" or "Create Expense"
    final buttonText = widget.isStandalone
        ? '${l10n.btn_create} ${widget.financeType.displayName}'
        : '${l10n.btn_add} ${widget.financeType.displayName}';

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 10.0,
          left: 12.0,
          right: 12.0,
          top: 10.0,
        ),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.96),
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                    border: Border.all(color: AppColors.ghostBorder(0.08)),
                  ),
                  child: Text(
                    l10n.publish_financialRecordSubtitle,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Gap.h10,
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
