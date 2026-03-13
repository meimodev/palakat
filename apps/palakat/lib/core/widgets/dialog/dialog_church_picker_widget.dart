import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/account/presentations/membership/membership_controller.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/widgets/search_field.dart';

/// Shows a dialog for selecting a church.
///
/// This is an app-specific implementation that uses the membership controller
/// to fetch churches. It wraps the shared dialog custom widget.
Future<Church?> showDialogChurchPickerWidget({
  required BuildContext context,
  VoidCallback? onPopBottomSheet,
}) {
  return showDialogCustomWidget<Church?>(
    context: context,
    title: context.l10n.nav_church,
    scrollControlled: false,
    closeIcon: FaIcon(
      AppIcons.close,
      size: BaseSize.w24,
      color: BaseColor.primaryText,
    ),
    content: const Expanded(child: _DialogChurchPickerWidget()),
  );
}

class _DialogChurchPickerWidget extends ConsumerStatefulWidget {
  const _DialogChurchPickerWidget();

  @override
  ConsumerState<_DialogChurchPickerWidget> createState() =>
      _DialogChurchPickerWidgetState();
}

class _DialogChurchPickerWidgetState
    extends ConsumerState<_DialogChurchPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Church> _churches = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchChurches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchChurches() async {
    setState(() => _isLoading = true);

    final controller = ref.read(membershipControllerProvider.notifier);
    final churches = await controller.fetchChurches(searchQuery: _searchQuery);

    if (mounted) {
      setState(() {
        _churches = churches;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _fetchChurches();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w16,
            vertical: BaseSize.h8,
          ),
          child: SearchField(
            controller: _searchController,
            hint: l10n.lbl_searchChurches,
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
              : _churches.isEmpty
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
                            l10n.lbl_noChurchesFound,
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
                  itemCount: _churches.length,
                  separatorBuilder: (context, index) => Gap.h6,
                  itemBuilder: (context, index) {
                    final church = _churches[index];
                    return CardChurch(
                      church: church,
                      onPressed: () => context.pop<Church>(church),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
