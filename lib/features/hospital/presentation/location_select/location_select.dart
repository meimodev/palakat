import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

Future showLocationSelect(
  BuildContext context, {
  String title = '',
  Location? selectedValue,
  required Function(Location) onSaveValue,
  bool showSearch = true,
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
      return LocationSelect(
        onSaveValue: onSaveValue,
        title: title,
        selectedValue: selectedValue,
        showSearch: showSearch,
      );
    },
  );
}

class LocationSelect extends ConsumerStatefulWidget {
  final Location? selectedValue;
  final Function(Location) onSaveValue;
  final String title;
  final bool showSearch;
  const LocationSelect({
    Key? key,
    this.title = '',
    required this.selectedValue,
    required this.onSaveValue,
    this.showSearch = true,
  }) : super(key: key);
  @override
  ConsumerState<LocationSelect> createState() => _LocationSelectState();
}

class _LocationSelectState extends ConsumerState<LocationSelect> {
  LocationSelectController get controller =>
      ref.read(locationSelectControllerProvider.notifier);
  @override
  void initState() {
    super.initState();
    safeRebuild(() {
      controller.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationSelectControllerProvider);
    if (state.initScreen == true) {
      return SelectSingleWidget<Location>(
        heightPercentage: 70,
        title: widget.title,
        options: state.data,
        getLabel: (val) => val.name,
        getValue: (val) => val.serial,
        preOptions: state.nearests,
        getPreTitle: LocaleKeys.text_nearest.tr(),
        getPreLabel: (val) => val.name,
        onSave: widget.onSaveValue,
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
