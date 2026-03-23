import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../application/membership_invitations_controller.dart';

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  return DateFormat('d MMM yyyy').format(value.toLocal());
}

String _statusLabel(BuildContext context, MembershipInvitationStatus status) {
  final l10n = context.l10n;
  switch (status) {
    case MembershipInvitationStatus.pending:
      return l10n.status_pending;
    case MembershipInvitationStatus.approved:
      return l10n.status_approved;
    case MembershipInvitationStatus.rejected:
      return l10n.status_rejected;
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

StatusChip _statusChip(
  BuildContext context,
  MembershipInvitationStatus status,
) {
  final l10n = context.l10n;
  switch (status) {
    case MembershipInvitationStatus.pending:
      return StatusChip(
        label: l10n.status_pending,
        background: AppColors.warning,
        foreground: AppColors.onPrimary,
        icon: Icons.schedule,
      );
    case MembershipInvitationStatus.approved:
      return StatusChip(
        label: l10n.status_approved,
        background: AppColors.success,
        foreground: AppColors.onPrimary,
        icon: Icons.check_circle_outline,
      );
    case MembershipInvitationStatus.rejected:
      return StatusChip(
        label: l10n.status_rejected,
        background: AppColors.error,
        foreground: AppColors.onPrimary,
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
    String? confirmLabel,
  }) {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.btn_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel ?? l10n.btn_confirm),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _promptRejectReason(BuildContext context) async {
    final controller = TextEditingController();
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.btn_reject),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: '${l10n.lbl_note} ${l10n.lbl_optional}',
            ),
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.btn_cancel),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.btn_reject),
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
    final l10n = context.l10n;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.dashboard_membershipInvitation_title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          title: l10n.dashboard_membershipInvitation_title,
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
              searchHint: l10n.dashboard_membershipInvitation_searchHint,
              onSearchChanged: controller.onChangedSearch,
              dateRangePreset: state.dateRangePreset,
              customDateRange: state.customDateRange,
              onDateRangePresetChanged: controller.onChangedDateRangePreset,
              onCustomDateRangeSelected: controller.onCustomDateRangeSelected,
              useRootNavigatorForDateRangePicker: true,
              dropdownLabel: l10n.tbl_status,
              dropdownOptions: {
                'PENDING': l10n.status_pending,
                'APPROVED': l10n.status_approved,
                'REJECTED': l10n.status_rejected,
              },
              dropdownValue: state.status == null
                  ? null
                  : _statusLabel(context, state.status!),
              onDropdownChanged: (value) =>
                  controller.onChangedStatus(_apiToStatus(value)),
            ),
            columns: [
              AppTableColumn<MembershipInvitation>(
                title: l10n.tbl_id,
                flex: 1,
                cellBuilder: (context, row) => Text('${row.id ?? '-'}'),
              ),
              AppTableColumn<MembershipInvitation>(
                title: l10n.tbl_status,
                flex: 2,
                cellBuilder: (context, row) => _statusChip(context, row.status),
              ),
              AppTableColumn<MembershipInvitation>(
                title: l10n.nav_church,
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.church?.name ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<MembershipInvitation>(
                title: l10n.lbl_columnName,
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.column?.name ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<MembershipInvitation>(
                title: l10n.dashboard_membershipInvitation_inviter,
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
                title: l10n.dashboard_membershipInvitation_invitee,
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
                title: l10n.tbl_requestDate,
                flex: 2,
                cellBuilder: (context, row) => Text(_formatDate(row.createdAt)),
              ),
              AppTableColumn<MembershipInvitation>(
                title: l10n.churchOperationsAccess_actionColumn,
                flex: 3,
                cellAlignment: Alignment.centerRight,
                headerAlignment: Alignment.centerRight,
                cellBuilder: (context, row) {
                  final id = row.id;
                  final isPending =
                      row.status == MembershipInvitationStatus.pending;

                  return Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      IconButton(
                        tooltip: l10n.btn_approve,
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: (!isPending || id == null)
                            ? null
                            : () async {
                                final ok = await _confirm(
                                  context,
                                  title: l10n.btn_approve,
                                  content: l10n
                                      .dashboard_membershipInvitation_confirmApprove,
                                  confirmLabel: l10n.btn_approve,
                                );
                                if (ok != true) return;
                                try {
                                  await controller.approve(id);
                                  if (context.mounted) {
                                    AppSnackbars.showSuccess(
                                      context,
                                      message: l10n
                                          .dashboard_membershipInvitation_snackbarApproved,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppSnackbars.showError(
                                      context,
                                      message: e.toString(),
                                    );
                                  }
                                }
                              },
                      ),
                      IconButton(
                        tooltip: l10n.btn_reject,
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
                                    AppSnackbars.showSuccess(
                                      context,
                                      message: l10n
                                          .dashboard_membershipInvitation_snackbarRejected,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppSnackbars.showError(
                                      context,
                                      message: e.toString(),
                                    );
                                  }
                                }
                              },
                      ),
                      IconButton(
                        tooltip: l10n.btn_delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: id == null
                            ? null
                            : () async {
                                final ok = await _confirm(
                                  context,
                                  title: l10n.btn_delete,
                                  content: l10n
                                      .dashboard_membershipInvitation_confirmDelete,
                                  confirmLabel: l10n.btn_delete,
                                );
                                if (ok != true) return;
                                try {
                                  await controller.delete(id);
                                  if (context.mounted) {
                                    AppSnackbars.showSuccess(
                                      context,
                                      message: l10n.msg_deleted,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppSnackbars.showError(
                                      context,
                                      message: e.toString(),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: content,
          );
        }
        return content;
      },
    );
  }
}
