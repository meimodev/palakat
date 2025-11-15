import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/models.dart' as cm show Column;
import 'package:palakat_admin/features/church/church.dart';

class ChurchScreen extends ConsumerStatefulWidget {
  const ChurchScreen({super.key});

  @override
  ConsumerState<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends ConsumerState<ChurchScreen> {
  ChurchController get churchController =>
      ref.read(churchControllerProvider.notifier);

  ChurchState get state => ref.watch(churchControllerProvider);

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
              title: 'Saved',
              message: 'Church updated successfully',
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError
                ? e.userMessage
                : 'Failed to update church';
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: 'Update failed',
              message: msg,
              statusCode: code,
            );
          }
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
              title: 'Saved',
              message: 'Location updated successfully',
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError
                ? e.userMessage
                : 'Failed to update location';
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: 'Update failed',
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
            final churchId =
                state.church.value?.id ?? updatedColumn.churchId;
            churchController.fetchColumns(churchId);
            if (!mounted) return;
            AppSnackbars.showSuccess(
              context,
              title: 'Saved',
              message: 'Column saved successfully',
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError
                ? e.userMessage
                : 'Failed to save column';
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: 'Save failed',
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
                final churchId =
                    state.church.value?.id ?? column.churchId;
                churchController.fetchColumns(churchId);
                if (!mounted) return;
                AppSnackbars.showSuccess(
                  context,
                  title: 'Deleted',
                  message: 'Column deleted successfully',
                );
              })
              .catchError((e) {
                if (!mounted) return;
                final msg = e is AppError
                    ? e.userMessage
                    : 'Failed to delete column';
                final code = e is AppError ? e.statusCode : null;
                AppSnackbars.showError(
                  context,
                  title: 'Delete failed',
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
              title: 'Saved',
              message: 'Column created successfully',
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError
                ? e.userMessage
                : 'Failed to create column';
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: 'Create failed',
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
              title: 'Saved',
              message: 'Position saved successfully',
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError
                ? e.userMessage
                : 'Failed to save position';
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: 'Save failed',
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
                title: 'Deleted',
                message: 'Position deleted successfully',
              );
            } catch (e) {
              if (!mounted) return;
              final msg = e is AppError
                  ? e.userMessage
                  : 'Failed to delete position';
              final code = e is AppError ? e.statusCode : null;
              AppSnackbars.showError(
                context,
                title: 'Delete failed',
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
              title: 'Saved',
              message: 'Position created successfully',
            );
          } catch (e) {
            if (!mounted) return;
            final msg = e is AppError
                ? e.userMessage
                : 'Failed to create position';
            final code = e is AppError ? e.statusCode : null;
            AppSnackbars.showError(
              context,
              title: 'Create failed',
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

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Church Profile', style: theme.textTheme.headlineMedium),
            Text(
              'Manage your church\'s public information and columns.',
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
            'Failed to load this section.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildChurchInformationSection(ThemeData theme) {
    final infoAsync = state.church;

    return ExpandableSurfaceCard(
      title: 'Basic Information',
      subtitle:
          'Update the details for your church. This information is visible to members.',
      initiallyExpanded: true,
      trailing: ElevatedButton.icon(
        onPressed: infoAsync.hasValue
            ? () => _openEditDrawer(infoAsync.value!)
            : null,
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
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
            _buildInfoRow('Church Name', church.name, theme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Phone Number',
                    church.phoneNumber ?? '-',
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow('Email', church.email ?? '-', theme),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'About the Church',
              church.description ?? '-',
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
      title: 'Location',
      subtitle: 'Update address and coordinates for your church location.',
      initiallyExpanded: true,
      trailing: ElevatedButton.icon(
        onPressed: (state.church.hasValue && locationAsync.hasValue)
            ? () => _openLocationEditDrawer(state.church.value!)
            : null,
        icon: const Icon(Icons.edit_location_alt),
        label: const Text('Edit Location'),
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
            _buildInfoRow('Address', location.name, theme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Latitude',
                    location.latitude.toString(),
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow(
                    'Longitude',
                    location.longitude.toString(),
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
      title: 'Column Management',
      initiallyExpanded: true,
      subtitle: columnsAsync.hasValue
          ? 'Manage your church columns. Total columns: ${columnsAsync.value!.length}'
          : 'Manage your church columns.',
      trailing: ElevatedButton.icon(
        onPressed: () => _openAddColumnDrawer(state.church.value!.id!),
        icon: const Icon(Icons.add),
        label: const Text('Add Column'),
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
                                    "#${column.id}",
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
      title: 'Position Management',
      initiallyExpanded: true,
      subtitle: positionsAsync.hasValue
          ? 'Manage member positions. Total positions: ${positionsAsync.value!.length}'
          : 'Manage member positions.',
      trailing: ElevatedButton.icon(
        onPressed: _openAddPositionDrawer,
        icon: const Icon(Icons.add),
        label: const Text('Add Position'),
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
                                    "#${position.id}",
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
