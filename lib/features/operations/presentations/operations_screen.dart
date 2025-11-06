import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
import 'package:palakat/features/operations/presentations/widgets/widgets.dart';

class OperationsScreen extends ConsumerWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(operationsControllerProvider);

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(title: "Operations"),
          Gap.h16,
          if (state.membership == null || state.membership!.membershipPositions.isEmpty)
            Container(
              padding: EdgeInsets.all(BaseSize.w24),
              decoration: BoxDecoration(
                color: BaseColor.cardBackground1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: BaseColor.neutral20,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.work_off_outlined,
                    size: BaseSize.w48,
                    color: BaseColor.secondaryText,
                  ),
                  Gap.h12,
                  Text(
                    "No positions available",
                    textAlign: TextAlign.center,
                    style: BaseTypography.titleMedium.copyWith(
                      color: BaseColor.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    "You don't have any operational positions yet",
                    textAlign: TextAlign.center,
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.secondaryText,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            MembershipPositionsCardWidget(membership: state.membership!),
            Gap.h16,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.membership!.membershipPositions.length,
              separatorBuilder: (_, _) => Gap.h16,
              itemBuilder: (context, index) {
                return OperationSegmentCardWidget(
                  position: state.membership!.membershipPositions[index],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
