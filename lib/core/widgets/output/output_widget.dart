import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class OutputWidget extends StatelessWidget {
  const OutputWidget.bipra({
    super.key,
    required this.title,
    this.label,
    required this.startText,
  })  : startIcon = null,
        onPressedEndIcon = null,
        endIcon = null;

  const OutputWidget.startIcon({
    super.key,
    required this.title,
    this.label,
    required this.startIcon,
  })  : startText = null,
        onPressedEndIcon = null,
        endIcon = null;

  const OutputWidget.endIcon({
    super.key,
    required this.title,
    this.label,
    required this.endIcon,
    this.onPressedEndIcon,
    this.startIcon,
  }) : startText = null;

  final String title;

  final String? label;
  final String? startText;
  final SvgGenImage? startIcon;

  final SvgGenImage? endIcon;
  final VoidCallback? onPressedEndIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Text(
            label!,
            style: BaseTypography.bodyMedium.toSecondary,
          ),
        Gap.h6,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStartWidget(),
              Gap.w12,
              Expanded(
                child: Text(
                  title,
                  style: BaseTypography.titleMedium,
                ),
              ),
              Gap.w12,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildEndWidget(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartWidget() {
    if (startText == null && startIcon == null) {
      return const SizedBox();
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: BaseSize.w36,
        minHeight: BaseSize.w36,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (startIcon != null)
                startIcon!.svg(
                  width: BaseSize.w12,
                  height: BaseSize.w12,
                  colorFilter: BaseColor.primaryText.filterSrcIn,
                ),
              Gap.w12,
              if (startText != null)
                Text(
                  startText!,
                  style: BaseTypography.bodySmall.toBold,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndWidget() {
    if (endIcon == null) {
      return const SizedBox();
    }
    return InkWell(
      onTap: onPressedEndIcon,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: Container(
        padding: EdgeInsets.all(BaseSize.w12),
        decoration: BoxDecoration(
          color: BaseColor.primaryText,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        child: Center(
          child: endIcon!.svg(
            width: BaseSize.w12,
            height: BaseSize.w12,
            colorFilter: BaseColor.cardBackground1.filterSrcIn,
          ),
        ),
      ),
    );
  }
}
