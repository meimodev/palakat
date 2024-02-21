import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

Future showSpecialistsSelect(
  BuildContext context, {
  String title = '',
  bool isDissmissible = true,
  List<SerialName> selectedValue = const [],
  required Function(List<SerialName>) onSave,
  bool showSearch = true,
}) {
  return showModalBottomSheet<dynamic>(
    isScrollControlled: true,
    context: context,
    isDismissible: isDissmissible,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BaseSize.customRadius(16)),
      ),
    ),
    builder: (context) {
      return SpecialistSelect(
        onSaveValues: onSave,
        title: title,
        selectedValues: selectedValue,
        showSearch: showSearch,
      );
    },
  );
}

Future showSpecialistSelect(
  BuildContext context, {
  String title = '',
  bool isDissmissible = true,
  SerialName? selectedValue,
  required Function(SerialName) onSave,
  bool showSearch = true,
}) {
  return showModalBottomSheet<dynamic>(
    isScrollControlled: true,
    context: context,
    isDismissible: isDissmissible,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BaseSize.customRadius(16)),
      ),
    ),
    builder: (context) {
      return SpecialistSelect(
        onSaveValue: onSave,
        title: title,
        selectedValue: selectedValue,
        showSearch: showSearch,
        isMultiple: false,
      );
    },
  );
}

class SpecialistSelect extends ConsumerStatefulWidget {
  final List<SerialName> selectedValues;
  final Function(List<SerialName>)? onSaveValues;
  final SerialName? selectedValue;
  final Function(SerialName)? onSaveValue;
  final String title;
  final bool showSearch;
  final bool isMultiple;
  const SpecialistSelect({
    Key? key,
    this.title = '',
    this.selectedValues = const [],
    this.onSaveValues,
    this.selectedValue,
    this.onSaveValue,
    this.showSearch = true,
    this.isMultiple = true,
  }) : super(key: key);
  @override
  ConsumerState<SpecialistSelect> createState() => _SpecialistSelectState();
}

class _SpecialistSelectState extends ConsumerState<SpecialistSelect> {
  SpecialistSelectController get controller =>
      ref.read(specialistSelectControllerProvider.notifier);
  @override
  void initState() {
    super.initState();
    safeRebuild(() {
      controller.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(specialistSelectControllerProvider);
    if (state.initScreen == true) {
      if (widget.isMultiple) {
        return SelectMultipleWidget<SerialName>(
          title: widget.title,
          pagingController: controller.pagingController,
          options: const [],
          getLabel: (val) => val.name,
          getValue: (val) => val.serial,
          onSave: widget.onSaveValues!,
          isLoading: false,
          selectedValue: widget.selectedValues,
          extra: widget.showSearch
              ? [
                  Gap.h20,
                  InputSearchWidget(
                    isShowClearButton: true,
                    onTapClear: controller.clearSearch,
                    controller: controller.searchController,
                    hint: LocaleKeys.text_search.tr(),
                    onChanged: controller.onSearchChange,
                  ),
                ]
              : null,
        );
      }

      return SelectSingleWidget<SerialName>(
        heightPercentage: 70,
        title: widget.title,
        pagingController: controller.pagingController,
        options: const [],
        getLabel: (val) => val.name,
        getValue: (val) => val.serial,
        onSave: widget.onSaveValue!,
        isLoading: false,
        selectedValue: widget.selectedValue,
        extra: widget.showSearch
            ? [
                Gap.h20,
                InputSearchWidget(
                  isShowClearButton: true,
                  onTapClear: controller.clearSearch,
                  controller: controller.searchController,
                  hint: LocaleKeys.text_search.tr(),
                  onChanged: controller.onSearchChange,
                ),
              ]
            : null,
      );
    }
    return const SizedBox();
  }
}
