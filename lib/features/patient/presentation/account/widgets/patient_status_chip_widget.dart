import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';

class PatientStatusChipWidget extends StatelessWidget {
  const PatientStatusChipWidget({
    super.key,
    required this.status,
  });
  final PatientStatus status;

  @override
  Widget build(BuildContext context) {
    return ChipsWidget(
      size: ChipsSize.small,
      title: status.name.capitalizeSnakeCaseToTitle,
      color: status == PatientStatus.verified
          ? BaseColor.primary1
          : BaseColor.yellow.shade50,
      textColor: status == PatientStatus.verified
          ? BaseColor.primary3
          : BaseColor.yellow.shade500,
      border: Border.all(
        width: 1,
        color: status == PatientStatus.verified
            ? BaseColor.primary2
            : BaseColor.yellow.shade100,
      ),
    );
  }
}
