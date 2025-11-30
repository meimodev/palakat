import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/financial/financial.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';

class FinancialAccountListScreen extends ConsumerStatefulWidget {
  const FinancialAccountListScreen({super.key});

  @override
  ConsumerState<FinancialAccountListScreen> createState() =>
      _FinancialAccountListScreenState();
}

class _FinancialAccountListScreenState
    extends ConsumerState<FinancialAccountListScreen> {
  void _showAddDrawer() {
    DrawerUtils.showDrawer(
      context: context,
      drawer: FinancialAccountEditDrawer(
        onClose: () => DrawerUtils.closeDrawer(context),
        onSave: (accountNumber, type, description) async {
          final controller = ref.read(
            financialAccountListControllerProvider.notifier,
          );
          await controller.createAccount(
            accountNumber: accountNumber,
            type: type,
            description: description,
          );
        },
      ),
    );
  }

  void _showEditDrawer(FinancialAccountNumber account) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: FinancialAccountEditDrawer(
        account: account,
        onClose: () => DrawerUtils.closeDrawer(context),
        onSave: (accountNumber, type, description) async {
          final controller = ref.read(
            financialAccountListControllerProvider.notifier,
          );
          await controller.updateAccount(
            id: account.id,
            accountNumber: accountNumber,
            type: type,
            description: description,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final state = ref.watch(financialAccountListControllerProvider);
    final controller = ref.watch(
      financialAccountListControllerProvider.notifier,
    );

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Account Numbers',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage predefined account numbers for revenues and expenses.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: _showAddDrawer,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Account Number'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: 'Account Numbers',
              subtitle:
                  'List of all financial account numbers for your church.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTable<FinancialAccountNumber>(
                    loading: state.accounts.isLoading,
                    data: state.accounts.value?.data ?? [],
                    errorText: state.accounts.hasError
                        ? state.accounts.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
                    onRowTap: _showEditDrawer,
                    pagination: () {
                      final pageSize =
                          state.accounts.value?.pagination.pageSize ?? 10;
                      final page = state.accounts.value?.pagination.page ?? 1;
                      final total = state.accounts.value?.pagination.total ?? 0;

                      final hasPrev =
                          state.accounts.value?.pagination.hasPrev ?? false;
                      final hasNext =
                          state.accounts.value?.pagination.hasNext ?? false;

                      return AppTablePaginationConfig(
                        total: total,
                        pageSize: pageSize,
                        page: page,
                        onPageSizeChanged: controller.onChangedPageSize,
                        onPageChanged: controller.onChangedPage,
                        onPrev: hasPrev ? controller.onPressedPrevPage : null,
                        onNext: hasNext ? controller.onPressedNextPage : null,
                      );
                    }.call(),
                    filtersConfig: AppTableFiltersConfig(
                      searchHint: 'Search by account number or description...',
                      onSearchChanged: controller.onChangedSearch,
                      dropdownLabel: 'Type',
                      dropdownOptions: {
                        for (var type in FinanceType.values)
                          type.value: type.displayName,
                      },
                      dropdownValue: state.typeFilter?.value,
                      onDropdownChanged: (value) {
                        final type = value != null
                            ? FinanceType.values.firstWhere(
                                (t) => t.value == value,
                              )
                            : null;
                        controller.onChangedTypeFilter(type);
                      },
                    ),
                    columns: _buildTableColumns(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AppTableColumn<FinancialAccountNumber>> _buildTableColumns() {
    final theme = Theme.of(context);
    return [
      AppTableColumn<FinancialAccountNumber>(
        title: 'Account Number',
        flex: 2,
        cellBuilder: (ctx, account) {
          return Text(
            account.accountNumber,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      AppTableColumn<FinancialAccountNumber>(
        title: 'Type',
        flex: 1,
        cellBuilder: (ctx, account) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: account.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      account.type.icon,
                      size: 14,
                      color: account.type.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      account.type.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: account.type.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      AppTableColumn<FinancialAccountNumber>(
        title: 'Description',
        flex: 3,
        cellBuilder: (ctx, account) {
          return Text(
            account.description ?? '-',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: account.description != null
                  ? null
                  : theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<FinancialAccountNumber>(
        title: 'Created Date',
        flex: 2,
        cellBuilder: (ctx, account) {
          if (account.createdAt == null) {
            return Text('-', style: theme.textTheme.bodyMedium);
          }
          final date = account.createdAt!.toCustomFormat("dd MMM yyyy");
          return Text(date, style: theme.textTheme.bodyMedium);
        },
      ),
    ];
  }
}
