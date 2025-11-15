import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/widgets/widgets.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

class OperationSegmentCardWidget extends StatelessWidget {
  const OperationSegmentCardWidget({super.key, required this.position});

  final MemberPosition position;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: BaseSize.w32,
              height: BaseSize.w32,
              decoration: BoxDecoration(
                color: BaseColor.blue[100],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.work_outline,
                size: BaseSize.w16,
                color: BaseColor.blue[700],
              ),
            ),
            Gap.w12,
            Expanded(
              child: Text(
                "Operations",
                style: BaseTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.black,
                ),
              ),
            ),
            ChipsWidget(title: position.name),
          ],
        ),
        Gap.h12,
        // Operation buttons
        ReportButtonWidget(
          title: "Add Income",
          description: "Generate detailed income and donation reports",
          icon: Icons.trending_up,
          color: const Color(0xFF10B981),
          isLoading: false,
          onPressed: () {},
        ),
        Gap.h12,
        ReportButtonWidget(
          title: "Add Expense",
          description: "Generate expense and spending reports",
          icon: Icons.trending_down,
          color: const Color(0xFFEF4444),
          isLoading: false,
          onPressed: () {},
        ),
        Gap.h12,
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
