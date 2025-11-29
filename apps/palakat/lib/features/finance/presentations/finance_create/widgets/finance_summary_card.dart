import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/finance/presentations/finance_create/widgets/currency_input_widget.dart';
import 'package:palakat_shared/models.dart' hide Column;

/// Displays attached finance summary in ActivityPublishScreen.
/// Shows finance type badge, formatted amount, account number, payment method,
/// and provides edit and remove action buttons.
/// Requirements: 1.4, 1.5
class FinanceSummaryCard extends StatelessWidget {
  const FinanceSummaryCard({
    super.key,
    required this.financeData,
    required this.onRemove,
    required this.onEdit,
  });

  final FinanceData financeData;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: BaseColor.neutral[300]!),
        boxShadow: [
          BoxShadow(
            color: BaseColor.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with finance type badge and actions
          _buildHeader(),
          // Divider
          Divider(height: 1, color: BaseColor.neutral[200]),
          // Content with amount, account number, payment method
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(BaseSize.w12),
      child: Row(
        children: [
          // Finance type badge
          _FinanceTypeBadge(type: financeData.type),
          const Spacer(),
          // Edit button
          _ActionButton(
            icon: Icons.edit_outlined,
            onTap: onEdit,
            color: BaseColor.primary,
          ),
          Gap.w8,
          // Remove button
          _ActionButton(
            icon: Icons.delete_outline,
            onTap: onRemove,
            color: BaseColor.error,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(BaseSize.w12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount (formatted as Rupiah)
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Amount',
            value: formatRupiah(financeData.amount),
            valueStyle: BaseTypography.titleMedium.copyWith(
              color: financeData.type.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap.h12,
          // Account number
          _InfoRow(
            icon: Icons.account_balance_outlined,
            label: 'Account Number',
            value: financeData.accountNumber,
          ),
          Gap.h12,
          // Payment method
          _InfoRow(
            icon: financeData.paymentMethod == PaymentMethod.cash
                ? Icons.payments_outlined
                : Icons.credit_card_outlined,
            label: 'Payment Method',
            value: _getPaymentMethodDisplayName(financeData.paymentMethod),
          ),
        ],
      ),
    );
  }

  /// Returns the display name for a payment method.
  String _getPaymentMethodDisplayName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.cashless:
        return 'Cashless';
    }
  }
}

/// Badge displaying the finance type (Revenue/Expense) with appropriate color.
class _FinanceTypeBadge extends StatelessWidget {
  const _FinanceTypeBadge({required this.type});

  final FinanceType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h6,
      ),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(color: type.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: BaseSize.w16, color: type.color),
          Gap.w6,
          Text(
            type.displayName,
            style: BaseTypography.bodyMedium.copyWith(
              color: type.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button for edit/remove actions.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      child: Container(
        padding: EdgeInsets.all(BaseSize.w8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        ),
        child: Icon(icon, size: BaseSize.w18, color: color),
      ),
    );
  }
}

/// Row displaying an icon, label, and value.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: BaseSize.w32,
          height: BaseSize.w32,
          decoration: BoxDecoration(
            color: BaseColor.neutral[100],
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          child: Icon(icon, size: BaseSize.w16, color: BaseColor.neutral[600]),
        ),
        Gap.w12,
        // Label and value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: BaseTypography.bodySmall.copyWith(
                  color: BaseColor.neutral[500],
                ),
              ),
              Gap.h4,
              Text(
                value,
                style:
                    valueStyle ??
                    BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
