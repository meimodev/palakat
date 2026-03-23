import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../application/church_requests_controller.dart';

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  return DateFormat('d MMM yyyy').format(value.toLocal());
}

String _statusLabel(BuildContext context, RequestStatus status) {
  final l10n = context.l10n;
  switch (status) {
    case RequestStatus.todo:
      return l10n.churchRequest_status_onReview;
    case RequestStatus.doing:
      return l10n.churchRequest_status_onProgress;
    case RequestStatus.done:
      return l10n.status_completed;
    case RequestStatus.rejected:
      return l10n.status_rejected;
  }
}

StatusChip _statusChip(BuildContext context, RequestStatus status) {
  final l10n = context.l10n;
  switch (status) {
    case RequestStatus.todo:
      return StatusChip(
        label: l10n.churchRequest_status_onReview,
        background: AppColors.warning,
        foreground: AppColors.onPrimary,
        icon: Icons.schedule,
      );
    case RequestStatus.doing:
      return StatusChip(
        label: l10n.churchRequest_status_onProgress,
        background: AppColors.primary,
        foreground: AppColors.onPrimary,
        icon: Icons.sync,
      );
    case RequestStatus.done:
      return StatusChip(
        label: l10n.status_completed,
        background: AppColors.success,
        foreground: AppColors.onPrimary,
        icon: Icons.check_circle,
      );
    case RequestStatus.rejected:
      return StatusChip(
        label: l10n.status_rejected,
        background: AppColors.error,
        foreground: AppColors.onPrimary,
        icon: Icons.cancel,
      );
  }
}

RequestStatus? _apiToStatus(String? value) {
  switch (value) {
    case null:
      return null;
    case 'TODO':
      return RequestStatus.todo;
    case 'DOING':
      return RequestStatus.doing;
    case 'DONE':
      return RequestStatus.done;
    case 'REJECTED':
      return RequestStatus.rejected;
  }
  return null;
}

class ChurchRequestsListScreen extends ConsumerWidget {
  const ChurchRequestsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(churchRequestsControllerProvider.notifier);
    final state = ref.watch(churchRequestsControllerProvider);
    final asyncItems = state.items;
    final items = asyncItems.asData?.value;
    final l10n = context.l10n;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.churchRequest_title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          title: l10n.churchRequest_title,
          subtitle: l10n.churchRequest_churchInformation,
          child: AppTable<ChurchRequest>(
            loading: asyncItems.isLoading,
            data: items?.data ?? const [],
            errorText: asyncItems.hasError ? asyncItems.error.toString() : null,
            onRetry: controller.refresh,
            onRowTap: (row) {
              final id = row.id;
              if (id != null) {
                context.go('/church-requests/$id');
              }
            },
            filtersConfig: AppTableFiltersConfig(
              searchHint: l10n.hint_searchByTitleDescription,
              onSearchChanged: controller.onChangedSearch,
              dropdownLabel: l10n.tbl_status,
              dropdownOptions: {
                'TODO': l10n.churchRequest_status_onReview,
                'DOING': l10n.churchRequest_status_onProgress,
                'DONE': l10n.status_completed,
                'REJECTED': l10n.status_rejected,
              },
              dropdownValue: state.status == null
                  ? null
                  : _statusLabel(context, state.status!),
              onDropdownChanged: (v) =>
                  controller.onChangedStatus(_apiToStatus(v)),
            ),
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
            columns: [
              AppTableColumn<ChurchRequest>(
                title: l10n.nav_church,
                flex: 4,
                cellBuilder: (context, row) => Text(
                  row.churchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<ChurchRequest>(
                title: l10n.lbl_contactPerson,
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.contactPerson,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<ChurchRequest>(
                title: l10n.tbl_phone,
                flex: 2,
                cellBuilder: (context, row) => Text(
                  row.contactPhone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<ChurchRequest>(
                title: l10n.tbl_status,
                flex: 2,
                cellBuilder: (context, row) => Align(
                  alignment: Alignment.centerLeft,
                  child: _statusChip(context, row.status),
                ),
              ),
              AppTableColumn<ChurchRequest>(
                title: l10n.tbl_requestDate,
                flex: 2,
                cellBuilder: (context, row) => Text(
                  _formatDate(row.createdAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
