import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/features/presentation.dart';

class ServiceListWidget extends StatelessWidget {
  const ServiceListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ServiceItemWidget(
            icon: Assets.icons.tint.mcu,
            title: LocaleKeys.text_mcuAppointment.tr(),
            onTap: () {
              context.pushNamed(AppRoute.bookMcu);
            },
          ),
        ),
        Gap.w8,
        Expanded(
          child: ServiceItemWidget(
            icon: Assets.icons.tint.breaker,
            title: LocaleKeys.text_laboratoryAppointment.tr(),
            onTap: () {
              context.pushNamed(AppRoute.bookLaboratory);
            },
          ),
        ),
        Gap.w8,
        Expanded(
          child: ServiceItemWidget(
            icon: Assets.icons.tint.xRay,
            title: LocaleKeys.text_radiologyAppointment.tr(),
            onTap: () {
              context.pushNamed(AppRoute.bookRadiology);
            },
          ),
        ),
        Gap.w8,
        Expanded(
          child: ServiceItemWidget(
            icon: Assets.icons.tint.category,
            title: LocaleKeys.text_othersAppoinment.tr(),
            onTap: () {
              context.pushNamed(AppRoute.appointmentServiceList);
            },
          ),
        ),
      ],
    );
  }
}
