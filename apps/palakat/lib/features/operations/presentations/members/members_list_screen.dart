import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/members/members_list_controller.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat_shared/core/models/models.dart' as shared;
import 'package:palakat_shared/core/extension/extension.dart';

/// Screen for viewing and managing church members.
/// Displays a list of current members with search and filter capabilities.
class MembersListScreen extends ConsumerWidget {
  const MembersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(membersListControllerProvider);
    final controller = ref.read(membersListControllerProvider.notifier);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationsReveal(
            child: ScreenTitleWidget.titleSecondary(
              title: l10n.operationsItem_view_members_title,
              subTitle: state.scopeLabel,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          Gap.h16,
          OperationsReveal(
            delay: const Duration(milliseconds: 40),
            child: InputSearchWidget(
              hint: l10n.lbl_search,
              autoClearButton: true,
              debounceMilliseconds: 200,
              onChanged: controller.setSearchQuery,
            ),
          ),
          Gap.h16,
          Expanded(
            child: LoadingWrapper(
              loading: state.isLoading,
              hasError: state.errorMessage != null && !state.isLoading,
              errorMessage: state.errorMessage,
              onRetry: controller.fetchMembers,
              shimmerPlaceholder: Column(
                children: [
                  PalakatShimmerPlaceholders.listItemCard(),
                  Gap.h8,
                  PalakatShimmerPlaceholders.listItemCard(),
                  Gap.h8,
                  PalakatShimmerPlaceholders.listItemCard(),
                ],
              ),
              child: _MembersContent(
                memberships: state.filteredMemberships,
                onMemberTap: (membership) {
                  final id = membership.id;
                  if (id == null) return;
                  context.pushNamed(
                    AppRoute.memberDetail,
                    pathParameters: {'membershipId': id.toString()},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersContent extends StatelessWidget {
  const _MembersContent({required this.memberships, required this.onMemberTap});

  final List<shared.Membership> memberships;
  final ValueChanged<shared.Membership> onMemberTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (memberships.isEmpty) {
      return OperationsAnimatedPresence(
        visible: true,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: InfoBoxWidget(message: l10n.err_noData),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 16.0),
      itemCount: memberships.length,
      separatorBuilder: (context, index) => Gap.h12,
      itemBuilder: (context, index) {
        final theme = Theme.of(context);
        final membership = memberships[index];
        final account = membership.account;
        final name = account?.name ?? l10n.lbl_unknown;
        final phone = account?.phone;

        return OperationsReveal(
          delay: Duration(milliseconds: 40 + (index * 30)),
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
              side: BorderSide(color: AppColors.ghostBorder(0.08)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
              ),
              child: InkWell(
                onTap: membership.id == null
                    ? null
                    : () => onMemberTap(membership),
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          border: Border.all(
                            color: AppColors.ghostBorder(0.06),
                          ),
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radius,
                          ),
                          boxShadow: SanctuaryDepth.ambient(
                            opacity: 0.02,
                            blur: 10,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          AppIcons.person,
                          size: 18.0,
                          color: AppColors.primary,
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                  ),
                                ),
                                if (account?.claimed == true) ...[
                                  Gap.w8,
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 6.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(
                                        alpha: 0.12,
                                      ),
                                      border: Border.all(
                                        color: AppColors.success.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        SanctuaryLayout.radius,
                                      ),
                                      boxShadow: SanctuaryDepth.ambient(
                                        opacity: 0.02,
                                        blur: 8,
                                      ),
                                    ),
                                    child: Icon(
                                      AppIcons.verified,
                                      size: 14.0,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Gap.h4,
                            Text(
                              phone != null && phone.trim().isNotEmpty
                                  ? phone
                                  : l10n.lbl_na,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap.h12,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _MemberStatusChip(
                                  title: membership.baptize
                                      ? l10n.lbl_baptized
                                      : l10n.membership_notBaptized,
                                  isActive: membership.baptize,
                                ),
                                _MemberStatusChip(
                                  title: membership.sidi
                                      ? l10n.lbl_sidi
                                      : l10n.membership_notSidi,
                                  isActive: membership.sidi,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MemberStatusChip extends StatelessWidget {
  const _MemberStatusChip({required this.title, required this.isActive});

  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.18)
              : AppColors.ghostBorder(0.08),
        ),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
      ),
      child: Text(
        title,
        style: theme.textTheme.labelMedium!.copyWith(
          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
