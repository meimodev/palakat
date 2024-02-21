import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class AppointmentServiceListScreen extends StatelessWidget {
  AppointmentServiceListScreen({
    super.key,
  });

  final List<Map<String, dynamic>> _appointmentServices = [
    {
      "title": LocaleKeys.text_mainServices.tr(),
      "services": [
        {
          "title": LocaleKeys.text_bookDoctor.tr(),
          "subtitle": LocaleKeys.text_makeAnAppointmentWithTheDoctor.tr(),
          "icon": Assets.icons.tint.chatBox.svg(
            height: BaseSize.h40,
            width: BaseSize.h40,
          ),
          "route": AppRoute.searchDoctor,
        },
        {
          "title": LocaleKeys.text_medicalCheckUp.tr(),
          "subtitle": LocaleKeys.text_getToKnowYourHealthCondition.tr(),
          "icon": Assets.icons.tint.mcu.svg(
            height: BaseSize.h40,
            width: BaseSize.h40,
          ),
          "route": AppRoute.bookMcu,
        },
        {
          "title": LocaleKeys.text_laboratory.tr(),
          "subtitle": LocaleKeys.text_labTestsInNearestHospital.tr(),
          "icon": Assets.icons.tint.breaker.svg(),
          "route": AppRoute.bookLaboratory,
        },
        {
          "title": LocaleKeys.text_radiology.tr(),
          "subtitle": LocaleKeys.text_detectConditionsInYourBody.tr(),
          "icon": Assets.icons.tint.xRay.svg(
            height: BaseSize.h40,
            width: BaseSize.h40,
          ),
          "route": AppRoute.bookRadiology,
        },
      ],
    },
    {
      "title": LocaleKeys.text_specialisedService.tr(),
      "services": [
        {
          "title": LocaleKeys.text_vaccineImmunization.tr(),
          "subtitle": LocaleKeys.text_increaseTheBodysImmunity.tr(),
          "icon": Assets.icons.tint.drugs.svg(
            height: BaseSize.h40,
            width: BaseSize.h40,
          ),
          "route": AppRoute.bookVaccine,
        },
        {
          "title": LocaleKeys.text_pregnancyExercise.tr(),
          "subtitle": LocaleKeys.text_takeAnExerciseClassForPregnantWomen.tr(),
          "icon": Assets.icons.tint.pregnant.svg(
            height: BaseSize.h40,
            width: BaseSize.h40,
          ),
          "route": AppRoute.bookPregnancy
        },
        {
          "title": LocaleKeys.text_homecare.tr(),
          "subtitle": LocaleKeys.text_getHealthServicesAtThePatientsHome.tr(),
          "icon": Assets.icons.tint.homecare.svg(
            height: BaseSize.h40,
            width: BaseSize.h40,
          ),
          "route": null
        },
        {
          "title": LocaleKeys.text_physiotherapy.tr(),
          "subtitle": LocaleKeys.text_restoreYourMovementAndFunction.tr(),
          "icon": Assets.icons.tint.massage.svg(
            height: BaseSize.h40,
            width: BaseSize.h40,
          ),
          "route": AppRoute.bookPhysiotherapy
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: LocaleKeys.text_othersAppoinment.tr(),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _appointmentServices.length,
        padding: horizontalPadding,
        itemBuilder: (context, index) {
          var services = _appointmentServices[index]['services'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap.h20,
              Text(
                _appointmentServices[index]['title'],
                style: TypographyTheme.bodySemiBold,
              ),
              Gap.h16,
              ...services.map((service) {
                var isLast = services.indexOf(service) == services.length - 1;
                String? routePath = service['route'];
                return Container(
                  padding: EdgeInsets.symmetric(vertical: BaseSize.h8),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: isLast ? 0 : 1,
                              color: BaseColor.neutral.shade10))),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BaseSize.radiusMd)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: BaseSize.w4),
                    onTap: () {
                      if (routePath != null) context.pushNamed(routePath);
                    },
                    leading: Container(
                      clipBehavior: Clip.hardEdge,
                      height: BaseSize.customWidth(56),
                      width: BaseSize.customWidth(56),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: BaseColor.primary1,
                        borderRadius: BorderRadius.circular(
                          BaseSize.customRadius(56),
                        ),
                      ),
                      child: service['icon'],
                    ),
                    title: Text(
                      service['title'],
                      style: TypographyTheme.textLSemiBold
                          .fontColor(BaseColor.neutral.shade80),
                    ),
                    subtitle: Text(
                      service['subtitle'],
                      style: TypographyTheme.textSRegular
                          .fontColor(BaseColor.neutral.shade60),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
