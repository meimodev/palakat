import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class AppointmentAuthorizedLayoutWidget extends StatelessWidget {
  const AppointmentAuthorizedLayoutWidget({
    super.key,
    this.selectedFilter,
    required this.onValueChanged,
  });

  final FilterTab? selectedFilter;
  final void Function(FilterTab value) onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.h12,
        Padding(
          padding: horizontalPadding,
          child: SegmentedControlWidget<FilterTab>(
            value: selectedFilter,
            options: {
              FilterTab.active: LocaleKeys.text_active.tr(),
              FilterTab.past: LocaleKeys.text_past.tr(),
            },
            onValueChanged: onValueChanged,
          ),
        ),
        Gap.h12,
        Flexible(
          child: selectedFilter == FilterTab.active
              ? const ActiveAppointmentListWidget()
              : const PastAppointmentListWidget(),
        )
      ],
    );
  }
}
