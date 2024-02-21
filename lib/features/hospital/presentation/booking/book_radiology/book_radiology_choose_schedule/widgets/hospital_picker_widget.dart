import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class HospitalPickerWidget extends StatefulWidget {
  const HospitalPickerWidget({
    super.key,
    required this.hospitals,
    required this.onSelectedHospital,
  });

  final List<String> hospitals;
  final void Function(String hospital) onSelectedHospital;

  @override
  State<HospitalPickerWidget> createState() => _HospitalPickerWidgetState();
}

class _HospitalPickerWidgetState extends State<HospitalPickerWidget> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // hospital picker bottom sheet
        showCustomDialogWidget(
          context,
          title: "Choose Hospital",
          onTap: () {},
          hideButtons: true,
          isScrollControlled: true,
          content: _BuildBottomSheetHospitalPicker(
            onSelectedHospital: (value) {
              setState(() {
                name = value;
              });
              widget.onSelectedHospital(value);
            },
            hospitals: widget.hospitals,
          ),
        );
      },
      borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h24,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: BaseColor.neutral.shade20,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        ),
        child: Row(
          children: [
            Assets.icons.line.hospital3.svg(
              width: BaseSize.customWidth(24),
              height: BaseSize.customWidth(24),
              colorFilter: BaseColor.primary3.filterSrcIn,
            ),
            Gap.w12,
            Expanded(
              child: Text(
                name.isEmpty
                    ? "${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_hospital.tr()}"
                    : name,
                style: TypographyTheme.bodySemiBold.fontColor(
                  name.isEmpty
                      ? BaseColor.neutral.shade60
                      : BaseColor.neutral.shade80,
                ),
              ),
            ),
            Assets.icons.line.chevronRight.svg(
              width: BaseSize.customWidth(24),
              height: BaseSize.customWidth(24),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildBottomSheetHospitalPicker extends StatelessWidget {
  const _BuildBottomSheetHospitalPicker({
    required this.onSelectedHospital,
    required this.hospitals,
  });

  final void Function(String hospital) onSelectedHospital;
  final List<String> hospitals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: horizontalPadding,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: hospitals.length,
        itemBuilder: (context, index) => _buildListItem(
          text: hospitals[index],
          onTap: () {
            onSelectedHospital(hospitals[index]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildListItem({
    required String text,
    required void Function() onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.h20,
          Text(
            text,
          ),
          Gap.h20,
          Container(
            height: 1,
            color: BaseColor.neutral.shade10,
          )
        ],
      ),
    );
  }
}
