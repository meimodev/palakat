import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
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
          ScreenTitleWidget.titleSecondary(
            title: l10n.lbl_memberWithId(memberIdText, name),
            onBack: () => context.pop(),
          ),
          Gap.h16,
          Expanded(
            child: LoadingWrapper(
              loading: async.isLoading,
              hasError: hasError,
              errorMessage: errorMessage,
              onRetry: () => ref.invalidate(memberDetailProvider(membershipId)),
              shimmerPlaceholder: Column(
                children: [
                  PalakatShimmerPlaceholders.infoCard(),
                  Gap.h12,
                  PalakatShimmerPlaceholders.infoCard(),
                  Gap.h12,
                  PalakatShimmerPlaceholders.infoCard(),
                ],
              ),
              child: membership == null
                  ? Center(child: Text(l10n.noData_available))
                  : ListView(
                      padding: EdgeInsets.only(bottom: BaseSize.h16),
                      children: [
                        _HeaderCard(membership: membership),
                        Gap.h12,
                        _AccountCard(membership: membership),
                        Gap.h12,
                        MembershipPositionsCardWidget(membership: membership),
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

    final name = account?.name ?? l10n.lbl_unknown;
    final phone = account?.phone;

    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.blue[100],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    AppIcons.person,
                    size: BaseSize.w20,
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
                              style: BaseTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: BaseColor.black,
                              ),
                            ),
                          ),
                          if (account?.claimed == true) ...[
                            Gap.w8,
                            Icon(
                              AppIcons.verified,
                              size: BaseSize.w18,
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
                    ],
                  ),
                ),
              ],
            ),
            Gap.h16,
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
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.primary[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
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
                    AppIcons.info,
                    size: BaseSize.w20,
                    color: BaseColor.primary[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    l10n.account_personalInformation_title,
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
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
            _InfoRow(icon: AppIcons.phone, label: l10n.lbl_phone, value: phone),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: BaseSize.w28,
          height: BaseSize.w28,
          decoration: BoxDecoration(
            color: BaseColor.primary[50],
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: BaseSize.w14, color: BaseColor.primary[700]),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: BaseTypography.bodySmall.copyWith(
                  color: BaseColor.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Text(
                value,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
