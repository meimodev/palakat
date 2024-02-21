import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({
    super.key,
    required this.doctor,
  });
  final Doctor doctor;

  List<Widget> get educationList {
    final educations = doctor.content?.educations;
    return educations
            ?.map((education) => Container(
                  padding: EdgeInsets.only(
                    top: educations.indexOf(education) == 0 ? 0 : BaseSize.h16,
                    bottom:
                        educations.indexOf(education) == educations.length - 1
                            ? 0
                            : BaseSize.h16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: educations.indexOf(education) ==
                                educations.length - 1
                            ? 0
                            : 1,
                        color: BaseColor.neutral.shade10,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        education.year,
                        style: TypographyTheme.textLRegular.toPrimary,
                      ),
                      Gap.w24,
                      Expanded(
                        child: Text(
                          education.school,
                          style: TypographyTheme.textMRegular.toNeutral60,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(title: LocaleKeys.text_detailDoctor.tr()),
      child: ListView(
        padding: horizontalPadding,
        children: [
          Gap.h20,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(BaseSize.radiusLg),
                ),
                child: Stack(
                  children: <Widget>[
                    ImageNetworkWidget(
                      imageUrl: doctor.content?.pictureURL ?? "",
                      fit: BoxFit.cover,
                      width: BaseSize.customWidth(100),
                      height: BaseSize.customWidth(100),
                    ),
                  ],
                ),
              ),
              Gap.w20,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: BaseSize.h8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: TypographyTheme.textLSemiBold.toNeutral80,
                      ),
                      Gap.customGapHeight(6),
                      Text(
                        doctor.specialist?.name ?? "",
                        style: TypographyTheme.textMRegular.toNeutral60,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Gap.h24,
          CardWidget(
            icon: Assets.icons.line.stethoscope,
            title: LocaleKeys.text_about.tr(),
            content: [
              Text(
                doctor.content?.about ?? "",
                style: TypographyTheme.textMRegular.toNeutral60
                    .copyWith(height: 1.5),
              )
            ],
          ),
          Gap.h16,
          CardWidget(
            icon: Assets.icons.line.graduationCap,
            title: LocaleKeys.text_education.tr(),
            content: educationList,
          ),
        ],
      ),
    );
  }
}
