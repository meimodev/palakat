import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class CardDatePreviewWidget extends StatelessWidget {
  const CardDatePreviewWidget({
    super.key,
    required this.date,
    required this.onPressedCardDatePreview,
    this.height,
    this.width,
    required this.eventCount,
    required this.serviceCount,
  });

  final DateTime date;
  final VoidCallback onPressedCardDatePreview;

  final int eventCount;
  final int serviceCount;

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final today = date.isSameDay(DateTime.now());
    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        side: BorderSide(
          width: 3,
          color: today ? BaseColor.primaryText : BaseColor.transparent,
        ),
      ),
      child: InkWell(
        onTap: onPressedCardDatePreview,
        child: Container(
          height: height,
          width: width,
          padding: EdgeInsets.only(
            top: BaseSize.h6,
            left: BaseSize.w6,
            right: BaseSize.w6,
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.toStringFormatted("E"),
                style: BaseTypography.bodyMedium.toSecondary,
              ),
              Text(
                date.day.toString(),
                style: BaseTypography.headlineSmall,
              ),
              serviceCount == 0 && eventCount == 0
                  ? const SizedBox()
                  : _buildCounters()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap.h6,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            serviceCount != 0
                ? Text(
                    "$serviceCount Service",
                    style: BaseTypography.labelSmall.toBold,
                  )
                : const SizedBox(),
            eventCount != 0
                ? Text(
                    "$eventCount Event",
                    style: BaseTypography.labelSmall.toBold,
                  )
                : const SizedBox(),
          ],
        ),
      ],
    );
  }
}
