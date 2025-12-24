import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/financial/financial.dart';
import 'package:palakat_admin/extensions.dart';
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
    final l10n = context.l10n;

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
                      l10n.admin_financial_title,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.admin_financial_subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: _showAddDrawer,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.btn_addAccountNumber),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: l10n.card_accountNumbers_title,
              subtitle: l10n.card_accountNumbers_subtitle,
              child: AppTable<FinancialAccountNumber>(
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
                  searchHint: l10n.hint_searchAccountNumberDescription,
                  onSearchChanged: controller.onChangedSearch,
                  dropdownLabel: l10n.lbl_type,
                  dropdownOptions: {
                    for (var type in FinanceType.values)
                      type.value: type.displayName,
                  },
                  dropdownValue: state.typeFilter?.value,
                  onDropdownChanged: (value) {
                    final type = value != null
                        ? FinanceType.values.firstWhere((t) => t.value == value)
                        : null;
                    controller.onChangedTypeFilter(type);
                  },
                ),
                columns: _buildTableColumns(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AppTableColumn<FinancialAccountNumber>> _buildTableColumns() {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return [
      AppTableColumn<FinancialAccountNumber>(
        title: l10n.tbl_accountNumber,
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
        title: l10n.tbl_type,
        flex: 1,
        cellBuilder: (ctx, account) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: account.type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(account.type.icon, size: 14, color: account.type.color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    account.type.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: account.type.color,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      AppTableColumn<FinancialAccountNumber>(
        title: l10n.tbl_description,
        flex: 3,
        cellBuilder: (ctx, account) {
          return Text(
            account.description ?? l10n.lbl_na,
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
        title: l10n.tbl_linkedApprovalRule,
        flex: 2,
        cellBuilder: (ctx, account) {
          final approvalRule = account.approvalRule;
          if (approvalRule == null) {
            return Text(
              l10n.lbl_na,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          }
          return Text(
            approvalRule.name,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
    ];
  }
}
