import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/expense/expense.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  /// Shows expense drawer for viewing
  void _showExpenseDrawer(int expenseId) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: ExpenseDetailDrawer(
        expenseId: expenseId,
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final ExpenseScreenState state = ref.watch(expenseControllerProvider);
    final ExpenseController controller = ref.watch(
      expenseControllerProvider.notifier,
    );

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.nav_expense, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              l10n.card_expenseRecords_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: l10n.card_expenseRecords_title,
              subtitle: l10n.card_expenseRecords_subtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTable<Expense>(
                    loading: state.expenses.isLoading,
                    data: state.expenses.value?.data ?? [],
                    errorText: state.expenses.hasError
                        ? state.expenses.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
                    pagination: () {
                      final pageSize =
                          state.expenses.value?.pagination.pageSize ?? 10;
                      final page = state.expenses.value?.pagination.page ?? 1;
                      final total = state.expenses.value?.pagination.total ?? 0;

                      final hasPrev =
                          state.expenses.value?.pagination.hasPrev ?? false;
                      final hasNext =
                          state.expenses.value?.pagination.hasNext ?? false;

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
                      searchHint: l10n.hint_searchByAccountNumber,
                      onSearchChanged: controller.onChangedSearch,
                      dateRangePreset: state.dateRangePreset,
                      customDateRange: state.customDateRange,
                      onDateRangePresetChanged:
                          controller.onChangedDateRangePreset,
                      onCustomDateRangeSelected:
                          controller.onCustomDateRangeSelected,
                      dropdownLabel: l10n.filter_paymentMethod,
                      dropdownOptions: {
                        PaymentMethod.cash.name: PaymentMethod.cash.displayName,
                        PaymentMethod.cashless.name:
                            PaymentMethod.cashless.displayName,
                      },
                      dropdownValue: state.paymentMethodFilter?.name,
                      onDropdownChanged: (value) {
                        final paymentMethod = value == null
                            ? null
                            : PaymentMethod.values.firstWhere(
                                (e) => e.name == value,
                              );
                        controller.onChangedPaymentMethod(paymentMethod);
                      },
                    ),
                    onRowTap: (expense) async {
                      if (expense.id != null) {
                        _showExpenseDrawer(expense.id!);
                      }
                    },
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

  /// Builds the table column configuration for the expense table
  List<AppTableColumn<Expense>> _buildTableColumns() {
    final l10n = context.l10n;
    return [
      AppTableColumn<Expense>(
        title: l10n.tbl_accountNumber,
        flex: 2,
        cellBuilder: (ctx, expense) {
          final theme = Theme.of(ctx);
          return Text(
            expense.accountNumber,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
      AppTableColumn<Expense>(
        title: l10n.tbl_activity,
        flex: 3,
        cellBuilder: (ctx, expense) {
          final theme = Theme.of(ctx);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                expense.activity?.title ?? ctx.l10n.lbl_na,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (expense.activity?.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  expense.activity?.description ?? "",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          );
        },
      ),
      AppTableColumn<Expense>(
        title: l10n.tbl_requestDate,
        flex: 2,
        cellBuilder: (ctx, expense) {
          final theme = Theme.of(ctx);
          if (expense.createdAt == null) {
            return Text(ctx.l10n.lbl_na, style: theme.textTheme.bodyMedium);
          }
          final requestDate = expense.createdAt!;
          final date = requestDate.toCustomFormat("EEEE, dd MMMM yyyy");
          return Text(date, style: theme.textTheme.bodyMedium);
        },
      ),
      AppTableColumn<Expense>(
        title: l10n.tbl_approvalDate,
        flex: 2,
        cellBuilder: (ctx, expense) {
          final theme = Theme.of(ctx);
          if (expense.activity?.date == null) {
            return Text(ctx.l10n.lbl_na, style: theme.textTheme.bodyMedium);
          }
          final approvalDate = expense.activity!.approvers.approvalDate;
          final date = approvalDate.toCustomFormat("EEEE, dd MMMM yyyy");
          return Text(date, style: theme.textTheme.bodyMedium);
        },
      ),
      AppTableColumn<Expense>(
        title: l10n.tbl_amount,
        flex: 2,
        cellBuilder: (ctx, expense) {
          final theme = Theme.of(ctx);
          return Text(
            ctx.l10n.lbl_negativeAmount(expense.amount.toCurrency),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      AppTableColumn<Expense>(
        title: l10n.tbl_paymentMethod,
        flex: 2,
        cellBuilder: (ctx, expense) {
          return PaymentMethodChip(
            method: expense.paymentMethod,
            iconSize: 16,
            fontSize: 13,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          );
        },
      ),
    ];
  }
}
