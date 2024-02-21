import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

Future showDoctorSelect(
  BuildContext context, {
  String title = '',
  bool isDissmissible = true,
  List<Doctor> selectedValue = const [],
  required Function(List<Doctor>) onSave,
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
      return DoctorSelect(
        onSave: onSave,
        title: title,
        selectedValue: selectedValue,
        showSearch: showSearch,
      );
    },
  );
}

class DoctorSelect extends ConsumerStatefulWidget {
  final List<Doctor> selectedValue;
  final Function(List<Doctor>) onSave;
  final String title;
  final bool showSearch;
  const DoctorSelect({
    Key? key,
    this.title = '',
    required this.selectedValue,
    required this.onSave,
    this.showSearch = true,
  }) : super(key: key);
  @override
  ConsumerState<DoctorSelect> createState() => _DoctorSelectState();
}

class _DoctorSelectState extends ConsumerState<DoctorSelect> {
  DoctorSelectController get controller =>
      ref.read(doctorSelectControllerProvider.notifier);
  @override
  void initState() {
    super.initState();
    safeRebuild(() {
      controller.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorSelectControllerProvider);
    if (state.initScreen == true) {
      return SelectMultipleWidget<Doctor>(
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
