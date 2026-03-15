import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/account/presentations/membership/membership_controller.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/column.dart' as model;
import 'package:palakat_shared/core/widgets/search_field.dart';

/// Shows a dialog for selecting a column.
///
/// This is an app-specific implementation that uses the membership controller
/// to fetch columns. It wraps the shared dialog custom widget.
Future<model.Column?> showDialogColumnPickerWidget({
  required BuildContext context,
  required int? churchId,
  VoidCallback? onPopBottomSheet,
}) {
  return showDialogCustomWidget<model.Column?>(
    context: context,
    title: context.l10n.lbl_selectColumn,
    scrollControlled: false,
    closeIcon: FaIcon(
      AppIcons.close,
      size: BaseSize.w24,
      color: BaseColor.primaryText,
    ),
    content: Expanded(child: _DialogColumnPickerWidget(churchId: churchId)),
  );
}

class _DialogColumnPickerWidget extends ConsumerStatefulWidget {
  final int? churchId;

  const _DialogColumnPickerWidget({required this.churchId});

  @override
  ConsumerState<_DialogColumnPickerWidget> createState() =>
      _DialogColumnPickerWidgetState();
}

class _DialogColumnPickerWidgetState
    extends ConsumerState<_DialogColumnPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<model.Column> _columns = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;
  int _latestRequestId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.churchId != null) {
      _fetchColumns();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchColumns() async {
    if (widget.churchId == null) return;

    final requestId = ++_latestRequestId;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final controller = ref.read(membershipControllerProvider.notifier);
    final result = await controller.fetchColumns(
      churchId: widget.churchId!,
      searchQuery: _searchQuery,
    );

    if (!mounted || requestId != _latestRequestId) {
      return;
    }

    result.when(
      onSuccess: (columns) {
        setState(() {
          _columns = columns;
          _isLoading = false;
          _errorMessage = null;
        });
      },
      onFailure: (failure) {
        setState(() {
          _columns = [];
          _isLoading = false;
          _errorMessage = failure.message.trim().isEmpty
              ? context.l10n.err_loadFailed
              : failure.message;
        });
      },
    );
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _fetchColumns();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (widget.churchId == null) {
      return Center(
        child: Material(
          color: BaseColor.surfaceMedium,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BaseSize.radiusLg),
            side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w24),
            child: Text(
              l10n.lbl_selectChurchFirst,
              style: BaseTypography.bodyMedium.toSecondary,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Search field
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w16,
            vertical: BaseSize.h8,
          ),
          child: SearchField(
            controller: _searchController,
            hint: l10n.lbl_searchColumns,
            debounceMilliseconds: 500,
            unfocusOnSearch: true,
            prefixIcon: FaIcon(AppIcons.search),
            clearIcon: FaIcon(AppIcons.clear),
            onSearch: _onSearchChanged,
            onChanged: null,
            borderRadius: BaseSize.radiusMd,
          ),
        ),
        Gap.h8,
        // Column list
        Expanded(
          child: _isLoading
              ? Center(
                  child: LoadingShimmer(
                    isLoading: true,
                    child: Column(
                      children: [
                        PalakatShimmerPlaceholders.listItemCard(),
                        Gap.h8,
                        PalakatShimmerPlaceholders.listItemCard(),
                        Gap.h8,
                        PalakatShimmerPlaceholders.listItemCard(),
                      ],
                    ),
                  ),
                )
              : _errorMessage != null && _errorMessage!.trim().isNotEmpty
              ? ErrorDisplayWidget(
                  message: _errorMessage!,
                  padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                  onRetry: _fetchColumns,
                )
              : _columns.isEmpty
              ? Center(
                  child: Material(
                    color: BaseColor.surfaceMedium,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                      side: BorderSide(
                        color: BaseColor.neutral[200]!,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(BaseSize.w24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: BaseSize.w56,
                            height: BaseSize.w56,
                            decoration: BoxDecoration(
                              color: BaseColor.primary[50],
                              borderRadius: BorderRadius.circular(
                                BaseSize.radiusLg,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: FaIcon(
                              AppIcons.searchOff,
                              size: BaseSize.w24,
                              color: BaseColor.primary,
                            ),
                          ),
                          Gap.h12,
                          Text(
                            l10n.lbl_noColumnsFound,
                            textAlign: TextAlign.center,
                            style: BaseTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: BaseColor.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: BaseSize.w12),
                  itemCount: _columns.length,
                  separatorBuilder: (context, index) => Gap.h6,
                  itemBuilder: (context, index) {
                    final column = _columns[index];
                    return CardColumn(
                      column: column,
                      onPressed: () => context.pop<model.Column>(column),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
