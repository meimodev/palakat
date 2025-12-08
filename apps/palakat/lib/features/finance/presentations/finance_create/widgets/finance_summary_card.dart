import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  bool get _isExpense => financeData.type == FinanceType.expense;

  Color get _accentColor => financeData.type.color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(
          color: _accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.08),
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
          // Divider with accent color
          Divider(height: 1, color: _accentColor.withValues(alpha: 0.2)),
          // Content with amount, account number, payment method
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BaseSize.radiusMd - 1),
          topRight: Radius.circular(BaseSize.radiusMd - 1),
        ),
      ),
      child: Row(
        children: [
          // Finance type badge
          _FinanceTypeBadge(type: financeData.type),
          const Spacer(),
          // Edit button
          _ActionButton(
            icon: AppIcons.edit,
            onTap: onEdit,
            color: BaseColor.primary,
          ),
          Gap.w8,
          // Remove button
          _ActionButton(
            icon: AppIcons.delete,
            onTap: onRemove,
            color: BaseColor.error,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Format amount with negative sign for expense
    final formattedAmount = _isExpense
        ? '- ${formatRupiah(financeData.amount)}'
        : formatRupiah(financeData.amount);

    return Padding(
      padding: EdgeInsets.all(BaseSize.w12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount (formatted as Rupiah, negative for expense)
          _InfoRow(
            icon: _isExpense ? AppIcons.expense : AppIcons.revenue,
            iconColor: _accentColor,
            label: 'Amount',
            value: formattedAmount,
            valueStyle: BaseTypography.titleMedium.copyWith(
              color: _accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap.h12,
          // Account number with description
          _InfoRow(
            icon: AppIcons.bankAccount,
            label: 'Account Number',
            value: financeData.accountNumber,
            subtitle: financeData.accountDescription,
          ),
          Gap.h12,
          // Payment method
          _InfoRow(
            icon: financeData.paymentMethod == PaymentMethod.cash
                ? AppIcons.cash
                : AppIcons.payment,
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
          FaIcon(type.icon, size: BaseSize.w16, color: type.color),
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
        child: FaIcon(icon, size: BaseSize.w18, color: color),
      ),
    );
  }
}

/// Row displaying an icon, label, value, and optional subtitle.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueStyle,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final TextStyle? valueStyle;
  final Color? iconColor;

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
            color: iconColor?.withValues(alpha: 0.1) ?? BaseColor.neutral[100],
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          child: FaIcon(
            icon,
            size: BaseSize.w16,
            color: iconColor ?? BaseColor.neutral[600],
          ),
        ),
        Gap.w12,
        // Label, value, and optional subtitle
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
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                Gap.h4,
                Text(
                  subtitle!,
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.neutral[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
