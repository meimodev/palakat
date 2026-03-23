import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/account/presentations/account/account_controller.dart';
import 'package:palakat/features/account/presentations/account/account_motion_widget.dart';
import 'package:palakat/features/account/presentations/account/account_state.dart';
import 'package:palakat/features/authentication/presentations/widgets/phone_input_formatter.dart';
import 'package:palakat/features/notification/presentations/widgets/notification_permission_banner.dart';
import 'package:palakat_shared/core/extension/extension.dart';

class AccountScreen extends ConsumerStatefulWidget {
  final String? verifiedPhone;
  final int? accountId;
  final String? firebaseIdToken;

  const AccountScreen({
    super.key,
    this.verifiedPhone,
    this.accountId,
    this.firebaseIdToken,
  });

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  /// Whether this screen was opened from signin flow (new registration)
  bool get _isFromSignIn =>
      widget.verifiedPhone != null && widget.verifiedPhone!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Debug: Print what data was received

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(accountControllerProvider.notifier);

      // Fetch account data if accountId is provided (signed-in user editing profile)
      if (widget.accountId != null) {
        controller.fetchAccountData(widget.accountId!);
      }
      // Otherwise, initialize with verified phone if provided (new registration)
      else if (widget.verifiedPhone != null &&
          widget.verifiedPhone!.isNotEmpty) {
        controller.initializeWithVerifiedPhone(widget.verifiedPhone!);
        if (widget.firebaseIdToken != null &&
            widget.firebaseIdToken!.isNotEmpty) {
          controller.initializeWithFirebaseIdToken(widget.firebaseIdToken!);
        }
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(accountControllerProvider.notifier);
    final state = ref.watch(accountControllerProvider);

    return PopScope(
      canPop: !_isFromSignIn,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showBackConfirmation(context);
        if (shouldPop == true && context.mounted) {
          // Navigate back to phone input screen (not OTP verification)
          context.goNamed(AppRoute.authentication);
        }
      },
      child: ScaffoldWidget(
        loading:
            state.loading || state.isRegistering || state.isFetchingAccount,
        persistBottomWidget: AccountReveal(
          delay: const Duration(milliseconds: 180),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 24.0,
              left: 12.0,
              right: 12.0,
              top: 6.0,
            ),
            child: Material(
              color: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
                side: BorderSide(color: AppColors.ghostBorder(0.08)),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(
                    SanctuaryLayout.radiusLarge,
                  ),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.04, blur: 24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
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
                      child: Text(
                        l10n.account_personalInformation_title,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Gap.h12,
                    ButtonWidget.primary(
                      text: state.account != null
                          ? l10n.btn_update
                          : l10n.btn_submit,
                      isLoading: state.isRegistering,
                      onTap: () async {
                        if (state.account != null &&
                            state.account!.id != null) {
                          final updatedAccount = await controller
                              .updateAccount();
                          if (context.mounted) {
                            if (updatedAccount == null) {
                              showSnackBar(
                                context,
                                state.errorMessage ??
                                    l10n.err_somethingWentWrong,
                              );
                              return;
                            }
                            showSnackBar(
                              context,
                              l10n.msg_accountUpdated,
                              isSuccess: true,
                            );

                            if (updatedAccount.membership?.id != null) {
                              context.pushNamed(
                                AppRoute.membership,
                                extra: RouteParam(
                                  params: {
                                    'membershipId':
                                        updatedAccount.membership!.id,
                                  },
                                ),
                              );
                            } else {
                              context.pushNamed(AppRoute.membership);
                            }
                          }
                        } else if (state.isPhoneVerified) {
                          final authResponse = await controller
                              .registerAccount();
                          if (context.mounted) {
                            if (authResponse == null) {
                              showSnackBar(
                                context,
                                state.errorMessage ??
                                    l10n.err_somethingWentWrong,
                              );
                              return;
                            }
                            final account = authResponse.account;
                            if (account.membership?.id != null) {
                              context.goNamed(
                                AppRoute.membership,
                                extra: RouteParam(
                                  params: {
                                    'membershipId': account.membership!.id,
                                  },
                                ),
                              );
                            } else {
                              context.goNamed(AppRoute.membership);
                            }
                          }
                        } else {
                          final success = await controller.submit();
                          if (context.mounted) {
                            if (!success) {
                              showSnackBar(
                                context,
                                l10n.publish_fillAllRequiredFields,
                              );
                              controller.publish();
                              return;
                            }
                            context.pushNamed(AppRoute.membership);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccountReveal(
              child: ScreenTitleWidget.primary(
                title: l10n.nav_account,
                leadIcon: AppIcons.back,
                leadIconColor: AppColors.onSurface,
                onPressedLeadIcon: () async {
                  if (_isFromSignIn) {
                    final shouldPop = await _showBackConfirmation(context);
                    if (shouldPop == true && context.mounted) {
                      context.goNamed(AppRoute.authentication);
                    }
                  } else {
                    context.pop();
                  }
                },
              ),
            ),
            Gap.h16,
            AccountReveal(
              delay: const Duration(milliseconds: 20),
              child: _buildHeroPanel(context, state),
            ),
            Gap.h16,
            AccountAnimatedPresence(
              visible:
                  state.errorMessage != null &&
                  state.errorMessage!.trim().isNotEmpty,
              child: Column(
                children: [
                  ErrorDisplayWidget(
                    message: state.errorMessage ?? '',
                    padding: EdgeInsets.zero,
                  ),
                  Gap.h16,
                ],
              ),
            ),
            AccountReveal(
              delay: const Duration(milliseconds: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(color: AppColors.ghostBorder(0.08)),
                  borderRadius: BorderRadius.circular(
                    SanctuaryLayout.radiusLarge,
                  ),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.035, blur: 28),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AccountReveal(
                        delay: const Duration(milliseconds: 80),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final shouldStack =
                                constraints.maxWidth < 280 ||
                                MediaQuery.textScalerOf(context).scale(1) > 1.1;

                            final icon = Container(
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
                              child: const Icon(
                                Icons.person_rounded,
                                size: 20.0,
                                color: AppColors.primary,
                              ),
                            );

                            final title = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.account_personalInformation_title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                  maxLines: shouldStack ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Gap.h4,
                                Text(
                                  l10n.nav_account,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            );

                            if (shouldStack) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [icon, Gap.h12, title],
                              );
                            }

                            return Row(
                              children: [
                                icon,
                                Gap.w12,
                                Expanded(child: title),
                              ],
                            );
                          },
                        ),
                      ),
                      Gap.h16,
                      AccountReveal(
                        delay: const Duration(milliseconds: 110),
                        child: Opacity(
                          opacity:
                              (state.isPhoneVerified || state.account != null)
                              ? 0.6
                              : 1.0,
                          child: IgnorePointer(
                            ignoring:
                                state.isPhoneVerified || state.account != null,
                            child: InputWidget.text(
                              key: ValueKey('phone_${state.phone}'),
                              hint: l10n.churchRequest_hintPhoneExample,
                              label:
                                  (state.isPhoneVerified ||
                                      state.account != null)
                                  ? l10n.account_phoneLabel_locked
                                  : l10n.account_phoneLabel_active,
                              currentInputValue: state.phone,
                              textInputType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                PhoneInputFormatter(),
                              ],
                              onChanged: controller.onChangedTextPhone,
                              validators: (val) => state.errorPhone,
                              errorText: state.errorPhone,
                            ),
                          ),
                        ),
                      ),
                      Gap.h12,
                      AccountReveal(
                        delay: const Duration(milliseconds: 140),
                        child: InputWidget.text(
                          key: ValueKey('name_${state.name}'),
                          hint: l10n.hint_enterFullName,
                          label: l10n.account_fullNameLabel,
                          currentInputValue: state.name,
                          errorText: state.errorName,
                          onChanged: controller.onChangedTextName,
                        ),
                      ),
                      Gap.h12,
                      AccountReveal(
                        delay: const Duration(milliseconds: 170),
                        child: InputWidget.text(
                          key: ValueKey('email_${state.email}'),
                          hint: l10n.hint_enterEmailAddress,
                          label: l10n.account_emailLabel_optional,
                          currentInputValue: state.email,
                          textInputType: TextInputType.emailAddress,
                          errorText: state.errorEmail,
                          onChanged: controller.onChangedEmail,
                        ),
                      ),
                      Gap.h12,
                      AccountReveal(
                        delay: const Duration(milliseconds: 200),
                        child: InputWidget<DateTime>.dropdown(
                          key: ValueKey('dob_${state.dob}'),
                          label: l10n.account_bipraHint,
                          hint: l10n.lbl_dateOfBirth,
                          currentInputValue: state.dob,
                          errorText: state.errorDob,
                          endIcon: FaIcon(AppIcons.calendar, size: 20),
                          optionLabel: (DateTime option) => option.ddMmmmYyyy,
                          onChanged: controller.onChangedDOB,
                          onPressedWithResult: () async =>
                              await showDialogDatePickerWidget(
                                context: context,
                              ),
                        ),
                      ),
                      Gap.h12,
                      AccountReveal(
                        delay: const Duration(milliseconds: 230),
                        child: InputWidget<Gender>.binaryOption(
                          key: ValueKey('gender_${state.gender}'),
                          label: l10n.account_bipraHint,
                          currentInputValue: state.gender,
                          options: Gender.values,
                          onChanged: controller.onChangedGender,
                          errorText: state.errorGender,
                          optionLabel: (Gender option) => switch (option) {
                            Gender.male => l10n.gender_male,
                            Gender.female => l10n.gender_female,
                          },
                        ),
                      ),
                      Gap.h12,
                      AccountReveal(
                        delay: const Duration(milliseconds: 260),
                        child: InputWidget<MaritalStatus>.binaryOption(
                          key: ValueKey('maritalStatus_${state.maritalStatus}'),
                          label: l10n.account_bipraHint,
                          currentInputValue: state.maritalStatus,
                          options: MaritalStatus.values,
                          onChanged: controller.onChangedMaritalStatus,
                          errorText: state.errorMarried,
                          optionLabel: (MaritalStatus option) =>
                              switch (option) {
                                MaritalStatus.single =>
                                  l10n.maritalStatus_single,
                                MaritalStatus.married =>
                                  l10n.maritalStatus_married,
                              },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Gap.h16,
            AccountReveal(
              delay: const Duration(milliseconds: 120),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  border: Border.all(color: AppColors.ghostBorder(0.06)),
                  borderRadius: BorderRadius.circular(
                    SanctuaryLayout.radiusLarge,
                  ),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 14),
                ),
                child: CheckboxListTile(
                  key: ValueKey('claimed_${state.claimed}'),
                  value: state.claimed,
                  onChanged: state.claimed
                      ? null
                      : (value) async {
                          if (value != null && value) {
                            final confirmed = await _showClaimConfirmation(
                              context,
                            );
                            if (confirmed == true) {
                              controller.onChangedClaimed(value);
                            }
                          }
                        },
                  title: Text(
                    l10n.account_claim_title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    state.claimed
                        ? l10n.account_claimedSubtitle_locked
                        : l10n.account_claimedSubtitle_unlocked,
                    style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
                  ),
                  activeColor: AppColors.primary,
                  checkColor: AppColors.surfaceContainerLowest,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
              ),
            ),
            Gap.h16,
            const AccountReveal(
              delay: Duration(milliseconds: 150),
              child: NotificationPermissionBanner(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPanel(BuildContext context, AccountState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.ghostBorder(0.06)),
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
              ),
              child: const Icon(Icons.badge_rounded, color: AppColors.primary),
            ),
            Gap.h16,
            Text(
              l10n.nav_account,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap.h8,
            Text(
              l10n.account_personalInformation_title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Gap.h20,
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSummaryChip(
                  context,
                  icon: Icons.phone_iphone_outlined,
                  label: l10n.lbl_phone,
                  value: state.phone?.isNotEmpty == true
                      ? state.phone!
                      : l10n.lbl_notSpecified,
                ),
                _buildSummaryChip(
                  context,
                  icon: Icons.person_outline_rounded,
                  label: l10n.lbl_name,
                  value: state.name?.isNotEmpty == true
                      ? state.name!
                      : l10n.lbl_notSpecified,
                ),
                _buildSummaryChip(
                  context,
                  icon: Icons.verified_user_outlined,
                  label: l10n.section_status,
                  value: state.isPhoneVerified
                      ? l10n.status_approved
                      : l10n.status_pending,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.ghostBorder(0.06)),
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border.all(color: AppColors.ghostBorder(0.06)),
              borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          Gap.w10,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap.h2,
                Text(
                  value,
                  style: theme.textTheme.labelLarge?.copyWith(
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
    );
  }

  /// Show confirmation dialog when back button is pressed from signin flow
  Future<bool?> _showBackConfirmation(BuildContext context) {
    final l10n = context.l10n;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SanctuaryLayout.radiusLarge),
            ),
            side: BorderSide(color: AppColors.ghostBorder(0.08)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SanctuaryLayout.radiusLarge),
              ),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.04, blur: 24),
            ),
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: AppColors.ghostBorder(0.18),
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 4),
                    ),
                  ),
                ),
                Gap.h16,
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.18),
                    ),
                    borderRadius: BorderRadius.circular(
                      SanctuaryLayout.radiusLarge,
                    ),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.warning,
                    size: 24.0,
                    color: AppColors.warning,
                  ),
                ),
                Gap.h16,
                Text(
                  l10n.auth_cancelRegistration_title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap.h12,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    border: Border.all(color: AppColors.ghostBorder(0.06)),
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
                  ),
                  child: Text(
                    l10n.auth_cancelRegistration_message,
                    style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
                Gap.h24,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          side: BorderSide(color: AppColors.ghostBorder(0.18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SanctuaryLayout.radius,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.btn_stay,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surfaceContainerLowest,
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SanctuaryLayout.radius,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.btn_goBack,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.surfaceContainerLowest,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap.h8,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show confirmation bottom sheet for claiming account
  Future<bool?> _showClaimConfirmation(BuildContext context) {
    final l10n = context.l10n;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SanctuaryLayout.radiusLarge),
            ),
            side: BorderSide(color: AppColors.ghostBorder(0.08)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SanctuaryLayout.radiusLarge),
              ),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.04, blur: 24),
            ),
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: AppColors.ghostBorder(0.18),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
                Gap.h16,
                // Warning icon
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.18),
                    ),
                    borderRadius: BorderRadius.circular(
                      SanctuaryLayout.radiusLarge,
                    ),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.warning,
                    size: 24.0,
                    color: AppColors.warning,
                  ),
                ),
                Gap.h16,
                // Title
                Text(
                  l10n.account_claimConfirm_title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap.h12,
                // Message
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    border: Border.all(color: AppColors.ghostBorder(0.06)),
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
                  ),
                  child: Text(
                    l10n.account_claimConfirm_message,
                    style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
                Gap.h24,
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          side: BorderSide(color: AppColors.ghostBorder(0.18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SanctuaryLayout.radius,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.btn_cancel,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surfaceContainerLowest,
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SanctuaryLayout.radius,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.btn_confirm,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.surfaceContainerLowest,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap.h8,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnackBar(
    BuildContext context,
    String msg, {
    bool isSuccess = false,
  }) {
    if (msg.trim().isEmpty) {
      return;
    }

    final theme = Theme.of(context);
    final accentColor = isSuccess ? AppColors.success : AppColors.error;
    final accentIcon = isSuccess ? AppIcons.success : AppIcons.error;
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            border: Border.all(color: accentColor.withValues(alpha: 0.18)),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 16),
          ),
          child: Row(
            children: [
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.18),
                  ),
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                ),
                alignment: Alignment.center,
                child: FaIcon(accentIcon, size: 14.0, color: accentColor),
              ),
              Gap.w12,
              Expanded(
                child: Text(
                  msg,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
