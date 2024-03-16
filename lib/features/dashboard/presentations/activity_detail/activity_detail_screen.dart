import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        children: [
          ScreenTitleWidget.primary(
            title: "Activity This Week",
            leadIcon: Assets.icons.line.chevronLeft,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h24,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            child: Column(
              children: [
                Text("Activity Detail $id"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
