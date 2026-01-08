import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';

class CardDatePreviewWidget extends StatelessWidget {
  const CardDatePreviewWidget({
    super.key,
    required this.date,
    required this.onPressedCardDatePreview,
    this.height,
    this.width,
    required this.eventCount,
    required this.serviceCount,
    required this.birthdayCount,
    this.announcementCount = 0,
  });

  final DateTime date;
  final VoidCallback onPressedCardDatePreview;

  final int eventCount;
  final int serviceCount;
  final int birthdayCount;
  final int announcementCount;

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final today = date.isSameDay(DateTime.now());
    final hasEvents =
        serviceCount > 0 ||
        eventCount > 0 ||
        birthdayCount > 0 ||
        announcementCount > 0;

    return Material(
      clipBehavior: Clip.hardEdge,
      elevation: today ? 2 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: today ? BaseColor.teal[300] : BaseColor.teal[50],
      color: today ? Colors.transparent : BaseColor.cardBackground1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: today
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [BaseColor.blue[600]!, BaseColor.teal[500]!],
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
                    color: today
                        ? Colors.white.withValues(alpha: 0.9)
                        : BaseColor.secondaryText,
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
                if (hasEvents) ...[Gap.h6, _buildCounters(today)],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounters(bool isToday) {
    final items = <Widget>[];

    if (birthdayCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.birthday,
          label: birthdayCount.toString(),
          bg: isToday
              ? Colors.white.withValues(alpha: 0.2)
              : BaseColor.yellow[50]!,
          fg: isToday ? Colors.white : BaseColor.yellow[700]!,
          border: isToday
              ? Colors.white.withValues(alpha: 0.3)
              : BaseColor.yellow[200]!,
        ),
      );
    }

    if (serviceCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.church,
          label: serviceCount.toString(),
          bg: isToday
              ? Colors.white.withValues(alpha: 0.2)
              : BaseColor.green[50]!,
          fg: isToday ? Colors.white : BaseColor.green[700]!,
          border: isToday
              ? Colors.white.withValues(alpha: 0.3)
              : BaseColor.green[200]!,
        ),
      );
    }

    if (eventCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.event,
          label: eventCount.toString(),
          bg: isToday
              ? Colors.white.withValues(alpha: 0.2)
              : BaseColor.blue[50]!,
          fg: isToday ? Colors.white : BaseColor.blue[700]!,
          border: isToday
              ? Colors.white.withValues(alpha: 0.3)
              : BaseColor.blue[200]!,
        ),
      );
    }

    if (announcementCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.announcement,
          label: announcementCount.toString(),
          bg: isToday
              ? Colors.white.withValues(alpha: 0.2)
              : BaseColor.teal[50]!,
          fg: isToday ? Colors.white : BaseColor.teal[700]!,
          border: isToday
              ? Colors.white.withValues(alpha: 0.3)
              : BaseColor.teal[200]!,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox();

    Widget cell(Widget? child) {
      return Expanded(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: child ?? const SizedBox(),
          ),
        ),
      );
    }

    Widget row(Widget? left, Widget? right) {
      return Row(children: [cell(left), Gap.w4, cell(right)]);
    }

    final row1Left = items.isNotEmpty ? items[0] : null;
    final row1Right = items.length > 1 ? items[1] : null;
    final row2Left = items.length > 2 ? items[2] : null;
    final row2Right = items.length > 3 ? items[3] : null;

    final hasSecondRow = row2Left != null || row2Right != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row(row1Left, row1Right),
        if (hasSecondRow) ...[Gap.h4, row(row2Left, row2Right)],
      ],
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
