import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/member/member.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class MemberScreen extends ConsumerStatefulWidget {
  const MemberScreen({super.key});

  @override
  ConsumerState<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends ConsumerState<MemberScreen> {
  /// Shows member drawer for editing or creating
  void _showMemberDrawer({int? accountId}) {
    final isEditing = accountId != null;

    DrawerUtils.showDrawer(
      context: context,
      drawer: MemberEditDrawer(
        accountId: accountId,
        onSave: (account) async {
          final controller = ref.read(memberControllerProvider.notifier);
          await controller.saveMember(account);
          if (!mounted) return;
          AppSnackbars.showSuccess(
            context,
            title: isEditing
                ? context.l10n.msg_saved
                : context.l10n.msg_created,
            message: isEditing
                ? context.l10n.msg_saved
                : context.l10n.msg_created,
          );
        },
        onDelete: isEditing
            ? () {
                final controller = ref.read(memberControllerProvider.notifier);
                controller
                    .deleteMember(accountId)
                    .then((_) {
                      if (!mounted) return;
                      AppSnackbars.showSuccess(
                        context,
                        title: context.l10n.msg_deleted,
                        message: context.l10n.msg_deleted,
                      );
                    })
                    .catchError((e) {
                      if (!mounted) return;
                      _handleMemberOperationError(
                        context,
                        e,
                        operation: 'delete',
                      );
                    });
              }
            : null,
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  /// Handles errors from member operations (save/create/delete)
  void _handleMemberOperationError(
    BuildContext context,
    dynamic error, {
    required String operation,
  }) {
    final msg = error is AppError
        ? error.userMessage
        : 'Failed to $operation member';
    final code = error is AppError ? error.statusCode : null;

    AppSnackbars.showError(
      context,
      title: operation == 'delete'
          ? context.l10n.msg_deleteFailed
          : context.l10n.msg_saveFailed,
      message: msg,
      statusCode: code,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final MemberScreenState state = ref.watch(memberControllerProvider);
    final MemberController controller = ref.watch(
      memberControllerProvider.notifier,
    );

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.admin_member_title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.card_memberDirectory_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: context.l10n.card_memberDirectory_title,
              subtitle: context.l10n.card_memberDirectory_subtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick stats row
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      QuickStatCard(
                        label: context.l10n.dashboard_totalMembers,
                        value: state.counts.value?.total.toString() ?? "",
                        icon: Icons.groups_outlined,
                        iconColor: Colors.orange.shade700,
                        iconBackgroundColor: Colors.orange.shade50,
                        isLoading: state.counts.isLoading,
                      ),
                      QuickStatCard(
                        label: context.l10n.tooltip_appLinked,
                        value: state.counts.value?.claimed.toString() ?? "",
                        icon: Icons.phone_android_outlined,
                        iconColor: Colors.purple.shade600,
                        iconBackgroundColor: Colors.purple.shade50,
                        isLoading: state.counts.isLoading,
                      ),
                      QuickStatCard(
                        label: context.l10n.lbl_baptized,
                        value: state.counts.value?.baptized.toString() ?? "",
                        icon: Icons.water_drop_outlined,
                        iconColor: Colors.blue.shade600,
                        iconBackgroundColor: Colors.blue.shade50,
                        isLoading: state.counts.isLoading,
                      ),
                      QuickStatCard(
                        label: context.l10n.lbl_sidi,
                        value: state.counts.value?.sidi.toString() ?? "",
                        icon: Icons.emoji_people_outlined,
                        iconColor: Colors.green.shade600,
                        iconBackgroundColor: Colors.green.shade50,
                        isLoading: state.counts.isLoading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTable<Account>(
                    loading: state.accounts.isLoading,
                    data: state.accounts.value?.data ?? [],
                    errorText: state.accounts.hasError
                        ? state.accounts.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
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
                      searchHint: context.l10n.hint_searchNameColumnPosition,
                      onSearchChanged: controller.onChangedSearch,
                      positionOptions: state.positions.value,
                      positionValue: state.selectedPosition,
                      onPositionChanged: controller.onChangedPosition,
                      actionLabel: context.l10n.drawer_addMember_title,
                      actionIcon: Icons.add,
                      onActionPressed: () => _showMemberDrawer(),
                    ),
                    onRowTap: (account) async {
                      _showMemberDrawer(accountId: account.id);
                    },
                    columns: _buildTableColumns(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the table column configuration for the members table
  static List<AppTableColumn<Account>> _buildTableColumns(BuildContext ctx) {
    return [
      AppTableColumn<Account>(
        title: ctx.l10n.tbl_name,
        flex: 4,
        cellBuilder: (ctx, account) => MemberNameCell(account: account),
      ),
      AppTableColumn<Account>(
        title: ctx.l10n.tbl_phone,
        flex: 3,
        cellBuilder: (ctx, account) {
          final theme = Theme.of(ctx);
          return SelectableText(
            account.phone?.formattedPhone ?? '-',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
      AppTableColumn<Account>(
        title: ctx.l10n.tbl_birth,
        flex: 2,
        cellBuilder: (ctx, account) {
          final theme = Theme.of(ctx);
          final formattedDob = account.dob.toCustomFormat('yyyy, MMMM dd');
          final age = account.calculateAge;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDob,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                age.formatted,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
      AppTableColumn<Account>(
        title: ctx.l10n.tbl_bipra,
        flex: 2,
        cellBuilder: (ctx, account) {
          final theme = Theme.of(ctx);
          final bipra = account.calculateBipra;
          return Text(
            bipra.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
      AppTableColumn<Account>(
        title: ctx.l10n.tbl_positions,
        flex: 3,
        cellBuilder: (ctx, account) {
          final positions = (account.membership?.membershipPositions ?? [])
              .map((e) => e.name)
              .toList();
          return PositionsCell(positions: positions);
        },
      ),
    ];
  }
}
