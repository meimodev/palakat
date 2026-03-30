import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/repositories/document_repository.dart';
import 'package:palakat_shared/core/repositories/file_manager_repository.dart';
import 'package:palakat_shared/core/repositories/membership_repository.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:palakat_shared/core/widgets/searchable_dialog_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class SuratKeteranganJemaatScreen extends ConsumerStatefulWidget {
  const SuratKeteranganJemaatScreen({super.key});

  @override
  ConsumerState<SuratKeteranganJemaatScreen> createState() =>
      _SuratKeteranganJemaatScreenState();
}

class _SuratKeteranganJemaatScreenState
    extends ConsumerState<SuratKeteranganJemaatScreen> {
  List<Membership> _memberships = const [];
  bool _membershipsHasMore = false;
  Membership? _selectedMembership;
  bool _isLoadingMembers = true;
  bool _isGenerating = false;
  int? _churchId;
  int? _columnId;
  String? _scopeBlockedMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadMembers);
  }

  Future<void> _loadMembers() async {
    final l10n = context.l10n;
    final localStorage = ref.read(localStorageServiceProvider);
    final membership = localStorage.currentMembership;
    final churchId = membership?.church?.id;
    final columnId = membership?.column?.id;

    if (churchId == null) {
      setState(() {
        _isLoadingMembers = false;
        _errorMessage = l10n.msg_operationFailed;
      });
      return;
    }

    if (columnId == null) {
      setState(() {
        _churchId = churchId;
        _columnId = null;
        _scopeBlockedMessage =
            l10n.publish_publishToColumnOnly_subtitleNoColumn;
        _memberships = const [];
        _membershipsHasMore = false;
        _isLoadingMembers = false;
      });
      return;
    }

    setState(() {
      _churchId = churchId;
      _columnId = columnId;
      _scopeBlockedMessage = null;
      _isLoadingMembers = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(membershipRepositoryProvider)
        .fetchMemberPickerPage(
          request: GetFetchMemberPosition(
            churchId: churchId,
            columnId: columnId,
            requireColumnId: true,
          ),
        );

    if (!mounted) {
      return;
    }

    result.when(
      onSuccess: (response) {
        setState(() {
          _memberships = response.items;
          _membershipsHasMore = response.hasMore;
          _isLoadingMembers = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _errorMessage = failure.message;
          _isLoadingMembers = false;
        });
      },
    );
  }

  Future<Result<MembershipPickerPage, Failure>> _fetchMemberPickerPage(
    String query,
    int page,
  ) {
    final churchId = _churchId;
    final columnId = _columnId;
    if (churchId == null) {
      return Future.value(
        Result.failure(Failure(context.l10n.msg_operationFailed)),
      );
    }
    if (columnId == null) {
      return Future.value(
        Result.failure(
          Failure(context.l10n.publish_publishToColumnOnly_subtitleNoColumn),
        ),
      );
    }

    final normalizedQuery = query.trim();
    return ref
        .read(membershipRepositoryProvider)
        .fetchMemberPickerPage(
          page: page,
          request: GetFetchMemberPosition(
            churchId: churchId,
            columnId: columnId,
            requireColumnId: true,
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.account?.name ?? l10n.lbl_na,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if ((item.account?.phone ?? '').trim().isNotEmpty)
                Text(
                  item.account!.phone!,
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

  Future<void> _generate() async {
    final l10n = context.l10n;
    final selectedMembership = _selectedMembership;

    if (_scopeBlockedMessage != null) {
      setState(() {
        _errorMessage = _scopeBlockedMessage;
      });
      return;
    }

    if (selectedMembership?.id == null) {
      setState(() {
        _errorMessage = l10n.err_requiredField;
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(documentRepositoryProvider)
        .generateCertificate(
          certificateType: CertificateType.suratKeteranganJemaat,
          membershipId: selectedMembership!.id,
          name: selectedMembership.account?.name,
          accountNumber: selectedMembership.account?.phone,
        );

    if (!mounted) {
      return;
    }

    int? fileId;
    String? failureMessage;
    result.when(
      onSuccess: (payload) {
        fileId = payload.document.fileId;
      },
      onFailure: (failure) {
        failureMessage = failure.message;
      },
    );

    if (failureMessage != null) {
      setState(() {
        _isGenerating = false;
        _errorMessage = failureMessage;
      });
      return;
    }

    if (fileId == null) {
      setState(() {
        _isGenerating = false;
        _errorMessage = l10n.msg_operationFailed;
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
        failureMessage = failure.message;
      },
    );

    if (failureMessage != null) {
      setState(() {
        _isGenerating = false;
        _errorMessage = failureMessage;
      });
      return;
    }

    final uri = Uri.tryParse(resolvedUrl ?? '');
    if (uri == null) {
      setState(() {
        _isGenerating = false;
        _errorMessage = l10n.msg_invalidUrl;
      });
      return;
    }

    final launched = await launchUrl(uri);

    if (!mounted) {
      return;
    }

    if (!launched) {
      setState(() {
        _isGenerating = false;
        _errorMessage = l10n.msg_cannotOpenReportFile;
      });
      return;
    }

    setState(() {
      _isGenerating = false;
    });

    _showSnackBar(context, l10n.msg_certificateGenerated);
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final displayError = _scopeBlockedMessage ?? _errorMessage;
    final selectedName = _selectedMembership?.account?.name;
    final selectedPhone = _selectedMembership?.account?.phone;

    return ScaffoldWidget(
      loading: _isLoadingMembers,
      disableSingleChildScrollView: false,
      persistBottomWidget: OperationsReveal(
        delay: const Duration(milliseconds: 140),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 24.0,
            left: 12.0,
            right: 12.0,
            top: 6.0,
          ),
          child: ButtonWidget.primary(
            text: l10n.btn_generateCertificate,
            isLoading: _isGenerating,
            onTap: _isGenerating || _scopeBlockedMessage != null
                ? null
                : _generate,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationsReveal(
            child: ScreenTitleWidget.primary(
              title: l10n.certificate_suratKeteranganJemaat_title,
              subTitle: l10n.operationsItem_suratKeteranganJemaat_desc,
              leadIcon: AppIcons.back,
              leadIconColor: AppColors.onSurface,
              onPressedLeadIcon: context.pop,
            ),
          ),
          Gap.h16,
          OperationsAnimatedPresence(
            visible: displayError != null && displayError.trim().isNotEmpty,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: ErrorDisplayWidget(message: displayError ?? ''),
            ),
          ),
          OperationsReveal(
            delay: const Duration(milliseconds: 40),
            child: InfoBoxWidget(
              message: l10n.certificate_suratKeteranganJemaat_subtitle,
            ),
          ),
          Gap.h16,
          OperationsReveal(
            delay: const Duration(milliseconds: 80),
            child: FormSectionWidget(
              icon: AppIcons.document,
              title: l10n.drawer_suratKeteranganJemaat_title,
              children: [
                InkWell(
                  onTap: _isLoadingMembers || _scopeBlockedMessage != null
                      ? null
                      : _openMemberPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.lbl_selectMember,
                      hintText: l10n.hint_searchMember,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(selectedName ?? l10n.lbl_selectMember),
                  ),
                ),
                if (selectedName != null) ...[
                  Gap.h12,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radiusLarge,
                      ),
                      border: Border.all(color: AppColors.ghostBorder(0.06)),
                      boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if ((selectedPhone ?? '').trim().isNotEmpty) ...[
                          Gap.h4,
                          Text(
                            selectedPhone!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showSnackBar(BuildContext context, String msg) {
    if (msg.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
