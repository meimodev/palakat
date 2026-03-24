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
    closeIcon: FaIcon(AppIcons.close, size: 24.0, color: AppColors.onSurface),
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
                  Icons.church_rounded,
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
                      l10n.nav_church,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      l10n.lbl_searchChurches,
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
              hint: l10n.lbl_searchChurches,
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
                      child: PalakatShimmerPlaceholders.listSection(),
                    ),
                  ),
                )
              : _churches.isEmpty
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
                            l10n.lbl_noChurchesFound,
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
                  itemCount: _churches.length,
                  separatorBuilder: (context, index) => Gap.h8,
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
