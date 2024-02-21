import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

Future showHospitalsSelect(
  BuildContext context, {
  String title = '',
  List<Hospital> selectedValue = const [],
  required Function(List<Hospital>) onSave,
  bool showSearch = true,
  String? doctorSerial,
  List<String>? serials,
}) {
  return showModalBottomSheet<dynamic>(
    isScrollControlled: true,
    context: context,
    isDismissible: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BaseSize.customRadius(16)),
      ),
    ),
    builder: (context) {
      return HospitalSelect(
        onSaveValues: onSave,
        title: title,
        selectedValues: selectedValue,
        showSearch: showSearch,
        type: SelectType.multiple,
        doctorSerial: doctorSerial,
      );
    },
  );
}

Future showHospitalSelect(
  BuildContext context, {
  String title = '',
  Hospital? selectedValue,
  required Function(Hospital) onSave,
  bool showSearch = true,
  bool withNearest = false,
  String? doctorSerial,
}) {
  return showModalBottomSheet<dynamic>(
    isScrollControlled: true,
    context: context,
    isDismissible: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BaseSize.customRadius(16)),
      ),
    ),
    builder: (context) {
      return HospitalSelect(
        onSaveValue: onSave,
        title: title,
        selectedValue: selectedValue,
        showSearch: showSearch,
        type: withNearest ? SelectType.singleWithNearest : SelectType.single,
      );
    },
  );
}

class HospitalSelect extends ConsumerStatefulWidget {
  final List<Hospital> selectedValues;
  final Function(List<Hospital>)? onSaveValues;
  final Hospital? selectedValue;
  final Function(Hospital)? onSaveValue;
  final String title;
  final bool showSearch;
  final SelectType type;
  final String? doctorSerial;
  final List<String>? serials;
  const HospitalSelect({
    Key? key,
    this.title = '',
    this.selectedValues = const [],
    this.onSaveValues,
    this.selectedValue,
    this.onSaveValue,
    this.showSearch = true,
    this.type = SelectType.single,
    this.doctorSerial,
    this.serials,
  }) : super(key: key);
  @override
  ConsumerState<HospitalSelect> createState() => _HospitalSelectState();
}

class _HospitalSelectState extends ConsumerState<HospitalSelect> {
  HospitalSelectController get controller =>
      ref.read(hospitalSelectControllerProvider.notifier);
  @override
  void initState() {
    super.initState();
    safeRebuild(() {
      controller.init(widget.type, widget.doctorSerial, widget.serials);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hospitalSelectControllerProvider);
    if (state.initScreen == true) {
      if (widget.type == SelectType.multiple) {
        return SelectMultipleWidget<Hospital>(
          title: widget.title,
          options: state.data,
          getLabel: (val) => val.name,
          getValue: (val) => val.serial,
          onSave: widget.onSaveValues!,
          isLoadingBottom: state.hasMore,
          isLoading: state.isLoading,
          onRefresh: controller.handleRefresh,
          onEdgeBottom: controller.handleGetMore,
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

      return SelectSingleWidget<Hospital>(
        heightPercentage: 70,
        title: widget.title,
        options: state.data,
        getLabel: (val) => val.name,
        getValue: (val) => val.serial,
        preOptions: state.nearests,
        getPreTitle: LocaleKeys.text_nearest.tr(),
        getPreLabel: (val) => val.name,
        onSave: widget.onSaveValue!,
        isLoading: state.isLoading,
        isLoadingBottom: state.hasMore,
        selectedValue: widget.selectedValue,
        onRefresh: controller.handleRefresh,
        onEdgeBottom: controller.handleGetMore,
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
