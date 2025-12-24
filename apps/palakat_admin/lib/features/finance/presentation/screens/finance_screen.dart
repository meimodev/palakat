import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/features/finance/finance.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/widgets.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final overviewState = ref.watch(financeOverviewControllerProvider);
    final overviewController = ref.watch(
      financeOverviewControllerProvider.notifier,
    );

    final dataState = ref.watch(financeDataControllerProvider);
    final dataController = ref.watch(financeDataControllerProvider.notifier);

    final overview = overviewState.overview.value;

    final lastUpdatedText = overview?.lastUpdatedAt == null
        ? l10n.lbl_na
        : overview!.lastUpdatedAt!.toDateTimeString();

    final subtitle = '${l10n.lbl_updatedAt}: $lastUpdatedText';

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.nav_finance, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              l10n.lbl_balance,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: l10n.lbl_balance,
              subtitle: subtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      QuickStatCard(
                        label: l10n.lbl_balance,
                        value: (overview?.totalBalance ?? 0).toCurrency,
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: Colors.indigo.shade700,
                        iconBackgroundColor: Colors.indigo.shade50,
                        isLoading: overviewState.overview.isLoading,
                        subtitle: subtitle,
                        width: 240,
                      ),
                      QuickStatCard(
                        label: '${l10n.paymentMethod_cash} ${l10n.lbl_balance}',
                        value: (overview?.cashBalance ?? 0).toCurrency,
                        icon: Icons.payments_outlined,
                        iconColor: Colors.green.shade700,
                        iconBackgroundColor: Colors.green.shade50,
                        isLoading: overviewState.overview.isLoading,
                        subtitle: subtitle,
                        width: 240,
                      ),
                      QuickStatCard(
                        label:
                            '${l10n.paymentMethod_cashless} ${l10n.lbl_balance}',
                        value: (overview?.cashlessBalance ?? 0).toCurrency,
                        icon: Icons.credit_card_outlined,
                        iconColor: Colors.purple.shade700,
                        iconBackgroundColor: Colors.purple.shade50,
                        isLoading: overviewState.overview.isLoading,
                        subtitle: subtitle,
                        width: 240,
                      ),
                    ],
                  ),
                  if (overviewState.overview.hasError) ...[
                    const SizedBox(height: 12),
                    CompactErrorWidget(
                      error: overviewState.overview.error as AppError,
                      onRetry: overviewController.refresh,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SurfaceCard(
              title: l10n.card_financeRecords_title,
              subtitle: l10n.card_financeRecords_subtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTable<FinanceEntry>(
                    loading: dataState.entries.isLoading,
                    data: dataState.entries.value?.data ?? [],
                    errorText: dataState.entries.hasError
                        ? dataState.entries.error.toString()
                        : null,
                    onRetry: () => dataController.refresh(),
                    pagination: () {
                      final pageSize =
                          dataState.entries.value?.pagination.pageSize ?? 10;
                      final page =
                          dataState.entries.value?.pagination.page ?? 1;
                      final total =
                          dataState.entries.value?.pagination.total ?? 0;

                      final hasPrev =
                          dataState.entries.value?.pagination.hasPrev ?? false;
                      final hasNext =
                          dataState.entries.value?.pagination.hasNext ?? false;

                      return AppTablePaginationConfig(
                        total: total,
                        pageSize: pageSize,
                        page: page,
                        onPageSizeChanged: dataController.onChangedPageSize,
                        onPageChanged: dataController.onChangedPage,
                        onPrev: hasPrev
                            ? dataController.onPressedPrevPage
                            : null,
                        onNext: hasNext
                            ? dataController.onPressedNextPage
                            : null,
                      );
                    }.call(),
                    filtersConfig: AppTableFiltersConfig(
                      searchHint: l10n.hint_searchByAccountNumber,
                      onSearchChanged: dataController.onChangedSearch,
                      dateRangePreset: dataState.dateRangePreset,
                      customDateRange: dataState.customDateRange,
                      onDateRangePresetChanged:
                          dataController.onChangedDateRangePreset,
                      onCustomDateRangeSelected:
                          dataController.onCustomDateRangeSelected,
                      dropdownLabel: l10n.filter_type,
                      dropdownOptions: {
                        FinanceEntryType.revenue.name: l10n.financeType_revenue,
                        FinanceEntryType.expense.name: l10n.financeType_expense,
                      },
                      dropdownValue: dataState.typeFilter?.name,
                      onDropdownChanged: (value) {
                        final type = value == null
                            ? null
                            : FinanceEntryType.fromString(value);
                        dataController.onChangedType(type);
                      },
                    ),
                    columns: _buildTableColumns(l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<AppTableColumn<FinanceEntry>> _buildTableColumns(dynamic l10n) {
    return [
      AppTableColumn<FinanceEntry>(
        title: l10n.tbl_type,
        flex: 1,
        cellBuilder: (ctx, entry) {
          return _FinanceTypeChip(type: entry.type);
        },
      ),
      AppTableColumn<FinanceEntry>(
        title: l10n.tbl_accountNumber,
        flex: 2,
        cellBuilder: (ctx, entry) {
          final theme = Theme.of(ctx);
          return Text(
            entry.accountNumber,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
      AppTableColumn<FinanceEntry>(
        title: l10n.tbl_activity,
        flex: 3,
        cellBuilder: (ctx, entry) {
          final theme = Theme.of(ctx);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.activity?.title ?? ctx.l10n.lbl_na,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (entry.activity?.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  entry.activity?.description ?? "",
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
      AppTableColumn<FinanceEntry>(
        title: l10n.tbl_requestDate,
        flex: 2,
        cellBuilder: (ctx, entry) {
          final theme = Theme.of(ctx);
          if (entry.createdAt == null) {
            return Text(ctx.l10n.lbl_na, style: theme.textTheme.bodyMedium);
          }
          final requestDate = entry.createdAt!;
          final date = requestDate.toCustomFormat("EEEE, dd MMMM yyyy");
          return Text(date, style: theme.textTheme.bodyMedium);
        },
      ),
      AppTableColumn<FinanceEntry>(
        title: l10n.tbl_amount,
        flex: 2,
        cellBuilder: (ctx, entry) {
          final theme = Theme.of(ctx);
          final isRevenue = entry.type == FinanceEntryType.revenue;
          final displayAmount = isRevenue
              ? entry.amount.toCurrency
              : ctx.l10n.lbl_negativeAmount(entry.amount.toCurrency);
          return Text(
            displayAmount,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isRevenue
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          );
        },
      ),
      AppTableColumn<FinanceEntry>(
        title: l10n.tbl_paymentMethod,
        flex: 2,
        cellBuilder: (ctx, entry) {
          return PaymentMethodChip(
            method: entry.paymentMethod,
            iconSize: 16,
            fontSize: 13,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          );
        },
      ),
    ];
  }
}

class _FinanceTypeChip extends StatelessWidget {
  const _FinanceTypeChip({required this.type});

  final FinanceEntryType type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRevenue = type == FinanceEntryType.revenue;

    final label = isRevenue
        ? l10n.financeType_revenue
        : l10n.financeType_expense;
    final color = isRevenue ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRevenue ? Icons.arrow_downward : Icons.arrow_upward,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
