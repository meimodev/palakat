import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import '../state/billing_controller.dart';
import '../state/billing_screen_state.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  late final TextEditingController _searchController;
  late final Debouncer _searchDebouncer;

  BillingController get controller => ref.read(billingControllerProvider.notifier);
  BillingScreenState get state => ref.watch(billingControllerProvider);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebouncer(() {
      controller.updateSearchQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Billing Management', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Manage church billing, payments, and view payment history.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            _buildOverdueBillsSection(theme),
            _buildPaymentHistorySection(theme),
            const SizedBox(height: 24),
            _buildBillingItemsSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _cardError({
    required ThemeData theme,
    required Object error,
    required VoidCallback onRetry,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueBillsSection(ThemeData theme) {
    final billingItemsAsync = state.billingItems;
    
    return billingItemsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (items) {
        final overdueItems = controller.getOverdueItems();
        
        if (overdueItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            SurfaceCard(
              title: 'Overdue Bills',
              subtitle: 'Require urgent attention',
              child: Column(
                children: [
                  _BillingHeader(),
                  const Divider(height: 1),
                  ...overdueItems.map(
                    (item) => _BillingRow(
                      item: item,
                      onTap: () => _showBillingItemDetail(item),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildPaymentHistorySection(ThemeData theme) {
    final paymentHistoryAsync = state.paymentHistory;

    return SurfaceCard(
      title: 'Payment History',
      subtitle: 'View all payment transactions and history.',
      child: paymentHistoryAsync.when(
        loading: () => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LoadingShimmer(
              child: Column(
                children: [
                  ShimmerPlaceholders.table(rows: 5, columns: 5),
                ],
              ),
            ),
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
          onRetry: controller.fetchPaymentHistory,
          message: 'Failed to load payment history.',
        ),
        data: (payments) {
          return Column(
            children: [
              _PaymentHistoryHeader(),
              const Divider(height: 1),
              ...payments.take(10).map(
                (payment) => _PaymentHistoryRow(payment: payment),
              ),
              if (payments.length > 10) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _showFullPaymentHistory(payments),
                  child: Text('View All ${payments.length} Payments'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildBillingItemsSection(ThemeData theme) {
    final billingItemsAsync = state.billingItems;
    final filteredItems = controller.getFilteredBillingItems();
    final paginatedItems = controller.getPaginatedBillingItems();
    final total = filteredItems.length;

    return SurfaceCard(
      title: 'Billing Items',
      subtitle: billingItemsAsync.hasValue && total > 0
          ? 'Manage church billing and payment records. Total items: $total'
          : 'Manage church billing and payment records.',
      child: billingItemsAsync.when(
        loading: () => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LoadingShimmer(
              child: Column(
                children: [
                  // Search bar shimmer
                  ShimmerPlaceholders.text(width: double.infinity, height: 48),
                  const SizedBox(height: 16),
                  // Table shimmer
                  ShimmerPlaceholders.table(rows: 5, columns: 5),
                ],
              ),
            ),
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
          onRetry: controller.fetchBillingItems,
          message: 'Failed to load billing items.',
        ),
        data: (items) {
          return Column(
            children: [
              // Search and Filters
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search billing items...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<BillingStatus?>(
                    value: state.statusFilter,
                    hint: const Text('All Status'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Status'),
                      ),
                      ...BillingStatus.values.map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        ),
                      ),
                    ],
                    onChanged: controller.updateStatusFilter,
                  ),
                  const SizedBox(width: 8),
                  DateRangeFilter(
                    value: state.dateRange,
                    onChanged: controller.updateDateRange,
                    onClear: () => controller.updateDateRange(null),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Table Header
              _BillingHeader(),
              const Divider(height: 1),

              // Table Rows
              if (paginatedItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No billing items found.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...paginatedItems.map(
                  (item) => _BillingRow(
                    item: item,
                    onTap: () => _showBillingItemDetail(item),
                  ),
                ),

              const SizedBox(height: 8),
              // Pagination
              PaginationBar(
                total: total,
                pageSize: state.rowsPerPage,
                page: state.page,
                onPageSizeChanged: (v) => controller.updateRowsPerPage(v),
                onPrev: () {
                  if (state.page > 0) controller.updatePage(state.page - 1);
                },
                onNext: () {
                  final maxPage = (total / state.rowsPerPage).ceil() - 1;
                  if (state.page < maxPage) controller.updatePage(state.page + 1);
                },
                onPageChanged: (int value) {},
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBillingItemDetail(BillingItem? item) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: _BillingDetailDrawer(
        item: item!,
        onClose: () => DrawerUtils.closeDrawer(context),
        onPayment: () async {
          final result = await showDialog<Map<String, dynamic>?>(
            context: context,
            builder: (dialogCtx) => _PaymentDialog(item: item),
          );

          if (result != null && mounted) {
            try {
              await controller.recordPayment(
                billingItemId: item.id ?? '',
                paymentMethod: result['paymentMethod'] as PaymentMethod,
                transactionId: result['transactionId'] as String?,
                notes: result['notes'] as String?,
              );

              if (mounted) {
                DrawerUtils.closeDrawer(context);
                AppSnackbars.showSuccess(context, message: 'Payment recorded successfully');
              }
            } catch (e) {
              if (mounted) {
                AppSnackbars.showError(context, message: 'Failed to record payment: $e');
              }
            }
          }
        },
      ),
    );
  }

  void _showFullPaymentHistory(List<PaymentHistory> payments) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: SideDrawer(
        title: 'Payment History',
        subtitle: 'Complete payment transaction history',
        onClose: () => DrawerUtils.closeDrawer(context),
        width: 600,
        content: Column(
          children: [
            _PaymentHistoryHeader(),
            const Divider(height: 1),
            ...payments.map(
              (payment) => _PaymentHistoryRow(payment: payment),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Bill ID'), flex: 2, style: textStyle),
          _cell(const Text('Description'), flex: 4, style: textStyle),
          _cell(const Text('Amount'), flex: 2, style: textStyle),
          _cell(const Text('Due Date'), flex: 2, style: textStyle),
          _cell(const Text('Status'), flex: 2, style: textStyle),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1, TextStyle? style}) => Expanded(
    flex: flex,
    child: DefaultTextStyle.merge(style: style, child: child),
  );
}

class _BillingRow extends StatelessWidget {
  final BillingItem item;
  final VoidCallback onTap;

  const _BillingRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hoverColor = theme.colorScheme.primary.withValues(alpha: 0.04);
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              hoverColor: hoverColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _cell(
                      Text(
                        item.id ?? '-',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      flex: 2,
                    ),
                    _cell(
                      Text(
                        item.description,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      flex: 4,
                    ),
                    _cell(
                      Text(
                        item.formattedAmount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      flex: 2,
                    ),
                    _cell(
                      Text(
                        _formatDate(item.dueDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: item.isOverdue ? Colors.red : null,
                        ),
                      ),
                      flex: 2,
                    ),
                    _cell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _StatusChip(status: item.status),
                      ),
                      flex: 2,
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return DateFormat('MMM dd, yyyy').format(d);
  }

  Widget _cell(Widget child, {int flex = 1}) =>
      Expanded(flex: flex, child: child);
}

class _StatusChip extends StatelessWidget {
  final BillingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon) = switch (status) {
      BillingStatus.paid => (Colors.green, Icons.check_circle),
      BillingStatus.pending => (Colors.orange, Icons.pending),
      BillingStatus.overdue => (Colors.red, Icons.warning),
      BillingStatus.cancelled => (Colors.grey, Icons.cancel),
      BillingStatus.refunded => (Colors.blue, Icons.undo),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Payment ID'), flex: 2, style: textStyle),
          _cell(const Text('Account ID'), flex: 2, style: textStyle),
          _cell(const Text('Amount'), flex: 2, style: textStyle),
          _cell(const Text('Method'), flex: 2, style: textStyle),
          _cell(const Text('Date'), flex: 2, style: textStyle),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1, TextStyle? style}) => Expanded(
    flex: flex,
    child: DefaultTextStyle.merge(style: style, child: child),
  );
}

class _PaymentHistoryRow extends StatelessWidget {
  final PaymentHistory payment;

  const _PaymentHistoryRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _cell(
                Text(
                  payment.id ?? '-',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                flex: 2,
              ),
              _cell(
                Text(payment.billingItemId, style: theme.textTheme.bodyMedium),
                flex: 2,
              ),
              _cell(
                Text(
                  payment.formattedAmount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                flex: 2,
              ),
              _cell(
                Align(
                  alignment: Alignment.centerLeft,
                  child: PaymentMethodChip(
                    method: payment.paymentMethod,
                    iconSize: 10,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
                ),
                flex: 2,
              ),
              _cell(
                Text(
                  DateFormat('MMM dd, yyyy').format(payment.paymentDate),
                  style: theme.textTheme.bodyMedium,
                ),
                flex: 2,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _cell(Widget child, {int flex = 1}) =>
      Expanded(flex: flex, child: child);
}


class _BillingDetailDrawer extends StatelessWidget {
  final BillingItem item;
  final VoidCallback onClose;
  final VoidCallback onPayment;

  const _BillingDetailDrawer({
    required this.item,
    required this.onClose,
    required this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    return SideDrawer(
      title: 'Billing Details',
      subtitle: item.id,
      onClose: onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoSection(
            title: 'Basic Information',
            children: [
              InfoRow(
                label: 'Description',
                value: item.description,
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: 'Amount',
                value: item.formattedAmount,
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: 'Status',
                value: item.status.displayName,
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusChip(status: item.status),
                ),
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: 'Due Date',
                value: DateFormat('MMM dd, yyyy').format(item.dueDate),
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: 'Paid Date',
                value: item.paidDate != null
                    ? DateFormat('MMM dd, yyyy').format(item.paidDate!)
                    : '—',
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ],
          ),

          const SizedBox(height: 24),

          InfoSection(
            title: 'Payment Information',
            children: [
              InfoRow(
                label: 'Method',
                value: item.paymentMethod?.displayName ?? '—',
                valueWidget: item.paymentMethod != null
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: PaymentMethodChip(method: item.paymentMethod!),
                      )
                    : null,
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: 'Transaction ID',
                value: item.transactionId ?? '—',
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              if (item.notes != null)
                InfoRow(
                  label: 'Notes',
                  value: item.notes!,
                  labelWidth: 140,
                  spacing: 16,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
            ],
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onPayment,
              icon: const Icon(Icons.payment),
              label: const Text('Record Payment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final BillingItem item;

  const _PaymentDialog({required this.item});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _transactionController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.cashless;

  @override
  void dispose() {
    _transactionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Record Payment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bill: ${widget.item.id}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Amount: ${widget.item.formattedAmount}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: PaymentMethod.values
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(method.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (method) => setState(() => _paymentMethod = method!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _transactionController,
              decoration: const InputDecoration(
                labelText: 'Transaction ID (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'paymentMethod': _paymentMethod,
              'transactionId': _transactionController.text.trim().isEmpty
                  ? null
                  : _transactionController.text.trim(),
              'notes': _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            });
          },
          child: const Text('Record Payment'),
        ),
      ],
    );
  }
}
