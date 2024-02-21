import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientFormAddressStepWidget extends ConsumerWidget {
  const PatientFormAddressStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(patientFormControllerProvider.notifier);
    final state = ref.watch(patientFormControllerProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      InputFormWidget(
        controller: controller.addressController,
        hintText: LocaleKeys.text_address.tr(),
        hasIconState: false,
        label: LocaleKeys.text_address.tr(),
        keyboardType: TextInputType.text,
        hasBorderState: false,
        onChanged: (_) => controller.clearError("address"),
        error: state.errors['address'],
      ),
      Gap.h32,
      Row(
        children: [
          Expanded(
            child: InputFormWidget(
              controller: controller.rtNumberController,
              hintText: LocaleKeys.text_rt.tr(),
              hasIconState: false,
              label: LocaleKeys.text_rt.tr(),
              keyboardType: TextInputType.number,
              hasBorderState: false,
              onChanged: (_) => controller.clearError("rtNumber"),
              error: state.errors['rtNumber'],
            ),
          ),
          Gap.w24,
          Expanded(
            child: InputFormWidget(
              controller: controller.rwNumberController,
              hintText: LocaleKeys.text_rw.tr(),
              hasIconState: false,
              label: LocaleKeys.text_rw.tr(),
              keyboardType: TextInputType.number,
              hasBorderState: false,
              onChanged: (_) => controller.clearError("rwNumber"),
              error: state.errors['rwNumber'],
            ),
          )
        ],
      ),
      Gap.h32,
      InputFormWidget.dropdown(
        controller: controller.provinceController,
        hintText: LocaleKeys.text_province.tr(),
        hasIconState: false,
        label: LocaleKeys.text_province.tr(),
        onBodyTap: () {
          showGeneralDataSelect(context,
              title: LocaleKeys.text_province.tr(),
              category: GeneralDataKey.state,
              selectedValue: state.selectedProvince,
              onSave: controller.onProvinceChange);
        },
        onChanged: (_) => controller.clearError("provinceSerial"),
        error: state.errors['provinceSerial'],
      ),
      Gap.h32,
      InputFormWidget.dropdown(
        controller: controller.cityController,
        hintText: LocaleKeys.text_city.tr(),
        hasIconState: false,
        label: LocaleKeys.text_city.tr(),
        onBodyTap: () {
          showGeneralDataSelect(context,
              title: LocaleKeys.text_city.tr(),
              category: GeneralDataKey.city,
              selectedValue: state.selectedCity,
              onSave: controller.onCityChange);
        },
        onChanged: (_) => controller.clearError("citySerial"),
        error: state.errors['citySerial'],
      ),
      Gap.h32,
      InputFormWidget.dropdown(
        controller: controller.districtController,
        hintText: LocaleKeys.text_district.tr(),
        hasIconState: false,
        label: LocaleKeys.text_district.tr(),
        onBodyTap: () {
          showGeneralDataSelect(context,
              title: LocaleKeys.text_district.tr(),
              category: GeneralDataKey.district,
              selectedValue: state.selectedDistrict,
              onSave: controller.onDistrictChange);
        },
        onChanged: (_) => controller.clearError("districtSerial"),
        error: state.errors['districtSerial'],
      ),
      Gap.h32,
      InputFormWidget.dropdown(
        controller: controller.villageController,
        hintText: LocaleKeys.text_village.tr(),
        hasIconState: false,
        label: LocaleKeys.text_village.tr(),
        onBodyTap: () {
          showGeneralDataSelect(context,
              title: LocaleKeys.text_village.tr(),
              category: GeneralDataKey.village,
              selectedValue: state.selectedVillage,
              onSave: controller.onVillageChange);
        },
        onChanged: (_) => controller.clearError("villageSerial"),
        error: state.errors['villageSerial'],
      ),
      Gap.h32,
      InputFormWidget(
        controller: controller.postalCodeController,
        hintText: LocaleKeys.text_postalCode.tr(),
        hasIconState: false,
        label: LocaleKeys.text_postalCode.tr(),
        keyboardType: TextInputType.number,
        hasBorderState: false,
        onChanged: (_) => controller.clearError("postalCode"),
        error: state.errors['postalCode'],
      ),
      Gap.h32,
    ]);
  }
}
