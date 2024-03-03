import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets.dart';

class ActivityWidget extends StatelessWidget {
  const ActivityWidget({
    super.key,
    required this.onPressedViewAll,
    required this.height,
    required this.activities,
  });

  final void Function() onPressedViewAll;
  final List<String> activities;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: onPressedViewAll,
          count: activities.length,
          title: 'Activity',
        ),
        Gap.h6,
        SizedBox(
          height: height,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            separatorBuilder: (context, index) => Gap.w12,
            itemBuilder: (context, index) => CardDatePreviewWidget(
              width: 80,
              date: index + 1,
              selected: index == 1,
              onPressedCardDatePreview: () {
                print("date preview $index");
              },
            ),
          ),
        ),
      ],
    );
  }
}
