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
          padding: EdgeInsets.symmetric(
            vertical: BaseSize.h6,
            horizontal: BaseSize.w6,
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
    return Padding(
      padding: EdgeInsets.only(top: BaseSize.h6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (serviceCount != 0)
            _pillChip(
              icon: Icons.church,
              label: serviceCount.toString(),
              bg: BaseColor.green[50]!,
              fg: BaseColor.green[700]!,
              border: BaseColor.green[200]!,
            ),
          if (serviceCount != 0 && eventCount != 0) Gap.w6,
          if (eventCount != 0)
            _pillChip(
              icon: Icons.event,
              label: eventCount.toString(),
              bg: BaseColor.blue[50]!,
              fg: BaseColor.blue[700]!,
              border: BaseColor.blue[200]!,
            ),
        ],
      ),
    );
  }

  Widget _pillChip({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    required Color border,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: BaseSize.radiusSm, color: fg),
          Gap.w4,
          Text(
            label,
            style: BaseTypography.labelSmall.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
