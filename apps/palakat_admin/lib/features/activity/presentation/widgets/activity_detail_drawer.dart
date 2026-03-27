import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/activity/activity.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _openDocumentFile(int fileId) async {
    final l10n = context.l10n;
    try {
      final fileRepo = ref.read(fileManagerRepositoryProvider);
      final result = await fileRepo.resolveDownloadUrl(fileId: fileId);
      
      if (!mounted) return;

      result.when(
        onSuccess: (url) async {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            AppSnackbars.showSuccess(
              context,
              title: l10n.msg_opening,
              message: l10n.msg_openingReport(_activity!.document?.name ?? ''),
            );
            await launchUrl(uri);
          } else {
            AppSnackbars.showError(
              context,
              title: l10n.msg_invalidUrl,
              message: l10n.msg_cannotOpenReportFile,
            );
          }
        },
        onFailure: (failure) {
          AppSnackbars.showError(
            context,
            title: l10n.msg_invalidUrl,
            message: failure.message,
          );
        },
      );
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(
          context,
          title: l10n.msg_invalidUrl,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SideDrawer(
      title: l10n.drawer_activityDetails_title,
      subtitle: l10n.drawer_activityDetails_subtitle,
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: l10n.loading_activities,
      errorMessage: _errorMessage,
      onRetry: _fetchActivity,
      content: _activity == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                InfoSection(
                  title: l10n.section_basicInformation,
                  children: [
                    InfoRow(
                      label: l10n.lbl_activityId,
                      value: l10n.lbl_hashId(
                        _activity!.id?.toString() ?? l10n.lbl_na,
                      ),
                    ),
                    InfoRow(label: l10n.lbl_title, value: _activity!.title),
                    InfoRow(
                      label: l10n.lbl_activityDateTime,
                      value: _activity!.date.toDateTimeString(),
                    ),
                    InfoRow(
                      label: l10n.lbl_type,
                      value: _activity!.activityType.displayName,
                      valueWidget: ActivityTypeChip(
                        type: _activity!.activityType,
                      ),
                    ),
                    InfoRow(
                      label: l10n.lbl_description,
                      value: _activity!.description ?? l10n.lbl_na,
                    ),
                    if (_activity!.note != null)
                      InfoRow(label: l10n.lbl_notes, value: _activity!.note!),
                  ],
                ),

                const SizedBox(height: 24),
                InfoSection(
                  title: l10n.section_approval,
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
                    InfoSection(
                      title: l10n.tbl_supervisor,
                      children: [
                        SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activity!.supervisor.account?.name ??
                                    l10n.lbl_na,
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
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
                  ],
                ),

                const SizedBox(height: 24),

                // Approvers
                if (_activity!.approvers.isNotEmpty)
                  InfoSection(
                    title: l10n.tbl_approvers,
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
                    title: l10n.tbl_approvers,
                    children: [
                      InfoRow(
                        label: l10n.tbl_approvers,
                        value: l10n.msg_noApproversAssigned,
                      ),
                    ],
                  ),

                if (_activity!.documentId != null || _activity!.document != null) ...[
                  const SizedBox(height: 24),
                  InfoSection(
                    title: l10n.nav_document,
                    children: [
                      InfoRow(
                        label: l10n.tbl_documentName,
                        value: _activity!.document?.name ?? l10n.lbl_na,
                      ),
                      InfoRow(
                        label: 'Document ID',
                        value: _activity!.document?.accountNumber ?? l10n.lbl_na,
                      ),
                      if (_activity!.document?.fileId != null)
                        InfoRow(
                          label: l10n.tbl_file,
                          value: '',
                          valueWidget: OutlinedButton.icon(
                            onPressed: () => _openDocumentFile(_activity!.document!.fileId!),
                            icon: const Icon(Icons.download, size: 16),
                            label: Text(l10n.tooltip_downloadReport),
                          ),
                        ),
                    ],
                  ),
                ],

                if (_activity!.location != null) ...[
                  const SizedBox(height: 24),
                  InfoSection(
                    title: l10n.section_locationDetails,
                    children: [
                      InfoRow(
                        label: l10n.lbl_name,
                        value:
                            _activity!.location?.name.trim().isNotEmpty == true
                            ? _activity!.location!.name
                            : l10n.lbl_notSpecified,
                      ),
                      if (_activity!.location?.latitude != null &&
                          _activity!.location?.longitude != null)
                        InfoRow(
                          label: l10n.lbl_locationPosition,
                          value:
                              "${_activity!.location!.latitude} - ${_activity!.location!.longitude}",
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
      footer: Column(
        children: [
          InfoBoxWidget(message: l10n.publish_publishedNotice),
        ],
      ),
    );
  }
}
