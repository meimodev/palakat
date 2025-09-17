import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/utils/extensions/date_time_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

class ViewAllScreen extends ConsumerWidget {
  const ViewAllScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = ref.read(viewAllControllerProvider.notifier);
    final state = ref.watch(viewAllControllerProvider);

    return ScaffoldWidget(
      child: Column(
        children: [
          ScreenTitleWidget.primary(
            title: "Activity This Week",
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h24,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            child: Column(
              children: [
                ...DateTime.now().generateThisWeekDates.map(
                      (date) => Column(
                        children: [
                          CardActivitySectionWidget(
                            title: date.EEEEddMMM,
                            today: date.isSameDay(DateTime.now()),
                            activities: state.activities
                                .where((activity) =>
                                    activity.activityDate.isSameDay(date))
                                .toList(),
                            onPressedCard: (Activity activity) {
                              context.pushNamed(
                                AppRoute.activityDetail,
                                extra: RouteParam(
                                  params: {
                                    RouteParamKey.activity: activity.toJson(),
                                  },
                                ),
                              );
                            },
                          ),
                          Gap.h24,
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
