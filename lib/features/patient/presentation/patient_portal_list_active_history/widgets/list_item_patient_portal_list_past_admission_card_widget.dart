import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'widgets.dart';

class ListItemPatientPortalListPastAdmissionCardWidget extends StatelessWidget {
  const ListItemPatientPortalListPastAdmissionCardWidget({
    super.key,
    required this.id,
    required this.hospital,
    required this.admissionDate,
    required this.doctorName,
    required this.onTap,
    required this.inpatient,
  });

  final String id;
  final String hospital;
  final String admissionDate;
  final String doctorName;
  final bool inpatient;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: BaseSize.h24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          BaseSize.radiusLg,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.h16,
            vertical: BaseSize.w16,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: BaseColor.neutral.shade20,
            ),
            borderRadius: BorderRadius.circular(
              BaseSize.radiusLg,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTheme.textMSemiBold.toNeutral70,
                    ),
                    Gap.customGapHeight(6),
                    Text(
                      id,
                      style: TypographyTheme.textMSemiBold.toNeutral60,
                    ),
                    Gap.customGapHeight(6),
                    Text(
                      doctorName,
                      style: TypographyTheme.textSRegular.toNeutral60,
                    ),
                    Gap.customGapHeight(10),
                    PatientStatusTagChipWidget(inpatient: inpatient),
                  ],
                ),
              ),
              Text(
                admissionDate,
                style: TypographyTheme.textSRegular.toNeutral50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
