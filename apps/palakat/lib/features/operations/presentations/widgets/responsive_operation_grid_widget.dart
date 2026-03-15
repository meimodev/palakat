import 'package:flutter/material.dart';
import 'package:palakat/features/operations/data/operation_models.dart';
import 'package:palakat/features/operations/presentations/widgets/operation_item_card_widget.dart';

/// Responsive grid layout for operation cards.
/// Adapts column count based on screen width.
///
/// Requirements: 7.1, 7.2, 7.3, 7.4
class ResponsiveOperationGrid extends StatelessWidget {
  const ResponsiveOperationGrid({
    super.key,
    required this.operations,
    required this.onOperationTap,
  });

  /// List of operations to display in the grid
  final List<OperationItem> operations;

  /// Callback when an operation card is tapped
  final ValueChanged<OperationItem> onOperationTap;

  /// Breakpoint for switching between compact and multi-column layouts.
  static const double breakpoint = 600.0;
  static const double largeBreakpoint = 960.0;

  /// Minimum touch target size in pixels (Requirement 7.4)
  static const double minTouchTarget = 48.0;

  /// Grid spacing following 8px grid system (Requirement 3.4)
  static const double gridSpacing = 8.0;

  /// Returns the number of columns based on screen width.
  static int getColumnCount(double width) {
    if (width >= largeBreakpoint) return 3;
    if (width >= breakpoint) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (operations.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = getColumnCount(constraints.maxWidth);

        return _buildGrid(columnCount, constraints.maxWidth);
      },
    );
  }

  Widget _buildGrid(int columnCount, double availableWidth) {
    if (columnCount == 1) {
      // Single column layout - use Column for simplicity
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: operations.map((operation) {
          return Padding(
            padding: EdgeInsets.only(bottom: gridSpacing),
            child: _buildOperationCard(operation),
          );
        }).toList(),
      );
    }

    final totalSpacing = gridSpacing * (columnCount - 1);
    final itemWidth = (availableWidth - totalSpacing) / columnCount;

    return Wrap(
      spacing: gridSpacing,
      runSpacing: gridSpacing,
      children: operations.map((operation) {
        return SizedBox(
          width: itemWidth,
          child: _buildOperationCard(operation),
        );
      }).toList(),
    );
  }

  Widget _buildOperationCard(OperationItem operation) {
    // Ensure minimum touch target size (Requirement 7.4)
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: minTouchTarget,
        minWidth: minTouchTarget,
      ),
      child: OperationItemCard(
        operation: operation,
        onTap: () => onOperationTap(operation),
      ),
    );
  }
}
