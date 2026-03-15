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
    final l10n = context.l10n;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.nav_church,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          title: l10n.nav_church,
          subtitle: l10n.admin_church_subtitle,
          trailing: FilledButton.icon(
            onPressed: () => context.go('/churches/new'),
            icon: const Icon(Icons.add),
            label: Text(l10n.btn_add),
          ),
          child: AppTable<Church>(
            loading: asyncItems.isLoading,
            data: items?.data ?? const [],
            errorText: asyncItems.hasError ? asyncItems.error.toString() : null,
            onRetry: controller.refresh,
            onRowTap: (row) => context.go('/churches/${row.id}'),
            filtersConfig: AppTableFiltersConfig(
              searchHint: l10n.lbl_searchChurches,
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
                title: l10n.tbl_name,
                flex: 4,
                cellBuilder: (context, row) => Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Church>(
                title: l10n.tbl_phone,
                flex: 2,
                cellBuilder: (context, row) => Text(
                  row.phoneNumber?.toString() ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Church>(
                title: l10n.lbl_email,
                flex: 3,
                cellBuilder: (context, row) => Text(
                  row.email?.toString() ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppTableColumn<Church>(
                title: l10n.card_location_title,
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
