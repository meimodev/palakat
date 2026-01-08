import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

import 'birthdays_widget.dart';

class CardActivitySectionWidget extends StatelessWidget {
  const CardActivitySectionWidget({
    super.key,
    required this.title,
    required this.activities,
    this.birthdays = const <BirthdayItem>[],
    this.today = false,
    required this.onPressedCard,
    this.onPressedBirthday,
  });

  final String title;
  final List<Activity> activities;
  final List<BirthdayItem> birthdays;
  final bool today;
  final void Function(Activity activityOverview) onPressedCard;
  final void Function(BirthdayItem birthday)? onPressedBirthday;

  @override
  Widget build(BuildContext context) {
    final totalCount = activities.length + birthdays.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header with badge
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: BaseTypography.titleMedium.copyWith(
                  fontWeight: today ? FontWeight.bold : FontWeight.w600,
                  color: BaseColor.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Gap.w8,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w10,
                vertical: BaseSize.h4,
              ),
              decoration: BoxDecoration(
                color: today ? BaseColor.teal[100] : BaseColor.teal[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: today ? BaseColor.teal[300]! : BaseColor.teal[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                totalCount.toString(),
                style: BaseTypography.labelMedium.copyWith(
                  color: BaseColor.teal[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Gap.h12,
        // List of activities
        if (totalCount == 0)
          Container(
            padding: EdgeInsets.all(BaseSize.w16),
            decoration: BoxDecoration(
              color: BaseColor.cardBackground1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BaseColor.neutral20, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  AppIcons.eventBusy,
                  size: BaseSize.w24,
                  color: BaseColor.secondaryText,
                ),
                Gap.h8,
                Text(
                  context.l10n.noData_activities,
                  textAlign: TextAlign.center,
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.secondaryText,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: totalCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => Gap.h8,
            itemBuilder: (_, index) {
              if (index < birthdays.length) {
                final birthday = birthdays[index];
                final name =
                    birthday.membership.account?.name ??
                    context.l10n.lbl_unknown;

                return Material(
                  color: BaseColor.cardBackground1,
                  elevation: 1,
                  shadowColor: Colors.black.withValues(alpha: 0.05),
                  surfaceTintColor: BaseColor.yellow[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: onPressedBirthday == null
                        ? null
                        : () => onPressedBirthday!(birthday),
                    child: Padding(
                      padding: EdgeInsets.all(BaseSize.w12),
                      child: Row(
                        children: [
                          Container(
                            width: BaseSize.w32,
                            height: BaseSize.w32,
                            decoration: BoxDecoration(
                              color: BaseColor.yellow[100],
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              AppIcons.birthday,
                              size: BaseSize.w16,
                              color: BaseColor.yellow[700],
                            ),
                          ),
                          Gap.w12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: BaseTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: BaseColor.black,
                                  ),
                                ),
                                Gap.h6,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: BaseSize.w8,
                                    vertical: BaseSize.h4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: BaseColor.yellow[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: BaseColor.yellow[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n.tbl_birth,
                                    style: BaseTypography.labelSmall.copyWith(
                                      color: BaseColor.yellow[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap.w8,
                          Icon(
                            Icons.chevron_right,
                            size: BaseSize.w20,
                            color: BaseColor.secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final activity = activities[index - birthdays.length];
              return CardOverviewListItemWidget(
                title: activity.title,
                type: activity.activityType,
                onPressedCard: () => onPressedCard(activity),
              );
            },
          ),
        Gap.h16,
      ],
    );
  }
}
