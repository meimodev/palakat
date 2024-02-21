import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

Future showAppointmentTypeSelect(
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
      return AppointmentTypeSelect(
        onSave: onSave,
        title: title,
        selectedValue: selectedValue,
        showSearch: showSearch,
      );
    },
  );
}

class AppointmentTypeSelect extends ConsumerStatefulWidget {
  final List<SerialName> selectedValue;
  final Function(List<SerialName>) onSave;
  final String title;
  final bool showSearch;
  const AppointmentTypeSelect({
    Key? key,
    this.title = '',
    required this.selectedValue,
    required this.onSave,
    this.showSearch = true,
  }) : super(key: key);
  @override
  ConsumerState<AppointmentTypeSelect> createState() =>
      _AppointmentTypeSelectState();
}

class _AppointmentTypeSelectState extends ConsumerState<AppointmentTypeSelect> {
  AppointmentTypeSelectController get controller =>
      ref.read(appointmentTypeSelectControllerProvider.notifier);
  @override
  void initState() {
    super.initState();
    safeRebuild(() {
      controller.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentTypeSelectControllerProvider);
    if (state.initScreen == true) {
      return SelectMultipleWidget<SerialName>(
        title: widget.title,
        pagingController: controller.pagingController,
        options: const [],
        getLabel: (val) => val.name,
        getValue: (val) => val.serial,
        onSave: widget.onSave,
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
