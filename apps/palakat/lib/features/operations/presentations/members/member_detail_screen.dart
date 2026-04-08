import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat/features/operations/presentations/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/repositories/repositories.dart';

final memberDetailProvider = FutureProvider.autoDispose.family<Membership, int>(
  (ref, membershipId) async {
    final repo = ref.read(membershipRepositoryProvider);
    final result = await repo.fetchMembership(membershipId: membershipId);

    return result.when(
      onSuccess: (membership) => membership,
      onFailure: (failure) {
        throw failure;
      },
    )!;
  },
);

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({super.key, required this.membershipId});

  final int membershipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(memberDetailProvider(membershipId));

    final failure = async.error is Failure ? (async.error as Failure) : null;
    final errorMessage = failure?.message;
    final hasError =
        async.hasError && (errorMessage?.trim().isNotEmpty == true);

    final membership = async.value;
    final account = membership?.account;
    final name = account?.name ?? l10n.lbl_unknown;
    final memberIdText = membership?.id?.toString() ?? l10n.lbl_na;

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationsReveal(
            child: ScreenTitleWidget.titleSecondary(
              title: l10n.lbl_memberWithId(memberIdText, name),
              onBack: () => context.pop(),
            ),
          ),
          Gap.h16,
          Expanded(
            child: LoadingWrapper(
              loading: async.isLoading,
              hasError: hasError,
              errorMessage: errorMessage,
              onRetry: () => ref.invalidate(memberDetailProvider(membershipId)),
              shimmerPlaceholder: ShimmerPlaceholders.infoSection(),
              child: membership == null
                  ? OperationsAnimatedPresence(
                      visible: true,
                      child: Center(child: Text(l10n.noData_available)),
                    )
                  : ListView(
                      padding: EdgeInsets.only(bottom: 16.0),
                      children: [
                        OperationsReveal(
                          delay: const Duration(milliseconds: 40),
                          child: _HeaderCard(membership: membership),
                        ),
                        Gap.h12,
                        OperationsReveal(
                          delay: const Duration(milliseconds: 80),
                          child: _AccountCard(membership: membership),
                        ),
                        Gap.h12,
                        OperationsReveal(
                          delay: const Duration(milliseconds: 120),
                          child: MembershipPositionsCardWidget(
                            membership: membership,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final account = membership.account;
    final theme = Theme.of(context);

    final name = account?.name ?? l10n.lbl_unknown;
    final phone = account?.phone;

    return Material(
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
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium!.copyWith(
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
                                  borderRadius: BorderRadius.circular(
                                    SanctuaryLayout.radius,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      AppIcons.verified,
                                      size: 14.0,
                                      color: AppColors.success,
                                    ),
                                    Gap.w6,
                                    Text(
                                      l10n.account_claim_title,
                                      style: theme.textTheme.labelMedium!
                                          .copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
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
                      ],
                    ),
                  ),
                ],
              ),
              Gap.h16,
              Container(
                padding: EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(color: AppColors.ghostBorder(0.06)),
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusChip(
                      title: membership.baptize
                          ? l10n.lbl_baptized
                          : l10n.membership_notBaptized,
                      isActive: membership.baptize,
                    ),
                    _StatusChip(
                      title: membership.sidi
                          ? l10n.lbl_sidi
                          : l10n.membership_notSidi,
                      isActive: membership.sidi,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final account = membership.account;
    final theme = Theme.of(context);

    final phone = account?.phone ?? l10n.lbl_na;
    final email = (account?.email?.trim().isNotEmpty ?? false)
        ? account!.email!.trim()
        : l10n.lbl_na;

    final dobLabel = account?.dob.ddMmmmYyyy ?? l10n.lbl_na;

    final genderLabel = account == null
        ? l10n.lbl_na
        : switch (account.gender) {
            Gender.male => l10n.gender_male,
            Gender.female => l10n.gender_female,
          };

    final maritalStatusLabel = account == null
        ? l10n.lbl_na
        : switch (account.maritalStatus) {
            MaritalStatus.single => l10n.maritalStatus_single,
            MaritalStatus.married => l10n.maritalStatus_married,
          };

    final claimed = account?.claimed ?? false;
    final claimedLabel = claimed
        ? l10n.account_claimedSubtitle_locked
        : l10n.account_claimedSubtitle_unlocked;

    final memberId = membership.id?.toString() ?? l10n.lbl_na;
    final churchName = membership.church?.name ?? l10n.lbl_na;
    final columnName = membership.column?.name ?? l10n.lbl_na;

    return Material(
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
                      AppIcons.info,
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
                          l10n.account_personalInformation_title,
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          churchName,
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
              Gap.h16,
              Container(
                padding: EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(color: AppColors.ghostBorder(0.06)),
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InfoRow(
                      icon: AppIcons.badge,
                      label: l10n.lbl_memberId,
                      value: memberId,
                    ),
                    Gap.h12,
                    _InfoRow(
                      icon: AppIcons.church,
                      label: l10n.lbl_churchName,
                      value: churchName,
                    ),
                    Gap.h12,
                    _InfoRow(
                      icon: AppIcons.grid,
                      label: l10n.lbl_columnName,
                      value: columnName,
                    ),
                    Gap.h12,
                    _InfoRow(
                      icon: AppIcons.phone,
                      label: l10n.lbl_phone,
                      value: phone,
                    ),
                    Gap.h12,
                    _InfoRow(
                      icon: AppIcons.document,
                      label: l10n.lbl_email,
                      value: email,
                    ),
                    Gap.h12,
                    _InfoRow(
                      icon: AppIcons.calendar,
                      label: l10n.lbl_dateOfBirth,
                      value: dobLabel,
                    ),
                    Gap.h12,
                    _InfoRow(
                      icon: AppIcons.person,
                      label: l10n.lbl_gender,
                      value: genderLabel,
                    ),
                    Gap.h12,
                    _InfoRow(
                      icon: AppIcons.handshake,
                      label: l10n.lbl_maritalStatus,
                      value: maritalStatusLabel,
                    ),
                    Gap.h12,
                    _InfoRow(
                      icon: claimed ? AppIcons.verified : AppIcons.person,
                      label: l10n.account_claim_title,
                      value: claimedLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.title, required this.isActive});

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
            : AppColors.surfaceContainerLow,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border.all(color: AppColors.ghostBorder(0.06)),
            borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14.0, color: AppColors.primary),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Text(
                value,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
