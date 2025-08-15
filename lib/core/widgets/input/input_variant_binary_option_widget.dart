import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class InputVariantBinaryOptionWidget<T> extends StatefulWidget {
  const InputVariantBinaryOptionWidget({
    super.key,
    required this.options,
    required this.optionLabel,
    this.currentInputValue,
    required this.onChanged,
    this.borderColor,
  });

  final List<T> options;
  final String Function(T option) optionLabel;
  final T? currentInputValue;
  final ValueChanged<T> onChanged;
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
      setState(() {
        active = widget.currentInputValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.options
          .map(
            (e) => Expanded(
              child: Material(
                clipBehavior: Clip.hardEdge,
                shape: ContinuousRectangleBorder(
                  side: BorderSide(
                    color: widget.borderColor ?? Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: e == widget.options.first
                        ? Radius.circular(BaseSize.radiusLg * 2)
                        : Radius.zero,
                    topLeft: e == widget.options.first
                        ? Radius.circular(BaseSize.radiusLg * 2)
                        : Radius.zero,
                    bottomRight: e == widget.options.last
                        ? Radius.circular(BaseSize.radiusLg * 2)
                        : Radius.zero,
                    topRight: e == widget.options.last
                        ? Radius.circular(BaseSize.radiusLg * 2)
                        : Radius.zero,
                  ),
                ),
                color: e == active
                    ? BaseColor.primary3
                    : BaseColor.cardBackground1,
                child: InkWell(
                  onTap: e == active
                      ? null
                      : () {
                          setState(() {
                            active = e;
                          });
                          widget.onChanged(e);
                        },
                  child: Container(
                    padding: EdgeInsets.all(
                      BaseSize.w12,
                    ),
                    child: Center(
                      child: Text(
                        widget.optionLabel(e),
                        style: BaseTypography.titleMedium.bold.copyWith(
                          color: e == active
                              ? BaseColor.cardBackground1
                              : BaseColor.primary3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
