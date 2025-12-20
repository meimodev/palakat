import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../application/churches_controller.dart';

class ChurchesListScreen extends ConsumerWidget {
  const ChurchesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(churchesControllerProvider.notifier);
    final state = ref.watch(churchesControllerProvider);
    final asyncItems = state.items;
    final items = asyncItems.asData?.value;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Churches', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        SurfaceCard(
          title: 'Manage Churches',
          subtitle: 'Create and update church profiles and their locations.',
          trailing: ElevatedButton.icon(
            onPressed: () => context.go('/churches/new'),
            icon: const Icon(Icons.add),
            label: const Text('New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: AppTable<Church>(
            loading: asyncItems.isLoading,
            data: items?.data ?? const [],
            errorText: asyncItems.hasError ? asyncItems.error.toString() : null,
            onRetry: controller.refresh,
            onRowTap: (row) => context.go('/churches/${row.id}'),
            filtersConfig: AppTableFiltersConfig(
              searchHint: 'Search church name',
              onSearchChanged: controller.onChangedSearch,
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
              AppTableColumn<Church>(
                title: 'Name',
                flex: 4,
                cellBuilder: (context, row) => Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Church>(
                title: 'Phone',
                flex: 2,
                cellBuilder: (context, row) => Text(
                  row.phoneNumber?.toString() ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Church>(
                title: 'Email',
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.email?.toString() ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Church>(
                title: 'Location',
                flex: 4,
                cellBuilder: (context, row) => Text(
                  row.location?.name ?? '-',
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
