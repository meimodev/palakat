import 'package:flutter/material.dart';

import '../utils/debouncer.dart';
import 'input/input_search_widget.dart';

/// A specialized search field widget with common search patterns.
///
/// This widget provides a consistent search experience across the app with:
/// - Automatic debouncing
/// - Auto-clear button
/// - Consistent styling
/// - Loading state support
///
/// Example usage:
/// ```dart
/// SearchField(
///   hint: 'Search songs...',
///   onSearch: (query) async {
///     // Perform search
///     await searchApi(query);
///   },
///   isLoading: isSearching,
/// )
/// ```
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.hint,
    this.onSearch,
    this.onChanged,
    this.debounceMilliseconds = 300,
    this.isLoading = false,
    this.borderRadius,
    this.constraints,
    this.prefixIcon,
    this.clearIcon,
    this.readOnly = false,
    this.focusNode,
    this.unfocusOnSearch = false,
  });

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Hint text for the search field.
  final String? hint;

  /// Callback for search with debouncing.
  ///
  /// This is called after the debounce delay when the user stops typing.
  /// Use this for API calls or expensive operations.
  final ValueChanged<String>? onSearch;

  /// Immediate callback when text changes.
  ///
  /// This is called immediately without debouncing.
  /// Use this for local filtering or UI updates.
  final ValueChanged<String>? onChanged;

  /// Debounce delay in milliseconds for [onSearch].
  ///
  /// Defaults to 300ms. Set to 0 to disable debouncing.
  final int debounceMilliseconds;

  /// Whether to show a loading indicator in place of the clear button.
  final bool isLoading;

  /// Border radius for the search field.
  final double? borderRadius;

  /// Box constraints for the search field.
  final BoxConstraints? constraints;

  /// Custom prefix icon widget.
  final Widget? prefixIcon;

  final Widget? clearIcon;

  /// Set the field to read only.
  final bool readOnly;

  /// Focus node for the search field.
  final FocusNode? focusNode;

  final bool unfocusOnSearch;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  bool _isInternalController = false;
  late Debouncer _debouncer;
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _isInternalController = widget.controller == null;
    _debouncer = Debouncer(milliseconds: widget.debounceMilliseconds);
    _lastText = _controller.text;
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.debounceMilliseconds != oldWidget.debounceMilliseconds) {
      _debouncer.dispose();
      _debouncer = Debouncer(milliseconds: widget.debounceMilliseconds);
    }
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleControllerChanged);
      if (_isInternalController) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _isInternalController = widget.controller == null;
      _lastText = _controller.text;
      _controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _debouncer.dispose();
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleControllerChanged() {
    final value = _controller.text;
    if (value == _lastText) return;
    _lastText = value;

    widget.onChanged?.call(value);

    final onSearch = widget.onSearch;
    if (onSearch == null) return;

    void doSearch() {
      if (!mounted) return;
      if (widget.unfocusOnSearch) {
        FocusScope.of(context).unfocus();
      }
      onSearch(value);
    }

    if (value.isEmpty || widget.debounceMilliseconds <= 0) {
      _debouncer.cancel();
      doSearch();
      return;
    }

    _debouncer.run(doSearch);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InputSearchWidget(
      controller: _controller,
      hint: widget.hint,
      readOnly: widget.readOnly,
      focusNode: widget.focusNode,
      borderRadius: widget.borderRadius,
      constraints: widget.constraints,
      prefixIcon: widget.prefixIcon,
      clearIcon: widget.clearIcon,
      autoClearButton: true,
      onChanged: null,
      suffixIcon: widget.isLoading
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
