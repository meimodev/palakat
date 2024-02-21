import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class PatientPortalCreatePinWidget extends StatefulWidget {
  const PatientPortalCreatePinWidget({
    super.key,
    required this.patientPortalStatus,
    required this.onCreatingNewPin,
  });

  final PatientPortalStatus patientPortalStatus;
  final void Function() onCreatingNewPin;

  @override
  State<PatientPortalCreatePinWidget> createState() =>
      _PatientPortalCreatePinWidgetState();
}

class _PatientPortalCreatePinWidgetState
    extends State<PatientPortalCreatePinWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: LoadingWrapper(
        value: true,
        child: SizedBox(),
      ),
    );
  }
}
