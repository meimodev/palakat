import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/features/activity/activity.dart';
import 'package:palakat_admin/features/expense/expense.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';

class ExpenseDetailDrawer extends ConsumerStatefulWidget {
  final int expenseId;
  final VoidCallback onClose;
  const ExpenseDetailDrawer({
    super.key,
    required this.expenseId,
    required this.onClose,
  });

  @override
  ConsumerState<ExpenseDetailDrawer> createState() =>
      _ExpenseDetailDrawerState();
}

class _ExpenseDetailDrawerState extends ConsumerState<ExpenseDetailDrawer> {
  bool _isLoading = true;
  String? _errorMessage;
  Expense? _expense;

  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  Future<void> _loadExpense() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(expenseControllerProvider.notifier);
      final expense = await controller.fetchExpense(widget.expenseId);
      if (mounted) {
        setState(() {
          _expense = expense;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showActivityDetail() {
    if (_expense?.activity == null) return;
    DrawerUtils.showDrawer(
      context: context,
      drawer: ActivityDetailDrawer(
        activityId: _expense!.activity!.id!,
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SideDrawer(
      title: l10n.drawer_expenseDetails_title,
      subtitle: l10n.drawer_expenseDetails_subtitle,
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: l10n.loading_expenses,
      errorMessage: _errorMessage,
      onRetry: _loadExpense,
      content: _expense == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                InfoSection(
                  title: l10n.section_basicInformation,
                  children: [
                    InfoRow(
                      label: l10n.lbl_expenseId,
                      value: l10n.lbl_hashId(
                        _expense!.id?.toString() ?? l10n.lbl_na,
                      ),
                    ),
                    InfoRow(
                      label: l10n.lbl_accountNumber,
                      value: _expense!.accountNumber,
                    ),
                    InfoRow(
                      label: l10n.lbl_amount,
                      value: l10n.lbl_negativeAmount(
                        _expense!.amount.toCurrency,
                      ),
                      valueStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                    InfoRow(
                      label: l10n.lbl_method,
                      value: _expense!.paymentMethod.displayName,
                      valueWidget: Align(
                        alignment: Alignment.centerLeft,
                        child: PaymentMethodChip(
                          method: _expense!.paymentMethod,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Activity Information (only show if activity exists)
                if (_expense!.activity != null) ...[
                  InfoSection(
                    title: l10n.section_activityInformation,
                    action: IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      onPressed: _showActivityDetail,
                      tooltip: l10n.tooltip_viewActivityDetails,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    children: [
                      InfoRow(
                        label: l10n.lbl_activityId,
                        value: l10n.lbl_hashId(
                          _expense!.activity!.id?.toString() ?? l10n.lbl_na,
                        ),
                      ),
                      InfoRow(
                        label: l10n.lbl_title,
                        value: _expense!.activity!.title,
                      ),
                      if (_expense!.activity!.description != null)
                        InfoRow(
                          label: l10n.lbl_description,
                          value: _expense!.activity!.description!,
                        ),
                      InfoRow(
                        label: l10n.lbl_activityDateTime,
                        value: _expense!.activity!.date.toDateTimeString(),
                      ),
                      if (_expense!.activity!.note != null)
                        InfoRow(
                          label: l10n.lbl_note,
                          value: _expense!.activity!.note!,
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

                // Supervisor
                if (_expense!.activity?.supervisor != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          l10n.tbl_supervisor,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _expense!.activity!.supervisor.account?.name ??
                                  '-',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (_expense!
                                .activity!
                                .supervisor
                                .membershipPositions
                                .isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _expense!
                                    .activity!
                                    .supervisor
                                    .membershipPositions
                                    .map((position) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outlineVariant,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          position.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Approval (only show if activity exists)
                if (_expense!.activity != null)
                  InfoSection(
                    title: l10n.section_approval,
                    trailing: Builder(
                      builder: (context) {
                        final status =
                            _expense!.activity!.approvers.approvalStatus;
                        final (bg, fg, label, icon) = status.displayProperties;
                        return StatusChip(
                          label: label,
                          background: bg,
                          foreground: fg,
                          icon: icon,
                          fontSize: 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        );
                      },
                    ),
                    children: [
                      if (_expense!.createdAt != null)
                        InfoRow(
                          label: l10n.lbl_approveOn,
                          value:
                              "${_expense!.activity!.approvers.approvalDate.toDateTimeString()}"
                              "\n"
                              "${_expense!.activity!.approvers.approvalDate.toRelativeTime()}",
                        ),
                      if (_expense!.updatedAt != null)
                        InfoRow(
                          label: l10n.lbl_requestedAt,
                          value:
                              "${_expense!.createdAt!.toDateTimeString()}"
                              "\n"
                              "${_expense!.createdAt!.toRelativeTime()}",
                        ),
                    ],
                  ),

                // Timestamps (show when no activity)
                if (_expense!.activity == null)
                  InfoSection(
                    title: l10n.section_timestamps,
                    children: [
                      if (_expense!.createdAt != null)
                        InfoRow(
                          label: l10n.lbl_createdAt,
                          value:
                              "${_expense!.createdAt!.toDateTimeString()}"
                              "\n"
                              "${_expense!.createdAt!.toRelativeTime()}",
                        ),
                      if (_expense!.updatedAt != null)
                        InfoRow(
                          label: l10n.lbl_updatedAt,
                          value:
                              "${_expense!.updatedAt!.toDateTimeString()}"
                              "\n"
                              "${_expense!.updatedAt!.toRelativeTime()}",
                        ),
                    ],
                  ),
              ],
            ),
      footer: _expense == null
          ? null
          : Center(
              child: FilledButton.icon(
                onPressed: () {
                  // Placeholder for future actions (e.g., edit, export)
                },
                icon: const Icon(Icons.receipt_long),
                label: Text(l10n.btn_exportReceipt),
              ),
            ),
    );
  }
}
