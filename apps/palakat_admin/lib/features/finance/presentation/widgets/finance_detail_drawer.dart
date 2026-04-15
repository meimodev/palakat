import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/activity/activity.dart';
import 'package:palakat_admin/features/expense/expense.dart';
import 'package:palakat_admin/features/revenue/revenue.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class FinanceDetailDrawer extends ConsumerStatefulWidget {
  const FinanceDetailDrawer({
    super.key,
    required this.financeId,
    required this.type,
    required this.onClose,
  });

  final int financeId;
  final FinanceEntryType type;
  final VoidCallback onClose;

  @override
  ConsumerState<FinanceDetailDrawer> createState() =>
      _FinanceDetailDrawerState();
}

class _FinanceDetailDrawerState extends ConsumerState<FinanceDetailDrawer> {
  bool _isLoading = true;
  bool _isProcessingOverride = false;
  String? _errorMessage;
  Revenue? _revenue;
  Expense? _expense;
  ProviderSubscription<AsyncValue<RealtimeEvent>>? _realtimeSubscription;
  late final SocketService _socket;
  late SocketConnectionStatus _previousConnectionStatus;
  late final VoidCallback _socketStatusListener;

  Activity? get _activity => _revenue?.activity ?? _expense?.activity;
  List<Approver> get _approvers =>
      _revenue?.approvers ?? _expense?.approvers ?? const [];
  int? get _resolvedFinanceId => _revenue?.id ?? _expense?.id;
  String get _accountNumber =>
      _revenue?.accountNumber ?? _expense?.accountNumber ?? '';
  int get _amount => _revenue?.amount ?? _expense?.amount ?? 0;
  PaymentMethod? get _paymentMethod =>
      _revenue?.paymentMethod ?? _expense?.paymentMethod;
  DateTime? get _createdAt => _revenue?.createdAt ?? _expense?.createdAt;
  DateTime? get _updatedAt => _revenue?.updatedAt ?? _expense?.updatedAt;
  String? get _notes => _expense?.notes;

  @override
  void initState() {
    super.initState();
    _socket = ref.read(socketServiceProvider);
    _previousConnectionStatus = _socket.connectionStatus;
    _socketStatusListener = () {
      final nextStatus = _socket.connectionStatus;
      final didReconnect =
          _previousConnectionStatus != SocketConnectionStatus.connected &&
          nextStatus == SocketConnectionStatus.connected;
      _previousConnectionStatus = nextStatus;

      if (!didReconnect || !mounted) {
        return;
      }

      _loadDetail();
    };
    _socket.connectionStatusListenable.addListener(_socketStatusListener);
    _realtimeSubscription = ref.listenManual(realtimeEventProvider, (
      previous,
      next,
    ) {
      final event = next.asData?.value;
      if (event == null) {
        return;
      }

      final eventFinanceId = _extractEventFinanceId(event);
      if (eventFinanceId != widget.financeId) {
        return;
      }

      if (event.name == 'finance.updated' && mounted) {
        _loadDetail();
      }

      if (event.name == 'finance.deleted' && mounted) {
        widget.onClose();
      }
    });
    _loadDetail();
  }

  @override
  void dispose() {
    _realtimeSubscription?.close();
    _socket.connectionStatusListenable.removeListener(_socketStatusListener);
    super.dispose();
  }

  int? _extractEventFinanceId(RealtimeEvent event) {
    if (event.name != 'finance.updated' && event.name != 'finance.deleted') {
      return null;
    }

    final data = event.payload['data'];
    if (data is Map<String, dynamic>) {
      final value = data['financeId'];
      return value is int ? value : int.tryParse('$value');
    }

    if (data is Map) {
      final value = data['financeId'];
      return value is int ? value : int.tryParse('$value');
    }

    return null;
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.type == FinanceEntryType.revenue) {
        final controller = ref.read(revenueControllerProvider.notifier);
        final revenue = await controller.fetchRevenue(widget.financeId);
        if (!mounted) return;
        setState(() {
          _revenue = revenue;
          _expense = null;
          _isLoading = false;
        });
        return;
      }

