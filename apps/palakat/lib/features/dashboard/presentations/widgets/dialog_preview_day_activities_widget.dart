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
        child: Text(
          context.l10n.noData_activities,
          textAlign: TextAlign.center,
        ),
      );
    }

    final itemsCount = birthdays.length + activities.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: BaseSize.customHeight(300)),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
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
                  color: BaseColor.cardBackground1,
                  elevation: 1,
                  shadowColor: Colors.black.withValues(alpha: 0.05),
                  surfaceTintColor: BaseColor.yellow[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: onPressedCardBirthday == null
                        ? null
                        : () => onPressedCardBirthday!(birthday),
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
        ),
      ],
    );
  }
}
