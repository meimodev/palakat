import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/approval/presentations/approval_controller.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_card_widget.dart';
import 'package:palakat/core/constants/constants.dart';

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
          // Date range filter
          DateRangePresetInput(
            label: 'Filter by date',
            start: state.filterStartDate,
            end: state.filterEndDate,
            onChanged: (s, e) {
              final notifier = ref.read(approvalControllerProvider.notifier);
              if (s == null && e == null) {
                notifier.clearDateFilter();
              } else {
                notifier.setDateRange(start: s, end: e);
              }
            },
          ),
          Gap.h16,
          // Approvals list
          if (state.filteredApprovals.isEmpty)
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
                    Icons.approval_outlined,
                    size: BaseSize.w48,
                    color: BaseColor.secondaryText,
                  ),
                  Gap.h12,
                  Text(
                    "No approvals found",
                    textAlign: TextAlign.center,
                    style: BaseTypography.titleMedium.copyWith(
                      color: BaseColor.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    "Try adjusting your filters",
                    textAlign: TextAlign.center,
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.secondaryText,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.filteredApprovals.length,
              separatorBuilder: (_, _) => Gap.h12,
              itemBuilder: (context, index) {
                final approval = state.filteredApprovals[index];
                final title = approval.title;

                return ApprovalCardWidget(
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
                );
              },
            ),
        ],
      ),
    );
  }
}

// (Date range preset helpers moved into DateRangePresetInput)
