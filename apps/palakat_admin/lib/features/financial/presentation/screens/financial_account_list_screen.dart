import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/cash/cash.dart';
import 'package:palakat_admin/features/financial/financial.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';

enum _FinancialSection { accountNumbers, cashAccounts, cashMutations }

class FinancialAccountListScreen extends ConsumerStatefulWidget {
  const FinancialAccountListScreen({super.key});

  @override
  ConsumerState<FinancialAccountListScreen> createState() =>
      _FinancialAccountListScreenState();
}

class _FinancialAccountListScreenState
    extends ConsumerState<FinancialAccountListScreen> {
  _FinancialSection _section = _FinancialSection.accountNumbers;

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

  void _showAddCashAccountDrawer({CashAccount? account}) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: CashAccountEditDrawer(
        account: account,
        onClose: () => DrawerUtils.closeDrawer(context),
        onSave: (name, currency, openingBalance) async {
          final controller = ref.read(cashAccountsControllerProvider.notifier);
          if (account?.id != null) {
            await controller.update(
              id: account!.id!,
              name: name,
              currency: currency,
              openingBalance: openingBalance,
            );
          } else {
            await controller.create(
              name: name,
              currency: currency,
              openingBalance: openingBalance,
            );
          }
        },
      ),
    );
  }

  void _showCashTransferDrawer() {
    final cashAccountsState = ref.read(cashAccountsControllerProvider);
    final accounts = cashAccountsState.accounts.asData?.value.data ?? const [];
    if (accounts.isEmpty) return;

    DrawerUtils.showDrawer(
      context: context,
      drawer: CashTransferDrawer(
        accounts: accounts,
        onClose: () => DrawerUtils.closeDrawer(context),
        onTransfer:
            ({
              required fromAccountId,
              required toAccountId,
              required amount,
              required happenedAt,
              String? note,
            }) async {
              final controller = ref.read(
                cashMutationsControllerProvider.notifier,
              );
              await controller.transfer(
                fromAccountId: fromAccountId,
                toAccountId: toAccountId,
                amount: amount,
                happenedAt: happenedAt,
                note: note,
              );
              await ref.read(cashAccountsControllerProvider.notifier).refresh();
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

    final cashAccountsState = ref.watch(cashAccountsControllerProvider);
    final cashAccountsController = ref.watch(
      cashAccountsControllerProvider.notifier,
    );

    final cashMutationsState = ref.watch(cashMutationsControllerProvider);
    final cashMutationsController = ref.watch(
      cashMutationsControllerProvider.notifier,
    );

    final canTransfer =
        (cashAccountsState.accounts.asData?.value.data ?? const []).isNotEmpty;

    String actionLabel;
    VoidCallback? onAction;
    if (_section == _FinancialSection.accountNumbers) {
      actionLabel = l10n.btn_addAccountNumber;
      onAction = _showAddDrawer;
    } else if (_section == _FinancialSection.cashAccounts) {
      actionLabel = l10n.btn_add;
      onAction = () => _showAddCashAccountDrawer();
    } else {
      actionLabel = l10n.btn_transfer;
      onAction = canTransfer ? _showCashTransferDrawer : null;
    }

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
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<_FinancialSection>(
              segments: [
                ButtonSegment<_FinancialSection>(
                  value: _FinancialSection.accountNumbers,
                  label: Text(l10n.card_accountNumbers_title),
                  icon: const Icon(Icons.numbers),
                ),
                ButtonSegment<_FinancialSection>(
                  value: _FinancialSection.cashAccounts,
                  label: Text(l10n.card_cashAccounts_title),
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                ),
                ButtonSegment<_FinancialSection>(
                  value: _FinancialSection.cashMutations,
                  label: Text(l10n.card_cashMutations_title),
                  icon: const Icon(Icons.swap_horiz),
                ),
              ],
              selected: {_section},
              onSelectionChanged: (value) {
                setState(() {
                  _section = value.first;
                });
              },
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: _section == _FinancialSection.accountNumbers
                  ? l10n.card_accountNumbers_title
                  : _section == _FinancialSection.cashAccounts
                  ? l10n.card_cashAccounts_title
                  : l10n.card_cashMutations_title,
              subtitle: _section == _FinancialSection.accountNumbers
                  ? l10n.card_accountNumbers_subtitle
                  : _section == _FinancialSection.cashAccounts
                  ? l10n.card_cashAccounts_subtitle
                  : l10n.card_cashMutations_subtitle,
              child: _section == _FinancialSection.accountNumbers
                  ? AppTable<FinancialAccountNumber>(
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
                        final total =
                            state.accounts.value?.pagination.total ?? 0;

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
                              ? FinanceType.values.firstWhere(
                                  (t) => t.value == value,
                                )
                              : null;
                          controller.onChangedTypeFilter(type);
                        },
                      ),
                      columns: _buildTableColumns(),
                    )
                  : _section == _FinancialSection.cashAccounts
                  ? AppTable<CashAccount>(
                      loading: cashAccountsState.accounts.isLoading,
                      data: cashAccountsState.accounts.value?.data ?? [],
                      errorText: cashAccountsState.accounts.hasError
                          ? cashAccountsState.accounts.error.toString()
                          : null,
                      onRetry: () => cashAccountsController.refresh(),
                      onRowTap: (row) =>
                          _showAddCashAccountDrawer(account: row),
                      pagination: () {
                        final pageSize =
                            cashAccountsState
                                .accounts
                                .value
                                ?.pagination
                                .pageSize ??
                            10;
                        final page =
                            cashAccountsState.accounts.value?.pagination.page ??
                            1;
                        final total =
                            cashAccountsState
                                .accounts
                                .value
                                ?.pagination
                                .total ??
                            0;

                        final hasPrev =
                            cashAccountsState
                                .accounts
                                .value
                                ?.pagination
                                .hasPrev ??
                            false;
                        final hasNext =
                            cashAccountsState
                                .accounts
                                .value
                                ?.pagination
                                .hasNext ??
                            false;

                        return AppTablePaginationConfig(
                          total: total,
                          pageSize: pageSize,
                          page: page,
                          onPageSizeChanged:
                              cashAccountsController.onChangedPageSize,
                          onPageChanged: cashAccountsController.onChangedPage,
                          onPrev: hasPrev
                              ? cashAccountsController.onPressedPrevPage
                              : null,
                          onNext: hasNext
                              ? cashAccountsController.onPressedNextPage
                              : null,
                        );
                      }.call(),
                      filtersConfig: AppTableFiltersConfig(
                        searchHint: l10n.hint_searchByAccountNumber,
                        onSearchChanged: cashAccountsController.onChangedSearch,
                      ),
                      columns: _buildCashAccountsColumns(),
                    )
                  : AppTable<CashMutation>(
                      loading: cashMutationsState.mutations.isLoading,
                      data: cashMutationsState.mutations.value?.data ?? [],
                      errorText: cashMutationsState.mutations.hasError
                          ? cashMutationsState.mutations.error.toString()
                          : null,
                      onRetry: () => cashMutationsController.refresh(),
                      pagination: () {
                        final pageSize =
                            cashMutationsState
                                .mutations
                                .value
                                ?.pagination
                                .pageSize ??
                            10;
                        final page =
                            cashMutationsState
                                .mutations
                                .value
                                ?.pagination
                                .page ??
                            1;
                        final total =
                            cashMutationsState
                                .mutations
                                .value
                                ?.pagination
                                .total ??
                            0;

                        final hasPrev =
                            cashMutationsState
                                .mutations
                                .value
                                ?.pagination
                                .hasPrev ??
                            false;
                        final hasNext =
                            cashMutationsState
                                .mutations
                                .value
                                ?.pagination
                                .hasNext ??
                            false;

                        return AppTablePaginationConfig(
                          total: total,
                          pageSize: pageSize,
                          page: page,
                          onPageSizeChanged:
                              cashMutationsController.onChangedPageSize,
                          onPageChanged: cashMutationsController.onChangedPage,
                          onPrev: hasPrev
                              ? cashMutationsController.onPressedPrevPage
                              : null,
                          onNext: hasNext
                              ? cashMutationsController.onPressedNextPage
                              : null,
                        );
                      }.call(),
                      filtersConfig: AppTableFiltersConfig(
                        searchHint: l10n.hint_searchByAccountNumber,
                        onSearchChanged:
                            cashMutationsController.onChangedSearch,
                        dateRangePreset: cashMutationsState.dateRangePreset,
                        customDateRange: cashMutationsState.customDateRange,
                        onDateRangePresetChanged:
                            cashMutationsController.onChangedDateRangePreset,
                        onCustomDateRangeSelected:
                            cashMutationsController.onCustomDateRangeSelected,
                        dropdownLabel: l10n.lbl_type,
                        dropdownOptions: {
                          'IN': 'IN',
                          'OUT': 'OUT',
                          'TRANSFER': 'TRANSFER',
                          'ADJUSTMENT': 'ADJUSTMENT',
                        },
                        dropdownValue: cashMutationsState.typeFilter?.apiValue,
                        onDropdownChanged: (value) {
                          cashMutationsController.onChangedTypeFilter(
                            CashMutationTypeApi.fromApiValue(value),
                          );
                        },
                      ),
                      columns: _buildCashMutationsColumns(),
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

  List<AppTableColumn<CashAccount>> _buildCashAccountsColumns() {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return [
      AppTableColumn<CashAccount>(
        title: l10n.tbl_name,
        flex: 3,
        cellBuilder: (ctx, row) {
          return Text(
            row.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      AppTableColumn<CashAccount>(
        title: l10n.tbl_currency,
        flex: 1,
        cellBuilder: (ctx, row) => Text(row.currency),
      ),
      AppTableColumn<CashAccount>(
        title: l10n.tbl_openingBalance,
        flex: 2,
        headerAlignment: Alignment.centerRight,
        cellAlignment: Alignment.centerRight,
        cellBuilder: (ctx, row) => Text((row.openingBalance).toCurrency),
      ),
      AppTableColumn<CashAccount>(
        title: l10n.tbl_balance,
        flex: 2,
        headerAlignment: Alignment.centerRight,
        cellAlignment: Alignment.centerRight,
        cellBuilder: (ctx, row) {
          final balance = row.balance ?? 0;
          return Text(
            balance.toCurrency,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: balance >= 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          );
        },
      ),
    ];
  }

  List<AppTableColumn<CashMutation>> _buildCashMutationsColumns() {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return [
      AppTableColumn<CashMutation>(
        title: l10n.tbl_type,
        flex: 2,
        cellBuilder: (ctx, row) => Text(row.type.apiValue),
      ),
      AppTableColumn<CashMutation>(
        title: l10n.tbl_from,
        flex: 3,
        cellBuilder: (ctx, row) => Text(
          row.fromAccount?.name ?? l10n.lbl_na,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<CashMutation>(
        title: l10n.tbl_to,
        flex: 3,
        cellBuilder: (ctx, row) => Text(
          row.toAccount?.name ?? l10n.lbl_na,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppTableColumn<CashMutation>(
        title: l10n.tbl_requestDate,
        flex: 2,
        cellBuilder: (ctx, row) => Text(row.happenedAt.toDateTimeString()),
      ),
      AppTableColumn<CashMutation>(
        title: l10n.tbl_amount,
        flex: 2,
        headerAlignment: Alignment.centerRight,
        cellAlignment: Alignment.centerRight,
        cellBuilder: (ctx, row) {
          final isOut =
              row.type == CashMutationType.out ||
              (row.type == CashMutationType.adjustment &&
                  row.fromAccountId != null);
          final color = isOut
              ? theme.colorScheme.error
              : theme.colorScheme.primary;
          final prefix = isOut ? '-' : '+';
          return Text(
            '$prefix${row.amount.toCurrency}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          );
        },
      ),
    ];
  }
}
