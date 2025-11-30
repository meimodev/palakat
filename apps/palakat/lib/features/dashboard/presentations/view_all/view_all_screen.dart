import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat_shared/core/extension/date_time_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

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
          Gap.h16,
          Column(
            children: [
              ...DateTime.now().generateThisWeekDates.map(
                (date) => Padding(
                  padding: EdgeInsets.only(bottom: BaseSize.h16),
                  child: CardActivitySectionWidget(
                    title: date.EEEEddMMM,
                    today: date.isSameDay(DateTime.now()),
                    activities: state.activities
                        .where((activity) => activity.date.isSameDay(date))
                        .toList(),
                    onPressedCard: (Activity activity) {
                      context.pushNamed(
                        AppRoute.activityDetail,
                        pathParameters: {'activityId': activity.id.toString()},
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
