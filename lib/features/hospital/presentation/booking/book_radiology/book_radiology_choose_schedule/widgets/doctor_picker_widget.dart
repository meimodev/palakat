import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorPickerWidget extends StatefulWidget {
  const DoctorPickerWidget({
    super.key,
    required this.doctors,
    required this.onSelectedDoctor,
  });

  final List<Map<String, String>> doctors;
  final void Function(String doctor) onSelectedDoctor;

  @override
  State<DoctorPickerWidget> createState() => _DoctorPickerWidgetState();
}

class _DoctorPickerWidgetState extends State<DoctorPickerWidget> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // doctor picker bottom sheet
        showCustomDialogWidget(
          context,
          title:
              "${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_doctor.tr()}",
          onTap: () {},
          hideButtons: true,
          isScrollControlled: true,
          content: _BuildBottomSheetDoctorPicker(
            onSelectedDoctor: (value) {
              setState(() {
                name = value;
              });
              widget.onSelectedDoctor(value);
            },
            images: widget.doctors.map((doctor) => doctor['image']!).toList(),
            doctors: widget.doctors.map((doctor) => doctor['name']!).toList(),
            specialists:
                widget.doctors.map((doctor) => doctor['specialist']!).toList(),
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
            Assets.icons.line.users.svg(
              width: BaseSize.customWidth(24),
              height: BaseSize.customWidth(24),
              colorFilter: BaseColor.primary3.filterSrcIn,
            ),
            Gap.w12,
            Expanded(
              child: Text(
                name.isEmpty
                    ? "${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_doctor.tr()}"
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

class _BuildBottomSheetDoctorPicker extends StatelessWidget {
  const _BuildBottomSheetDoctorPicker({
    required this.onSelectedDoctor,
    required this.doctors,
    required this.images,
    required this.specialists,
  });

  final void Function(String doctor) onSelectedDoctor;
  final List<String> doctors;
  final List<String> images;
  final List<String> specialists;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: DoctorLookupWidget(),
        ),
        Gap.h16,
        Padding(
          padding: horizontalPadding,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            separatorBuilder: (_, __) => Gap.h8,
            shrinkWrap: true,
            itemCount: doctors.length,
            itemBuilder: (context, index) => _buildListItem(
              text: doctors[index],
              image: images[index],
              specialist: specialists[index],
              onTap: () {
                onSelectedDoctor(doctors[index]);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListItem({
    required String image,
    required String text,
    required String specialist,
    required void Function() onTap,
  }) {
    return DoctorListItemWidget(
        name: text, onTap: onTap, image: image, specialist: specialist);
  }
}

// Column(
//   children: [
//     InkWell(
//       borderRadius: BorderRadius.circular(BaseSize.radiusLg),
//       onTap: onTap,
//       child: Row(
//         children: [
//           ImageNetworkWidget(
//             imageUrl: image,
//             fit: BoxFit.cover,
//             width: BaseSize.customWidth(65),
//             height: BaseSize.customWidth(65),
//           ),
//           Gap.w12,
//           Text(
//             text,
//           ),
//         ],
//       ),
//     ),
//     Gap.h8,
//     const HLineDivider(),
//     Gap.h8,
//   ],
// );