import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/authentication/presentations/widgets/phone_input_formatter.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat/features/operations/presentations/members/member_invite_controller.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// Screen for inviting new members to the church.
/// Provides a form to send invitations to potential members.
class MemberInviteScreen extends ConsumerWidget {
  const MemberInviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(memberInviteControllerProvider);
    final controller = ref.read(memberInviteControllerProvider.notifier);

    final eligibility = state.invitationEligibility;
    final canInvite =
        eligibility == MembershipInvitationEligibility.canInvite ||
        eligibility == MembershipInvitationEligibility.rejectedPreviously;
    final canEditSacrament = canInvite;
    final inviteLabel =
        eligibility == MembershipInvitationEligibility.rejectedPreviously
        ? 'Re-invite'
        : l10n.operationsItem_invite_member_title;

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationsReveal(
            child: ScreenTitleWidget.titleSecondary(
              title: l10n.operationsItem_invite_member_title,
              subTitle: state.scopeLabel,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          Gap.h16,
          OperationsAnimatedPresence(
            visible:
                state.errorMessage != null &&
                state.errorMessage!.trim().isNotEmpty,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: ErrorDisplayWidget(message: state.errorMessage ?? ''),
            ),
          ),
          OperationsReveal(
            delay: const Duration(milliseconds: 40),
            child: InfoBoxWidget(
              message: l10n.operationsItem_invite_member_desc,
            ),
          ),
          Gap.h16,
          OperationsReveal(
            delay: const Duration(milliseconds: 80),
            child: InputWidget.text(
              label: l10n.lbl_phone,
              hint: l10n.auth_phoneHint,
              textInputType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PhoneInputFormatter(),
              ],
              onChanged: controller.setPhone,
              endIcon: Icon(AppIcons.search, size: 16.0),
            ),
          ),
          Gap.h12,
          OperationsReveal(
            delay: const Duration(milliseconds: 120),
            child: ButtonWidget.primary(
              text: l10n.btn_submit,
              isLoading: state.isSearching,
              onTap: state.isSearching || state.isSubmitting
                  ? null
                  : () async {
                      await controller.lookupByPhone();
                    },
            ),
          ),
          Gap.h16,
          Expanded(
            child: _InviteResultSection(
              isSearching: state.isSearching,
              hasSearched: state.hasSearched,
              accountName: state.foundAccount?.name,
              phone: state.foundAccount?.phone,
              claimed: state.foundAccount?.claimed ?? false,
              bipraLabel: state.foundAccount?.calculateBipra.abv,
              infoMessage: state.infoMessage,
              baptize: state.baptize,
              sidi: state.sidi,
              canEditSacrament: canEditSacrament,
              onChangedBaptize: controller.setBaptize,
              onChangedSidi: controller.setSidi,
              inviteLabel: inviteLabel,
              onPressedInvite: state.foundAccount == null || !canInvite
                  ? null
                  : () async {
                      final ok = await controller.inviteToMyColumn();
                      if (ok && context.mounted) {
                        context.pop(true);
                      }
                    },
              isSubmitting: state.isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteResultSection extends StatelessWidget {
  const _InviteResultSection({
    required this.isSearching,
    required this.hasSearched,
    required this.accountName,
    required this.phone,
    required this.claimed,
    required this.bipraLabel,
    required this.infoMessage,
    required this.baptize,
    required this.sidi,
    required this.canEditSacrament,
    required this.onChangedBaptize,
    required this.onChangedSidi,
    required this.inviteLabel,
    required this.onPressedInvite,
    required this.isSubmitting,
  });

  final bool isSearching;
  final bool hasSearched;
  final String? accountName;
  final String? phone;
  final bool claimed;
  final String? bipraLabel;
  final String? infoMessage;
  final bool baptize;
  final bool sidi;
  final bool canEditSacrament;
  final ValueChanged<bool> onChangedBaptize;
  final ValueChanged<bool> onChangedSidi;
  final String inviteLabel;
  final VoidCallback? onPressedInvite;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (isSearching) {
      return OperationsAnimatedPresence(
        visible: true,
        child: ShimmerPlaceholders.listSection(count: 2, gap: 12),
      );
    }

    if (accountName == null) {
      if (!hasSearched) {
        return OperationsAnimatedPresence(
          visible: true,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: InfoBoxWidget(message: l10n.auth_enterPhoneNumber),
            ),
          ),
        );
      }
      return OperationsAnimatedPresence(
        visible: true,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: InfoBoxWidget(message: l10n.msg_notFound),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OperationsReveal(
          delay: const Duration(milliseconds: 40),
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
              side: BorderSide(color: AppColors.ghostBorder(0.08)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
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
                        border: Border.all(color: AppColors.ghostBorder(0.06)),
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
                                  accountName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              if (bipraLabel != null &&
                                  bipraLabel!.trim().isNotEmpty) ...[
                                Gap.w8,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 6.0,
                                  ),
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
                                      blur: 8,
                                    ),
                                  ),
                                  child: Text(
                                    bipraLabel!,
                                    style: theme.textTheme.labelMedium!
                                        .copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                              if (claimed) ...[
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
                                    borderRadius: BorderRadius.circular(
                                      SanctuaryLayout.radius,
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
                            phone != null && phone!.trim().isNotEmpty
                                ? phone!
                                : l10n.lbl_na,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
        if (infoMessage != null && infoMessage!.trim().isNotEmpty) ...[
          Gap.h12,
          OperationsReveal(
            delay: const Duration(milliseconds: 80),
            child: InfoBoxWidget(message: infoMessage!),
          ),
        ],
        Gap.h16,
        OperationsReveal(
          delay: const Duration(milliseconds: 120),
          child: AbsorbPointer(
            absorbing: !canEditSacrament,
            child: Opacity(
              opacity: canEditSacrament ? 1 : 0.6,
              child: InputWidget<bool>.binaryOption(
                currentInputValue: baptize,
                options: const [true, false],
                label: l10n.lbl_baptized,
                onChanged: onChangedBaptize,
                optionLabel: (option) =>
                    option ? l10n.lbl_baptized : l10n.membership_notBaptized,
              ),
            ),
          ),
        ),
        Gap.h12,
        OperationsReveal(
          delay: const Duration(milliseconds: 160),
          child: AbsorbPointer(
            absorbing: !canEditSacrament,
            child: Opacity(
              opacity: canEditSacrament ? 1 : 0.6,
              child: InputWidget<bool>.binaryOption(
                currentInputValue: sidi,
                options: const [true, false],
                label: l10n.lbl_sidi,
                onChanged: onChangedSidi,
                optionLabel: (option) =>
                    option ? l10n.lbl_sidi : l10n.membership_notSidi,
              ),
            ),
          ),
        ),
        Gap.h16,
        OperationsReveal(
          delay: const Duration(milliseconds: 200),
          child: ButtonWidget.primary(
            text: inviteLabel,
            isLoading: isSubmitting,
            onTap: isSubmitting ? null : onPressedInvite,
          ),
        ),
      ],
    );
  }
}
