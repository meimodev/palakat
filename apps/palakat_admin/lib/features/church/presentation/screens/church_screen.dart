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

  void _openPermissionPolicyDrawer() {
    DrawerUtils.showDrawer(
      context: context,
      drawer: PermissionPolicyEditDrawer(
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

    return ExpandableSurfaceCard(
      title: 'Operations access control',
      subtitle: 'Configure which positions can access Operations features',
      initiallyExpanded: true,
      trailing: ElevatedButton.icon(
        onPressed: enabled ? _openPermissionPolicyDrawer : null,
        icon: const Icon(Icons.security),
        label: Text(context.l10n.btn_edit),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Publishing is open to all members. Other Operations features can be restricted by position.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardError({
    required ThemeData theme,
    required Object error,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.error_loadingData,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.btn_retry),
          ),
        ],
      ),
    );
  }

  Widget _buildChurchInformationSection(ThemeData theme) {
    final infoAsync = state.church;

    return ExpandableSurfaceCard(
      title: l10n.card_basicInfo_title,
      subtitle: l10n.card_basicInfo_subtitle,
      initiallyExpanded: true,
      trailing: ElevatedButton.icon(
        onPressed: infoAsync.hasValue
            ? () => _openEditDrawer(infoAsync.value!)
            : null,
        icon: const Icon(Icons.edit),
        label: Text(l10n.btn_edit),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
      ),
      child: infoAsync.when(
        loading: () => LoadingShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ShimmerPlaceholders.text(width: 220, height: 16),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ShimmerPlaceholders.text(
                      width: double.infinity,
                      height: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShimmerPlaceholders.text(
                      width: double.infinity,
                      height: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ShimmerPlaceholders.text(width: double.infinity, height: 48),
              const SizedBox(height: 16),
            ],
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
          onRetry: () => churchController.fetchChurch(),
        ),
        data: (church) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildInfoRow(l10n.lbl_churchName, church.name, theme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    l10n.lbl_phone,
                    church.phoneNumber ?? l10n.lbl_na,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow(
                    l10n.lbl_email,
                    church.email ?? l10n.lbl_na,
                    theme,
                  ),
                ),
              ],
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

  Widget _buildLocationSection(ThemeData theme) {
    final locationAsync = state.location;

    return ExpandableSurfaceCard(
      title: l10n.card_location_title,
      subtitle: l10n.card_location_subtitle,
      initiallyExpanded: true,
      trailing: ElevatedButton.icon(
        onPressed: (state.church.hasValue && locationAsync.hasValue)
            ? () => _openLocationEditDrawer(state.church.value!)
            : null,
        icon: const Icon(Icons.edit_location_alt),
        label: Text(l10n.btn_edit),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
      ),
      child: locationAsync.when(
        loading: () => LoadingShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ShimmerPlaceholders.text(width: double.infinity, height: 16),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ShimmerPlaceholders.text(
                      width: double.infinity,
                      height: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShimmerPlaceholders.text(
                      width: double.infinity,
                      height: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
          onRetry: () => churchController.fetchLocation(
            state.location.value?.id ??
                churchController.locallyStoredChurch.locationId!,
          ),
        ),
        data: (location) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildInfoRow(l10n.lbl_address, location.name, theme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    l10n.lbl_latitude,
                    location.latitude?.toString() ?? l10n.lbl_na,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow(
                    l10n.lbl_longitude,
                    location.longitude?.toString() ?? l10n.lbl_na,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
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
      trailing: ElevatedButton.icon(
        onPressed: () => _openAddColumnDrawer(state.church.value!.id!),
        icon: const Icon(Icons.add),
        label: Text(l10n.btn_add),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
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
              child: ShimmerPlaceholders.table(rows: 4, columns: 3),
            ),
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    l10n.lbl_hashId(column.id.toString()),
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
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ],
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
      trailing: ElevatedButton.icon(
        onPressed: _openAddPositionDrawer,
        icon: const Icon(Icons.add),
        label: Text(l10n.btn_add),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
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
              child: ShimmerPlaceholders.table(rows: 4, columns: 2),
            ),
          ),
        ),
        error: (e, st) => _cardError(
          theme: theme,
          error: e,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    l10n.lbl_hashId(position.id.toString()),
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
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ],
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
