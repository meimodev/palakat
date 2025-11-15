import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/activity/activity.dart';

class ActivityDetailDrawer extends ConsumerStatefulWidget {
  final int activityId;
  final VoidCallback onClose;

  const ActivityDetailDrawer({
    super.key,
    required this.activityId,
    required this.onClose,
  });

  @override
  ConsumerState<ActivityDetailDrawer> createState() =>
      _ActivityDetailDrawerState();
}

class _ActivityDetailDrawerState extends ConsumerState<ActivityDetailDrawer> {
  bool _isLoading = true;
  String? _errorMessage;
  Activity? _activity;

  @override
  void initState() {
    super.initState();
    _fetchActivity();
  }

  Future<void> _fetchActivity() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(activityControllerProvider.notifier);
      final activity = await controller.fetchActivity(widget.activityId);
      if (mounted) {
        setState(() {
          _activity = activity;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideDrawer(
      title: 'Activity Details',
      subtitle: 'View detailed information about this activity',
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: 'Fetching activity details...',
      errorMessage: _errorMessage,
      onRetry: _fetchActivity,
      content: _activity == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                InfoSection(
                  title: 'Basic Information',
                  children: [
                    InfoRow(
                      label: 'ID',
                      value: "# ${_activity!.id?.toString() ?? '-'}",
                    ),
                    InfoRow(label: 'Title', value: _activity!.title),
                    InfoRow(
                      label: 'Designated Date & Time',
                      value: _activity!.date.toDateTimeString(),
                    ),
                    InfoRow(
                      label: 'Type',
                      value: _activity!.activityType.displayName,
                      valueWidget: ActivityTypeChip(
                        type: _activity!.activityType,
                      ),
                    ),
                    InfoRow(
                      label: 'Description',
                      value: _activity!.description ?? '-',
                    ),
                    if (_activity!.note != null)
                      InfoRow(label: ' Notes', value: _activity!.note!),
                  ],
                ),

                const SizedBox(height: 24),
                InfoSection(
                  title: 'Approval Status',
                  children: [
                    Builder(
                      builder: (context) {
                        final status = _activity!.approvers.approvalStatus;
                        return StatusChip(
                          label: status.displayLabel.toUpperCase(),
                          background: status.backgroundColor,
                          foreground: status.foregroundColor,
                          icon: status.icon,
                          elevated: true,
                          fontSize: 13.5,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          fullWidth: true,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Supervisor
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Supervisor',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activity!.supervisor.account?.name ?? '-',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (_activity!
                              .supervisor
                              .membershipPositions
                              .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _activity!
                                  .supervisor
                                  .membershipPositions
                                  .map((position) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outlineVariant,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        position.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Approvers
                if (_activity!.approvers.isNotEmpty)
                  InfoSection(
                    title: 'Approvers',
                    children: [
                      ApproversStackDisplay(
                        approvers: _activity!.approvers,
                        fallbackDate:
                            _activity!.updatedAt ?? _activity!.createdAt,
                      ),
                    ],
                  )
                else
                  InfoSection(
                    title: 'Approvers',
                    children: [
                      InfoRow(
                        label: 'Approvers',
                        value: 'No approvers assigned',
                      ),
                    ],
                  ),

                if (_activity!.location != null) ...[
                  const SizedBox(height: 24),
                  InfoSection(
                    title: 'Location',
                    children: [
                      InfoRow(
                        label: 'Location Name',
                        value: _activity!.location?.name ?? 'Not specified',
                      ),
                      InfoRow(
                        label: 'Position',
                        value:
                            "${_activity!.location?.latitude.toString()} - ${_activity!.location?.longitude.toString()}",
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
      footer: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Published activities can only be managed on mobile app by the corresponding supervisor.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
