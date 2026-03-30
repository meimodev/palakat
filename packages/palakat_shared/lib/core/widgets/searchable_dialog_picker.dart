import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/theme/theme.dart';

import 'loading_widget.dart';
import 'search_field.dart';

/// A reusable dialog widget for searchable item pickers.
///
/// This widget provides a consistent UI for selecting items from a searchable list.
/// It includes:
/// - Search field with debounce
/// - Filtered list of items
/// - Empty state handling
/// - Selected item highlighting
///
/// Example usage:
/// ```dart
/// final result = await showDialog<MyItem>(
///   context: context,
///   builder: (context) => SearchableDialogPicker<MyItem>(
///     title: 'Select Item',
///     searchHint: 'Search items...',
///     items: myItems,
///     selectedItem: currentItem,
///     itemBuilder: (item) => Text(item.name),
///     onFilter: (item, query) => item.name.toLowerCase().contains(query),
///     emptyStateMessage: 'No items found',
///   ),
/// );
/// ```
class SearchableDialogPicker<T> extends StatefulWidget {
  const SearchableDialogPicker({
    super.key,
    required this.title,
    required this.searchHint,
    required this.items,
    required this.itemBuilder,
    required this.onFilter,
    this.selectedItem,
    this.emptyStateMessage,
    this.maxWidth = 500,
    this.maxHeightFactor = 0.6,
    this.debounceMilliseconds = 300,
    this.searchBorderRadius = 8,
    this.initialHasMore = false,
    this.onFetchPage,
  });

  /// Dialog title displayed at the top.
  final String title;

  /// Hint text for the search field.
  final String searchHint;

  /// List of items to display and search through.
  final List<T> items;

  /// Currently selected item (will be highlighted).
  final T? selectedItem;

  /// Builder function to create the widget for each item.
  final Widget Function(T item) itemBuilder;

  /// Filter function to determine if an item matches the search query.
  ///
  /// Should return true if the item matches the query (case-insensitive).
  final bool Function(T item, String query) onFilter;

  /// Message to display when no items match the search.
  final String? emptyStateMessage;

  /// Maximum width of the dialog.
  final double maxWidth;

  /// Maximum height as a factor of screen height (0.0 to 1.0).
  final double maxHeightFactor;

  /// Debounce delay for search in milliseconds.
  final int debounceMilliseconds;

  /// Border radius for the search field.
  final double searchBorderRadius;

  final bool initialHasMore;

  final Future<Result<({List<T> items, bool hasMore}), Failure>> Function(
    String query,
    int page,
  )?
  onFetchPage;

  @override
  State<SearchableDialogPicker<T>> createState() =>
      _SearchableDialogPickerState<T>();
}

class _SearchableDialogPickerState<T> extends State<SearchableDialogPicker<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;
  late List<T> _asyncItems;
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
    _hasMore = widget.initialHasMore;
    _currentPage = widget.items.isNotEmpty ? 1 : 0;

    if (_isAsyncMode && widget.items.isEmpty) {
      Future.microtask(() => _fetchAsyncPage(reset: true));
    }
  }

  @override
  void didUpdateWidget(covariant SearchableDialogPicker<T> oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            widget.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
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

                // Search field
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
                                  final isSelected =
                                      item == widget.selectedItem;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          SanctuaryLayout.radius,
                                        ),
                                        onTap: () =>
                                            Navigator.of(context).pop(item),
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
                                              if (isSelected)
                                                Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          SanctuaryLayout
                                                              .radius,
                                                        ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.check,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    size: 16,
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
