import 'package:flutter/material.dart';
import 'package:palakat_shared/core/models/member_position.dart';

/// A reusable widget for selecting member positions with a dropdown + chips pattern.
///
/// Displays a dropdown to add positions and shows selected positions as removable chips.
/// Supports search functionality to filter positions by name (case-insensitive).
///
/// Features:
/// - Search functionality to filter positions by name
/// - Scrollable list for large position sets
/// - Selected positions displayed as removable chips
///
/// Example usage:
/// ```dart
/// PositionSelector(
///   selectedPositions: mySelectedPositions,
///   onPositionsChanged: (positions) => setState(() => mySelectedPositions = positions),
///   availablePositions: allPositions,
///   label: 'Positions',
///   searchable: true,
/// )
/// ```
class PositionSelector extends StatefulWidget {
  /// List of currently selected positions
  final List<MemberPosition> selectedPositions;

  /// Callback when positions list changes
  final ValueChanged<List<MemberPosition>> onPositionsChanged;

  /// List of all available positions to choose from
  final List<MemberPosition> availablePositions;

  /// Optional label for the field
  final String? label;

  /// Optional hint text for the dropdown
  final String hintText;

  /// Whether the selector is enabled
  final bool enabled;

  /// Whether to enable search functionality in the dropdown.
  /// When true, a search input field is shown at the top of the dropdown.
  /// Defaults to true.
  final bool searchable;

  const PositionSelector({
    super.key,
    required this.selectedPositions,
    required this.onPositionsChanged,
    required this.availablePositions,
    this.label,
    this.hintText = 'Add a position...',
    this.enabled = true,
    this.searchable = true,
  });

  /// Default position names commonly used in church management
  /// Useful for creating MemberPosition objects
  static const List<String> defaultPositionNames = [
    'Elder',
    'Deacon',
    'Member',
    'Worship Leader',
    'Sunday School Teacher',
    'Youth Leader',
    'Small Group Leader',
    'Volunteer',
  ];

  @override
  State<PositionSelector> createState() => _PositionSelectorState();
}

class _PositionSelectorState extends State<PositionSelector> {
  void _addPosition(MemberPosition position) {
    // Check if position already exists by ID or name
    final alreadySelected = widget.selectedPositions.any(
      (p) => p.id == position.id || p.name == position.name,
    );

    if (!alreadySelected) {
      final updated = [...widget.selectedPositions, position];
      widget.onPositionsChanged(updated);
    }
  }

  void _removePosition(MemberPosition position) {
    final updated = widget.selectedPositions
        .where((p) => p.id != position.id && p.name != position.name)
        .toList();
    widget.onPositionsChanged(updated);
  }

  /// Get available items (positions not yet selected)
  List<MemberPosition> get _availableItems {
    final selectedNames = widget.selectedPositions.map((p) => p.name).toSet();
    return widget.availablePositions
        .where((p) => !selectedNames.contains(p.name))
        .toList();
  }

  void _handleTap(BuildContext context) {
    if (!widget.enabled || _availableItems.isEmpty) return;

    if (widget.searchable) {
      _showSearchableDropdown(context);
    } else {
      _showDropdownMenu(context);
    }
  }

  void _showSearchableDropdown(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final buttonWidth = button.size.width;

    showDialog<MemberPosition>(
      context: context,
      builder: (dialogContext) => _SearchablePositionDropdown(
        positions: _availableItems,
        buttonWidth: buttonWidth,
      ),
    ).then((value) {
      if (value != null) {
        _addPosition(value);
      }
    });
  }

  void _showDropdownMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<MemberPosition>(
      context: context,
      position: position,
      constraints: BoxConstraints(
        maxHeight: 300,
        minWidth: button.size.width,
        maxWidth: button.size.width,
      ),
      items: _availableItems.map((position) {
        return PopupMenuItem<MemberPosition>(
          value: position,
          child: Text(position.name),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        _addPosition(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvailableItems = _availableItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Clickable dropdown trigger
        InkWell(
          onTap: widget.enabled && hasAvailableItems
              ? () => _handleTap(context)
              : null,
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: const OutlineInputBorder(),
              fillColor: widget.enabled ? null : Colors.grey.shade100,
              filled: !widget.enabled,
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                color: widget.enabled && hasAvailableItems
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.disabledColor,
              ),
            ),
            child: Text(
              hasAvailableItems ? widget.hintText : 'No positions available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: hasAvailableItems
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.disabledColor,
              ),
            ),
          ),
        ),
        if (widget.selectedPositions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final position in widget.selectedPositions)
                Chip(
                  label: Text(position.name),
                  onDeleted: widget.enabled
                      ? () => _removePosition(position)
                      : null,
                  deleteIcon: widget.enabled
                      ? const Icon(Icons.close, size: 18)
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Searchable dropdown dialog for member positions.
///
/// Provides a search input field that filters positions by name (case-insensitive).
class _SearchablePositionDropdown extends StatefulWidget {
  const _SearchablePositionDropdown({
    required this.positions,
    required this.buttonWidth,
  });

  final List<MemberPosition> positions;
  final double buttonWidth;

  @override
  State<_SearchablePositionDropdown> createState() =>
      _SearchablePositionDropdownState();
}

class _SearchablePositionDropdownState
    extends State<_SearchablePositionDropdown> {
  late TextEditingController _searchController;
  late List<MemberPosition> _filteredPositions;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredPositions = widget.positions;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters positions based on the search query.
  ///
  /// Search strategy: Filter by position name match (case-insensitive)
  List<MemberPosition> _filterPositions(String query) {
    if (query.isEmpty) {
      return widget.positions;
    }

    final lowerQuery = query.toLowerCase();

    return widget.positions.where((position) {
      final name = position.name.toLowerCase();
      return name.contains(lowerQuery);
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredPositions = _filterPositions(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.buttonWidth.clamp(300, 500),
          maxHeight: screenSize.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Select Position',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Search input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by position name',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Divider
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            // Scrollable list of positions
            Flexible(
              child: _filteredPositions.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredPositions.length,
                      itemBuilder: (context, index) {
                        final position = _filteredPositions[index];

                        return ListTile(
                          onTap: () => Navigator.of(context).pop(position),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(
                            position.name,
                            style: theme.textTheme.bodyLarge,
                          ),
                        );
                      },
                    ),
            ),
            // Cancel button
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No positions found',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
