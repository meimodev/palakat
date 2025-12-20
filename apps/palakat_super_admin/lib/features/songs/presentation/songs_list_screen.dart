import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../application/songs_controller.dart';
import '../data/admin_song_model.dart';

class SongsListScreen extends ConsumerWidget {
  const SongsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(songsControllerProvider.notifier);
    final state = ref.watch(songsControllerProvider);
    final asyncItems = state.items;
    final items = asyncItems.asData?.value;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Songs', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        SurfaceCard(
          title: 'Manage Songs',
          subtitle: 'Create and update song metadata and lyrics.',
          trailing: ElevatedButton.icon(
            onPressed: () => context.go('/songs/new'),
            icon: const Icon(Icons.add),
            label: const Text('New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: AppTable<AdminSongModel>(
            loading: asyncItems.isLoading,
            data: items?.data ?? const [],
            errorText: asyncItems.hasError ? asyncItems.error.toString() : null,
            onRetry: controller.refresh,
            onRowTap: (row) => context.go('/songs/${row.id}'),
            filtersConfig: AppTableFiltersConfig(
              searchHint: 'Search title / lyrics',
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
              AppTableColumn<AdminSongModel>(
                title: 'Title',
                flex: 4,
                cellBuilder: (context, row) => Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<AdminSongModel>(
                title: 'Book',
                flex: 2,
                cellBuilder: (context, row) => Text(row.book),
              ),
              AppTableColumn<AdminSongModel>(
                title: 'Index',
                flex: 1,
                headerAlignment: Alignment.centerRight,
                cellAlignment: Alignment.centerRight,
                cellBuilder: (context, row) =>
                    Center(child: Text('${row.index}')),
              ),
              AppTableColumn<AdminSongModel>(
                title: 'Link',
                flex: 4,
                cellBuilder: (context, row) => Text(
                  row.link,
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
