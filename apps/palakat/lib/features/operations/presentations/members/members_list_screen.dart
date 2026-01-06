import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/members/members_list_controller.dart';
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
          ScreenTitleWidget.titleSecondary(
            title: l10n.operationsItem_view_members_title,
            subTitle: state.scopeLabel,
            onBack: () => Navigator.of(context).pop(),
          ),
          Gap.h16,
          InputSearchWidget(
            hint: l10n.lbl_search,
            autoClearButton: true,
            debounceMilliseconds: 200,
            onChanged: controller.setSearchQuery,
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
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: BaseSize.h12),
          child: InfoBoxWidget(message: l10n.err_noData),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: BaseSize.h16),
      itemCount: memberships.length,
      separatorBuilder: (context, index) => Gap.h12,
      itemBuilder: (context, index) {
        final membership = memberships[index];
        final account = membership.account;
        final name = account?.name ?? l10n.lbl_unknown;
        final phone = account?.phone;

        return Material(
          color: BaseColor.cardBackground1,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          surfaceTintColor: BaseColor.blue[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: membership.id == null ? null : () => onMemberTap(membership),
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: BaseSize.w36,
                    height: BaseSize.w36,
                    decoration: BoxDecoration(
                      color: BaseColor.blue[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      AppIcons.person,
                      size: BaseSize.w16,
                      color: BaseColor.blue[700],
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: BaseTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: BaseColor.black,
                                ),
                              ),
                            ),
                            if (account?.claimed == true) ...[
                              Gap.w8,
                              Icon(
                                AppIcons.verified,
                                size: BaseSize.w16,
                                color: BaseColor.green[700],
                              ),
                            ],
                          ],
                        ),
                        if (phone != null && phone.trim().isNotEmpty) ...[
                          Gap.h4,
                          Text(
                            phone,
                            style: BaseTypography.bodySmall.copyWith(
                              color: BaseColor.textSecondary,
                            ),
                          ),
                        ],
                        Gap.h12,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChipsWidget(
                              title: membership.baptize
                                  ? l10n.lbl_baptized
                                  : l10n.membership_notBaptized,
                            ),
                            ChipsWidget(
                              title: membership.sidi
                                  ? l10n.lbl_sidi
                                  : l10n.membership_notSidi,
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
        );
      },
    );
  }
}
