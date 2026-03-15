import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';

class CardDatePreviewWidget extends StatefulWidget {
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
  State<CardDatePreviewWidget> createState() => _CardDatePreviewWidgetState();
}

class _CardDatePreviewWidgetState extends State<CardDatePreviewWidget> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final date = widget.date;
    final today = date.isSameDay(DateTime.now());
    final hasEvents =
        widget.serviceCount > 0 ||
        widget.eventCount > 0 ||
        widget.birthdayCount > 0 ||
        widget.announcementCount > 0;
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    return AnimatedScale(
      scale: _pressed && !reduceMotion ? 0.97 : 1,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        clipBehavior: Clip.hardEdge,
        elevation: today ? 2 : 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor:
            today ? BaseColor.primary[200] : BaseColor.primary[50],
        color: today ? Colors.transparent : BaseColor.cardBackground1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        ),
        child: Container(
          decoration: today
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [BaseColor.blue[600]!, BaseColor.teal[500]!],
                  ),
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                )
              : null,
          child: InkWell(
            onTap: widget.onPressedCardDatePreview,
            onHighlightChanged: (value) {
              if (_pressed == value) return;
              setState(() => _pressed = value);
            },
            child: Container(
              height: widget.height,
              width: widget.width,
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
                    style: BaseTypography.labelMedium.copyWith(
                      color: today
                          ? Colors.white.withValues(alpha: 0.9)
                          : BaseColor.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  // Day number
                  Text(
                    date.day.toString(),
                    style: BaseTypography.headlineSmall.copyWith(
                      color: today ? Colors.white : BaseColor.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Event counters
                  if (hasEvents) ...[Gap.h6, _buildCounters(today)],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounters(bool isToday) {
    final items = <Widget>[];

    if (widget.birthdayCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.birthday,
          label: widget.birthdayCount.toString(),
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

    if (widget.serviceCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.church,
          label: widget.serviceCount.toString(),
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

    if (widget.eventCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.event,
          label: widget.eventCount.toString(),
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

    if (widget.announcementCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.announcement,
          label: widget.announcementCount.toString(),
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
            style: BaseTypography.labelMedium.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
