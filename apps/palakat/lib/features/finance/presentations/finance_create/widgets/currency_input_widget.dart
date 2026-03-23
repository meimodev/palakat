import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palakat/core/constants/constants.dart';

String _formatThousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// A currency input widget that formats values as Indonesian Rupiah.
/// Displays as "Rp X.XXX.XXX" while storing the raw integer value.
/// Requirements: 6.4
class CurrencyInputWidget extends StatefulWidget {
  const CurrencyInputWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.currentValue,
    this.errorText,
  });

  final String label;
  final String hint;
  final String? currentValue;
  final String? errorText;
  final void Function(String value) onChanged;

  @override
  State<CurrencyInputWidget> createState() => _CurrencyInputWidgetState();
}

class _CurrencyInputWidgetState extends State<CurrencyInputWidget> {
  late TextEditingController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _initializeValue();
  }

  void _initializeValue() {
    if (widget.currentValue != null && widget.currentValue!.isNotEmpty) {
      final rawValue = widget.currentValue!.replaceAll('.', '');
      final formatted = _formatCurrency(rawValue);
      _controller.text = formatted;
    }
    _isInitialized = true;
  }

  @override
  void didUpdateWidget(CurrencyInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the value changed externally and we're initialized
    if (_isInitialized &&
        widget.currentValue != oldWidget.currentValue &&
        widget.currentValue != null) {
      final rawValue = widget.currentValue!.replaceAll('.', '');
      final formatted = _formatCurrency(rawValue);
      if (_controller.text != formatted) {
        _controller.text = formatted;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: formatted.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Formats a raw number string to currency format with thousand separators.
  /// Example: "1500000" -> "1.500.000"
  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    // Remove any existing formatting
    final cleanValue = value.replaceAll('.', '').replaceAll(',', '');

    // Parse to ensure it's a valid number
    final number = int.tryParse(cleanValue);
    if (number == null) return value;

    // Format with thousand separators (Indonesian style uses period)
    final formatted = _formatThousands(number);

    return formatted;
  }

  void _onChanged(String value) {
    // Remove formatting to get raw value
    final rawValue = value.replaceAll('.', '');

    // Format the display value
    final formatted = _formatCurrency(rawValue);

    // Update controller if formatting changed
    if (value != formatted) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Pass raw value to parent (with dots for storage format)
    widget.onChanged(rawValue);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColors.neutral,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.h6,
        // Input field with Rp prefix
        Material(
          color: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: hasError
                  ? AppColors.error.withValues(alpha: 0.5)
                  : AppColors.neutral,
            ),
          ),
          child: Row(
            children: [
              // Rp prefix
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Rp',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Input field
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _onChanged,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: AppColors.neutral),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Error message
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text(
              widget.errorText!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

/// Utility function to format an integer amount to Indonesian Rupiah display format.
/// Example: 1500000 -> "Rp 1.500.000"
/// Requirements: 6.4
String formatRupiah(int amount) {
  final formatted = _formatThousands(amount);
  return 'Rp $formatted';
}
