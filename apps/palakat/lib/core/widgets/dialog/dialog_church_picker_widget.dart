import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/account/presentations/membership/membership_controller.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/widgets/search_field.dart';
import 'package:palakat_shared/core/widgets/dialog/dialog_custom_widget.dart';
import 'package:palakat_shared/core/widgets/card/card_church.dart';

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
    title: context.l10n.lbl_selectChurch,
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
            hint: context.l10n.lbl_searchChurches,
            debounceMilliseconds: 500,
            unfocusOnSearch: true,
            prefixIcon: FaIcon(AppIcons.search),
            clearIcon: FaIcon(AppIcons.clear),
            onSearch: _onSearchChanged,
            onChanged: null,
          ),
        ),
        Gap.h8,
        // Church list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _churches.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.lbl_noChurchesFound,
                    style: BaseTypography.bodyMedium.toSecondary,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
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
