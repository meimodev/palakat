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
                  fontWeight: today ? FontWeight.w700 : FontWeight.w600,
                  color: BaseColor.textPrimary,
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
                borderRadius: BorderRadius.circular(BaseSize.radiusMd),
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
          Material(
            color: BaseColor.surfaceMedium,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BaseSize.radiusLg),
              side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: BaseSize.w56,
                    height: BaseSize.w56,
                    decoration: BoxDecoration(
                      color: BaseColor.primary[50],
                      borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                    ),
                    alignment: Alignment.center,
                    child: FaIcon(
                      AppIcons.eventBusy,
                      size: BaseSize.w24,
                      color: BaseColor.primary,
                    ),
                  ),
                  Gap.h12,
                  Text(
                    context.l10n.noData_activities,
                    textAlign: TextAlign.center,
                    style: BaseTypography.titleMedium.copyWith(
                      color: BaseColor.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
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
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
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
                            width: BaseSize.w36,
                            height: BaseSize.w36,
                            decoration: BoxDecoration(
                              color: BaseColor.yellow[100],
                              borderRadius: BorderRadius.circular(
                                BaseSize.radiusMd,
                              ),
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
                                    fontWeight: FontWeight.w700,
                                    color: BaseColor.textPrimary,
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
                                    borderRadius: BorderRadius.circular(
                                      BaseSize.radiusSm,
                                    ),
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
                            size: BaseSize.w18,
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
