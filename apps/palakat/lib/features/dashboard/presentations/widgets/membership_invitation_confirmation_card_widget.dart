import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/repositories.dart';
import 'package:palakat_shared/services.dart';

class MembershipInvitationConfirmationCardWidget
    extends ConsumerStatefulWidget {
  const MembershipInvitationConfirmationCardWidget({
    super.key,
    required this.invitation,
    required this.onResolved,
  });

  final MembershipInvitation invitation;
  final VoidCallback onResolved;

  @override
  ConsumerState<MembershipInvitationConfirmationCardWidget> createState() =>
      _MembershipInvitationConfirmationCardWidgetState();
}

class _MembershipInvitationConfirmationCardWidgetState
    extends ConsumerState<MembershipInvitationConfirmationCardWidget> {
  bool _loading = false;

  void _showSnack(String msg) {
    if (msg.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _approve() async {
    final id = widget.invitation.id;
    if (id == null) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(membershipRepositoryProvider);
      final res = await repo.membershipInvitationRespond(
        id: id,
        action: 'APPROVE',
      );

      final respond = res.when(
        onSuccess: (d) => d,
        onFailure: (f) {
          _showSnack(f.message);
        },
      );

      if (respond == null) return;

      final membership = respond.membership;
      if (membership?.id != null) {
        final storage = ref.read(localStorageServiceProvider);
        await storage.saveMembership(membership!);

        final currentAuth = storage.currentAuth;
        if (currentAuth != null) {
          final updatedAccount = currentAuth.account.copyWith(
            membership: membership,
          );
          final updatedAuth = currentAuth.copyWith(account: updatedAccount);
          await storage.saveAuth(updatedAuth);
        }
      }

      widget.onResolved();
      _showSnack('Invitation approved');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    final id = widget.invitation.id;
    if (id == null) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(membershipRepositoryProvider);
      final res = await repo.membershipInvitationRespond(
        id: id,
        action: 'REJECT',
      );

      final ok = res.when<bool>(
        onSuccess: (_) => true,
        onFailure: (f) {
          _showSnack(f.message);
        },
      );

      if (ok != true) return;

      widget.onResolved();
      _showSnack('Invitation rejected');

      if (mounted) {
        context.goNamed(AppRoute.membership);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final inv = widget.invitation;

    final inviterName = inv.inviter?.name ?? l10n.lbl_na;
    final churchName = inv.church?.name ?? l10n.lbl_na;
    final columnName = inv.column?.name ?? l10n.lbl_na;

    final subtitle = '$churchName • $columnName';

    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BaseColor.yellow[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: BaseSize.w32,
                height: BaseSize.w32,
                decoration: BoxDecoration(
                  color: BaseColor.yellow[100],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  AppIcons.schedule,
                  size: BaseSize.w16,
                  color: BaseColor.yellow[800],
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membership invitation',
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BaseColor.black,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      'From $inviterName',
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.neutral[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h4,
                    Text(
                      subtitle,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.neutral[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Gap.w8,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w8,
                  vertical: BaseSize.h4,
                ),
                decoration: BoxDecoration(
                  color: BaseColor.yellow[100],
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Text(
                  l10n.status_pending,
                  style: BaseTypography.labelSmall.copyWith(
                    color: BaseColor.yellow[800],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Gap.h12,
          Row(
            children: [
              Expanded(
                child: Text(
                  inv.baptize ? l10n.lbl_baptized : l10n.membership_notBaptized,
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.neutral[700],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  inv.sidi ? l10n.lbl_sidi : l10n.membership_notSidi,
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.neutral[700],
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          Gap.h12,
          Row(
            children: [
              Expanded(
                child: ButtonWidget.outlined(
                  text: l10n.btn_reject,
                  isEnabled: !_loading,
                  onTap: _loading ? null : _reject,
                ),
              ),
              Gap.w12,
              Expanded(
                child: ButtonWidget.primary(
                  text: l10n.btn_approve,
                  isEnabled: !_loading,
                  isLoading: _loading,
                  onTap: _loading ? null : _approve,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
