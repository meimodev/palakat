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
          if (state.membership != null &&
              state.membership!.membershipPositions.isNotEmpty) ...[
            MembershipPositionsCardWidget(membership: state.membership!),
            ...state.membership!.membershipPositions.map(
              (e) => Column(children: [Gap.h16, OperationSegmentCardWidget(position: e)]),
            ),
          ],
        ],
      ),
    );
  }
}
