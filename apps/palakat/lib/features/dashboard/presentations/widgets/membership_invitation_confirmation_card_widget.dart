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

    final approvedSnack =
        context.l10n.dashboard_membershipInvitation_snackbarApproved;

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
      _showSnack(approvedSnack);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    final id = widget.invitation.id;
    if (id == null) return;

    final rejectedSnack =
        context.l10n.dashboard_membershipInvitation_snackbarRejected;

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
      _showSnack(rejectedSnack);

      if (mounted) {
        context.goNamed(AppRoute.membership);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: BaseSize.w12, color: BaseColor.neutral[700]),
        Gap.w8,
        Expanded(
          child: Text(
            text,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.neutral[800],
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip({required bool isActive, required String text}) {
    final bgColor = isActive
        ? BaseColor.primary[100]!
        : BaseColor.neutral[200]!;
    final borderColor = isActive
        ? BaseColor.primary[400]!
        : BaseColor.neutral[300]!;
    final fgColor = isActive
        ? BaseColor.primary[800]!
        : BaseColor.neutral[800]!;
    final icon = isActive ? AppIcons.checkCircle : AppIcons.cancel;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w10,
        vertical: BaseSize.h6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: BaseSize.w12, color: fgColor),
          Gap.w8,
          Text(
            text,
            style: BaseTypography.bodySmall.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final inv = widget.invitation;

    final inviterName = inv.inviter?.name ?? l10n.lbl_na;
    final churchName = inv.church?.name ?? l10n.lbl_na;
    final columnName = inv.column?.name ?? l10n.lbl_na;

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
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.primary[100],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  AppIcons.handshake,
                  size: BaseSize.w18,
                  color: BaseColor.primary[700],
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboard_membershipInvitation_title,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.neutral[700],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      inviterName,
                      style: BaseTypography.labelLarge.copyWith(
                        color: BaseColor.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h8,
                    _buildInfoRow(icon: AppIcons.church, text: churchName),
                    Gap.h4,
                    _buildInfoRow(icon: AppIcons.group, text: columnName),
                  ],
                ),
              ),
            ],
          ),
          Gap.h12,
          Wrap(
            spacing: BaseSize.w8,
            runSpacing: BaseSize.h8,
            children: [
              _buildStatusChip(
                isActive: inv.baptize,
                text: inv.baptize
                    ? l10n.lbl_baptized
                    : l10n.membership_notBaptized,
              ),
              _buildStatusChip(
                isActive: inv.sidi,
                text: inv.sidi ? l10n.lbl_sidi : l10n.membership_notSidi,
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
