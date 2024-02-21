import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/domain.dart';

class PatientPickerWidget extends StatefulWidget {
  const PatientPickerWidget({
    super.key,
    this.onSelectedPatient,
    this.patient,
  });

  final Patient? patient;
  final void Function(Patient? patient)? onSelectedPatient;

  @override
  State<PatientPickerWidget> createState() => _PatientPickerWidgetState();
}

class _PatientPickerWidgetState extends State<PatientPickerWidget> {
  Patient? patient;

  @override
  void initState() {
    super.initState();
    patient = widget.patient;
  }

  @override
  void didUpdateWidget(covariant PatientPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    safeRebuild(() {
      if (oldWidget.patient != widget.patient) {
        setState(() {
          patient = widget.patient;
        });
      }
    });
  }

  void _handleOnClick(BuildContext context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BaseSize.customRadius(16)),
        ),
      ),
      builder: (context) {
        return PatientPickerDialog(
          value: patient,
          onSave: (value) {
            setState(() {
              patient = value;
            });
            if (widget.onSelectedPatient != null) {
              widget.onSelectedPatient!(value);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PatientPickerCardWidget(
      enable: widget.onSelectedPatient != null,
      patient: patient,
      onClick: () {
        if (widget.onSelectedPatient != null) {
          _handleOnClick(context);
        }
      },
    );
  }
}
