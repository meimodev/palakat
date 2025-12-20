import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../application/articles_controller.dart';
import '../data/article_model.dart';

String _formatDate(DateTime? value) {
  if (value == null) return '-';
  return DateFormat('d MMM yyyy').format(value.toLocal());
}

class _ArticleTypeOption {
  const _ArticleTypeOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

const _articleTypeOptions = <_ArticleTypeOption>[
  _ArticleTypeOption(
    value: 'PREACHING_MATERIAL',
    label: 'Preaching material',
    icon: Icons.menu_book_outlined,
  ),
  _ArticleTypeOption(
    value: 'GAME_INSTRUCTION',
    label: 'Game instruction',
    icon: Icons.sports_esports_outlined,
  ),
];

Widget _articleTypeChip(BuildContext context, String type) {
  final theme = Theme.of(context);
  _ArticleTypeOption? opt;
  try {
    opt = _articleTypeOptions.firstWhere((o) => o.value == type);
  } catch (_) {
    opt = null;
  }

  if (opt == null) {
    return TypeChip(label: type);
  }

  return Chip(
    avatar: Icon(opt.icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
    label: Text(opt.label),
    visualDensity: VisualDensity.compact,
  );
}

class ArticlesListScreen extends ConsumerWidget {
  const ArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(articlesControllerProvider.notifier);
    final state = ref.watch(articlesControllerProvider);
    final asyncItems = state.items;
    final items = asyncItems.asData?.value;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Articles', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        SurfaceCard(
          title: 'Manage Articles',
          subtitle: 'Create, publish, and organize global articles.',
          trailing: ElevatedButton.icon(
            onPressed: () => context.go('/articles/new'),
            icon: const Icon(Icons.add),
            label: const Text('New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: AppTable<ArticleModel>(
            loading: asyncItems.isLoading,
            data: items?.data ?? const [],
            errorText: asyncItems.hasError ? asyncItems.error.toString() : null,
            onRetry: controller.refresh,
            onRowTap: (row) => context.go('/articles/${row.id}'),
            filtersConfig: AppTableFiltersConfig(
              searchHint: 'Search title / excerpt / slug',
              onSearchChanged: controller.onChangedSearch,
              dropdownLabel: 'Status',
              dropdownOptions: const {
                'DRAFT': 'Draft',
                'PUBLISHED': 'Published',
                'ARCHIVED': 'Archived',
              },
              dropdownValue: state.status,
              onDropdownChanged: controller.onChangedStatus,
              actionLabel: 'Type',
              actionIcon: Icons.filter_alt_outlined,
              onActionPressed: () async {
                final picked = await showDialog<String?>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Filter by type'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('All'),
                            onTap: () => Navigator.of(context).pop(null),
                          ),
                          ListTile(
                            title: const Text('Preaching material'),
                            onTap: () =>
                                Navigator.of(context).pop('PREACHING_MATERIAL'),
                          ),
                          ListTile(
                            title: const Text('Game instruction'),
                            onTap: () =>
                                Navigator.of(context).pop('GAME_INSTRUCTION'),
                          ),
                        ],
                      ),
                    );
                  },
                );
                controller.onChangedType(picked);
              },
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
              AppTableColumn<ArticleModel>(
                title: 'Title',
                flex: 4,
                cellBuilder: (context, row) => Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<ArticleModel>(
                title: 'Type',
                flex: 2,
                cellBuilder: (context, row) => Align(
                  alignment: Alignment.centerLeft,
                  child: _articleTypeChip(context, row.type),
                ),
              ),
              AppTableColumn<ArticleModel>(
                title: 'Status',
                flex: 2,
                cellBuilder: (context, row) => Text(row.status),
              ),
              AppTableColumn<ArticleModel>(
                title: 'Published',
                flex: 2,
                cellBuilder: (context, row) => Text(
                  _formatDate(row.publishedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<ArticleModel>(
                title: 'Updated',
                flex: 2,
                cellBuilder: (context, row) => Text(
                  _formatDate(row.updatedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<ArticleModel>(
                title: 'Likes',
                flex: 1,
                headerAlignment: Alignment.centerRight,
                cellAlignment: Alignment.centerRight,
                cellBuilder: (context, row) => Text('${row.likesCount}'),
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
