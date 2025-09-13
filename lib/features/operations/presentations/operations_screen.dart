import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/operations/domain/entities/report.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
import 'package:palakat/features/operations/presentations/widgets/widgets.dart';

class OperationsScreen extends ConsumerWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(operationsControllerProvider.notifier);
    final state = ref.watch(operationsControllerProvider);

    return ScaffoldWidget(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(
            title: "Operations",
          ),
          Gap.h12,
          state.membership != null
              ? IdentityCardWidget(
                  membership: state.membership!,
                  onTap: () {
                    context.pushNamed(AppRoute.membership);
                  },
                )
              : const SizedBox.shrink(),
          if (state.membership != null && state.membership!.positions.isNotEmpty) ...[
            Gap.h16,
            CardWidget(
              title: 'Positions',
              content: [
                Wrap(
                  spacing: BaseSize.w8,
                  runSpacing: BaseSize.h8,
                  children: state.membership!.positions.map((pos) {
                    final label = pos.name;
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w12,
                        vertical: BaseSize.h8,
                      ),
                      decoration: BoxDecoration(
                        color: BaseColor.primary4.withValues(alpha: 0.08),
                        border: Border.all(
                          color: BaseColor.primary4.withValues(alpha: 0.24),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                      ),
                      child: Text(
                        label,
                        style: BaseTypography.labelMedium.copyWith(
                          color: BaseColor.primary4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
          Gap.h24,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Member Operation",
                style: BaseTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h16,

              // Income Report Button
              ReportButtonWidget(
                title: "Add Income",
                description: "Generate detailed income and donation reports",
                icon: Icons.trending_up,
                color: const Color(0xFF10B981),
                isLoading: false,
                onPressed: () {},
              ),

              Gap.h12,

              // Expense Report Button
              ReportButtonWidget(
                title: "Add Expense",
                description: "Generate expense and spending reports",
                icon: Icons.trending_down,
                color: const Color(0xFFEF4444),
                isLoading: false,
                onPressed: () {},
              ),

              Gap.h12,

              // Inventory Report Button
              ReportButtonWidget(
                title: "Add Report",
                description: "Generate inventory and asset reports",
                icon: Icons.inventory_2,
                color: const Color(0xFF3B82F6),
                isLoading: false,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

}
