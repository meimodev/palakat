import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_summary/widgets/widgets.dart';

class MedicineOptionsWidget extends StatefulWidget {
  const MedicineOptionsWidget({super.key, required this.onSelectedMedicine});

  final Function(bool medicine) onSelectedMedicine;

  @override
  State<MedicineOptionsWidget> createState() => _MedicineOptionsWidgetState();
}

class _MedicineOptionsWidgetState extends State<MedicineOptionsWidget> {
  bool? selectedOption = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                selectedOption = true;
                widget.onSelectedMedicine(selectedOption!);
                print("inkwell Take All Medicine $selectedOption");
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.text_takeAllMedicine.tr(),
                  style: TypographyTheme.textLRegular.toNeutral80,
                ),
                RadioWidget.primary(
                  value: true,
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                      widget.onSelectedMedicine(selectedOption!);
                      print("Take All Medicine : $value");
                    });
                  },
                ),
              ],
            ),
          ),
          Gap.h4,
          const HLineDivider(),
          Gap.h4,
          InkWell(
            onTap: () {
              setState(() {
                selectedOption = false;
                widget.onSelectedMedicine(selectedOption!);
                print("inkwell Medicine Consideration $selectedOption");
              });
            },
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.text_medicineConsideration.tr(),
                      style: TypographyTheme.textLRegular.toNeutral80,
                    ),
                    RadioWidget.primary(
                      value: false,
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                          widget.onSelectedMedicine(selectedOption!);
                          print("Take All Medicine : $value");
                        });
                      },
                    ),
                  ],
                ),
                Gap.h4,
                Text(
                  LocaleKeys
                      .text_ifThereArePrescriptionConsiderationPleaseVisitPharmacy
                      .tr(),
                  style: TypographyTheme.textXSRegular.toNeutral50,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
