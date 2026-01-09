import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../application/membership_invitations_controller.dart';

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  return DateFormat('d MMM yyyy').format(value.toLocal());
}

String _statusLabel(MembershipInvitationStatus status) {
  switch (status) {
    case MembershipInvitationStatus.pending:
      return 'PENDING';
    case MembershipInvitationStatus.approved:
      return 'APPROVED';
    case MembershipInvitationStatus.rejected:
      return 'REJECTED';
  }
}

MembershipInvitationStatus? _apiToStatus(String? value) {
  switch ((value ?? '').trim().toUpperCase()) {
    case 'PENDING':
      return MembershipInvitationStatus.pending;
    case 'APPROVED':
      return MembershipInvitationStatus.approved;
    case 'REJECTED':
      return MembershipInvitationStatus.rejected;
  }
  return null;
}

StatusChip _statusChip(MembershipInvitationStatus status) {
  switch (status) {
    case MembershipInvitationStatus.pending:
      return StatusChip(
        label: 'PENDING',
        background: Colors.orange.shade100,
        foreground: Colors.orange.shade900,
        icon: Icons.schedule,
      );
    case MembershipInvitationStatus.approved:
      return StatusChip(
        label: 'APPROVED',
        background: Colors.green.shade100,
        foreground: Colors.green.shade800,
        icon: Icons.check_circle_outline,
      );
    case MembershipInvitationStatus.rejected:
      return StatusChip(
        label: 'REJECTED',
        background: Colors.red.shade100,
        foreground: Colors.red.shade900,
        icon: Icons.cancel_outlined,
      );
  }
}

class MembershipInvitationsListScreen extends ConsumerWidget {
  const MembershipInvitationsListScreen({super.key});

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = 'Confirm',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _promptRejectReason(BuildContext context) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject invitation'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Reason (optional)'),
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return null;
    return controller.text.trim().isEmpty ? null : controller.text.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      membershipInvitationsControllerProvider.notifier,
    );
    final state = ref.watch(membershipInvitationsControllerProvider);
    final asyncItems = state.items;
    final items = asyncItems.asData?.value;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Membership Invitations',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          title: 'Manage Membership Invitations',
          subtitle: 'Approve or reject member invitations across all churches.',
          child: AppTable<MembershipInvitation>(
            loading: asyncItems.isLoading,
            data: items?.data ?? const [],
            errorText: asyncItems.hasError ? asyncItems.error.toString() : null,
            onRetry: controller.refresh,
            pagination: items == null
                ? null
                : AppTablePaginationConfig(
                    total: items.pagination.total,
                    pageSize: items.pagination.pageSize,
                    page: items.pagination.page,
                    onPageSizeChanged: controller.onChangedPageSize,
                    onPageChanged: controller.onChangedPage,
                    onPrev: items.pagination.hasPrev ? controller.onPrev : null,
                    onNext: items.pagination.hasNext ? controller.onNext : null,
                  ),
            filtersConfig: AppTableFiltersConfig(
              searchHint: 'Search inviter / invitee / church / column / phone',
              onSearchChanged: controller.onChangedSearch,
              dateRangePreset: state.dateRangePreset,
              customDateRange: state.customDateRange,
              onDateRangePresetChanged: controller.onChangedDateRangePreset,
              onCustomDateRangeSelected: controller.onCustomDateRangeSelected,
              useRootNavigatorForDateRangePicker: true,
              dropdownLabel: 'Status',
              dropdownOptions: const {
                'PENDING': 'PENDING',
                'APPROVED': 'APPROVED',
                'REJECTED': 'REJECTED',
              },
              dropdownValue: state.status == null
                  ? null
                  : _statusLabel(state.status!),
              onDropdownChanged: (value) =>
                  controller.onChangedStatus(_apiToStatus(value)),
            ),
            columns: [
              AppTableColumn<MembershipInvitation>(
                title: 'ID',
                flex: 1,
                cellBuilder: (context, row) => Text('${row.id ?? '-'}'),
              ),
              AppTableColumn<MembershipInvitation>(
                title: 'Status',
                flex: 2,
                cellBuilder: (context, row) => _statusChip(row.status),
              ),
              AppTableColumn<MembershipInvitation>(
                title: 'Church',
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.church?.name ?? '- ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<MembershipInvitation>(
                title: 'Column',
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.column?.name ?? '- ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<MembershipInvitation>(
                title: 'Inviter',
                flex: 4,
                cellBuilder: (context, row) {
                  final name = row.inviter?.name ?? '-';
                  final phone = row.inviter?.phone ?? '-';
                  return Text(
                    '$name ($phone)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              AppTableColumn<MembershipInvitation>(
                title: 'Invitee',
                flex: 4,
                cellBuilder: (context, row) {
                  final name = row.invitee?.name ?? '-';
                  final phone = row.invitee?.phone ?? '-';
                  return Text(
                    '$name ($phone)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              AppTableColumn<MembershipInvitation>(
                title: 'Requested',
                flex: 2,
                cellBuilder: (context, row) => Text(_formatDate(row.createdAt)),
              ),
              AppTableColumn<MembershipInvitation>(
                title: 'Actions',
                flex: 3,
                cellAlignment: Alignment.centerRight,
                headerAlignment: Alignment.centerRight,
                cellBuilder: (context, row) {
                  final id = row.id;
                  final isPending =
                      row.status == MembershipInvitationStatus.pending;

                  return Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Approve',
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: (!isPending || id == null)
                            ? null
                            : () async {
                                final ok = await _confirm(
                                  context,
                                  title: 'Approve invitation',
                                  content:
                                      'Approve this invitation and create a membership for the invitee?',
                                  confirmLabel: 'Approve',
                                );
                                if (ok != true) return;
                                try {
                                  await controller.approve(id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Approved')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                      ),
                      IconButton(
                        tooltip: 'Reject',
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: (!isPending || id == null)
                            ? null
                            : () async {
                                final reason = await _promptRejectReason(
                                  context,
                                );
                                if (!context.mounted) return;
                                try {
                                  await controller.reject(
                                    id,
                                    rejectedReason: reason,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Rejected')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: id == null
                            ? null
                            : () async {
                                final ok = await _confirm(
                                  context,
                                  title: 'Delete invitation',
                                  content:
                                      'Delete this invitation? This cannot be undone.',
                                  confirmLabel: 'Delete',
                                );
                                if (ok != true) return;
                                try {
                                  await controller.delete(id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Deleted')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight) {
          return SingleChildScrollView(child: content);
        }
        return content;
      },
    );
  }
}
