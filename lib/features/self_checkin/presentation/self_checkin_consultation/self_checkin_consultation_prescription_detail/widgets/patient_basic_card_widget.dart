import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class PatientBasicCardWidget extends StatelessWidget {
  const PatientBasicCardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h4),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.neutral.shade20, width: 1),
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Assets.images.userDefault.image(
                height: BaseSize.customHeight(65),
                width: BaseSize.customHeight(65)),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pricilla Pamela Pricilla',
                    style: TypographyTheme.textLSemiBold.toPrimary,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap.h4,
                  Text(
                    'Female',
                    style: TypographyTheme.textXSRegular.toNeutral60,
                  ),
                  Gap.h4,
                  Text(
                    '24 April 1996',
                    style: TypographyTheme.textXSRegular.toNeutral60,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
