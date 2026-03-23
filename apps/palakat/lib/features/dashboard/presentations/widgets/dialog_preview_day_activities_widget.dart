import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

import 'birthdays_widget.dart';

Future<void> showDialogPreviewDayActivitiesWidget({
  required BuildContext context,
  required void Function(Activity activity) onPressedCardActivity,
  required List<Activity> activities,
  List<BirthdayItem> birthdays = const <BirthdayItem>[],
  void Function(BirthdayItem birthday)? onPressedCardBirthday,
  required String title,
}) async {
  await showDialogCustomWidget(
    context: context,
    title: title,
    scrollControlled: true,
    content: _DialogPreviewDayActivitiesWidget(
      activities: activities,
      birthdays: birthdays,
      onPressedCard: onPressedCardActivity,
      onPressedCardBirthday: onPressedCardBirthday,
    ),
  );
}

class _DialogPreviewDayActivitiesWidget extends StatelessWidget {
  const _DialogPreviewDayActivitiesWidget({
    required this.activities,
    required this.birthdays,
    required this.onPressedCard,
    required this.onPressedCardBirthday,
  });

  final List<Activity> activities;
  final List<BirthdayItem> birthdays;
  final void Function(Activity activityOverview) onPressedCard;
  final void Function(BirthdayItem birthday)? onPressedCardBirthday;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty && birthdays.isEmpty) {
      return Center(
        child: Material(
          color: AppColors.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: AppColors.neutral, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              context.l10n.noData_activities,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    final itemsCount = birthdays.length + activities.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            separatorBuilder: (_, _) => Gap.h12,
            itemCount: itemsCount,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
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
                    onTap: onPressedCardBirthday == null
                        ? null
                        : () => onPressedCardBirthday!(birthday),
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
        ),
      ],
    );
  }
}
