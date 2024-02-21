import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class PatientDetailTileWidget extends StatelessWidget {
  final String title;
  final String value;
  const PatientDetailTileWidget({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TypographyTheme.textLRegular.toNeutral60,
        ),
        Text(
          value,
          style: TypographyTheme.textLSemiBold.toNeutral80,
        ),
      ],
    );
  }
}
