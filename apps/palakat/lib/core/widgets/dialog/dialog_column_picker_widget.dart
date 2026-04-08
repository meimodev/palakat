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
    closeIcon: FaIcon(AppIcons.close, size: 24.0, color: AppColors.onSurface),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    border: Border.all(color: AppColors.ghostBorder(0.06)),
                    borderRadius: BorderRadius.circular(
                      SanctuaryLayout.radiusLarge,
                    ),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.account_tree_rounded,
                    size: 24.0,
                    color: AppColors.primary,
                  ),
                ),
                Gap.h12,
                Text(
                  l10n.lbl_selectChurchFirst,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  border: Border.all(color: AppColors.ghostBorder(0.06)),
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.account_tree_rounded,
                  color: AppColors.primary,
                  size: 20.0,
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.lbl_selectColumn,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      l10n.lbl_searchColumns,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Gap.h12,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
              border: Border.all(color: AppColors.ghostBorder(0.08)),
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
              borderRadius: SanctuaryLayout.radiusLarge,
            ),
          ),
        ),
        Gap.h8,
        Expanded(
          child: _isLoading
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: LoadingShimmer(
                      isLoading: true,
                      child: ShimmerPlaceholders.listSection(),
                    ),
                  ),
                )
              : _errorMessage != null && _errorMessage!.trim().isNotEmpty
              ? ErrorDisplayWidget(
                  message: _errorMessage!,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  onRetry: _fetchColumns,
                )
              : _columns.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(
                          SanctuaryLayout.radiusLarge,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56.0,
                            height: 56.0,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              border: Border.all(
                                color: AppColors.ghostBorder(0.06),
                              ),
                              borderRadius: BorderRadius.circular(
                                SanctuaryLayout.radiusLarge,
                              ),
                              boxShadow: SanctuaryDepth.ambient(
                                opacity: 0.02,
                                blur: 12,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 24.0,
                              color: AppColors.primary,
                            ),
                          ),
                          Gap.h12,
                          Text(
                            l10n.lbl_noColumnsFound,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
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
                  padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 12.0),
                  itemCount: _columns.length,
                  separatorBuilder: (context, index) => Gap.h8,
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
