import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/activity/activity.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/models.dart' hide Column;

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
  
  int? _selectedDocumentId;
  List<Document> _availableDocuments = [];
  bool _isLoadingDocuments = false;
  bool _isSaving = false;

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
          _selectedDocumentId = activity?.documentId;
          _isLoading = false;
        });

        if (activity?.activityType == ActivityType.announcement) {
          _fetchDocuments();
        }
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

  Future<void> _fetchDocuments() async {
    setState(() => _isLoadingDocuments = true);
    try {
      final repository = ref.read(documentRepositoryProvider);
      final auth = ref.read(authControllerProvider).value;
      final churchId = auth!.account.membership!.church!.id!;

      final result = await repository.fetchDocuments(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchDocumentsRequest(churchId: churchId),
          page: 1,
          pageSize: 100,
          sortBy: 'createdAt',
          sortOrder: 'desc',
        ),
      );

      if (mounted) {
        result.when(
          onSuccess: (docs) {
            setState(() {
              _availableDocuments = docs.data;
              _isLoadingDocuments = false;
            });
          },
          onFailure: (_) => setState(() => _isLoadingDocuments = false),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingDocuments = false);
    }
  }

  Future<void> _saveDocument() async {
    if (_activity == null) return;
    setState(() => _isSaving = true);
    try {
      final controller = ref.read(activityControllerProvider.notifier);
      // documentId mapping for saving
      final editingActivity = _activity!.copyWith(documentId: _selectedDocumentId);

      await controller.saveActivity(editingActivity);

      if (mounted) {
        setState(() {
          _activity = editingActivity;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menyimpan dokumen')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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

                if (_activity!.activityType == ActivityType.announcement) ...[
                  const SizedBox(height: 24),
                  InfoSection(
                    title: l10n.nav_document,
                    children: [
                      if (_isLoadingDocuments)
                        const Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<int?>(
                          value: _selectedDocumentId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          hint: const Text('Pilih dokumen varian'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Tidak ada dokumen'),
                            ),
                            ..._availableDocuments.map((d) => DropdownMenuItem(
                              value: d.id,
                              child: Text('${d.input.name.toUpperCase()}: ${d.accountNumber}'),
                            )),
                          ],
                          onChanged: (id) => setState(() => _selectedDocumentId = id),
                        ),
                    ],
                  ),
                ] else if (_activity!.documentId != null || _activity!.document != null) ...[
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
          if (_activity?.activityType == ActivityType.announcement && _selectedDocumentId != _activity?.documentId)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveDocument,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Document Link'),
                ),
              ),
            ),
          InfoBoxWidget(message: l10n.publish_publishedNotice),
        ],
      ),
    );
  }
}
