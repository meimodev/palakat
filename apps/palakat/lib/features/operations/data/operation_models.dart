import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'operation_models.freezed.dart';

/// Represents a category of operations in the Operations screen.
/// Categories group related operations together (e.g., Publishing, Financial, Reports).
@freezed
abstract class OperationCategory with _$OperationCategory {
  const factory OperationCategory({
    /// Unique identifier for the category
    required String id,

    /// Display title for the category header
    required String title,

    /// Icon displayed in the category header
    required IconData icon,

    /// List of operations belonging to this category
    required List<OperationItem> operations,

    /// Whether the category is currently expanded to show all operations
    @Default(false) bool isExpanded,
  }) = _OperationCategory;
}

/// Represents an individual operation item within a category.
/// Each operation corresponds to a specific action the user can perform.
@freezed
abstract class OperationItem with _$OperationItem {
  const factory OperationItem({
    /// Unique identifier for the operation
    required String id,

    /// Display title for the operation card
    required String title,

    /// Brief description of what the operation does
    required String description,

    /// Icon displayed on the operation card
    required IconData icon,

    /// Route name for navigation when the operation is tapped
    required String routeName,

    /// Optional route parameters for navigation
    Map<String, dynamic>? routeParams,

    /// Whether the operation is currently available to the user
    @Default(true) bool isEnabled,
  }) = _OperationItem;
}
