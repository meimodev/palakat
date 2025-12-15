import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
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
                AppIcons.work,
                size: BaseSize.w16,
                color: BaseColor.blue[700],
              ),
            ),
            Gap.w12,
            Expanded(
              child: Text(
                context.l10n.operations_title,
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
          title: context.l10n.operationsItem_add_income_title,
          description: context.l10n.operationsItem_add_income_desc,
          icon: AppIcons.revenue,
          type: ReportButtonType.primary, // Teal for income
          isLoading: false,
          onPressed: () {},
        ),
        Gap.h12,
        ReportButtonWidget(
          title: context.l10n.operationsItem_add_expense_title,
          description: context.l10n.operationsItem_add_expense_desc,
          icon: AppIcons.expense,
          type: ReportButtonType.error, // Red for expense
          isLoading: false,
          onPressed: () {},
        ),
        Gap.h12,
        ReportButtonWidget(
          title: context.l10n.operationsItem_generate_report_title,
          description: context.l10n.operationsItem_generate_report_desc,
          icon: AppIcons.inventory,
          type: ReportButtonType.info, // Info teal for reports
          isLoading: false,
          onPressed: () {},
        ),
      ],
    );
  }
}
