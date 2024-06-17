import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';

class InputVariantDropdownWidget extends StatefulWidget {
  const InputVariantDropdownWidget({
    super.key,
    required this.options,
    required this.currentInputValue,
    required this.onChanged,
  });

  final List<String> options;
  final String? currentInputValue;
  final ValueChanged<String> onChanged;

  @override
  State<InputVariantDropdownWidget> createState() =>
      _InputVariantDropdownWidgetState();
}

class _InputVariantDropdownWidgetState
    extends State<InputVariantDropdownWidget> {
  String currentValue = "";

  @override
  void initState() {
    super.initState();
    if (widget.currentInputValue != null) {
      currentValue = widget.currentInputValue ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // showBottomDialog then catch result
        setState(() {
          currentValue = "changed";
        });
        widget.onChanged(currentValue);
      },
      child: Container(
        padding: EdgeInsets.all(BaseSize.w12),
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(
            BaseSize.radiusMd,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                currentValue,
                style: BaseTypography.titleMedium,
              ),
            ),
            Gap.w12,
            Assets.icons.line.chevronDownOutline.svg(
              width: BaseSize.w12,
              height: BaseSize.w12,
            ),
          ],
        ),
      ),
    );
  }
}
