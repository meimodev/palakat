import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/extension/extension.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/revenue/revenue.dart';
import 'package:palakat_admin/features/activity/activity.dart';

class RevenueDetailDrawer extends ConsumerStatefulWidget {
  final int revenueId;
  final VoidCallback onClose;

  const RevenueDetailDrawer({
    super.key,
    required this.revenueId,
    required this.onClose,
  });

  @override
  ConsumerState<RevenueDetailDrawer> createState() =>
      _RevenueDetailDrawerState();
}

class _RevenueDetailDrawerState extends ConsumerState<RevenueDetailDrawer> {
  bool _isLoading = true;
  String? _errorMessage;
  Revenue? _revenue;

  @override
  void initState() {
    super.initState();
    _fetchRevenue();
  }

  Future<void> _fetchRevenue() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(revenueControllerProvider.notifier);
      final revenue = await controller.fetchRevenue(widget.revenueId);
      if (mounted) {
        setState(() {
          _revenue = revenue;
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
    if (_revenue?.activity == null) return;
    DrawerUtils.showDrawer(
      context: context,
      drawer: ActivityDetailDrawer(
        activityId: _revenue!.activity!.id!,
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SideDrawer(
      title: 'Revenue Details',
      subtitle: 'View detailed information about this revenue entry',
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: 'Fetching revenue details...',
      errorMessage: _errorMessage,
      onRetry: _fetchRevenue,
      content: _revenue == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                InfoSection(
                  title: 'Basic Information',
                  children: [
                    InfoRow(
                      label: 'Revenue ID',
                      value: "# ${_revenue!.id?.toString() ?? '-'}",
                    ),
                    InfoRow(
                      label: 'Account Number',
                      value: _revenue!.accountNumber ?? '-',
                    ),
                    InfoRow(
                      label: 'Amount',
                      value: _revenue!.amount.toCurrency,
                      valueStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    InfoRow(
                      label: 'Payment Method',
                      value: _revenue!.paymentMethod.displayName,
                      valueWidget: Align(
                        alignment: Alignment.centerLeft,
                        child: PaymentMethodChip(method: _revenue!.paymentMethod),
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
                      value: "# ${_revenue!.activity!.id}",
                    ),
                    InfoRow(label: 'Title', value: _revenue!.activity!.title),
                    if (_revenue!.activity!.description != null)
                      InfoRow(
                        label: 'Description',
                        value: _revenue!.activity!.description!,
                      ),
                    InfoRow(
                      label: 'Activity Date & Time',
                      value: _revenue!.activity!.date.toDateTimeString(),
                    ),
                    if (_revenue!.activity!.note != null)
                      InfoRow(label: 'Note', value: _revenue!.activity!.note!),
                  ],
                ),

                const SizedBox(height: 24),

                // Supervisor
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
                            _revenue!.activity!.supervisor.account?.name ?? '-',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (_revenue!
                              .activity!
                              .supervisor
                              .membershipPositions
                              .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _revenue!
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

                // Approval
                InfoSection(
                  title: 'Approval',
                  trailing: Builder(
                    builder: (context) {
                      final status =
                          _revenue!.activity!.approvers.approvalStatus;
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
                    if (_revenue!.createdAt != null)
                      InfoRow(
                        label: 'Approve On',
                        value:
                            "${_revenue!.activity!.approvers.approvalDate.toDateTimeString()}"
                                "\n"
                                "${_revenue!.activity!.approvers.approvalDate.toRelativeTime()}",
                      ),
                    if (_revenue!.updatedAt != null)
                      InfoRow(
                        label: 'Requested At',
                        value: "${_revenue!.createdAt!.toDateTimeString()}"
                            "\n"
                            "${_revenue!.createdAt!.toRelativeTime()}",
                      ),
                  ],
                ),
              ],
            ),
      footer: Center(
        child: FilledButton.icon(
          onPressed: () {
            // Placeholder for future actions (e.g., edit, export)
          },
          icon: const Icon(Icons.print),
          label: const Text('Export Receipt'),
        ),
      ),
    );
  }
}
