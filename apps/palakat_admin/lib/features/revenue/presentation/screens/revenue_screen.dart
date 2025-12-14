import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/revenue/revenue.dart';

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  /// Shows revenue drawer for viewing
  void _showRevenueDrawer(int revenueId) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: RevenueDetailDrawer(
        revenueId: revenueId,
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final RevenueScreenState state = ref.watch(revenueControllerProvider);
    final RevenueController controller = ref.watch(
      revenueControllerProvider.notifier,
    );

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.admin_revenue_title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              l10n.admin_revenue_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: l10n.card_revenueLog_title,
              subtitle: l10n.card_revenueLog_subtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTable<Revenue>(
                    loading: state.revenues.isLoading,
                    data: state.revenues.value?.data ?? [],
                    errorText: state.revenues.hasError
                        ? state.revenues.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
                    pagination: () {
                      final pageSize =
                          state.revenues.value?.pagination.pageSize ?? 10;
                      final page = state.revenues.value?.pagination.page ?? 1;
                      final total = state.revenues.value?.pagination.total ?? 0;

                      final hasPrev =
                          state.revenues.value?.pagination.hasPrev ?? false;
                      final hasNext =
                          state.revenues.value?.pagination.hasNext ?? false;

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
                      dropdownOptions: {'cash': 'Cash', 'cashless': 'Cashless'},
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
                    onRowTap: (revenue) async {
                      if (revenue.id != null) {
                        _showRevenueDrawer(revenue.id!);
                      }
                    },
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

  /// Builds the table column configuration for the revenue table
  static List<AppTableColumn<Revenue>> _buildTableColumns(dynamic l10n) {
    return [
      AppTableColumn<Revenue>(
        title: l10n.tbl_accountNumber,
        flex: 2,
        cellBuilder: (ctx, revenue) {
          final theme = Theme.of(ctx);
          return Text(
            revenue.accountNumber,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
      AppTableColumn<Revenue>(
        title: l10n.tbl_activity,
        flex: 3,
        cellBuilder: (ctx, revenue) {
          final theme = Theme.of(ctx);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                revenue.activity?.title ?? '-',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (revenue.activity?.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  revenue.activity?.description ?? "",
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
      AppTableColumn<Revenue>(
        title: l10n.tbl_requestDate,
        flex: 2,
        cellBuilder: (ctx, revenue) {
          final theme = Theme.of(ctx);
          if (revenue.createdAt == null) {
            return Text('-', style: theme.textTheme.bodyMedium);
          }
          final requestDate = revenue.createdAt!;
          final date = requestDate.toCustomFormat("EEEE, dd MMMM yyyy");
          return Text(date, style: theme.textTheme.bodyMedium);
        },
      ),
      AppTableColumn<Revenue>(
        title: l10n.tbl_approvalDate,
        flex: 2,
        cellBuilder: (ctx, revenue) {
          final theme = Theme.of(ctx);
          if (revenue.activity?.date == null) {
            return Text('-', style: theme.textTheme.bodyMedium);
          }
          final approvalDate = revenue.activity!.approvers.approvalDate;
          final date = approvalDate.toCustomFormat("EEEE, dd MMMM yyyy");
          return Text(date, style: theme.textTheme.bodyMedium);
        },
      ),
      AppTableColumn<Revenue>(
        title: l10n.tbl_amount,
        flex: 2,
        cellBuilder: (ctx, revenue) {
          final theme = Theme.of(ctx);
          return Text(
            revenue.amount.toCurrency,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: revenue.amount > 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          );
        },
      ),
      AppTableColumn<Revenue>(
        title: l10n.tbl_paymentMethod,
        flex: 2,
        cellBuilder: (ctx, revenue) {
          return PaymentMethodChip(
            method: revenue.paymentMethod,
            iconSize: 16,
            fontSize: 13,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          );
        },
      ),
    ];
  }
}