      final controller = ref.read(expenseControllerProvider.notifier);
      final expense = await controller.fetchExpense(widget.financeId);
      if (!mounted) return;
      setState(() {
        _expense = expense;
        _revenue = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showActivityDetail() {
    final activity = _activity;
    if (activity?.id == null) {
      return;
    }

    DrawerUtils.showDrawer(
      context: context,
      drawer: ActivityDetailDrawer(
        activityId: activity!.id!,
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  Future<void> _overrideFinanceApproval(ApprovalStatus status) async {
    final approvers = _approvers;
    final l10n = context.l10n;
    final financeTypeLabel = _financeTypeLabel(l10n);

    if (approvers.isEmpty) {
      AppSnackbars.showError(
        context,
        title: l10n.dlg_financeOverride_title,
        message: l10n.msg_financeOverrideNoApprovers(financeTypeLabel),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isApprove = status == ApprovalStatus.approved;
        return AlertDialog(
          title: Text(l10n.dlg_financeOverride_title),
          content: Text(
            isApprove
                ? l10n.msg_financeOverrideApproveConfirmation(financeTypeLabel)
                : l10n.msg_financeOverrideRejectConfirmation(financeTypeLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.btn_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: isApprove
                  ? null
                  : FilledButton.styleFrom(
                      backgroundColor: Theme.of(
                        dialogContext,
                      ).colorScheme.error,
                    ),
              child: Text(
                isApprove ? l10n.btn_overrideApprove : l10n.btn_overrideReject,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isProcessingOverride = true;
    });

    try {
      final repo = ref.read(financeRepositoryProvider);
      for (final approver in approvers) {
        if (approver.id == null) {
          continue;
        }
        final result = await repo.overrideFinanceApprover(
          approverId: approver.id!,
          type: widget.type,
          status: status,
        );
        result.when(
          onSuccess: (_) {},
          onFailure: (failure) => throw Exception(failure.message),
        );
      }

      if (!mounted) {
        return;
      }

      AppSnackbars.showSuccess(
        context,
        title: l10n.dlg_financeOverride_title,
        message: status == ApprovalStatus.approved
            ? l10n.msg_financeOverrideApproveSuccess
            : l10n.msg_financeOverrideRejectSuccess,
      );
      await _loadDetail();
    } catch (e) {
      if (!mounted) {
        return;
      }
      AppSnackbars.showError(
        context,
        title: l10n.dlg_financeOverride_title,
        message: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOverride = false;
        });
      }
    }
  }

  String _financeTypeLabel(dynamic l10n) {
    return widget.type == FinanceEntryType.revenue
        ? l10n.financeType_revenue
        : l10n.financeType_expense;
  }

  String _loadingMessage(dynamic l10n) {
    return widget.type == FinanceEntryType.revenue
        ? l10n.loading_revenue
        : l10n.loading_expenses;
  }

  String _financeIdLabel(dynamic l10n) {
    return widget.type == FinanceEntryType.revenue
        ? l10n.lbl_revenueId
        : l10n.lbl_expenseId;
  }

  Widget _buildSupervisorSection(BuildContext context, Activity activity) {
    return InfoSection(
      title: context.l10n.tbl_supervisor,
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.supervisor.account?.name ?? context.l10n.lbl_na,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (activity.supervisor.membershipPositions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: activity.supervisor.membershipPositions.map((
                    position,
                  ) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        position.name,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activity = _activity;
    final approvers = _approvers;
    final paymentMethod = _paymentMethod;
    final isRevenue = widget.type == FinanceEntryType.revenue;
    final approvalStatus = approvers.approvalStatus;
    final (statusBg, statusFg, statusLabel, statusIcon) =
        approvalStatus.displayProperties;
    final amountText = isRevenue
        ? _amount.toCurrency
        : l10n.lbl_negativeAmount(_amount.toCurrency);

    return SideDrawer(
      title: l10n.drawer_financeDetails_title,
      subtitle: l10n.drawer_financeDetails_subtitle,
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: _loadingMessage(l10n),
      errorMessage: _errorMessage,
      onRetry: _loadDetail,
      content: _resolvedFinanceId == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoSection(
                  title: l10n.section_basicInformation,
                  children: [
                    InfoRow(
                      label: _financeIdLabel(l10n),
                      value: l10n.lbl_hashId(
                        _resolvedFinanceId?.toString() ?? l10n.lbl_na,
                      ),
                    ),
                    InfoRow(
                      label: l10n.lbl_type,
                      value: _financeTypeLabel(l10n),
                      valueWidget: Align(
                        alignment: Alignment.centerLeft,
                        child: _FinanceTypeChip(type: widget.type),
                      ),
                    ),
                    InfoRow(
                      label: l10n.lbl_accountNumber,
                      value: _accountNumber,
                    ),
                    InfoRow(
                      label: l10n.lbl_amount,
                      value: amountText,
                      valueStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isRevenue
                                ? AppColors.success
                                : Theme.of(context).colorScheme.error,
                          ),
                    ),
                    if (paymentMethod != null)
                      InfoRow(
                        label: l10n.lbl_method,
                        value: paymentMethod.displayName,
                        valueWidget: Align(
                          alignment: Alignment.centerLeft,
                          child: PaymentMethodChip(method: paymentMethod),
                        ),
                      ),
                    if (_notes != null && _notes!.trim().isNotEmpty)
                      InfoRow(label: l10n.lbl_notes, value: _notes!.trim()),
                  ],
                ),
                const SizedBox(height: 24),
                if (activity != null) ...[
                  InfoSection(
                    title: l10n.section_activityInformation,
                    action: IconButton.filledTonal(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      onPressed: _showActivityDetail,
                      tooltip: l10n.tooltip_viewActivityDetails,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    children: [
                      InfoRow(
                        label: l10n.lbl_activityId,
                        value: l10n.lbl_hashId(
                          activity.id?.toString() ?? l10n.lbl_na,
                        ),
                      ),
                      InfoRow(label: l10n.lbl_title, value: activity.title),
                      InfoRow(
                        label: l10n.lbl_type,
                        value: activity.activityType.displayName,
                        valueWidget: Align(
                          alignment: Alignment.centerLeft,
                          child: ActivityTypeChip(type: activity.activityType),
                        ),
                      ),
                      InfoRow(
                        label: l10n.lbl_activityDateTime,
                        value: activity.date.toDateTimeString(),
                      ),
                      if (activity.description != null &&
                          activity.description!.trim().isNotEmpty)
                        InfoRow(
                          label: l10n.lbl_description,
                          value: activity.description!.trim(),
                        ),
                      if (activity.note != null &&
                          activity.note!.trim().isNotEmpty)
                        InfoRow(
                          label: l10n.lbl_note,
                          value: activity.note!.trim(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  InfoSection(
                    title: l10n.section_activityInformation,
                    children: [
                      InfoRow(
                        label: l10n.lbl_activity,
                        value: l10n.noData_activityLink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                if (activity?.supervisor != null) ...[
                  _buildSupervisorSection(context, activity!),
                  const SizedBox(height: 24),
                ],
                InfoSection(
                  title: l10n.section_approval,
                  trailing: StatusChip(
                    label: statusLabel,
                    background: statusBg,
                    foreground: statusFg,
                    icon: statusIcon,
                    fontSize: 12,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  children: [
                    if (_createdAt != null)
                      InfoRow(
                        label: l10n.lbl_requestedAt,
                        value:
                            '${_createdAt!.toDateTimeString()}\n${_createdAt!.toRelativeTime()}',
                      ),
                    if (approvers.isNotEmpty)
                      InfoRow(
                        label: l10n.lbl_approveOn,
                        value:
                            '${approvers.approvalDate.toDateTimeString()}\n${approvers.approvalDate.toRelativeTime()}',
                      ),
                    if (_updatedAt != null)
                      InfoRow(
                        label: l10n.lbl_updatedAt,
                        value:
                            '${_updatedAt!.toDateTimeString()}\n${_updatedAt!.toRelativeTime()}',
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (approvers.isNotEmpty)
                  InfoSection(
                    title: l10n.tbl_approvers,
                    children: [
                      ApproversStackDisplay(
                        approvers: approvers,
                        fallbackDate: _updatedAt ?? _createdAt,
                      ),
                    ],
                  )
                else
                  InfoSection(
                    title: l10n.tbl_approvers,
                    children: [
                      InfoRow(
                        label: l10n.tbl_approvers,
                        value: l10n.msg_noApproversAssigned,
                      ),
                    ],
                  ),
                if (activity == null) ...[
                  const SizedBox(height: 24),
                  InfoSection(
                    title: l10n.section_timestamps,
                    children: [
                      if (_createdAt != null)
                        InfoRow(
                          label: l10n.lbl_createdAt,
                          value:
                              '${_createdAt!.toDateTimeString()}\n${_createdAt!.toRelativeTime()}',
                        ),
                      if (_updatedAt != null)
                        InfoRow(
                          label: l10n.lbl_updatedAt,
                          value:
                              '${_updatedAt!.toDateTimeString()}\n${_updatedAt!.toRelativeTime()}',
                        ),
                    ],
                  ),
                ],
              ],
            ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isProcessingOverride || approvers.isEmpty
                  ? null
                  : () => _overrideFinanceApproval(ApprovalStatus.approved),
              icon: _isProcessingOverride
                  ? CompactLoadingWidget(size: 14, padding: EdgeInsets.zero)
                  : const Icon(Icons.check_circle_outline, size: 16),
              label: Text(l10n.btn_overrideApprove),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isProcessingOverride || approvers.isEmpty
                  ? null
                  : () => _overrideFinanceApproval(ApprovalStatus.rejected),
              icon: _isProcessingOverride
                  ? CompactLoadingWidget(size: 14, padding: EdgeInsets.zero)
                  : const Icon(Icons.cancel_outlined, size: 16),
              label: Text(l10n.btn_overrideReject),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceTypeChip extends StatelessWidget {
  const _FinanceTypeChip({required this.type});

  final FinanceEntryType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRevenue = type == FinanceEntryType.revenue;
    final background = isRevenue
        ? AppColors.success.shade50
        : theme.colorScheme.errorContainer.withValues(alpha: 0.4);
    final foreground = isRevenue
        ? AppColors.success.shade800
        : theme.colorScheme.error;

    return StatusChip(
      label: isRevenue
          ? context.l10n.financeType_revenue
          : context.l10n.financeType_expense,
      background: background,
      foreground: foreground,
      icon: isRevenue ? Icons.trending_up : Icons.trending_down,
      fontSize: 12,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}
