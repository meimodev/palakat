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
        shadowColor: AppColors.onSurface,
        surfaceTintColor: today ? AppColors.primary : AppColors.primary,
        color: today ? Colors.transparent : AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          decoration: today
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
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
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day name
                  Text(
                    date.toStringFormatted("E"),
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: today
                          ? AppColors.surfaceContainerLowest
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  // Day number
                  Text(
                    date.day.toString(),
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: today
                          ? AppColors.surfaceContainerLowest
                          : AppColors.onSurface,
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
          bg: isToday ? AppColors.surfaceContainerLowest : AppColors.warning,
          fg: isToday ? AppColors.warning : AppColors.surfaceContainerLowest,
          border: isToday
              ? AppColors.surfaceContainerLowest
              : AppColors.warning,
        ),
      );
    }

    if (widget.serviceCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.church,
          label: widget.serviceCount.toString(),
          bg: isToday ? AppColors.surfaceContainerLowest : AppColors.success,
          fg: isToday ? AppColors.success : AppColors.surfaceContainerLowest,
          border: isToday
              ? AppColors.surfaceContainerLowest
              : AppColors.success,
        ),
      );
    }

    if (widget.eventCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.event,
          label: widget.eventCount.toString(),
          bg: isToday ? AppColors.surfaceContainerLowest : AppColors.primary,
          fg: isToday ? AppColors.primary : AppColors.surfaceContainerLowest,
          border: isToday
              ? AppColors.surfaceContainerLowest
              : AppColors.primary,
        ),
      );
    }

    if (widget.announcementCount != 0) {
      items.add(
        _pillChip(
          icon: AppIcons.announcement,
          label: widget.announcementCount.toString(),
          bg: isToday ? AppColors.surfaceContainerLowest : AppColors.secondary,
          fg: isToday ? AppColors.secondary : AppColors.surfaceContainerLowest,
          border: isToday
              ? AppColors.surfaceContainerLowest
              : AppColors.secondary,
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
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: border, width: 1),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          Gap.w4,
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
