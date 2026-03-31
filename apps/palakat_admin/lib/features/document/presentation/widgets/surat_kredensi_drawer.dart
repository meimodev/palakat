import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/document/presentation/state/document_controller.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_shared/core/constants/date_range_preset.dart';
import 'package:palakat_shared/core/theme/theme.dart';
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
  List<Membership> _selectedMemberships = const [];
  final TextEditingController _purposeController = TextEditingController();
  DateRangePreset _effectiveDatePreset = DateRangePreset.custom;
  DateTimeRange? _effectiveDateRange;
  bool _isLoading = false;
  int? _churchId;
  String? _errorMessage;
  String? _memberError;
  String? _purposeError;
  String? _effectiveDateError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadMembers);
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final l10n = context.l10n;
    final memberError = _selectedMemberships.length == 1
        ? null
        : l10n.validation_selectionRequired;
    final purposeError = _purposeController.text.trim().isEmpty
        ? l10n.validation_required
        : null;
    final effectiveDateError = _effectiveDateRange == null
        ? l10n.validation_dateRequired
        : null;

    setState(() {
      _memberError = memberError;
      _purposeError = purposeError;
      _effectiveDateError = effectiveDateError;
    });

    return memberError == null &&
        purposeError == null &&
        effectiveDateError == null;
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

    final selected = await showDialog<List<Membership>>(
      context: context,
      builder: (dialogContext) => _MultiMembershipPickerDialog<Membership>(
        title: l10n.lbl_selectMember,
        searchHint: l10n.hint_searchMember,
        items: _memberships,
        initialHasMore: _membershipsHasMore,
        onFetchPage: _fetchMemberPickerPage,
        selectedItems: _selectedMemberships,
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
      final memberError = selected.length == 1
          ? null
          : (_memberError != null ? l10n.validation_selectionRequired : null);
      setState(() {
        _selectedMemberships = selected;
        _errorMessage = null;
        _memberError = memberError;
      });
    }
  }

  Future<void> _generateCertificate() async {
    if (!_validateForm()) {
      return;
    }

    final selectedMembership = _selectedMemberships.length == 1
        ? _selectedMemberships.first
        : null;
    final l10n = context.l10n;

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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selectedCount = _selectedMemberships.length;
    final selectedMembership = selectedCount == 1
        ? _selectedMemberships.first
        : null;
    final selectedName = selectedMembership?.account?.name;
    final selectedPhone = selectedMembership?.account?.phone;
    final effectiveDateRange = _effectiveDateRange;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MemberPickerField(
                  title: selectedCount > 1
                      ? l10n.memberCount(selectedCount)
                      : selectedName ?? l10n.lbl_selectMember,
                  subtitle: selectedCount > 1
                      ? l10n.lbl_selected
                      : (selectedPhone != null &&
                            selectedPhone.trim().isNotEmpty)
                      ? selectedPhone
                      : l10n.hint_searchMember,
                  hasSelection: selectedCount > 0,
                  selectionCount: selectedCount,
                  enabled: !_isLoading,
                  onTap: _isLoading ? null : _openMemberPicker,
                ),
                if (_memberError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _memberError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                if (selectedCount > 0) ...[
                  Gap.h12,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedMemberships.map((membership) {
                      final accountName = membership.account?.name;
                      final name = accountName?.trim();
                      final phone = membership.account?.phone?.trim();
                      final memberId = membership.id?.toString();
                      final label =
                          memberId != null &&
                              memberId.isNotEmpty &&
                              name != null &&
                              name.isNotEmpty
                          ? l10n.lbl_memberWithId(memberId, name)
                          : (name != null && name.isNotEmpty
                                ? name
                                : l10n.lbl_na);

                      return InputChip(
                        label: Text(label),
                        avatar: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        labelStyle: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        onDeleted: _isLoading
                            ? null
                            : () {
                                final updatedMemberships = _selectedMemberships
                                    .where((item) => item != membership)
                                    .toList();
                                setState(() {
                                  _selectedMemberships = updatedMemberships;
                                  _memberError = updatedMemberships.length == 1
                                      ? null
                                      : (_memberError != null
                                            ? l10n.validation_selectionRequired
                                            : null);
                                });
                              },
                        tooltip: phone != null && phone.isNotEmpty
                            ? phone
                            : null,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          Gap.h12,
          LabeledField(
            label: l10n.lbl_purpose,
            child: TextField(
              controller: _purposeController,
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                setState(() {
                  _purposeError = null;
                });
              },
              decoration: InputDecoration(
                hintText: l10n.lbl_purpose,
                prefixIcon: const Icon(Icons.flag_outlined, size: 18),
                errorText: _purposeError,
              ),
            ),
          ),
          Gap.h12,
          LabeledField(
            label: l10n.lbl_effectiveDate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateRangePresetInput(
                  label: '',
                  hint: l10n.lbl_effectiveDate,
                  preset: _effectiveDatePreset,
                  start: effectiveDateRange?.start,
                  end: effectiveDateRange?.end,
                  allowedPresets: const [DateRangePreset.custom],
                  onCustomDateRangeSelected: (range) {
                    setState(() {
                      _effectiveDateRange = range;
                      _effectiveDateError = null;
                    });
                  },
                  onPresetChanged: (preset) {
                    setState(() {
                      _effectiveDatePreset = preset;
                    });
                  },
                  onChanged: (start, end) {
                    setState(() {
                      if (start != null && end != null) {
                        _effectiveDateRange = DateTimeRange(
                          start: start,
                          end: end,
                        );
                      } else {
                        _effectiveDateRange = null;
                      }
                      _effectiveDateError = null;
                    });
                  },
                ),
                if (_effectiveDateError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _effectiveDateError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
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

class _MemberPickerField extends StatelessWidget {
  const _MemberPickerField({
    required this.title,
    required this.subtitle,
    required this.hasSelection,
    required this.selectionCount,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool hasSelection;
  final int selectionCount;
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
                if (selectionCount > 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      selectionCount.toString(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
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

class _MultiMembershipPickerDialog<T> extends StatefulWidget {
  const _MultiMembershipPickerDialog({
    required this.title,
    required this.searchHint,
    required this.items,
    required this.selectedItems,
    required this.itemBuilder,
    required this.onFilter,
    this.emptyStateMessage,
    this.maxWidth = 500,
    this.maxHeightFactor = 0.7,
    this.debounceMilliseconds = 300,
    this.searchBorderRadius = 8,
    this.initialHasMore = false,
    this.onFetchPage,
  });

  final String title;
  final String searchHint;
  final List<T> items;
  final List<T> selectedItems;
  final Widget Function(T item) itemBuilder;
  final bool Function(T item, String query) onFilter;
  final String? emptyStateMessage;
  final double maxWidth;
  final double maxHeightFactor;
  final int debounceMilliseconds;
  final double searchBorderRadius;
  final bool initialHasMore;
  final Future<Result<({List<T> items, bool hasMore}), Failure>> Function(
    String query,
    int page,
  )?
  onFetchPage;

  @override
  State<_MultiMembershipPickerDialog<T>> createState() =>
      _MultiMembershipPickerDialogState<T>();
}

class _MultiMembershipPickerDialogState<T>
    extends State<_MultiMembershipPickerDialog<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;
  late List<T> _asyncItems;
  late List<T> _selectedItems;
  late bool _hasMore;
  int _currentPage = 0;
  int _requestId = 0;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  String? _asyncErrorMessage;

  bool get _isAsyncMode => widget.onFetchPage != null;

  List<T> get _visibleItems => _isAsyncMode ? _asyncItems : _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _asyncItems = widget.items;
    _selectedItems = List<T>.from(widget.selectedItems);
    _hasMore = widget.initialHasMore;
    _currentPage = widget.items.isNotEmpty ? 1 : 0;

    if (_isAsyncMode && widget.items.isEmpty) {
      Future.microtask(() => _fetchAsyncPage(reset: true));
    }
  }

  @override
  void didUpdateWidget(covariant _MultiMembershipPickerDialog<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isAsyncMode) {
      if (widget.items != oldWidget.items &&
          _searchController.text.trim().isEmpty) {
        _asyncItems = widget.items;
        _hasMore = widget.initialHasMore;
        _currentPage = widget.items.isNotEmpty ? 1 : 0;
      }
      return;
    }

    if (widget.items != oldWidget.items) {
      _onSearchChanged(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_isAsyncMode) {
      _fetchAsyncPage(reset: true);
      return;
    }

    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredItems = widget.items
            .where((item) => widget.onFilter(item, lowerQuery))
            .toList();
      }
    });
  }

  Future<void> _fetchAsyncPage({required bool reset}) async {
    final onFetchPage = widget.onFetchPage;
    if (onFetchPage == null) {
      return;
    }

    if (!reset && (_isLoadingMore || _isSearching || !_hasMore)) {
      return;
    }

    final page = reset ? 1 : _currentPage + 1;
    final requestId = ++_requestId;

    setState(() {
      if (reset) {
        _isSearching = true;
        _asyncErrorMessage = null;
        _hasMore = false;
        _currentPage = 0;
        _asyncItems = const [];
      } else {
        _isLoadingMore = true;
        _asyncErrorMessage = null;
      }
    });

    final result = await onFetchPage(_searchController.text.trim(), page);

    if (!mounted || requestId != _requestId) {
      return;
    }

    result.when(
      onSuccess: (payload) {
        setState(() {
          _asyncItems = reset
              ? payload.items
              : [..._asyncItems, ...payload.items];
          _hasMore = payload.hasMore;
          _currentPage = page;
          _isSearching = false;
          _isLoadingMore = false;
          _asyncErrorMessage = null;
        });
      },
      onFailure: (failure) {
        setState(() {
          _isSearching = false;
          _isLoadingMore = false;
          _hasMore = false;
          _asyncErrorMessage = failure.message;
          if (reset) {
            _asyncItems = const [];
            _currentPage = 0;
          }
        });
      },
    );
  }

  void _toggleSelection(T item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems = _selectedItems
            .where((entry) => entry != item)
            .toList();
      } else {
        _selectedItems = [..._selectedItems, item];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final screenSize = MediaQuery.of(context).size;
    final visibleItems = _visibleItems;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
          maxHeight: screenSize.height * widget.maxHeightFactor,
        ),
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            side: BorderSide(color: AppColors.ghostBorder(0.08)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.04, blur: 22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                widget.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              l10n.memberCount(_selectedItems.length),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap.w12,
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radius,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(
                    controller: _searchController,
                    hint: widget.searchHint,
                    debounceMilliseconds: widget.debounceMilliseconds,
                    borderRadius: widget.searchBorderRadius,
                    isLoading: _isAsyncMode && _isSearching,
                    onSearch: _onSearchChanged,
                  ),
                ),
                Gap.h16,
                Expanded(
                  child: _isAsyncMode && _isSearching && visibleItems.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: AppLoadingWidget(size: 28),
                          ),
                        )
                      : visibleItems.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  12,
                                ),
                                itemCount: visibleItems.length,
                                itemBuilder: (context, index) {
                                  final item = visibleItems[index];
                                  final isSelected = _selectedItems.contains(
                                    item,
                                  );

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          SanctuaryLayout.radius,
                                        ),
                                        onTap: () => _toggleSelection(item),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary.withValues(
                                                    alpha: 0.08,
                                                  )
                                                : AppColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(
                                              SanctuaryLayout.radius,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                        .withValues(alpha: 0.18)
                                                  : AppColors.ghostBorder(0.06),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: widget.itemBuilder(item),
                                              ),
                                              Checkbox(
                                                value: isSelected,
                                                onChanged: (_) =>
                                                    _toggleSelection(item),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (_isAsyncMode) _buildAsyncFooter(),
                          ],
                        ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.ghostBorder(0.06)),
                    ),
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _selectedItems.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  _selectedItems = const [];
                                });
                              },
                        child: Text(l10n.btn_clear),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.btn_cancel),
                      ),
                      Gap.w8,
                      FilledButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(List<T>.unmodifiable(_selectedItems)),
                        child: Text(l10n.btn_confirm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final action = _isAsyncMode && _asyncErrorMessage != null
        ? Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton(
              onPressed: () => _fetchAsyncPage(reset: true),
              child: Text(l10n.btn_retry),
            ),
          )
        : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.search_off,
                  size: 22,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Gap.h16,
              Text(
                _asyncErrorMessage ??
                    widget.emptyStateMessage ??
                    l10n.err_noData,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) action,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAsyncFooter() {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: AppLoadingWidget(size: 22),
      );
    }

    if (_asyncErrorMessage != null && _visibleItems.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Text(
              _asyncErrorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.h8,
            TextButton(
              onPressed: () => _fetchAsyncPage(reset: false),
              child: Text(l10n.btn_retry),
            ),
          ],
        ),
      );
    }

    if (!_hasMore) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextButton(
        onPressed: () => _fetchAsyncPage(reset: false),
        child: Text(l10n.pagination_next),
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
