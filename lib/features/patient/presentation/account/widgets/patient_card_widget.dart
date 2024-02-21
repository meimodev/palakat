import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientCardWidget extends StatelessWidget {
  final PatientStatus? status;
  final String name;
  final String dob;
  final String phone;
  final void Function() onTap;

  const PatientCardWidget({
    super.key,
    required this.name,
    required this.dob,
    required this.phone,
    required this.onTap,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return RippleTouch(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        BaseSize.radiusSm,
      ),
      child: Container(
        padding: EdgeInsets.all(BaseSize.w16),
        decoration: BoxDecoration(
          border: Border.all(
            color: BaseColor.neutral.shade20,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(
            BaseSize.radiusSm,
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (status != null)
                  PatientStatusChipWidget(
                    status: status ?? PatientStatus.unverified,
                  ),
                Gap.h8,
                Text(
                  name,
                  style: TypographyTheme.textLSemiBold.toNeutral80,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap.h8,
                Text(
                  dob,
                  style: TypographyTheme.textMRegular.toNeutral60,
                ),
                Gap.h4,
                Text(
                  phone,
                  style: TypographyTheme.textMRegular.toNeutral60,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
