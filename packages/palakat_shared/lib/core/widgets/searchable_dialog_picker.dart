import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';

import 'input/input_search_widget.dart';

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

  @override
  State<SearchableDialogPicker<T>> createState() =>
      _SearchableDialogPickerState<T>();
}

class _SearchableDialogPickerState<T> extends State<SearchableDialogPicker<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

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
                  child: InputSearchWidget(
                    controller: _searchController,
                    hint: widget.searchHint,
                    autoClearButton: true,
                    debounceMilliseconds: widget.debounceMilliseconds,
                    borderRadius: widget.searchBorderRadius,
                    onChanged: _onSearchChanged,
                  ),
                ),

                Gap.h16,

                // Items list
                Expanded(
                  child: _filteredItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected = item == widget.selectedItem;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                    SanctuaryLayout.radius,
                                  ),
                                  onTap: () => Navigator.of(context).pop(item),
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
                                            ? AppColors.primary.withValues(
                                                alpha: 0.18,
                                              )
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
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    SanctuaryLayout.radius,
                                                  ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.check,
                                              color: theme.colorScheme.primary,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

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
                widget.emptyStateMessage ?? 'No items found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
