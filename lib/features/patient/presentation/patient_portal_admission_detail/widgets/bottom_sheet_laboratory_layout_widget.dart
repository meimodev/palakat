import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';

import 'widgets.dart';

class BottomSheetLaboratoryLayoutWidget extends StatelessWidget {
  const BottomSheetLaboratoryLayoutWidget({super.key, required this.list});

  final List<Map<String, dynamic>> list;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const EmptyListLayoutWidget();
    }

    return Padding(
      padding: horizontalPadding,
      child: Column(
        children: [
          for (int i = 0; i < list.length; i++)
            ListItemExpandableCardWidget(
              title: list[i]["title"],
              contents: list[i]["contents"],
            ),
        ],
      ),
    );
  }
}
