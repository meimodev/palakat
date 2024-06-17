import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class InputVariantBinaryOptionWidget extends StatefulWidget {
  const InputVariantBinaryOptionWidget({
    super.key,
    required this.options,
    this.currentInputValue,
    required this.onChanged,
  });

  final List<String> options;
  final String? currentInputValue;
  final ValueChanged<String> onChanged;

  @override
  State<InputVariantBinaryOptionWidget> createState() =>
      _InputVariantBinaryOptionWidgetState();
}

class _InputVariantBinaryOptionWidgetState
    extends State<InputVariantBinaryOptionWidget> {
  String active = "";

  @override
  void initState() {
    super.initState();

    if (widget.currentInputValue != null) {
      setState(() {
        active = widget.currentInputValue!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.options.map(
            (e) {
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  active = e;
                });
                widget.onChanged(e);
              },
              child: Container(
                padding: EdgeInsets.all(
                  BaseSize.w12,
                ),
                decoration: BoxDecoration(
                  color: e == active
                      ? BaseColor.primary3
                      : BaseColor.cardBackground1,
                  borderRadius: BorderRadius.only(
                    bottomLeft: e == widget.options.first
                        ? Radius.circular(BaseSize.radiusMd)
                        : Radius.zero,
                    topLeft: e == widget.options.first
                        ? Radius.circular(BaseSize.radiusMd)
                        : Radius.zero,
                    bottomRight: e == widget.options.last
                        ? Radius.circular(BaseSize.radiusMd)
                        : Radius.zero,
                    topRight: e == widget.options.last
                        ? Radius.circular(BaseSize.radiusMd)
                        : Radius.zero,
                  ),
                ),
                child: Center(
                  child: Text(
                    e,
                    style: BaseTypography.titleMedium.bold.copyWith(
                      color: e == active
                          ? BaseColor.cardBackground1
                          : BaseColor.primary3,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

