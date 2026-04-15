import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/utils/download_url.dart'
    show triggerBrowserDownload;
import 'package:palakat_admin/features/activity/activity.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

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

class _ActivityDocumentDownloadState {
  final String documentName;
  final String documentAccountNumber;
  final ApprovalStatus approvalStatus;
  final int? fileId;
  final String displayLabel;

  const _ActivityDocumentDownloadState({
    required this.documentName,
    required this.documentAccountNumber,
    required this.approvalStatus,
    required this.fileId,
    required this.displayLabel,
  });

  bool get isReady => fileId != null;
}

class _ActivityDetailDrawerState extends ConsumerState<ActivityDetailDrawer> {
  bool _isLoading = true;
  String? _errorMessage;
  Activity? _activity;
  ProviderSubscription<AsyncValue<RealtimeEvent>>? _realtimeSubscription;
  late final SocketService _socket;
  late SocketConnectionStatus _previousConnectionStatus;
  late final VoidCallback _socketStatusListener;

  @override
  void initState() {
    super.initState();
    _socket = ref.read(socketServiceProvider);
    _previousConnectionStatus = _socket.connectionStatus;
    _socketStatusListener = () {
      final nextStatus = _socket.connectionStatus;
      final didReconnect =
          _previousConnectionStatus != SocketConnectionStatus.connected &&
          nextStatus == SocketConnectionStatus.connected;
      _previousConnectionStatus = nextStatus;

      if (!didReconnect || !mounted) {
        return;
      }

      _fetchActivity();
    };
    _socket.connectionStatusListenable.addListener(_socketStatusListener);
    _realtimeSubscription = ref.listenManual(realtimeEventProvider, (
      previous,
      next,
    ) {
      final event = next.asData?.value;
      if (event == null) {
        return;
      }

      final eventActivityId = _extractEventActivityId(event);
      if (eventActivityId != widget.activityId) {
        return;
      }

      if (event.name == 'activity.updated' && mounted) {
        _fetchActivity();
      }

      if (event.name == 'activity.deleted' && mounted) {
        widget.onClose();
      }
    });
    _fetchActivity();
  }

  @override
  void dispose() {
    _realtimeSubscription?.close();
    _socket.connectionStatusListenable.removeListener(_socketStatusListener);
    super.dispose();
  }

  int? _extractEventActivityId(RealtimeEvent event) {
    if (event.name != 'activity.updated' && event.name != 'activity.deleted') {
      return null;
    }

    final data = event.payload['data'];
    if (data is Map<String, dynamic>) {
      final value = data['activityId'];
      return value is int ? value : int.tryParse('$value');
    }

    if (data is Map) {
      final value = data['activityId'];
      return value is int ? value : int.tryParse('$value');
    }

    return null;
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

  Future<FileDownloadHandle?> _resolveFileHandle(
    int fileId, {
    required String filename,
    bool forceRedownload = false,
  }) async {
    final l10n = context.l10n;
    try {
      final fileRepo = ref.read(fileManagerRepositoryProvider);
      final result = await fileRepo.resolveCachedFile(
        fileId: fileId,
        filename: filename,
        forceRedownload: forceRedownload,
      );

      FileDownloadHandle? fileHandle;
      result.when(
        onSuccess: (value) => fileHandle = value,
        onFailure: (failure) {
          AppSnackbars.showError(
            context,
            title: l10n.msg_invalidUrl,
            message: failure.message,
          );
        },
      );
      return fileHandle;
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(
          context,
          title: l10n.msg_invalidUrl,
          message: e.toString(),
        );
      }
      return null;
    }
  }

