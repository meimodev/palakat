import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/domain.dart';
import 'widgets.dart';

class UnauthorizedLayoutWidget extends StatelessWidget {
  const UnauthorizedLayoutWidget({
    super.key,
    required this.patientPortalStatus,
    required this.tecPin,
    required this.onChangedPin,
    required this.loginByBiometric,
    required this.onCompletedPin,
    required this.onPressedSubmitChooseOption,
    required this.onPressedActivatePatientPortal,
    required this.onCreatingNewPin,
  });

  final PatientPortalStatus patientPortalStatus;
  final TextEditingController tecPin;

  final void Function() loginByBiometric;
  final void Function(String value) onChangedPin;
  final void Function(String value) onCompletedPin;
  final void Function(OtpProvider provider) onPressedSubmitChooseOption;
  final void Function() onPressedActivatePatientPortal;
  final void Function() onCreatingNewPin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildLayout(context),
        ),
      ],
    );
  }

  Widget _buildLayout(BuildContext context) {
    switch (patientPortalStatus) {
      case PatientPortalStatus.notActivated:
        return PatientPortalNotActivatedWidget(
          onPressedActivatePatientPortal: onPressedActivatePatientPortal,
        );

      case PatientPortalStatus.pending:
        return const PatientPortalUnderReviewWidget();

      case PatientPortalStatus.activated:
        return PatientPortalAlreadyActiveWidget(
          inputPinTextController: tecPin,
          loginByBiometric: loginByBiometric,
          onChangedPin: onChangedPin,
          onCompletedPin: onCompletedPin,
          onPressedForgotButton: () {
            showSendCodeOptionBottomSheet(
              context,
              isResend: false,
              onPressedSubmitChooseOption: onPressedSubmitChooseOption,
            );
          },
        );

      case PatientPortalStatus.rejected:
        return const PatientPortalRejectedWidget();
    }
  }
}

