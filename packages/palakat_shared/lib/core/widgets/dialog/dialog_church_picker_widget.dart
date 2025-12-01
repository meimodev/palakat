import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/church.dart';
import '../card/card_church.dart';
import 'dialog_custom_widget.dart';

/// Callback type for fetching churches with optional search query.
typedef ChurchFetcher = Future<List<Church>> Function({String? searchQuery});

/// Shows a dialog for selecting a church.
///
/// The [churchFetcher] callback is used to fetch churches, allowing the caller
/// to provide their own data fetching logic (e.g., from a repository or controller).
///
/// Returns the selected [Church] or null if cancelled.
Future<Church?> showDialogChurchPickerWidget({
  required BuildContext context,
  required ChurchFetcher churchFetcher,
  VoidCallback? onPopBottomSheet,
  Widget? closeIcon,
}) {
  return showDialogCustomWidget<Church?>(
    context: context,
    title: "Select Church",
    scrollControlled: false,
    closeIcon: closeIcon,
    content: Expanded(
      child: _DialogChurchPickerWidget(churchFetcher: churchFetcher),
    ),
  );
}

class _DialogChurchPickerWidget extends StatefulWidget {
  const _DialogChurchPickerWidget({required this.churchFetcher});

  final ChurchFetcher churchFetcher;

  @override
  State<_DialogChurchPickerWidget> createState() =>
      _DialogChurchPickerWidgetState();
}

class _DialogChurchPickerWidgetState extends State<_DialogChurchPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
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
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchChurches() async {
    setState(() => _isLoading = true);

    final churches = await widget.churchFetcher(searchQuery: _searchQuery);

    if (mounted) {
      setState(() {
        _churches = churches;
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
      _fetchChurches();
    });
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
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search churches...',
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
        // Church list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _churches.isEmpty
              ? Center(
                  child: Text(
                    'No churches found',
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
