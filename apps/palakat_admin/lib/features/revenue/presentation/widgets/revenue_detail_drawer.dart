import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/features/activity/activity.dart';
import 'package:palakat_admin/features/revenue/revenue.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';

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
    final l10n = context.l10n;
    return SideDrawer(
      title: l10n.drawer_revenueDetails_title,
      subtitle: l10n.drawer_revenueDetails_subtitle,
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: l10n.loading_revenue,
      errorMessage: _errorMessage,
      onRetry: _fetchRevenue,
      content: _revenue == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                InfoSection(
                  title: l10n.section_basicInformation,
                  children: [
                    InfoRow(
                      label: l10n.lbl_revenueId,
                      value: "# ${_revenue!.id?.toString() ?? '-'}",
                    ),
                    InfoRow(
                      label: l10n.lbl_accountNumber,
                      value: _revenue!.accountNumber,
                    ),
                    InfoRow(
                      label: l10n.lbl_amount,
                      value: _revenue!.amount.toCurrency,
                      valueStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    InfoRow(
                      label: l10n.lbl_method,
                      value: _revenue!.paymentMethod.displayName,
                      valueWidget: Align(
                        alignment: Alignment.centerLeft,
                        child: PaymentMethodChip(
                          method: _revenue!.paymentMethod,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Activity Information (only show if activity exists)
                if (_revenue!.activity != null) ...[
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
                        value: "# ${_revenue!.activity!.id}",
                      ),
                      InfoRow(label: l10n.lbl_title, value: _revenue!.activity!.title),
                      if (_revenue!.activity!.description != null)
                        InfoRow(
                          label: l10n.lbl_description,
                          value: _revenue!.activity!.description!,
                        ),
                      InfoRow(
                        label: l10n.lbl_activityDateTime,
                        value: _revenue!.activity!.date.toDateTimeString(),
                      ),
                      if (_revenue!.activity!.note != null)
                        InfoRow(
                          label: l10n.lbl_note,
                          value: _revenue!.activity!.note!,
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

                // Supervisor (only show if activity exists)
                if (_revenue!.activity?.supervisor != null) ...[
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
                              _revenue!.activity!.supervisor.account?.name ??
                                  '-',
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
                if (_revenue!.activity != null)
                  InfoSection(
                    title: l10n.section_approval,
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
                          label: l10n.lbl_approveOn,
                          value:
                              "${_revenue!.activity!.approvers.approvalDate.toDateTimeString()}"
                              "\n"
                              "${_revenue!.activity!.approvers.approvalDate.toRelativeTime()}",
                        ),
                      if (_revenue!.updatedAt != null)
                        InfoRow(
                          label: l10n.lbl_requestedAt,
                          value:
                              "${_revenue!.createdAt!.toDateTimeString()}"
                              "\n"
                              "${_revenue!.createdAt!.toRelativeTime()}",
                        ),
                    ],
                  ),

                // Timestamps (show when no activity)
                if (_revenue!.activity == null)
                  InfoSection(
                    title: l10n.section_timestamps,
                    children: [
                      if (_revenue!.createdAt != null)
                        InfoRow(
                          label: l10n.lbl_createdAt,
                          value:
                              "${_revenue!.createdAt!.toDateTimeString()}"
                              "\n"
                              "${_revenue!.createdAt!.toRelativeTime()}",
                        ),
                      if (_revenue!.updatedAt != null)
                        InfoRow(
                          label: l10n.lbl_updatedAt,
                          value:
                              "${_revenue!.updatedAt!.toDateTimeString()}"
                              "\n"
                              "${_revenue!.updatedAt!.toRelativeTime()}",
                        ),
                    ],
                  ),
              ],
            ),
      footer: _revenue == null
          ? null
          : Center(
              child: FilledButton.icon(
                onPressed: () {
                  // Placeholder for future actions (e.g., edit, export)
                },
                icon: const Icon(Icons.print),
                label: Text(l10n.btn_exportReceipt),
              ),
            ),
    );
  }
}
