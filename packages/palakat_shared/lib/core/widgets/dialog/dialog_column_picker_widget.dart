import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/column.dart' as model;
import '../card/card_column.dart';
import 'dialog_custom_widget.dart';

/// Callback type for fetching columns with church ID and optional search query.
typedef ColumnFetcher =
    Future<List<model.Column>> Function({
      required int churchId,
      String? searchQuery,
    });

/// Shows a dialog for selecting a column.
///
/// The [columnFetcher] callback is used to fetch columns, allowing the caller
/// to provide their own data fetching logic (e.g., from a repository or controller).
///
/// Returns the selected [Column] or null if cancelled.
Future<model.Column?> showDialogColumnPickerWidget({
  required BuildContext context,
  required int? churchId,
  required ColumnFetcher columnFetcher,
  VoidCallback? onPopBottomSheet,
  Widget? closeIcon,
}) {
  return showDialogCustomWidget<model.Column?>(
    context: context,
    title: "Select Column",
    scrollControlled: false,
    closeIcon: closeIcon,
    content: Expanded(
      child: _DialogColumnPickerWidget(
        churchId: churchId,
        columnFetcher: columnFetcher,
      ),
    ),
  );
}

class _DialogColumnPickerWidget extends StatefulWidget {
  final int? churchId;
  final ColumnFetcher columnFetcher;

  const _DialogColumnPickerWidget({
    required this.churchId,
    required this.columnFetcher,
  });

  @override
  State<_DialogColumnPickerWidget> createState() =>
      _DialogColumnPickerWidgetState();
}

class _DialogColumnPickerWidgetState extends State<_DialogColumnPickerWidget> {
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

    final columns = await widget.columnFetcher(
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
            'Please select a church first',
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
              hintText: 'Search columns...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
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
                    'No columns found',
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
