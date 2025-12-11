import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import '../state/approval_controller.dart';
import '../state/approval_screen_state.dart';
import '../widgets/approval_edit_drawer.dart';

class ApprovalScreen extends ConsumerStatefulWidget {
  const ApprovalScreen({super.key});

  @override
  ConsumerState<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends ConsumerState<ApprovalScreen> {
  ApprovalController get controller =>
      ref.read(approvalControllerProvider.notifier);

  ApprovalScreenState get state => ref.watch(approvalControllerProvider);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Approvals', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Configure approval routing rules and requirements.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            _buildApprovalRulesSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalRulesSection(ThemeData theme) {
    final rulesAsync = state.rules;
    final positionsAsync = state.positions;
    final rules = rulesAsync.value?.data ?? [];
    final pagination = rulesAsync.value?.pagination;
    final positions = positionsAsync.value?.data ?? [];

    return SurfaceCard(
      title: 'Approval Rules',
      subtitle: 'Configure approval routing rules and requirements',
      trailing: ElevatedButton.icon(
        onPressed: rulesAsync.hasValue && positionsAsync.hasValue
            ? () => _showAddRuleDialog(context)
            : null,
        icon: const Icon(Icons.add),
        label: const Text('Add Rule'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
      ),
      child: AppTable<ApprovalRule>(
        loading: rulesAsync.isLoading,
        data: rules,
        errorText: rulesAsync.hasError ? rulesAsync.error.toString() : null,
        onRetry: controller.refresh,
        filtersConfig: AppTableFiltersConfig(
          searchHint: 'Search approval rules...',
          onSearchChanged: controller.onChangedSearch,
          positionOptions: positions,
          positionValue:
              positions.isNotEmpty && state.selectedPositionId != null
              ? positions.firstWhere(
                  (p) => p.id == state.selectedPositionId,
                  orElse: () => positions.first,
                )
              : null,
          onPositionChanged: (position) {
            controller.onChangedPositionFilter(position?.id);
          },
          dropdownLabel: 'Status',
          dropdownOptions: const {'active': 'Active', 'inactive': 'Inactive'},
          dropdownValue: state.activeOnly == null
              ? null
              : (state.activeOnly! ? 'active' : 'inactive'),
          onDropdownChanged: (value) {
            final activeOnly = value == null
                ? null
                : (value == 'active' ? true : false);
            controller.onChangedActiveFilter(activeOnly);
          },
        ),
        pagination: pagination != null
            ? AppTablePaginationConfig(
                total: pagination.total,
                pageSize: pagination.pageSize,
                page: pagination.page,
                onPageSizeChanged: controller.onChangedPageSize,
                onPageChanged: controller.onChangedPage,
                onPrev: pagination.hasPrev ? controller.onPrevPage : null,
                onNext: pagination.hasNext ? controller.onNextPage : null,
              )
            : null,
        columns: _buildTableColumns(context),
        onRowTap: _showEditRuleDialog,
      ),
    );
  }

  /// Builds the table column configuration for the approval rules table
  List<AppTableColumn<ApprovalRule>> _buildTableColumns(BuildContext context) {
    return [
      AppTableColumn<ApprovalRule>(
        title: 'Rule Name',
        flex: 3,
        cellBuilder: (ctx, rule) {
          final theme = Theme.of(ctx);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rule.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (rule.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  rule.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          );
        },
      ),
      AppTableColumn<ApprovalRule>(
        title: 'Filters',
        flex: 2,
        cellBuilder: (ctx, rule) {
          final theme = Theme.of(ctx);
          final hasFilters =
              rule.activityType != null ||
              rule.financialType != null ||
              rule.financialAccountNumberId != null;

          if (!hasFilters) {
            return Text(
              'No filters',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            );
          }

          return Wrap(
            direction: Axis.vertical,
            spacing: 6,
            runSpacing: 4,
            children: [
              if (rule.activityType != null)
                Chip(
                  avatar: Icon(
                    Icons.event,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    rule.activityType!.displayName,
                    style: theme.textTheme.labelSmall,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.5),
                  side: BorderSide.none,
                ),
              if (rule.financialType != null)
                Chip(
                  avatar: Icon(
                    rule.financialType!.icon,
                    size: 14,
                    color: rule.financialType!.color,
                  ),
                  label: Text(
                    rule.financialType!.displayName,
                    style: theme.textTheme.labelSmall,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: rule.financialType!.color.withValues(
                    alpha: 0.1,
                  ),
                  side: BorderSide.none,
                ),
              if (rule.financialAccountNumber != null)
                Chip(
                  avatar: Icon(
                    Icons.account_balance,
                    size: 14,
                    color: theme.colorScheme.secondary,
                  ),
                  label: Text(
                    rule.financialAccountNumber!.accountNumber,
                    style: theme.textTheme.labelSmall,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: theme.colorScheme.secondaryContainer
                      .withValues(alpha: 0.5),
                  side: BorderSide.none,
                ),
            ],
          );
        },
      ),
      AppTableColumn<ApprovalRule>(
        title: 'Positions',
        flex: 2,
        cellBuilder: (ctx, rule) {
          final theme = Theme.of(ctx);
          return Wrap(
            spacing: 6,
            runSpacing: 4,
            children: rule.positions.map((position) {
              return Chip(
                label: Text(position.name, style: theme.textTheme.labelSmall),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          );
        },
      ),
      AppTableColumn<ApprovalRule>(
        title: 'Status',
        flex: 1,
        cellBuilder: (ctx, rule) {
          final theme = Theme.of(ctx);
          return Chip(
            label: Text(
              rule.active ? 'Active' : 'Inactive',
              style: theme.textTheme.labelSmall,
            ),
            backgroundColor: rule.active
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          );
        },
      ),
    ];
  }

  void _showAddRuleDialog(BuildContext ctx) {
    DrawerUtils.showDrawer(
      context: ctx,
      drawer: ApprovalEditDrawer(
        churchId: controller.church.id!,
        onSave: (rule) async {
          try {
            await controller.saveRule(rule);
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: 'Created',
              message: 'Approval rule created successfully',
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError
                ? e.userMessage
                : 'Failed to create approval rule';
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: 'Create failed',
              message: msg,
              statusCode: code,
            );
          }
        },
        onClose: () => DrawerUtils.closeDrawer(ctx),
      ),
    );
  }

  void _showEditRuleDialog(ApprovalRule rule) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: ApprovalEditDrawer(
        ruleId: rule.id,
        churchId: controller.church.id!,
        onSave: (updated) async {
          try {
            await controller.saveRule(updated);
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: 'Saved',
              message: 'Approval rule updated successfully',
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError
                ? e.userMessage
                : 'Failed to update approval rule';
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: 'Update failed',
              message: msg,
              statusCode: code,
            );
          }
        },
        onDelete: () async {
          try {
            await controller.deleteRule(rule.id!);
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: 'Deleted',
              message: 'Approval rule deleted successfully',
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError
                ? e.userMessage
                : 'Failed to delete approval rule';
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: 'Delete failed',
              message: msg,
              statusCode: code,
            );
          }
        },
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }
}
