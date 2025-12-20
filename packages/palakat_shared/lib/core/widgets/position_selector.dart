import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/member_position.dart';

import 'searchable_dialog_picker.dart';

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
    final l10n = context.l10n;
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
              hasAvailableItems ? widget.hintText : l10n.noData_positions,
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
class _SearchablePositionDropdown extends StatelessWidget {
  const _SearchablePositionDropdown({
    required this.positions,
    required this.buttonWidth,
  });

  final List<MemberPosition> positions;
  final double buttonWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SearchableDialogPicker<MemberPosition>(
      title: l10n.dlg_selectPosition_title,
      searchHint: l10n.hint_searchPositions,
      items: positions,
      itemBuilder: (position) => Text(position.name),
      onFilter: (position, query) =>
          position.name.toLowerCase().contains(query),
      emptyStateMessage: l10n.noData_matchingCriteria,
      maxWidth: buttonWidth.clamp(300, 500),
      maxHeightFactor: 0.6,
    );
  }
}
