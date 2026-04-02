import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/document/presentation/state/document_controller.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_shared/core/constants/enums.dart';

class SuratKeteranganJemaatDrawer extends ConsumerStatefulWidget {
  const SuratKeteranganJemaatDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<SuratKeteranganJemaatDrawer> createState() =>
      _SuratKeteranganJemaatDrawerState();
}

class _SuratKeteranganJemaatDrawerState
    extends ConsumerState<SuratKeteranganJemaatDrawer> {
  List<Membership> _memberships = const [];
  bool _membershipsHasMore = false;
  Membership? _selectedMembership;
  bool _isLoading = false;
  int? _churchId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadMembers);
  }

  Future<void> _loadMembers() async {
    final l10n = context.l10n;
    final churchId = ref
        .read(authControllerProvider)
        .value
        ?.account
        .membership
        ?.church
        ?.id;

    if (churchId == null) {
      setState(() {
        _errorMessage = l10n.msg_operationFailed;
      });
      return;
    }

    setState(() {
      _churchId = churchId;
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(membershipRepositoryProvider)
        .fetchMemberPickerPage(
          request: GetFetchMemberPosition(churchId: churchId),
        );

    if (!mounted) {
      return;
    }

    result.when(
      onSuccess: (response) {
        setState(() {
          _memberships = response.items;
          _membershipsHasMore = response.hasMore;
          _isLoading = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
    );
  }

  Future<Result<MembershipPickerPage, Failure>> _fetchMemberPickerPage(
    String query,
    int page,
  ) {
    final churchId = _churchId;
    if (churchId == null) {
      return Future.value(
        Result.failure(Failure(context.l10n.msg_operationFailed)),
      );
    }

    final normalizedQuery = query.trim();
    return ref
        .read(membershipRepositoryProvider)
        .fetchMemberPickerPage(
          page: page,
          request: GetFetchMemberPosition(
            churchId: churchId,
            search: normalizedQuery.isEmpty ? null : normalizedQuery,
          ),
        );
  }

  Future<void> _openMemberPicker() async {
    final l10n = context.l10n;

    final selected = await showDialog<Membership>(
      context: context,
      builder: (dialogContext) => SearchableDialogPicker<Membership>(
        title: l10n.lbl_selectMember,
        searchHint: l10n.hint_searchMember,
        items: _memberships,
        initialHasMore: _membershipsHasMore,
        onFetchPage: _fetchMemberPickerPage,
        selectedItem: _selectedMembership,
        emptyStateMessage: l10n.err_noData,
        onFilter: (item, query) {
          final name = item.account?.name.toLowerCase() ?? '';
          final phone = item.account?.phone?.toLowerCase() ?? '';
          return name.contains(query) || phone.contains(query);
        },
        itemBuilder: (item) {
          final theme = Theme.of(dialogContext);
          final name = item.account?.name ?? l10n.lbl_na;
          final phone = item.account?.phone;
          return _MemberPickerOption(
            title: name,
            subtitle: phone,
            accentColor: theme.colorScheme.primary,
          );
        },
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedMembership = selected;
        _errorMessage = null;
      });
    }
  }

  Future<void> _createActivity() async {
    final l10n = context.l10n;
    final selectedMembership = _selectedMembership;
    final selectedMemberName = selectedMembership?.account?.name.trim();
    final supervisorMembershipId = ref
        .read(authControllerProvider)
        .value
        ?.account
        .membership
        ?.id;

    if (selectedMembership?.id == null) {
      setState(() {
        _errorMessage = l10n.err_requiredField;
      });
      return;
    }

    if (selectedMemberName == null ||
        selectedMemberName.isEmpty ||
        supervisorMembershipId == null) {
      setState(() {
        _errorMessage = l10n.msg_operationFailed;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final activityTitle =
        '${l10n.certificate_suratKeteranganJemaat_title} - $selectedMemberName';
    final activityResult = await ref
        .read(activityRepositoryProvider)
        .createActivity(
          request: CreateActivityRequest(
            supervisorId: supervisorMembershipId,
            title: activityTitle,
            activityType: ActivityType.announcement,
          ),
        );

    int? linkedDocumentId;
    String? message;
    activityResult.when(
      onSuccess: (activity) {
        linkedDocumentId = activity.document?.id ?? activity.documentId;
      },
      onFailure: (failure) {
        message = failure.message;
      },
    );

    if (message != null) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
      return;
    }

    if (linkedDocumentId == null) {
      setState(() {
        _errorMessage = l10n.msg_operationFailed;
        _isLoading = false;
      });
      return;
    }

    final documentResult = await ref
        .read(documentRepositoryProvider)
        .updateDocument(
          documentId: linkedDocumentId!,
          update: {
            'name': selectedMemberName,
            'certificateType': CertificateType.suratKeteranganJemaat.name,
            'certificateTitle': l10n.certificate_suratKeteranganJemaat_title,
          },
        );

    documentResult.when(
      onSuccess: (_) {},
      onFailure: (failure) {
        message = failure.message;
      },
    );

    if (message != null) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
      return;
    }

    await ref.read(documentControllerProvider.notifier).refresh();

    if (!mounted) {
      return;
    }

    AppSnackbars.showSuccess(
      context,
      title: l10n.msg_created,
      message: l10n.certificate_suratKeteranganJemaat_title,
    );

    setState(() {
      _isLoading = false;
    });
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedName = _selectedMembership?.account?.name;
    final selectedPhone = _selectedMembership?.account?.phone;

    return SideDrawer(
      title: l10n.drawer_suratKeteranganJemaat_title,
      subtitle: l10n.certificate_suratKeteranganJemaat_subtitle,
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: l10n.loading_please_wait,
      errorMessage: _errorMessage,
      onRetry: _errorMessage != null ? _loadMembers : null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabeledField(
            label: l10n.lbl_selectMember,
            child: _MemberPickerField(
              title: selectedName ?? l10n.lbl_selectMember,
              subtitle:
                  (selectedPhone != null && selectedPhone.trim().isNotEmpty)
                  ? selectedPhone
                  : l10n.hint_searchMember,
              hasSelection: selectedName != null,
              enabled: !_isLoading,
              onTap: _isLoading ? null : _openMemberPicker,
            ),
          ),
        ],
      ),
      footer: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _isLoading ? null : _createActivity,
          icon: const Icon(Icons.add_task_outlined),
          label: Text(l10n.btn_create),
        ),
      ),
    );
  }
}

class _MemberPickerField extends StatelessWidget {
  const _MemberPickerField({
    required this.title,
    required this.subtitle,
    required this.hasSelection,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool hasSelection;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = hasSelection
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
        : theme.colorScheme.surfaceContainerLow;
    final borderColor = hasSelection
        ? theme.colorScheme.primary.withValues(alpha: 0.28)
        : theme.colorScheme.outlineVariant;
    final iconBackgroundColor = hasSelection
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest;

    return Opacity(
      opacity: enabled ? 1 : 0.72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    hasSelection
                        ? Icons.person_outline_rounded
                        : Icons.person_search_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberPickerOption extends StatelessWidget {
  const _MemberPickerOption({
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final String title;
  final String? subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.person_outline_rounded,
            size: 18,
            color: accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasSubtitle)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
