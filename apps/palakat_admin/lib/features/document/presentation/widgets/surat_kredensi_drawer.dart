import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/document/presentation/state/document_controller.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/repositories/membership_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class SuratKredensiDrawer extends ConsumerStatefulWidget {
  const SuratKredensiDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<SuratKredensiDrawer> createState() =>
      _SuratKredensiDrawerState();
}

class _SuratKredensiDrawerState extends ConsumerState<SuratKredensiDrawer> {
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (phone != null && phone.trim().isNotEmpty)
                Text(
                  phone,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
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

  Future<void> _generateCertificate() async {
    final l10n = context.l10n;
    final selectedMembership = _selectedMembership;

    if (selectedMembership?.id == null) {
      setState(() {
        _errorMessage = l10n.err_requiredField;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(documentRepositoryProvider)
        .generateCertificate(
          certificateType: CertificateType.suratKredensi,
          membershipId: selectedMembership!.id,
          name: selectedMembership.account?.name,
          accountNumber: selectedMembership.account?.phone,
        );

    if (!mounted) {
      return;
    }

    int? fileId;
    String? message;
    result.when(
      onSuccess: (payload) {
        fileId = payload.document.fileId;
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

    await ref.read(documentControllerProvider.notifier).refresh();

    if (fileId == null) {
      setState(() {
        _errorMessage = l10n.err_noData;
        _isLoading = false;
      });
      return;
    }

    final fileResult = await ref
        .read(fileManagerRepositoryProvider)
        .resolveDownloadUrl(fileId: fileId!);

    if (!mounted) {
      return;
    }

    String? resolvedUrl;
    fileResult.when(
      onSuccess: (url) {
        resolvedUrl = url;
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

    final uri = Uri.tryParse(resolvedUrl ?? '');
    if (uri == null) {
      setState(() {
        _errorMessage = l10n.msg_invalidUrl;
        _isLoading = false;
      });
      return;
    }

    final launched = await launchUrl(uri);
    if (!mounted) {
      return;
    }

    if (!launched) {
      setState(() {
        _errorMessage = l10n.msg_cannotOpenReportFile;
        _isLoading = false;
      });
      return;
    }

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final selectedName = _selectedMembership?.account?.name;
    final selectedPhone = _selectedMembership?.account?.phone;

    return SideDrawer(
      title: l10n.drawer_suratKredensi_title,
      subtitle: l10n.certificate_suratKredensi_subtitle,
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
            child: InkWell(
              onTap: _isLoading ? null : _openMemberPicker,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.hint_searchMember,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(selectedName ?? l10n.lbl_selectMember),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (selectedName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (selectedPhone != null &&
                      selectedPhone.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      selectedPhone,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
      footer: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _isLoading ? null : _generateCertificate,
          icon: const Icon(Icons.description),
          label: Text(l10n.btn_generateCertificate),
        ),
      ),
    );
  }
}
