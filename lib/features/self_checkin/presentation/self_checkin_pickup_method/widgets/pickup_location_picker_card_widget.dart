import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class PickUpLocationPickerCardWidget extends StatefulWidget {
  const PickUpLocationPickerCardWidget({
    super.key,
    required this.onSelectedLocation,
    required this.locations,
    this.selectedLocation,
  });

  final void Function(String value) onSelectedLocation;
  final List<String> locations;
  final String? selectedLocation;

  @override
  State<PickUpLocationPickerCardWidget> createState() =>
      _PickUpLocationPickerCardWidgetState();
}

class _PickUpLocationPickerCardWidgetState
    extends State<PickUpLocationPickerCardWidget> {
  late String selectedLocation = widget.selectedLocation ?? '';

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: () {
        showSelectSingleWidget<String>(
          context,
          title: LocaleKeys.text_chooseLocationPharmacy.tr(),
          options: widget.locations,
          getValue: (String option) => option,
          getLabel: (String option) => option,
          onSave: (String value) {
            setState(() {
              selectedLocation = value;
            });
            widget.onSelectedLocation(value);
          },
        );
      },
      content: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedLocation.isEmpty
                  ? LocaleKeys.text_chooseLocationPharmacy.tr()
                  : selectedLocation,
              style: TypographyTheme.textMSemiBold.toNeutral80,
            ),
            Assets.icons.line.chevronRight.svg(
              width: BaseSize.w24,
              height: BaseSize.h24,
            ),
          ],
        ),
      ],
    );
  }
}
