import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';

import 'widgets.dart';

class PatientAndCompanionSegmentWidget extends ConsumerWidget {
  const PatientAndCompanionSegmentWidget({
    super.key,
    required this.morningMenus,
    required this.afternoonMenus,
    required this.eveningMenus,
    required this.onChangedMorningRadioGroup,
    required this.onChangedAfternoonRadioGroup,
    required this.onChangedEveningRadioGroup,
    this.selectedMorningValue = "",
    this.selectedAfternoonValue = "",
    this.selectedEveningValue = "",
  });

  final List<Map<String, dynamic>> morningMenus;
  final List<Map<String, dynamic>> afternoonMenus;
  final List<Map<String, dynamic>> eveningMenus;

  final void Function(String value) onChangedMorningRadioGroup;
  final void Function(String value) onChangedAfternoonRadioGroup;
  final void Function(String value) onChangedEveningRadioGroup;

  final String selectedMorningValue;
  final String selectedAfternoonValue;
  final String selectedEveningValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        MenuListRadioGroupWidget(
          initialValue: selectedMorningValue,
          title: LocaleKeys.text_morning.tr(),
          subTitle: LocaleKeys.text_selectOneMealForMorning.tr(),
          menus: morningMenus,
          onChangedRadioValue: onChangedMorningRadioGroup,
        ),
        Gap.h24,
        MenuListRadioGroupWidget(
          initialValue: selectedAfternoonValue,
          title: LocaleKeys.text_afternoon.tr(),
          subTitle: LocaleKeys.text_selectOneMealForAfternoon.tr(),
          menus: afternoonMenus,
          onChangedRadioValue: onChangedAfternoonRadioGroup,
        ),
        Gap.h24,
        MenuListRadioGroupWidget(
          initialValue: selectedEveningValue,
          title: LocaleKeys.text_evening.tr(),
          subTitle: LocaleKeys.text_selectOneMealForEvening.tr(),
          menus: eveningMenus,
          onChangedRadioValue: onChangedEveningRadioGroup,
        ),
      ],
    );
  }
}
