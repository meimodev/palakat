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
              bottom: BaseSize.h24,
              left: BaseSize.w12,
              right: BaseSize.w12,
              top: BaseSize.h6,
            ),
            child: ButtonWidget.primary(
              text: state.account != null ? l10n.btn_update : l10n.btn_submit,
              isLoading: state.isRegistering,
              onTap: () async {
                if (state.account != null && state.account!.id != null) {
                  final updatedAccount = await controller.updateAccount();
                  if (context.mounted) {
                    if (updatedAccount == null) {
                      showSnackBar(
                        context,
                        state.errorMessage ?? l10n.err_somethingWentWrong,
                      );
                      return;
                    }
                    showSnackBar(context, l10n.msg_accountUpdated);

                    if (updatedAccount.membership?.id != null) {
                      context.pushNamed(
                        AppRoute.membership,
                        extra: RouteParam(
                          params: {
                            'membershipId': updatedAccount.membership!.id,
                          },
                        ),
                      );
                    } else {
                      context.pushNamed(AppRoute.membership);
                    }
                  }
                } else if (state.isPhoneVerified) {
                  final authResponse = await controller.registerAccount();
                  if (context.mounted) {
                    if (authResponse == null) {
                      showSnackBar(
                        context,
                        state.errorMessage ?? l10n.err_somethingWentWrong,
                      );
                      return;
                    }
                    final account = authResponse.account;
                    if (account.membership?.id != null) {
                      context.goNamed(
                        AppRoute.membership,
                        extra: RouteParam(
                          params: {'membershipId': account.membership!.id},
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
                      showSnackBar(context, l10n.publish_fillAllRequiredFields);
                      controller.publish();
                      return;
                    }
                    context.pushNamed(AppRoute.membership);
                  }
                }
              },
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
                leadIconColor: BaseColor.textPrimary,
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
              delay: const Duration(milliseconds: 40),
              child: Material(
                color: BaseColor.cardBackground1,
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                surfaceTintColor: BaseColor.primary[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                ),
                child: Padding(
                  padding: EdgeInsets.all(BaseSize.w16),
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
                              width: BaseSize.w32,
                              height: BaseSize.w32,
                              decoration: BoxDecoration(
                                color: BaseColor.primary[100],
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: FaIcon(
                                AppIcons.person,
                                size: BaseSize.w16,
                                color: BaseColor.primary[700],
                              ),
                            );

                            final title = Text(
                              l10n.account_personalInformation_title,
                              style: BaseTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: BaseColor.textPrimary,
                              ),
                              maxLines: shouldStack ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
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
              child: Material(
                color: BaseColor.primary[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                  side: BorderSide(
                    color: BaseColor.primary[200] ?? BaseColor.neutral[300]!,
                  ),
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
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    state.claimed
                        ? l10n.account_claimedSubtitle_locked
                        : l10n.account_claimedSubtitle_unlocked,
                    style: BaseTypography.bodyMedium.toSecondary,
                  ),
                  activeColor: BaseColor.primary[700],
                  checkColor: BaseColor.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w16,
                    vertical: BaseSize.h8,
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

  /// Show confirmation dialog when back button is pressed from signin flow
  Future<bool?> _showBackConfirmation(BuildContext context) {
    final l10n = context.l10n;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: BaseColor.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: BaseColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(BaseSize.radiusLg),
            topRight: Radius.circular(BaseSize.radiusLg),
          ),
        ),
        padding: EdgeInsets.all(BaseSize.w24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: BaseSize.w40,
                height: BaseSize.h4,
                decoration: BoxDecoration(
                  color: BaseColor.neutral30,
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
              ),
            ),
            Gap.h16,
            Container(
              width: BaseSize.w56,
              height: BaseSize.w56,
              decoration: BoxDecoration(
                color: BaseColor.yellow[50],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.warning,
                size: BaseSize.w32,
                color: BaseColor.yellow[700],
              ),
            ),
            Gap.h16,
            Text(
              l10n.auth_cancelRegistration_title,
              style: BaseTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: BaseColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.h12,
            Text(
              l10n.auth_cancelRegistration_message,
              style: BaseTypography.bodyMedium.toSecondary,
              textAlign: TextAlign.center,
            ),
            Gap.h24,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                      side: BorderSide(color: BaseColor.neutral[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                      ),
                    ),
                    child: Text(
                      l10n.btn_stay,
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.secondaryText,
                      ),
                    ),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BaseColor.primary[700],
                      foregroundColor: BaseColor.white,
                      padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                      ),
                    ),
                    child: Text(
                      l10n.btn_goBack,
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.white,
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
    );
  }

  /// Show confirmation bottom sheet for claiming account
  Future<bool?> _showClaimConfirmation(BuildContext context) {
    final l10n = context.l10n;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: BaseColor.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: BaseColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(BaseSize.radiusLg),
            topRight: Radius.circular(BaseSize.radiusLg),
          ),
        ),
        padding: EdgeInsets.all(BaseSize.w24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: BaseSize.w40,
                height: BaseSize.h4,
                decoration: BoxDecoration(
                  color: BaseColor.neutral30,
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
              ),
            ),
            Gap.h16,
            // Warning icon
            Container(
              width: BaseSize.w56,
              height: BaseSize.w56,
              decoration: BoxDecoration(
                color: BaseColor.yellow[50],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.warning,
                size: BaseSize.w32,
                color: BaseColor.yellow[700],
              ),
            ),
            Gap.h16,
            // Title
            Text(
              l10n.account_claimConfirm_title,
              style: BaseTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: BaseColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.h12,
            // Message
            Text(
              l10n.account_claimConfirm_message,
              style: BaseTypography.bodyMedium.toSecondary,
              textAlign: TextAlign.center,
            ),
            Gap.h24,
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                      side: BorderSide(color: BaseColor.neutral[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                      ),
                    ),
                    child: Text(
                      l10n.btn_cancel,
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.secondaryText,
                      ),
                    ),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BaseColor.primary[700],
                      foregroundColor: BaseColor.white,
                      padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                      ),
                    ),
                    child: Text(
                      l10n.btn_confirm,
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.white,
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
    );
  }

  void showSnackBar(BuildContext context, String msg) {
    if (msg.trim().isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
