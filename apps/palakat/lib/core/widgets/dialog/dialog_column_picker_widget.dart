import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/account/presentations/membership/membership_controller.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/column.dart' as model;
import 'package:palakat_shared/core/widgets/dialog/dialog_custom_widget.dart';
import 'package:palakat_shared/core/widgets/card/card_column.dart';

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
  Timer? _debounce;
  List<model.Column> _columns = [];
  bool _isLoading = false;
  String _searchQuery = '';

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
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchColumns() async {
    if (widget.churchId == null) return;

    setState(() => _isLoading = true);

    final controller = ref.read(membershipControllerProvider.notifier);
    final columns = await controller.fetchColumns(
      churchId: widget.churchId!,
      searchQuery: _searchQuery,
    );

    if (mounted) {
      setState(() {
        _columns = columns;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Hide keyboard after debounce
      FocusScope.of(context).unfocus();
      setState(() => _searchQuery = query);
      _fetchColumns();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.churchId == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w24),
          child: Text(
            context.l10n.lbl_selectChurchFirst,
            style: BaseTypography.bodyMedium.toSecondary,
            textAlign: TextAlign.center,
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
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: context.l10n.lbl_searchColumns,
              prefixIcon: FaIcon(AppIcons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: FaIcon(AppIcons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: BaseSize.w16,
                vertical: BaseSize.h12,
              ),
            ),
          ),
        ),
        Gap.h8,
        // Column list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _columns.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.lbl_noColumnsFound,
                    style: BaseTypography.bodyMedium.toSecondary,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
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