  Future<bool> _downloadResolvedFile(FileDownloadHandle fileHandle) async {
    final uri = Uri.tryParse(fileHandle.uri);
    if (uri == null) {
      return false;
    }

    try {
      await triggerBrowserDownload(uri, filename: fileHandle.filename);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _openDocumentFile(int fileId, {String? openingLabel}) async {
    final l10n = context.l10n;
    final filename = (openingLabel?.trim().isNotEmpty ?? false)
        ? openingLabel!.trim()
        : (_activity?.document?.file?.originalName ??
              _activity?.document?.file?.path?.split('/').last ??
              _activity?.document?.name ??
              'file_$fileId');

    final fileHandle = await _resolveFileHandle(fileId, filename: filename);
    if (fileHandle == null) {
      return;
    }

    var downloaded = await _downloadResolvedFile(fileHandle);
    if (!downloaded && fileHandle.fromCache) {
      if (!mounted) {
        return;
      }
      final refreshedHandle = await _resolveFileHandle(
        fileId,
        filename: filename,
        forceRedownload: true,
      );
      if (refreshedHandle != null) {
        downloaded = await _downloadResolvedFile(refreshedHandle);
      }
    }

    if (!downloaded && mounted) {
      AppSnackbars.showError(
        context,
        title: l10n.msg_invalidUrl,
        message: l10n.msg_cannotOpenReportFile,
      );
    }
  }

  _ActivityDocumentDownloadState? _resolvePrimaryDocumentDownload(
    Activity activity,
  ) {
    final document = activity.document;
    if (activity.documentId == null && document == null) {
      return null;
    }

    final l10n = context.l10n;
    final approvalStatus = activity.approvers.approvalStatus;
    final documentName =
        (document?.certificateTitle?.trim().isNotEmpty ?? false)
        ? document!.certificateTitle!
        : document?.name ?? l10n.lbl_na;
    final fileName =
        document?.file?.originalName ??
        (document?.file?.path?.split('/').last ?? documentName);

    return _ActivityDocumentDownloadState(
      documentName: documentName,
      documentAccountNumber: document?.accountNumber ?? l10n.lbl_na,
      approvalStatus: approvalStatus,
      fileId: document?.fileId,
      displayLabel: document?.fileId != null
          ? fileName
          : approvalStatus == ApprovalStatus.approved
          ? l10n.loading_please_wait
          : '${l10n.section_approvalStatus}: ${approvalStatus.displayLabel}',
    );
  }

  Widget _buildPrimaryDocumentSection(
    _ActivityDocumentDownloadState downloadState,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return InfoSection(
      title: l10n.nav_document,
      children: [
        InfoRow(
          label: l10n.tbl_documentName,
          value: downloadState.documentName,
        ),
        InfoRow(
          label: l10n.lbl_accountNumber,
          value: downloadState.documentAccountNumber,
        ),
        InfoRow(
          label: l10n.section_approvalStatus,
          value: downloadState.approvalStatus.displayLabel,
        ),
        InfoRow(
          label: l10n.tbl_file,
          value: '',
          valueWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                downloadState.displayLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: downloadState.isReady
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontStyle: downloadState.isReady
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: downloadState.fileId == null
                    ? null
                    : () => _openDocumentFile(
                        downloadState.fileId!,
                        openingLabel: downloadState.documentName,
                      ),
                icon: const Icon(Icons.download, size: 16),
                label: Text(l10n.tooltip_downloadReport),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _overrideActivityApproval(ApprovalStatus status) async {
    final activity = _activity;
    if (activity == null) return;

    final approvers = activity.approvers;
    if (approvers.isEmpty) {
      if (mounted) {
        AppSnackbars.showError(
          context,
          title: 'No approvers',
          message: 'This activity has no approvers to override.',
        );
      }
      return;
    }

    final l10n = context.l10n;
    final label = status == ApprovalStatus.approved ? 'approve' : 'reject';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Admin Override'),
        content: Text(
          'Are you sure you want to override and $label all approvals for "${activity.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.btn_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(label[0].toUpperCase() + label.substring(1)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(approverRepositoryProvider);
      for (final approver in approvers) {
        if (approver.id == null) continue;
        final result = await repo.overrideApprover(
          approverId: approver.id!,
          status: status,
        );
        result.when(
          onSuccess: (_) {},
          onFailure: (failure) => throw Exception(failure.message),
        );
      }
      if (mounted) {
        AppSnackbars.showSuccess(
          context,
          title: 'Override applied',
          message:
              'All approvals have been ${status == ApprovalStatus.approved ? 'approved' : 'rejected'} by admin.',
        );
        await _fetchActivity();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(
          context,
          title: 'Override failed',
          message: e.toString(),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryDocumentDownload = _activity == null
        ? null
        : _resolvePrimaryDocumentDownload(_activity!);
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
                        final status = _activity!.effectiveStatus;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusChip(
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
                            ),
                            if (_activity!.isOverridden) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings_outlined,
                                      size: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Admin override',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Override action buttons for admin
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _overrideActivityApproval(
                                          ApprovalStatus.approved,
                                        ),
                                    icon: const Icon(Icons.check_circle_outline,
                                        size: 16),
                                    label: const Text('Override Approve'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _overrideActivityApproval(
                                          ApprovalStatus.rejected,
                                        ),
                                    icon: const Icon(Icons.cancel_outlined,
                                        size: 16),
                                    label: const Text('Override Reject'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .error,
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                if (primaryDocumentDownload != null) ...[
                  const SizedBox(height: 24),
                  _buildPrimaryDocumentSection(primaryDocumentDownload),
                ],

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
        children: [InfoBoxWidget(message: l10n.publish_publishedNotice)],
      ),
    );
  }
}
