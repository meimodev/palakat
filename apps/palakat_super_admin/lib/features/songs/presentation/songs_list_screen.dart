import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../application/songs_controller.dart';

class SongsListScreen extends ConsumerStatefulWidget {
  const SongsListScreen({super.key});

  @override
  ConsumerState<SongsListScreen> createState() => _SongsListScreenState();
}

class _SongsListScreenState extends ConsumerState<SongsListScreen> {
  bool _saving = false;

  Future<void> _reload(
    BuildContext context, {
    required bool discardDraft,
  }) async {
    final controller = ref.read(songsControllerProvider.notifier);
    if (!discardDraft) {
      await controller.refresh();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard local draft?'),
          content: const Text(
            'Reload will discard your local draft changes that have not been published.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard & Reload'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await controller.refresh(discardDraft: true);
  }

  Future<void> _save(BuildContext context) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final controller = ref.read(songsControllerProvider.notifier);
      final res = await controller.saveSongDb();
      final updatedAt = res['updatedAt'];
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Published songs.json${updatedAt != null ? ' at $updatedAt' : ''}',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(songsControllerProvider.notifier);
    final state = ref.watch(songsControllerProvider);
    final asyncDb = state.songDb;
    final db = asyncDb.asData?.value;
    final songs = controller.pagedSongs();
    final total = controller.totalFilteredCount();

    final bookOptions = db == null || db.books.isEmpty
        ? null
        : {
            for (final b in db.books)
              b.id: b.name.trim().isEmpty ? b.id : '${b.id} - ${b.name}',
          };

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Songs', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        SurfaceCard(
          title: 'Manage Songs',
          subtitle: 'Edit the published songs.json used by the mobile app.',
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: asyncDb.isLoading
                    ? null
                    : () => _reload(context, discardDraft: state.hasDraft),
                icon: asyncDb.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
              ElevatedButton.icon(
                onPressed: _saving || asyncDb.isLoading
                    ? null
                    : () => _save(context),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: const Text('Publish songs.json'),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/songs/new'),
                icon: const Icon(Icons.add),
                label: const Text('New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          child: AppTable<Song>(
            loading: asyncDb.isLoading,
            data: songs,
            errorText: asyncDb.hasError ? asyncDb.error.toString() : null,
            onRetry: controller.refresh,
            onRowTap: (row) => context.go('/songs/${row.id}'),
            filtersConfig: AppTableFiltersConfig(
              searchHint: 'Search title / lyrics',
              onSearchChanged: controller.onChangedSearch,
              dropdownLabel: 'Book',
              dropdownOptions: bookOptions,
              dropdownValue: state.bookIdFilter.isEmpty
                  ? null
                  : state.bookIdFilter,
              onDropdownChanged: controller.onChangedBookFilter,
            ),
            pagination: asyncDb.isLoading || asyncDb.hasError
                ? null
                : AppTablePaginationConfig(
                    total: total,
                    pageSize: state.pageSize,
                    page: state.page,
                    onPageSizeChanged: controller.onChangedPageSize,
                    onPageChanged: controller.onChangedPage,
                    onPrev: controller.hasPrev ? controller.onPrev : null,
                    onNext: controller.hasNext ? controller.onNext : null,
                  ),
            columns: [
              AppTableColumn<Song>(
                title: 'ID',
                flex: 2,
                cellBuilder: (context, row) => Text(row.id),
              ),
              AppTableColumn<Song>(
                title: 'Title',
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Song>(
                title: 'Sub Title',
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Song>(
                title: 'Book',
                flex: 2,
                cellBuilder: (context, row) => Text(
                  row.bookId.isNotEmpty ? row.bookId : row.bookName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (db != null) ...[
          const SizedBox(height: 12),
          Text(
            'songs_count=${db.songsCount}, books_count=${db.booksCount}, updatedAt=${db.updatedAt?.toIso8601String() ?? ""}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (state.hasDraft) ...[
            const SizedBox(height: 4),
            Text(
              'Local draft pending publish',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
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
