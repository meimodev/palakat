import 'package:flutter/material.dart';

/// A theme-aware binary option input variant widget.
///
/// Uses [Theme.of(context)] for styling instead of hardcoded constants,
/// making it compatible with both palakat and palakat_admin apps.
///
/// Displays options as selectable buttons in a row.
class InputVariantBinaryOptionWidget<T> extends StatefulWidget {
  const InputVariantBinaryOptionWidget({
    super.key,
    required this.options,
    required this.optionLabel,
    this.currentInputValue,
    required this.onChanged,
    this.borderColor,
  });

  /// List of options to display.
  final List<T> options;

  /// Function to get the display label for an option.
  final String Function(T option) optionLabel;

  /// Currently selected value.
  final T? currentInputValue;

  /// Callback when the selection changes.
  final ValueChanged<T> onChanged;

  /// Border color override.
  final Color? borderColor;

  @override
  State<InputVariantBinaryOptionWidget> createState() =>
      _InputVariantBinaryOptionWidgetState<T>();
}

class _InputVariantBinaryOptionWidgetState<T>
    extends State<InputVariantBinaryOptionWidget<T>> {
  T? active;

  @override
  void initState() {
    super.initState();
    if (widget.currentInputValue != null) {
      active = widget.currentInputValue;
    }
  }

  @override
  void didUpdateWidget(InputVariantBinaryOptionWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentInputValue != oldWidget.currentInputValue) {
      active = widget.currentInputValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.options.map((e) {
        final isActive = e == active;
        final isFirst = e == widget.options.first;
        final isLast = e == widget.options.last;

        final effectiveBorderColor = isActive
            ? theme.colorScheme.primary
            : (widget.borderColor ?? theme.colorScheme.outline);

        return Expanded(
          child: Material(
            clipBehavior: Clip.hardEdge,
            shape: ContinuousRectangleBorder(
              side: BorderSide(
                color: effectiveBorderColor,
                width: isActive ? 2 : 1.5,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: isFirst ? const Radius.circular(48) : Radius.zero,
                topLeft: isFirst ? const Radius.circular(48) : Radius.zero,
                bottomRight: isLast ? const Radius.circular(48) : Radius.zero,
                topRight: isLast ? const Radius.circular(48) : Radius.zero,
              ),
            ),
            color: isActive
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface,
            shadowColor: Colors.black.withValues(alpha: 0.04),
            elevation: isActive ? 2 : 1,
            child: InkWell(
              onTap: isActive
                  ? null
                  : () {
                      setState(() {
                        active = e;
                      });
                      widget.onChanged(e);
                    },
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    widget.optionLabel(e),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
