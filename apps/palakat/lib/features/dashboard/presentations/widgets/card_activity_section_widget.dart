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
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: today ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Gap.w8,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: AppColors.onSecondaryContainer.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
              ),
              child: Text(
                totalCount.toString(),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: AppColors.onSecondaryContainer,
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
            color: AppColors.surfaceContainerLow,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: AppColors.neutral, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      border: Border.all(
                        color: AppColors.surfaceContainerLowest,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: SanctuaryDepth.ambient(
                        opacity: 0.02,
                        blur: 12,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: FaIcon(
                      AppIcons.eventBusy,
                      size: 24.0,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  Gap.h12,
                  Text(
                    context.l10n.noData_activities,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.onSurface,
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
                  color: AppColors.surfaceContainerLowest,
                  elevation: 1,
                  shadowColor: AppColors.onSurface,
                  surfaceTintColor: AppColors.warning,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: onPressedBirthday == null
                        ? null
                        : () => onPressedBirthday!(birthday),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: AppColors.warning.shade100,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: AppColors.warning.shade200,
                              ),
                              boxShadow: SanctuaryDepth.ambient(
                                opacity: 0.02,
                                blur: 8,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              AppIcons.birthday,
                              size: 16.0,
                              color: AppColors.warning.shade700,
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
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                ),
                                Gap.h6,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.shade100,
                                    borderRadius: BorderRadius.circular(4.0),
                                    border: Border.all(
                                      color: AppColors.warning.shade200,
                                      width: 1,
                                    ),
                                    boxShadow: SanctuaryDepth.ambient(
                                      opacity: 0.02,
                                      blur: 6,
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n.tbl_birth,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: AppColors.warning.shade700,
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
                            size: 18.0,
                            color: AppColors.onSurfaceVariant,
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
