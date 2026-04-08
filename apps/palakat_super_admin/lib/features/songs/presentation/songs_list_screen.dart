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
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.songs_discardDraftTitle),
          content: Text(l10n.songs_discardDraftContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.btn_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.songs_discardDraftAction),
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
        final msg = updatedAt != null
            ? context.l10n.msg_publishedSongsJson(updatedAt.toString())
            : context.l10n.msg_publishedSongsJsonWithoutDate;
        AppSnackbars.showSuccess(context, message: msg);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbars.showError(context, message: e.toString());
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
    final l10n = context.l10n;

    final bookOptions = db == null || db.books.isEmpty
        ? null
        : {
            for (final b in db.books)
              b.id: b.name.trim().isEmpty ? b.id : '${b.id} - ${b.name}',
          };

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.nav_songs, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        SurfaceCard(
          title: l10n.songBook_title,
          subtitle: l10n.songs_manageSubtitle,
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: asyncDb.isLoading
                    ? null
                    : () => _reload(context, discardDraft: state.hasDraft),
                icon: LoadingActionContent(
                  isLoading: asyncDb.isLoading,
                  loaderSize: 18,
                  child: const Icon(Icons.refresh),
                ),
                label: Text(l10n.btn_retry),
              ),
              FilledButton.tonalIcon(
                onPressed: _saving || asyncDb.isLoading
                    ? null
                    : () => _save(context),
                icon: LoadingActionContent(
                  isLoading: _saving,
                  loaderSize: 18,
                  child: const Icon(Icons.cloud_upload_outlined),
                ),
                label: Text(l10n.songs_publishAction),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/songs/new'),
                icon: const Icon(Icons.add),
                label: Text(l10n.btn_add),
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
              searchHint: l10n.songBook_searchHint,
              onSearchChanged: controller.onChangedSearch,
              dropdownLabel: l10n.songDetail_field_book,
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
                title: l10n.tbl_id,
                flex: 2,
                cellBuilder: (context, row) => Text(row.id),
              ),
              AppTableColumn<Song>(
                title: l10n.tbl_title,
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Song>(
                title: l10n.tbl_subtitle,
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Song>(
                title: l10n.songDetail_field_book,
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
            l10n.lbl_songsCount(
              db.songsCount,
              db.booksCount,
              db.updatedAt?.toIso8601String() ?? "",
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (state.hasDraft) ...[
            const SizedBox(height: 4),
            Text(
              l10n.songs_localDraftPendingPublish,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
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
