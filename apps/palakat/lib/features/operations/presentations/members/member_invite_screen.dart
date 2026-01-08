import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/authentication/presentations/widgets/phone_input_formatter.dart';
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
          ScreenTitleWidget.titleSecondary(
            title: l10n.operationsItem_invite_member_title,
            subTitle: state.scopeLabel,
            onBack: () => Navigator.of(context).pop(),
          ),
          Gap.h16,
          if (state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: BaseSize.h12),
              child: ErrorDisplayWidget(message: state.errorMessage!),
            ),
          InfoBoxWidget(message: l10n.operationsItem_invite_member_desc),
          Gap.h16,
          InputWidget.text(
            label: l10n.lbl_phone,
            hint: l10n.auth_phoneHint,
            textInputType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              PhoneInputFormatter(),
            ],
            onChanged: controller.setPhone,
            endIcon: Icon(AppIcons.search, size: BaseSize.w16),
          ),
          Gap.h12,
          ButtonWidget.primary(
            text: l10n.btn_submit,
            isLoading: state.isSearching,
            onTap: state.isSearching || state.isSubmitting
                ? null
                : () async {
                    await controller.lookupByPhone();
                  },
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

    if (isSearching) {
      return Column(
        children: [
          PalakatShimmerPlaceholders.listItemCard(),
          Gap.h12,
          PalakatShimmerPlaceholders.listItemCard(),
        ],
      );
    }

    if (accountName == null) {
      if (!hasSearched) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: BaseSize.h12),
            child: InfoBoxWidget(message: l10n.auth_enterPhoneNumber),
          ),
        );
      }
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: BaseSize.h12),
          child: InfoBoxWidget(message: l10n.msg_notFound),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: BaseColor.cardBackground1,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          surfaceTintColor: BaseColor.blue[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w12),
            child: Row(
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
                              accountName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: BaseTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: BaseColor.black,
                              ),
                            ),
                          ),
                          if (bipraLabel != null &&
                              bipraLabel!.trim().isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(left: BaseSize.w8),
                              padding: EdgeInsets.symmetric(
                                horizontal: BaseSize.w8,
                                vertical: BaseSize.h4,
                              ),
                              decoration: BoxDecoration(
                                color: BaseColor.teal[50],
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color:
                                      BaseColor.teal[200] ??
                                      BaseColor.neutral40,
                                ),
                              ),
                              child: Text(
                                bipraLabel!,
                                style: BaseTypography.labelSmall.copyWith(
                                  color: BaseColor.teal[700],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          if (claimed) ...[
                            Gap.w8,
                            Icon(
                              AppIcons.verified,
                              size: BaseSize.w16,
                              color: BaseColor.green[700],
                            ),
                          ],
                        ],
                      ),
                      if (phone != null && phone!.trim().isNotEmpty) ...[
                        Gap.h4,
                        Text(
                          phone!,
                          style: BaseTypography.bodySmall.copyWith(
                            color: BaseColor.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (infoMessage != null && infoMessage!.trim().isNotEmpty) ...[
          Gap.h12,
          InfoBoxWidget(message: infoMessage!),
        ],
        Gap.h16,
        AbsorbPointer(
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
        Gap.h12,
        AbsorbPointer(
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
        Gap.h16,
        ButtonWidget.primary(
          text: inviteLabel,
          isLoading: isSubmitting,
          onTap: isSubmitting ? null : onPressedInvite,
        ),
      ],
    );
  }
}
