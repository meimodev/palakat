import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/extension/extension.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/expense/expense.dart';
import 'package:palakat_admin/features/activity/activity.dart';

class ExpenseDetailDrawer extends ConsumerStatefulWidget {
  final int expenseId;
  final VoidCallback onClose;
  const ExpenseDetailDrawer({
    super.key,
    required this.expenseId,
    required this.onClose,
  });

  @override
  ConsumerState<ExpenseDetailDrawer> createState() => _ExpenseDetailDrawerState();
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
    return SideDrawer(
      title: 'Expense Details',
      subtitle: 'View detailed information about this expense entry',
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: 'Loading expense details...',
      errorMessage: _errorMessage,
      onRetry: _loadExpense,
      content: _expense == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                InfoSection(
                  title: 'Basic Information',
                  children: [
                    InfoRow(
                      label: 'Expense ID',
                      value: "# ${_expense!.id?.toString() ?? '-'}",
                    ),
                    InfoRow(
                      label: 'Account Number',
                      value: _expense!.accountNumber ?? '-',
                    ),
                    InfoRow(
                      label: 'Amount',
                      value: "- ${_expense!.amount.toCurrency}",
                      valueStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                    InfoRow(
                      label: 'Payment Method',
                      value: _expense!.paymentMethod.displayName,
                      valueWidget: Align(
                        alignment: Alignment.centerLeft,
                        child: PaymentMethodChip(method: _expense!.paymentMethod),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Activity Information
                InfoSection(
                  title: 'Activity Information',
                  action: IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    onPressed: _showActivityDetail,
                    tooltip: 'View Activity Details',
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
                      label: 'Activity ID',
                      value: "# ${_expense!.activity!.id}",
                    ),
                    InfoRow(label: 'Title', value: _expense!.activity!.title),
                    if (_expense!.activity!.description != null)
                      InfoRow(
                        label: 'Description',
                        value: _expense!.activity!.description!,
                      ),
                    InfoRow(
                      label: 'Activity Date & Time',
                      value: _expense!.activity!.date.toDateTimeString(),
                    ),
                    if (_expense!.activity!.note != null)
                      InfoRow(label: 'Note', value: _expense!.activity!.note!),
                  ],
                ),

                const SizedBox(height: 24),

                // Supervisor
                if (_expense!.activity?.supervisor != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Supervisor',
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
                              _expense!.activity!.supervisor.account?.name ?? '-',
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
                                          borderRadius: BorderRadius.circular(16),
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

                // Approval
                InfoSection(
                  title: 'Approval',
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
                        label: 'Approve On',
                        value:
                            "${_expense!.activity!.approvers.approvalDate.toDateTimeString()}"
                                "\n"
                                "${_expense!.activity!.approvers.approvalDate.toRelativeTime()}",
                      ),
                    if (_expense!.updatedAt != null)
                      InfoRow(
                        label: 'Requested At',
                        value: "${_expense!.createdAt!.toDateTimeString()}"
                            "\n"
                            "${_expense!.createdAt!.toRelativeTime()}",
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
                label: const Text('Export Expense'),
              ),
            ),
    );
  }
}

