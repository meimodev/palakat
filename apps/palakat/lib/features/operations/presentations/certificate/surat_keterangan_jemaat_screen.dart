import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/repositories/activity_repository.dart';
import 'package:palakat_shared/core/repositories/document_repository.dart';
import 'package:palakat_shared/core/repositories/membership_repository.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:palakat_shared/core/widgets/searchable_dialog_picker.dart';

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
          return _MemberPickerOption(
            title: item.account?.name ?? l10n.lbl_na,
            subtitle: item.account?.phone,
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
    final localStorage = ref.read(localStorageServiceProvider);
    final supervisorMembershipId =
        localStorage.currentMembership?.id ??
        localStorage.currentAuth?.account.membership?.id;
    final selectedMemberName = selectedMembership?.account?.name.trim();

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

    if (selectedMemberName == null ||
        selectedMemberName.isEmpty ||
        supervisorMembershipId == null) {
      setState(() {
        _errorMessage = l10n.msg_operationFailed;
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    final activityTitle =
        '${l10n.certificate_suratKeteranganJemaat_title} - $selectedMemberName';
    final activityNote = jsonEncode({
      'certificateType': CertificateType.suratKeteranganJemaat.name,
      'subjectMembership': {
        'membershipId': selectedMembership?.id,
        'name': selectedMemberName,
        'churchName': selectedMembership?.church?.name,
        'columnName': selectedMembership?.column?.name,
      },
    });
    final activityResult = await ref
        .read(activityRepositoryProvider)
        .createActivity(
          request: CreateActivityRequest(
            supervisorId: supervisorMembershipId,
            publishToColumnOnly: true,
            title: activityTitle,
            note: activityNote,
            activityType: ActivityType.announcement,
          ),
        );

    String? failureMessage;
    int? linkedDocumentId;
    activityResult.when(
      onSuccess: (activity) {
        linkedDocumentId = activity.document?.id ?? activity.documentId;
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

    if (linkedDocumentId == null) {
      setState(() {
        _isGenerating = false;
        _errorMessage = l10n.msg_operationFailed;
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

    setState(() {
      _isGenerating = false;
    });

    if (!mounted) {
      return;
    }

    _showSnackBar(context, l10n.msg_created);
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            text: l10n.btn_create,
            isLoading: _isGenerating,
            onTap: _isGenerating || _scopeBlockedMessage != null
                ? null
                : _createActivity,
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
                _MemberPickerField(
                  title: selectedName ?? l10n.lbl_selectMember,
                  subtitle:
                      (selectedPhone != null && selectedPhone.trim().isNotEmpty)
                      ? selectedPhone
                      : l10n.hint_searchMember,
                  hasSelection: selectedName != null,
                  enabled: !_isLoadingMembers && _scopeBlockedMessage == null,
                  onTap: _isLoadingMembers || _scopeBlockedMessage != null
                      ? null
                      : _openMemberPicker,
                ),
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

    return Opacity(
      opacity: enabled ? 1 : 0.72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasSelection
                  ? AppColors.primaryContainer.withValues(alpha: 0.36)
                  : AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
              border: Border.all(
                color: hasSelection
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.ghostBorder(0.08),
              ),
              boxShadow: SanctuaryDepth.ambient(
                opacity: hasSelection ? 0.024 : 0.02,
                blur: hasSelection ? 10 : 8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasSelection
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasSelection
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.ghostBorder(0.06),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    hasSelection
                        ? Icons.person_outline_rounded
                        : Icons.person_search_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                Gap.w12,
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
                          color: AppColors.onSurface,
                        ),
                      ),
                      Gap.h2,
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.w8,
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.onSurfaceVariant,
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
  const _MemberPickerOption({required this.title, required this.subtitle});

  final String title;
  final String? subtitle;

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
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.person_outline_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        Gap.w12,
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
                  color: AppColors.onSurface,
                ),
              ),
              if (hasSubtitle)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
