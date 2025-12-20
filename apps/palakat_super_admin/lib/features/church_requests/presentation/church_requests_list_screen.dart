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

String _statusLabel(RequestStatus status) {
  switch (status) {
    case RequestStatus.todo:
      return 'TODO';
    case RequestStatus.doing:
      return 'DOING';
    case RequestStatus.done:
      return 'DONE';
    case RequestStatus.rejected:
      return 'REJECTED';
  }
}

StatusChip _statusChip(RequestStatus status) {
  switch (status) {
    case RequestStatus.todo:
      return StatusChip(
        label: 'TODO',
        background: Colors.orange.shade100,
        foreground: Colors.orange.shade900,
        icon: Icons.schedule,
      );
    case RequestStatus.doing:
      return StatusChip(
        label: 'DOING',
        background: Colors.blue.shade100,
        foreground: Colors.blue.shade900,
        icon: Icons.sync,
      );
    case RequestStatus.done:
      return StatusChip(
        label: 'DONE',
        background: Colors.green.shade100,
        foreground: Colors.green.shade900,
        icon: Icons.check_circle,
      );
    case RequestStatus.rejected:
      return StatusChip(
        label: 'REJECTED',
        background: Colors.red.shade100,
        foreground: Colors.red.shade900,
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

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Church Requests',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          title: 'Manage Church Requests',
          subtitle: 'Review, approve, or reject church registration requests.',
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
              searchHint: 'Search church name / address / contact',
              onSearchChanged: controller.onChangedSearch,
              dropdownLabel: 'Status',
              dropdownOptions: const {
                'TODO': 'TODO',
                'DOING': 'DOING',
                'DONE': 'DONE',
                'REJECTED': 'REJECTED',
              },
              dropdownValue: state.status == null
                  ? null
                  : _statusLabel(state.status!),
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
                title: 'Church',
                flex: 4,
                cellBuilder: (context, row) => Text(
                  row.churchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<ChurchRequest>(
                title: 'Contact',
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.contactPerson,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<ChurchRequest>(
                title: 'Phone',
                flex: 2,
                cellBuilder: (context, row) => Text(
                  row.contactPhone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<ChurchRequest>(
                title: 'Status',
                flex: 2,
                cellBuilder: (context, row) => Align(
                  alignment: Alignment.centerLeft,
                  child: _statusChip(row.status),
                ),
              ),
              AppTableColumn<ChurchRequest>(
                title: 'Submitted',
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
          return SingleChildScrollView(child: content);
        }
        return content;
      },
    );
  }
}
