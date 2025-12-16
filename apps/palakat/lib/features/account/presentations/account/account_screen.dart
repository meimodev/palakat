import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/account/presentations/account/account_controller.dart';
import 'package:palakat/features/authentication/presentations/widgets/phone_input_formatter.dart';
import 'package:palakat/features/notification/presentations/widgets/notification_permission_banner.dart';
import 'package:palakat_shared/core/extension/extension.dart';

class AccountScreen extends ConsumerStatefulWidget {
  final String? verifiedPhone;
  final int? accountId;

  const AccountScreen({super.key, this.verifiedPhone, this.accountId});

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
        persistBottomWidget: Padding(
          padding: EdgeInsets.only(
            bottom: BaseSize.h24,
            left: BaseSize.w12,
            right: BaseSize.w12,
            top: BaseSize.h6,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitleWidget.primary(
              title: l10n.nav_account,
              leadIcon: AppIcons.back,
              leadIconColor: BaseColor.black,
              onPressedLeadIcon: () async {
                if (_isFromSignIn) {
                  final shouldPop = await _showBackConfirmation(context);
                  if (shouldPop == true && context.mounted) {
                    // Navigate back to phone input screen (not OTP verification)
                    context.goNamed(AppRoute.authentication);
                  }
                } else {
                  context.pop();
                }
              },
            ),
            Gap.h16,
            Material(
              color: BaseColor.cardBackground1,
              elevation: 1,
              shadowColor: BaseColor.black.withValues(alpha: 0.05),
              surfaceTintColor: BaseColor.primary[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(BaseSize.w16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
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
                    Opacity(
                      opacity: (state.isPhoneVerified || state.account != null)
                          ? 0.6
                          : 1.0,
                      child: IgnorePointer(
                        ignoring:
                            state.isPhoneVerified || state.account != null,
                        child: InputWidget.text(
                          key: ValueKey('phone_${state.phone}'),
                          hint: l10n.churchRequest_hintPhoneExample,
                          label:
                              (state.isPhoneVerified || state.account != null)
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
                    Gap.h12,
                    InputWidget.text(
                      key: ValueKey('name_${state.name}'),
                      hint: l10n.hint_enterFullName,
                      label: l10n.account_fullNameLabel,
                      currentInputValue: state.name,
                      errorText: state.errorName,
                      onChanged: controller.onChangedTextName,
                    ),
                    Gap.h12,
                    InputWidget.text(
                      key: ValueKey('email_${state.email}'),
                      hint: l10n.hint_enterEmailAddress,
                      label: l10n.account_emailLabel_optional,
                      currentInputValue: state.email,
                      textInputType: TextInputType.emailAddress,
                      errorText: state.errorEmail,
                      onChanged: controller.onChangedEmail,
                    ),
                    Gap.h12,
                    InputWidget<DateTime>.dropdown(
                      key: ValueKey('dob_${state.dob}'),
                      label: l10n.account_bipraHint,
                      hint: l10n.lbl_dateOfBirth,
                      currentInputValue: state.dob,
                      errorText: state.errorDob,
                      endIcon: FaIcon(AppIcons.calendar, size: 20),
                      optionLabel: (DateTime option) => option.ddMmmmYyyy,
                      onChanged: controller.onChangedDOB,
                      onPressedWithResult: () async =>
                          await showDialogDatePickerWidget(context: context),
                    ),
                    Gap.h12,
                    InputWidget<Gender>.binaryOption(
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
                    Gap.h12,
                    InputWidget<MaritalStatus>.binaryOption(
                      key: ValueKey('maritalStatus_${state.maritalStatus}'),
                      label: l10n.account_bipraHint,
                      currentInputValue: state.maritalStatus,
                      options: MaritalStatus.values,
                      onChanged: controller.onChangedMaritalStatus,
                      errorText: state.errorMarried,
                      optionLabel: (MaritalStatus option) => switch (option) {
                        MaritalStatus.single => l10n.maritalStatus_single,
                        MaritalStatus.married => l10n.maritalStatus_married,
                      },
                    ),
                    Gap.h16,
                    // Claimed checkbox
                    Material(
                      color: BaseColor.primary[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: BaseColor.primary[200] ?? BaseColor.neutral40,
                        ),
                      ),
                      child: CheckboxListTile(
                        key: ValueKey('claimed_${state.claimed}'),
                        value: state.claimed,
                        // Disable checkbox if already claimed
                        onChanged: state.claimed
                            ? null
                            : (value) async {
                                if (value != null && value) {
                                  // Show confirmation bottom sheet when trying to claim
                                  final confirmed =
                                      await _showClaimConfirmation(context);
                                  if (confirmed == true) {
                                    controller.onChangedClaimed(value);
                                  }
                                }
                              },
                        title: Text(
                          l10n.account_claim_title,
                          style: BaseTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: BaseColor.black,
                          ),
                        ),
                        subtitle: Text(
                          state.claimed
                              ? l10n.account_claimedSubtitle_locked
                              : l10n.account_claimedSubtitle_unlocked,
                          style: BaseTypography.bodySmall.toSecondary,
                        ),
                        activeColor: BaseColor.primary[700],
                        checkColor: BaseColor.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: BaseSize.w16,
                          vertical: BaseSize.h8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap.h16,
            // Notification permission banner - Requirements: 6.2, 6.3
            const NotificationPermissionBanner(),
            Gap.h16,
            ButtonWidget.primary(
              text: state.account != null ? l10n.btn_update : l10n.btn_submit,
              isLoading: state.isRegistering,
              onTap: () async {
                // Check if we're updating an existing account
                if (state.account != null && state.account!.id != null) {
                  // Update existing account
                  final updatedAccount = await controller.updateAccount();
                  if (context.mounted) {
                    if (updatedAccount == null) {
                      // Show error message from state
                      showSnackBar(
                        context,
                        state.errorMessage ?? l10n.err_somethingWentWrong,
                      );
                      return;
                    }
                    // Update successful
                    showSnackBar(context, l10n.msg_accountUpdated);

                    // Navigate to membership screen if membershipId exists
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
                      // No membership yet, go to membership creation
                      context.pushNamed(AppRoute.membership);
                    }
                  }
                }
                // If phone is verified (coming from auth flow), register new account
                else if (state.isPhoneVerified) {
                  final authResponse = await controller.registerAccount();
                  if (context.mounted) {
                    if (authResponse == null) {
                      // Show error message from state
                      showSnackBar(
                        context,
                        state.errorMessage ?? l10n.err_somethingWentWrong,
                      );
                      return;
                    }
                    // Registration successful, check for membership
                    final account = authResponse.account;
                    if (account.membership?.id != null) {
                      context.goNamed(
                        AppRoute.membership,
                        extra: RouteParam(
                          params: {'membershipId': account.membership!.id},
                        ),
                      );
                    } else {
                      // No membership yet, go to membership creation
                      context.goNamed(AppRoute.membership);
                    }
                  }
                } else {
                  // Legacy flow: just validate and go to membership
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
                fontWeight: FontWeight.bold,
                color: BaseColor.black,
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
                      side: BorderSide(color: BaseColor.neutral40),
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
                fontWeight: FontWeight.bold,
                color: BaseColor.black,
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
                      side: BorderSide(color: BaseColor.neutral40),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
