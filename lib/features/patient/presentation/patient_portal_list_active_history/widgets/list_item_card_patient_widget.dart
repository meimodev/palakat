import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class ListItemCardPatientWidget extends StatelessWidget {
  const ListItemCardPatientWidget({
    super.key,
    required this.name,
    required this.gender,
    required this.dob,
    required this.onTap,
    required this.activate,
  });

  final String name;
  final String gender;
  final String dob;

  final Function() onTap;

  final bool activate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: BaseSize.h16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          BaseSize.radiusMd,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w16,
            vertical: BaseSize.h16,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: activate ? BaseColor.primary3 : BaseColor.neutral.shade20,
            ),
            borderRadius: BorderRadius.circular(
              BaseSize.radiusMd,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.toUpperCase(),
                style: TypographyTheme.bodyRegular.toNeutral80,
              ),
              Gap.h8,
              Text(
                gender,
                style: TypographyTheme.textMRegular.toNeutral60,
              ),
              Gap.customGapHeight(2),
              Text(
                dob,
                style: TypographyTheme.textMRegular.toNeutral60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
