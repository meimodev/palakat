import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_admin/core/extension/extension.dart';

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
    final hasEvents = serviceCount > 0 || eventCount > 0;

    return Material(
      clipBehavior: Clip.hardEdge,
      elevation: today ? 2 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: today ? BaseColor.teal[300] : BaseColor.teal[50],
      color: today ? Colors.transparent : BaseColor.cardBackground1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: today
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    BaseColor.blue[600]!,
                    BaseColor.teal[500]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: InkWell(
          onTap: onPressedCardDatePreview,
          child: Container(
            height: height,
            width: width,
            padding: EdgeInsets.symmetric(
              vertical: BaseSize.customHeight(10),
              horizontal: BaseSize.customWidth(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Day name
                Text(
                  date.toStringFormatted("E"),
                  style: BaseTypography.bodySmall.copyWith(
                    color: today ? Colors.white.withValues(alpha: 0.9) : BaseColor.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap.h4,
                // Day number
                Text(
                  date.day.toString(),
                  style: BaseTypography.headlineSmall.copyWith(
                    color: today ? Colors.white : BaseColor.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Event counters
                if (hasEvents) ...[
                  Gap.h6,
                  _buildCounters(today),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounters(bool isToday) {
    return Flexible(
      child: Wrap(
        spacing: BaseSize.w4,
        runSpacing: BaseSize.h4,
        alignment: WrapAlignment.center,
        children: [
          if (serviceCount != 0)
            _pillChip(
              icon: Icons.church_outlined,
              label: serviceCount.toString(),
              bg: isToday ? Colors.white.withValues(alpha: 0.2) : BaseColor.green[50]!,
              fg: isToday ? Colors.white : BaseColor.green[700]!,
              border: isToday ? Colors.white.withValues(alpha: 0.3) : BaseColor.green[200]!,
            ),
          if (eventCount != 0)
            _pillChip(
              icon: Icons.event_outlined,
              label: eventCount.toString(),
              bg: isToday ? Colors.white.withValues(alpha: 0.2) : BaseColor.blue[50]!,
              fg: isToday ? Colors.white : BaseColor.blue[700]!,
              border: isToday ? Colors.white.withValues(alpha: 0.3) : BaseColor.blue[200]!,
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
        horizontal: BaseSize.w6,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: BaseSize.customWidth(12), color: fg),
          Gap.w4,
          Text(
            label,
            style: BaseTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
