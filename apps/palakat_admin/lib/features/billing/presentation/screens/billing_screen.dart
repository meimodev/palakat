import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;
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

  BillingController get controller =>
      ref.read(billingControllerProvider.notifier);
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
    final l10n = context.l10n;

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.admin_billing_title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.admin_billing_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            _buildOverdueBillsSection(context, theme),
            _buildPaymentHistorySection(context, theme),
            const SizedBox(height: 24),
            _buildBillingItemsSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _cardError({
    required BuildContext context,
    required ThemeData theme,
    required Object error,
    required VoidCallback onRetry,
    required String message,
  }) {
    final l10n = context.l10n;
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
            label: Text(l10n.btn_retry),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueBillsSection(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
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
              title: l10n.card_overdueBills_title,
              subtitle: l10n.card_overdueBills_subtitle,
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

  Widget _buildPaymentHistorySection(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
    final paymentHistoryAsync = state.paymentHistory;

    return SurfaceCard(
      title: l10n.card_paymentHistory_title,
      subtitle: l10n.card_paymentHistory_subtitle,
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
                children: [ShimmerPlaceholders.table(rows: 5, columns: 5)],
              ),
            ),
          ),
        ),
        error: (e, st) => _cardError(
          context: context,
          theme: theme,
          error: e,
          onRetry: controller.fetchPaymentHistory,
          message: l10n.error_loadingBilling,
        ),
        data: (payments) {
          return Column(
            children: [
              _PaymentHistoryHeader(),
              const Divider(height: 1),
              ...payments
                  .take(10)
                  .map((payment) => _PaymentHistoryRow(payment: payment)),
              if (payments.length > 10) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _showFullPaymentHistory(payments),
                  child: Text(
                    l10n.btn_viewAllPaymentsWithCount(payments.length),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildBillingItemsSection(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
    final billingItemsAsync = state.billingItems;
    final filteredItems = controller.getFilteredBillingItems();
    final paginatedItems = controller.getPaginatedBillingItems();
    final total = filteredItems.length;

    return SurfaceCard(
      title: l10n.card_billingItems_title,
      subtitle: billingItemsAsync.hasValue && total > 0
          ? l10n.card_billingItems_subtitleWithTotal(total)
          : l10n.card_billingItems_subtitle,
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
          context: context,
          theme: theme,
          error: e,
          onRetry: controller.fetchBillingItems,
          message: l10n.error_loadingBilling,
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
                      decoration: InputDecoration(
                        hintText: l10n.hint_searchBillingItems,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<BillingStatus?>(
                    value: state.statusFilter,
                    hint: Text(l10n.filter_allStatus),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.filter_allStatus),
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
                    l10n.noData_billing,
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
                  if (state.page < maxPage) {
                    controller.updatePage(state.page + 1);
                  }
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
                AppSnackbars.showSuccess(
                  context,
                  message: context.l10n.msg_recordedPayment,
                );
              }
            } catch (e) {
              if (mounted) {
                AppSnackbars.showError(
                  context,
                  message: '${context.l10n.msg_recordPaymentFailed}: $e',
                );
              }
            }
          }
        },
      ),
    );
  }

  void _showFullPaymentHistory(List<PaymentHistory> payments) {
    final l10n = context.l10n;
    DrawerUtils.showDrawer(
      context: context,
      drawer: SideDrawer(
        title: l10n.drawer_paymentHistory_title,
        subtitle: l10n.drawer_paymentHistory_subtitle,
        onClose: () => DrawerUtils.closeDrawer(context),
        width: 600,
        content: Column(
          children: [
            _PaymentHistoryHeader(),
            const Divider(height: 1),
            ...payments.map((payment) => _PaymentHistoryRow(payment: payment)),
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
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(Text(l10n.tbl_billId), flex: 2, style: textStyle),
          _cell(Text(l10n.tbl_description), flex: 4, style: textStyle),
          _cell(Text(l10n.tbl_amount), flex: 2, style: textStyle),
          _cell(Text(l10n.tbl_dueDate), flex: 2, style: textStyle),
          _cell(Text(l10n.tbl_status), flex: 2, style: textStyle),
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
                        item.id ?? context.l10n.lbl_na,
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
    return DateFormat.yMMMd().format(d);
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
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(Text(l10n.tbl_paymentId), flex: 2, style: textStyle),
          _cell(Text(l10n.tbl_accountId), flex: 2, style: textStyle),
          _cell(Text(l10n.tbl_amount), flex: 2, style: textStyle),
          _cell(Text(l10n.tbl_method), flex: 2, style: textStyle),
          _cell(Text(l10n.tbl_date), flex: 2, style: textStyle),
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
                  payment.id ?? context.l10n.lbl_na,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                  ),
                ),
                flex: 2,
              ),
              _cell(
                Text(
                  DateFormat.yMMMd().format(payment.paymentDate),
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
      title: context.l10n.drawer_billingDetails_title,
      subtitle: item.id,
      onClose: onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoSection(
            title: context.l10n.section_basicInformation,
            children: [
              InfoRow(
                label: context.l10n.lbl_description,
                value: item.description,
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: context.l10n.lbl_amount,
                value: item.formattedAmount,
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: context.l10n.tbl_status,
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
                label: context.l10n.tbl_dueDate,
                value: DateFormat.yMMMd().format(item.dueDate),
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: context.l10n.lbl_paidDate,
                value: item.paidDate != null
                    ? DateFormat.yMMMd().format(item.paidDate!)
                    : context.l10n.lbl_na,
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ],
          ),

          const SizedBox(height: 24),

          InfoSection(
            title: context.l10n.section_paymentInformation,
            children: [
              InfoRow(
                label: context.l10n.lbl_method,
                value: item.paymentMethod?.displayName ?? context.l10n.lbl_na,
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
                label: context.l10n.lbl_transactionId,
                value: item.transactionId ?? context.l10n.lbl_na,
                labelWidth: 140,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              if (item.notes != null)
                InfoRow(
                  label: context.l10n.lbl_notes,
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
              label: Text(context.l10n.btn_recordPayment),
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
      title: Text(context.l10n.dlg_recordPayment_title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.l10n.lbl_bill}: ${widget.item.id}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${context.l10n.lbl_amount}: ${widget.item.formattedAmount}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              value: _paymentMethod,
              decoration: InputDecoration(
                labelText: context.l10n.filter_paymentMethod,
                border: const OutlineInputBorder(),
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
              decoration: InputDecoration(
                labelText:
                    '${context.l10n.lbl_transactionId} ${context.l10n.lbl_optional}',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText:
                    '${context.l10n.lbl_notes} ${context.l10n.lbl_optional}',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.btn_cancel),
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
          child: Text(context.l10n.btn_recordPayment),
        ),
      ],
    );
  }
}
