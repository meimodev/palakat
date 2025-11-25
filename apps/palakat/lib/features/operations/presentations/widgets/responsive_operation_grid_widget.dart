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

  /// Breakpoint for switching between 1 and 2 columns (Requirement 7.2, 7.3)
  static const double breakpoint = 600.0;

  /// Minimum touch target size in pixels (Requirement 7.4)
  static const double minTouchTarget = 48.0;

  /// Grid spacing following 8px grid system (Requirement 3.4)
  static const double gridSpacing = 8.0;

  /// Returns the number of columns based on screen width
  /// 2 columns when width > 600px, 1 column otherwise (Requirements 7.2, 7.3)
  static int getColumnCount(double width) {
    return width > breakpoint ? 2 : 1;
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

    // Multi-column layout - calculate item width for 2 columns with spacing
    final itemWidth = (availableWidth - gridSpacing) / 2;

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
