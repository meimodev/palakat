import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/themes/size_constant.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/approval/presentations/approval_controller.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_card_widget.dart';

class ApprovalScreen extends ConsumerWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(approvalControllerProvider);

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(title: "Approvals"),
          Gap.h16,
          // Render activities (migrated from approvals)
          ...state.approvals.map((approval) {
            final title = approval.title;

            return Padding(
              padding: EdgeInsets.only(bottom: BaseSize.h12),
              child: ApprovalCardWidget(
                approval: approval,
                currentMembershipId: state.membership?.id,
                onTap: () {
                  context.pushNamed(
                    AppRoute.approvalDetail,
                    extra: RouteParam(
                      params: {
                        'activityId': approval.id,
                        'currentMembershipId': state.membership?.id,
                      },
                    ),
                  );
                },
                onApprove: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Approved: $title')),
                  );
                },
                onReject: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rejected: $title')),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

