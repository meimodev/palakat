import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/widgets/widgets.dart';

class OperationSegmentCardWidget extends StatelessWidget {
  const OperationSegmentCardWidget({super.key, required this.position});

  final MemberPosition position;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      shape: ContinuousRectangleBorder(),
      initiallyExpanded: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "5 Operation for ",
            style: BaseTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          ChipsWidget(title: position.name),
        ],
      ),
      children: [
        ReportButtonWidget(
          title: "Add Income",
          description: "Generate detailed income and donation reports",
          icon: Icons.trending_up,
          color: const Color(0xFF10B981),
          isLoading: false,
          onPressed: () {},
        ),
        ReportButtonWidget(
          title: "Add Expense",
          description: "Generate expense and spending reports",
          icon: Icons.trending_down,
          color: const Color(0xFFEF4444),
          isLoading: false,
          onPressed: () {},
        ),
        ReportButtonWidget(
          title: "Add Report",
          description: "Generate inventory and asset reports",
          icon: Icons.inventory_2,
          color: const Color(0xFF3B82F6),
          isLoading: false,
          onPressed: () {},
        ),
      ],
    );
  }
}
