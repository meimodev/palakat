import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/church/church.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;
import 'package:palakat_shared/palakat_shared.dart' as cm show Column;

class ChurchScreen extends ConsumerStatefulWidget {
  const ChurchScreen({super.key});

  @override
  ConsumerState<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends ConsumerState<ChurchScreen> {
  ChurchController get churchController =>
      ref.read(churchControllerProvider.notifier);

  ChurchState get state => ref.watch(churchControllerProvider);

  AppLocalizations get l10n => context.l10n;

  bool _permissionPolicyLoading = false;
  String? _permissionPolicyErrorMessage;
  ChurchPermissionPolicyRecord? _permissionPolicyRecord;

  @override
  void initState() {
    super.initState();
    _loadPermissionPolicy();
  }

  Future<void> _loadPermissionPolicy() async {
    if (mounted) {
      setState(() {
        _permissionPolicyLoading = true;
        _permissionPolicyErrorMessage = null;
      });
    }

    try {
      final repo = ref.read(churchPermissionPolicyRepositoryProvider);
      final res = await repo.fetchMyPolicy();

      if (!mounted) return;

      res.when(
        onSuccess: (record) {
          setState(() {
            _permissionPolicyRecord = record;
            _permissionPolicyErrorMessage = null;
          });
        },
        onFailure: (failure) {
          setState(() {
            _permissionPolicyErrorMessage = failure.message;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _permissionPolicyErrorMessage = context.l10n.err_loadFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _permissionPolicyLoading = false;
        });
      }
    }
  }

  void _openEditDrawer(Church church) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: InfoEditDrawer(
        church: church,
        onSave: (updatedChurch) async {
          try {
            await churchController.saveChurch(updatedChurch);
            if (!mounted) return;
            churchController.fetchChurch();
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: l10n.msg_saved,
              message: l10n.msg_updated,
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError ? e.userMessage : l10n.msg_updateFailed;
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: l10n.msg_updateFailed,
              message: msg,
              statusCode: code,
            );
          }
        },
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  void _openPermissionPolicyDrawer(
    OperationPermissionDefinition definition,
    List<MemberPosition> availablePositions,
  ) {
    final record = _permissionPolicyRecord;
    if (record == null) return;

    DrawerUtils.showDrawer(
      context: context,
      drawer: PermissionPolicyEditDrawer(
        definition: definition,
        record: record,
        availablePositions: availablePositions,
        onSaved: (updatedRecord) {
          if (!mounted) return;
          setState(() {
            _permissionPolicyRecord = updatedRecord;
            _permissionPolicyErrorMessage = null;
          });
        },
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  void _openLocationEditDrawer(Church church) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: LocationEditDrawer(
        church: church,
        onSave: (updatedChurch) async {
          try {
            await churchController.saveLocation(updatedChurch.location!);
            if (!mounted) return;
            // Refresh the specific location card to reflect latest data
            final locationId = church.locationId;
            if (locationId != null) {
              churchController.fetchLocation(locationId);
            }
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: l10n.msg_saved,
              message: l10n.msg_updated,
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError ? e.userMessage : l10n.msg_updateFailed;
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: l10n.msg_updateFailed,
              message: msg,
              statusCode: code,
            );
          }
        },
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  void _openColumnEditDrawer(cm.Column column) async {
    DrawerUtils.showDrawer(
      context: context,
      drawer: ColumnEditDrawer(
        columnId: column.id,
        churchId: column.churchId,
        onSave: (updatedColumn) async {
          try {
            await churchController.saveColumn(updatedColumn);
            if (!mounted) return;
            final churchId = state.church.value?.id ?? updatedColumn.churchId;
            churchController.fetchColumns(churchId);
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: l10n.msg_saved,
              message: l10n.msg_updated,
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError ? e.userMessage : l10n.msg_saveFailed;
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: l10n.msg_saveFailed,
              message: msg,
              statusCode: code,
            );
          }
        },
        onDelete: () {
          return churchController
              .deleteColumn(column.id!)
              .then((_) async {
                if (!mounted) return;
                final churchId = state.church.value?.id ?? column.churchId;
                churchController.fetchColumns(churchId);
                if (!mounted) return;
                AppSnackbars.showSuccess(
                  context,
                  title: l10n.msg_deleted,
                  message: l10n.msg_deleted,
                );
              })
              .catchError((e) {
                if (!mounted) return;
                final msg = e is AppError
                    ? e.userMessage
                    : l10n.msg_deleteFailed;
                final code = e is AppError ? e.statusCode : null;
                AppSnackbars.showError(
                  context,
                  title: l10n.msg_deleteFailed,
                  message: msg,
                  statusCode: code,
                );
              });
        },
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  void _openAddColumnDrawer(int churchId) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: ColumnEditDrawer(
        churchId: churchId,
        onSave: (newColumn) async {
          try {
            await churchController.createColumn(newColumn);
            if (!mounted) return;
            churchController.fetchColumns(newColumn.churchId);
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: l10n.msg_saved,
              message: l10n.msg_created,
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError ? e.userMessage : l10n.msg_createFailed;
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: l10n.msg_createFailed,
              message: msg,
              statusCode: code,
            );
          }
        },
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  void _openPositionEditDrawer(MemberPosition position) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: PositionEditDrawer(
        churchId: state.church.value!.id!,
        positionId: position.id!,
        onSave: (updatedPosition) async {
          try {
            await churchController.savePosition(updatedPosition);
            if (!mounted) return;
            churchController.fetchPositions(updatedPosition.churchId);
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: l10n.msg_saved,
              message: l10n.msg_updated,
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError ? e.userMessage : l10n.msg_saveFailed;
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: l10n.msg_saveFailed,
              message: msg,
              statusCode: code,
            );
          }
        },
        onDelete: () {
          final churchId = state.church.value?.id;
          if (churchId == null) return Future.value();
          return () async {
            try {
              await churchController.deletePosition(position.id!);
              if (!mounted) return;
              churchController.fetchPositions(churchId);
              if (!mounted) return;
              AppSnackbars.showSuccess(
                context,
                title: l10n.msg_deleted,
                message: l10n.msg_deleted,
              );
            } catch (e) {
              if (!mounted) return;
              final msg = e is AppError ? e.userMessage : l10n.msg_deleteFailed;
              final code = e is AppError ? e.statusCode : null;
              AppSnackbars.showError(
                context,
                title: l10n.msg_deleteFailed,
                message: msg,
                statusCode: code,
              );
            }
          }();
        },
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  void _openAddPositionDrawer() {
    DrawerUtils.showDrawer(
      context: context,
      drawer: PositionEditDrawer(
        churchId: state.church.value!.id!,
        onSave: (newPosition) async {
          try {
            await churchController.createPosition(newPosition);
            if (!mounted) return;
            churchController.fetchPositions(newPosition.churchId);
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: l10n.msg_saved,
              message: l10n.msg_created,
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError ? e.userMessage : l10n.msg_createFailed;
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: l10n.msg_createFailed,
              message: msg,
              statusCode: code,
            );
          }
        },
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.admin_church_title,
              style: theme.textTheme.headlineMedium,
            ),
            Text(
              l10n.admin_church_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            _buildChurchInformationSection(theme),
            const SizedBox(height: 24),

            _buildLocationSection(theme),
            const SizedBox(height: 24),

            _buildColumnManagementSection(theme),
            const SizedBox(height: 24),

            _buildPositionManagementSection(theme),
            const SizedBox(height: 24),

            _buildPermissionPolicySection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionPolicySection(ThemeData theme) {
    final enabled = state.church.hasValue;
    final positionsAsync = state.positions;
    final availablePositions = positionsAsync.value ?? const <MemberPosition>[];
    final l10n = context.l10n;
    final permissionDefinitions = buildOperationPermissionDefinitions(l10n);
    final selections = resolvePermissionSelections(
      policy: _permissionPolicyRecord?.policy,
      availablePositions: availablePositions,
    );
    final hasError =
        _permissionPolicyErrorMessage != null || positionsAsync.hasError;

    return ExpandableSurfaceCard(
      title: l10n.churchOperationsAccess_title,
      subtitle: l10n.churchOperationsAccess_subtitle,
      initiallyExpanded: true,
      trailing: IconButton(
        onPressed: enabled && !_permissionPolicyLoading
            ? _loadPermissionPolicy
            : null,
        icon: const Icon(Icons.refresh),
        tooltip: context.l10n.btn_retry,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _permissionPolicyLoading || positionsAsync.isLoading
            ? const SizedBox(height: 120, child: AppLoadingWidget())
            : hasError
            ? _cardError(
                onRetry: () {
                  _loadPermissionPolicy();
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.churchOperationsAccess_description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (availablePositions.isEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(
                          alpha: 0.35,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.churchOperationsAccess_emptyPositions,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppTable<OperationPermissionDefinition>(
                    loading: false,
                    data: permissionDefinitions,
                    columns: [
                      AppTableColumn<OperationPermissionDefinition>(
                        title: l10n.churchOperationsAccess_featureColumn,
                        flex: 4,
                        cellBuilder: (ctx, row) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                row.category,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                row.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                row.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      AppTableColumn<OperationPermissionDefinition>(
                        title:
                            l10n.churchOperationsAccess_assignedPositionsColumn,
                        flex: 3,
                        cellBuilder: (ctx, row) {
                          final assigned =
                              selections[row.key] ?? const <MemberPosition>[];
                          final configured = assigned.isNotEmpty;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                formatPermissionAssignmentSummary(
                                  assigned,
                                  l10n,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: configured
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.error,
                                  fontWeight: configured
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                configured
                                    ? l10n.churchOperationsAccess_assignedCount(
                                        assigned.length,
                                      )
                                    : l10n.churchOperationsAccess_needsConfiguration,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      AppTableColumn<OperationPermissionDefinition>(
                        title: l10n.tbl_status,
                        flex: 2,
                        cellBuilder: (ctx, row) {
                          final assigned =
                              selections[row.key] ?? const <MemberPosition>[];
                          final configured = assigned.isNotEmpty;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: configured
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              configured
                                  ? l10n.churchOperationsAccess_configured
                                  : l10n.churchOperationsAccess_needsSetup,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: configured
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                      AppTableColumn<OperationPermissionDefinition>(
                        title: l10n.churchOperationsAccess_actionColumn,
                        flex: 2,
                        cellBuilder: (ctx, row) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed:
                                  _permissionPolicyRecord == null ||
                                      availablePositions.isEmpty
                                  ? null
                                  : () => _openPermissionPolicyDrawer(
                                      row,
                                      availablePositions,
                                    ),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: Text(context.l10n.btn_edit),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _cardError({required VoidCallback onRetry}) {
    return SizedBox(
      width: double.infinity,
      child: ErrorDisplayWidget(
        message: context.l10n.error_loadingData,
        onRetry: onRetry,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildChurchInformationSection(ThemeData theme) {
    final infoAsync = state.church;

    return ExpandableSurfaceCard(
      title: l10n.card_basicInfo_title,
      subtitle: l10n.card_basicInfo_subtitle,
      initiallyExpanded: true,
      trailing: FilledButton.icon(
        onPressed: infoAsync.hasValue
            ? () => _openEditDrawer(infoAsync.value!)
            : null,
        icon: const Icon(Icons.edit),
        label: Text(l10n.btn_edit),
      ),
      child: infoAsync.when(
        loading: () => LoadingShimmer(
          child: ShimmerPlaceholders.detailSection(includeWideBlock: true),
        ),
        error: (e, st) =>
            _cardError(onRetry: () => churchController.fetchChurch()),
        data: (church) => LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildInfoRow(l10n.lbl_churchName, church.name, theme),
              const SizedBox(height: 16),
              _buildInfoPair(
                maxWidth: constraints.maxWidth,
                left: _buildInfoRow(
                  l10n.lbl_phone,
                  church.phoneNumber ?? l10n.lbl_na,
                  theme,
                ),
                right: _buildInfoRow(
                  l10n.lbl_email,
                  church.email ?? l10n.lbl_na,
                  theme,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                l10n.lbl_descriptionOptional,
                church.description ?? l10n.lbl_na,
                theme,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInfoPair({
    required double maxWidth,
    required Widget left,
    required Widget right,
  }) {
    if (maxWidth < 720) {
      return Column(children: [left, const SizedBox(height: 16), right]);
    }

    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildLocationSection(ThemeData theme) {
    final locationAsync = state.location;

    return ExpandableSurfaceCard(
      title: l10n.card_location_title,
      subtitle: l10n.card_location_subtitle,
      initiallyExpanded: true,
      trailing: FilledButton.icon(
        onPressed: (state.church.hasValue && locationAsync.hasValue)
            ? () => _openLocationEditDrawer(state.church.value!)
            : null,
        icon: const Icon(Icons.edit_location_alt),
        label: Text(l10n.btn_edit),
      ),
      child: locationAsync.when(
        loading: () => LoadingShimmer(
          child: ShimmerPlaceholders.detailSection(includeHeader: false),
        ),
        error: (e, st) => _cardError(
          onRetry: () => churchController.fetchLocation(
            state.location.value?.id ??
                churchController.locallyStoredChurch.locationId!,
          ),
        ),
        data: (location) => LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildInfoRow(l10n.lbl_address, location.name, theme),
              const SizedBox(height: 16),
              _buildInfoPair(
                maxWidth: constraints.maxWidth,
                left: _buildInfoRow(
                  l10n.lbl_latitude,
                  location.latitude?.toString() ?? l10n.lbl_na,
                  theme,
                ),
                right: _buildInfoRow(
                  l10n.lbl_longitude,
                  location.longitude?.toString() ?? l10n.lbl_na,
                  theme,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnManagementSection(ThemeData theme) {
    final columnsAsync = state.columns;

    return ExpandableSurfaceCard(
      title: l10n.card_columnManagement_title,
      initiallyExpanded: true,
      subtitle: l10n.card_columnManagement_subtitle,
      trailing: FilledButton.icon(
        onPressed: () => _openAddColumnDrawer(state.church.value!.id!),
        icon: const Icon(Icons.add),
        label: Text(l10n.btn_add),
      ),
      child: columnsAsync.when(
        loading: () => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: LoadingShimmer(
              child: ShimmerPlaceholders.tableSection(rows: 4, columns: 3),
            ),
          ),
        ),
        error: (e, st) => _cardError(
          onRetry: () => churchController.fetchColumns(
            (state.church.value?.id ??
                churchController.locallyStoredChurch.id)!,
          ),
        ),
        data: (columns) => Column(
          children: [
            const SizedBox(height: 16),
            ...columns.map((column) {
              final hoverColor = theme.colorScheme.primary.withValues(
                alpha: 0.04,
              );
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _openColumnEditDrawer(column);
                    },
                    hoverColor: hoverColor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 520;

                          return Row(
                            children: [
                              Expanded(
                                child: compact
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.lbl_hashId(
                                              column.id.toString(),
                                            ),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            column.name,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          SizedBox(
                                            width: 60,
                                            child: Text(
                                              l10n.lbl_hashId(
                                                column.id.toString(),
                                              ),
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              column.name,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionManagementSection(ThemeData theme) {
    final positionsAsync = state.positions;

    return ExpandableSurfaceCard(
      title: l10n.card_positionManagement_title,
      initiallyExpanded: true,
      subtitle: l10n.card_positionManagement_subtitle,
      trailing: FilledButton.icon(
        onPressed: _openAddPositionDrawer,
        icon: const Icon(Icons.add),
        label: Text(l10n.btn_add),
      ),
      child: positionsAsync.when(
        loading: () => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: LoadingShimmer(
              child: ShimmerPlaceholders.tableSection(rows: 4, columns: 2),
            ),
          ),
        ),
        error: (e, st) => _cardError(
          onRetry: () => churchController.fetchPositions(
            (state.church.value?.id ??
                churchController.locallyStoredChurch.id)!,
          ),
        ),
        data: (positions) => Column(
          children: [
            const SizedBox(height: 16),
            ...positions.map((position) {
              final hoverColor = theme.colorScheme.primary.withValues(
                alpha: 0.04,
              );
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openPositionEditDrawer(position),
                    hoverColor: hoverColor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 520;

                          return Row(
                            children: [
                              Expanded(
                                child: compact
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.lbl_hashId(
                                              position.id.toString(),
                                            ),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            position.name,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          SizedBox(
                                            width: 60,
                                            child: Text(
                                              l10n.lbl_hashId(
                                                position.id.toString(),
                                              ),
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              position.name,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
