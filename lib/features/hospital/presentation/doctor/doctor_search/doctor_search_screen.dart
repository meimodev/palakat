import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorSearchScreen extends ConsumerWidget {
  const DoctorSearchScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(doctorSearchControllerProvider.notifier);
    final state = ref.watch(doctorSearchControllerProvider);

    return ScaffoldWidget(
      resizeToAvoidBottomInset: true,
      type: ScaffoldType.accountGradient,
      appBar: const AppBarWidget(
        backgroundColor: Colors.transparent,
        backIconColor: BaseColor.primary4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: ListView(
            padding: horizontalPadding,
            children: [
              Gap.h12,
              Text(
                LocaleKeys.text_searchDoctor.tr(),
                style:
                    TypographyTheme.heading2Bold.fontColor(BaseColor.primary4),
              ),
              Gap.customGapHeight(10),
              Text(
                LocaleKeys.text_searchForDoctorsLocationsOrSpecialists.tr(),
                style:
                    TypographyTheme.textMRegular.fontColor(BaseColor.primary4),
              ),
              Gap.h52,
              InputFormWidget.dropdown(
                controller: controller.specialistController,
                hintText:
                    '${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_specialist.tr()}',
                hasIconState: false,
                label: LocaleKeys.text_specialist.tr(),
                onBodyTap: () {
                  showSpecialistSelect(
                    context,
                    title: LocaleKeys.text_specialist.tr(),
                    selectedValue: state.specialist,
                    onSave: controller.setSelectedSpecialist,
                    showSearch: true,
                  );
                },
              ),
              Gap.h28,
              InputFormWidget.dropdown(
                controller: controller.locationController,
                hintText:
                    '${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_location.tr()}',
                hasIconState: false,
                label: LocaleKeys.text_location.tr(),
                onBodyTap: () {
                  showLocationSelect(
                    context,
                    title: LocaleKeys.text_location.tr(),
                    selectedValue: state.location,
                    onSaveValue: controller.setSelectedLocation,
                    showSearch: false,
                  );
                },
              ),
              Gap.h28,
              DoctorAutocomplete(
                controller: controller.doctorController,
                hospitalSerial:
                    state.location?.hospitals.map((e) => e.serial).toList(),
                specialistSerial: state.specialist != null
                    ? [state.specialist?.serial ?? ""]
                    : null,
              ),
              Gap.h28,
            ],
          )),
          BottomActionWrapper(
            actionButton: ButtonWidget.primary(
              color: BaseColor.primary3,
              isShrink: true,
              isEnabled:
                  state.location.isNotNull() || state.specialist.isNotNull(),
              text: LocaleKeys.text_search.tr(),
              onTap: () {
                context.pushNamed(
                  AppRoute.doctorList,
                  extra: RouteParam(
                    params: {
                      RouteParamKey.location: state.location,
                      RouteParamKey.specialist: state.specialist,
                      RouteParamKey.doctorName:
                          controller.doctorController.text,
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
