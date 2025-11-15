import 'package:flutter/material.dart';
import 'package:palakat_shared/core/models/member_position.dart';

/// A reusable widget for selecting member positions with a dropdown + chips pattern.
/// 
/// Displays a dropdown to add positions and shows selected positions as removable chips.
class PositionSelector extends StatelessWidget {
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

  const PositionSelector({
    super.key,
    required this.selectedPositions,
    required this.onPositionsChanged,
    required this.availablePositions,
    this.label,
    this.hintText = 'Add a position...',
    this.enabled = true,
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

  void _addPosition(MemberPosition position) {
    // Check if position already exists by ID or name
    final alreadySelected = selectedPositions.any(
      (p) => p.id == position.id || p.name == position.name,
    );
    
    if (!alreadySelected) {
      final updated = [...selectedPositions, position];
      onPositionsChanged(updated);
    }
  }

  void _removePosition(MemberPosition position) {
    final updated = selectedPositions
        .where((p) => p.id != position.id && p.name != position.name)
        .toList();
    onPositionsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    // Filter out already selected positions
    final selectedNames = selectedPositions.map((p) => p.name).toSet();
    final availableItems = availablePositions
        .where((p) => !selectedNames.contains(p.name))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<MemberPosition>(
          key: ValueKey(selectedPositions.length),
          value: null,
          items: availableItems
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name),
                ),
              )
              .toList(),
          onChanged: enabled
              ? (v) {
                  if (v != null) _addPosition(v);
                }
              : null,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            fillColor: enabled ? null : Colors.grey.shade100,
            filled: !enabled,
          ),
        ),
        if (selectedPositions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final position in selectedPositions)
                Chip(
                  label: Text(position.name),
                  onDeleted: enabled ? () => _removePosition(position) : null,
                  deleteIcon: enabled ? const Icon(Icons.close, size: 18) : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
