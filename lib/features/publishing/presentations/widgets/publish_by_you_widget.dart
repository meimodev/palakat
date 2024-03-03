import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets.dart';

class PublishByYouWidget extends StatelessWidget {
  const PublishByYouWidget({
    super.key,
    required this.onPressedViewAll,
    required this.data,
  });

  final VoidCallback onPressedViewAll;
  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: onPressedViewAll,
          count: data.length,
          title: 'Publish By You',
        ),
        Gap.h12,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => Gap.h6,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final d = data[index];
            return CardOverviewPublishingListItemWidget(
              title: d["title"],
              type: d["type"],
              onPressedCard: d["onPressed"],
            );
          },
        ),
        Gap.h6,
      ],
    );
  }
}

