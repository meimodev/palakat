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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            border: Border.all(color: AppColors.ghostBorder(0.06)),
            borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
          ),
          child: Icon(icon, size: 12.0, color: AppColors.primary),
        ),
        Gap.w8,
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip({required bool isActive, required String text}) {
    final bgColor = isActive
        ? AppColors.primary.withValues(alpha: 0.12)
        : AppColors.surfaceContainerHighest;
    final borderColor = isActive
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.ghostBorder(0.08);
    final fgColor = isActive ? AppColors.primary : AppColors.onSurfaceVariant;
    final icon = isActive ? AppIcons.checkCircle : AppIcons.cancel;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.0, color: fgColor),
          Gap.w8,
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
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
    final theme = Theme.of(context);

    final inviterName = inv.inviter?.name ?? l10n.lbl_na;
    final churchName = inv.church?.name ?? l10n.lbl_na;
    final columnName = inv.column?.name ?? l10n.lbl_na;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        side: BorderSide(color: AppColors.ghostBorder(0.08), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 20),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
                      AppIcons.handshake,
                      size: 18.0,
                      color: AppColors.primary,
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dashboard_membershipInvitation_title,
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.h4,
                        Text(
                          inviterName,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap.h12,
              Container(
                padding: EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  border: Border.all(color: AppColors.ghostBorder(0.06)),
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(icon: AppIcons.church, text: churchName),
                    Gap.h8,
                    _buildInfoRow(icon: AppIcons.group, text: columnName),
                  ],
                ),
              ),
              Gap.h12,
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
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
              Gap.h16,
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
        ),
      ),
    );
  }
}
