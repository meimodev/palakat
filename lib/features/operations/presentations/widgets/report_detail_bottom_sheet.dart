import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/operations/domain/entities/report.dart';

class ReportDetailBottomSheet extends StatelessWidget {
  final Report report;

  const ReportDetailBottomSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BaseSize.radiusLg),
          topRight: Radius.circular(BaseSize.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: BaseSize.h12),
            width: BaseSize.w40,
            height: BaseSize.h4,
            decoration: BoxDecoration(
              color: BaseColor.neutral40,
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            ),
          ),

          Gap.h24,

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
            child: Row(
              children: [
                Container(
                  width: BaseSize.w48,
                  height: BaseSize.w48,
                  decoration: BoxDecoration(
                    color: _getReportTypeColor(report.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: Icon(
                    _getReportTypeIcon(report.type),
                    color: _getReportTypeColor(report.type),
                    size: BaseSize.w24,
                  ),
                ),
                Gap.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: BaseTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap.h4,
                      Text(
                        'Generated on ${_formatDate(report.generatedDate)}',
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.neutral60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Gap.h24,

          // Content based on report type
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
              child: _buildReportContent(),
            ),
          ),

          Gap.h24,

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement export functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export functionality coming soon'),
                        ),
                      );
                    },
                    child: const Text('Export'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    switch (report.type) {
      case ReportType.income:
        return _buildIncomeReportContent();
      case ReportType.expense:
        return _buildExpenseReportContent();
      case ReportType.inventory:
        return _buildInventoryReportContent();
    }
  }

  Widget _buildIncomeReportContent() {
    try {
      final data = IncomeReportData.fromJson(report.data);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard([
            _SummaryItem('Total Income', _formatCurrency(data.totalIncome)),
            _SummaryItem('Donations', _formatCurrency(data.donations)),
            _SummaryItem('Tithes', _formatCurrency(data.tithes)),
            _SummaryItem('Offerings', _formatCurrency(data.offerings)),
            _SummaryItem('Other Income', _formatCurrency(data.otherIncome)),
          ]),

          Gap.h24,

          Text(
            'Recent Transactions',
            style: BaseTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap.h12,

          ...data.items.map(
            (item) => _buildTransactionItem(
              item.description,
              _formatCurrency(item.amount),
              item.category,
              _formatDate(item.date),
            ),
          ),
        ],
      );
    } catch (e) {
      return const Text('Error loading report data');
    }
  }

  Widget _buildExpenseReportContent() {
    try {
      final data = ExpenseReportData.fromJson(report.data);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard([
            _SummaryItem('Total Expense', _formatCurrency(data.totalExpense)),
            _SummaryItem('Utilities', _formatCurrency(data.utilities)),
            _SummaryItem('Maintenance', _formatCurrency(data.maintenance)),
            _SummaryItem('Supplies', _formatCurrency(data.supplies)),
            _SummaryItem('Salaries', _formatCurrency(data.salaries)),
            _SummaryItem('Other Expenses', _formatCurrency(data.otherExpenses)),
          ]),

          Gap.h24,

          Text(
            'Recent Expenses',
            style: BaseTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap.h12,

          ...data.items.map(
            (item) => _buildTransactionItem(
              item.description,
              _formatCurrency(item.amount),
              item.category,
              _formatDate(item.date),
            ),
          ),
        ],
      );
    } catch (e) {
      return const Text('Error loading report data');
    }
  }

  Widget _buildInventoryReportContent() {
    try {
      final data = InventoryReportData.fromJson(report.data);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard([
            _SummaryItem('Total Items', data.totalItems.toString()),
            _SummaryItem('Total Value', _formatCurrency(data.totalValue)),
          ]),

          Gap.h24,

          Text(
            'Category Breakdown',
            style: BaseTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap.h12,

          ...data.categoryCount.entries.map(
            (entry) => _buildCategoryItem(entry.key, entry.value.toString()),
          ),

          Gap.h24,

          Text(
            'Sample Items',
            style: BaseTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap.h12,

          ...data.items
              .take(5)
              .map(
                (item) => _buildInventoryItem(
                  item.name,
                  item.category,
                  item.quantity,
                  _formatCurrency(item.unitValue),
                ),
              ),
        ],
      );
    } catch (e) {
      return const Text('Error loading report data');
    }
  }

  Widget _buildSummaryCard(List<_SummaryItem> items) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: BaseColor.neutral10,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(vertical: BaseSize.h4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label, style: BaseTypography.bodyMedium),
                    Text(
                      item.value,
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTransactionItem(
    String description,
    String amount,
    String category,
    String date,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: BaseSize.h8),
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.neutral20),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: BaseTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap.h4,
                Text(
                  '$category • $date',
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.neutral60,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: BaseTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: _getReportTypeColor(report.type),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, String count) {
    return Container(
      margin: EdgeInsets.only(bottom: BaseSize.h8),
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.neutral20),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: BaseTypography.bodyMedium),
          Text(
            '$count items',
            style: BaseTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(
    String name,
    String category,
    int quantity,
    String value,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: BaseSize.h8),
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.neutral20),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: BaseTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap.h4,
                Text(
                  '$category • Qty: $quantity',
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.neutral60,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: BaseTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.income:
        return const Color(0xFF10B981);
      case ReportType.expense:
        return const Color(0xFFEF4444);
      case ReportType.inventory:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.income:
        return Icons.trending_up;
      case ReportType.expense:
        return Icons.trending_down;
      case ReportType.inventory:
        return Icons.inventory_2;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }
}

class _SummaryItem {
  final String label;
  final String value;

  _SummaryItem(this.label, this.value);
}
