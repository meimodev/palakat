import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';

class DoctorSegmentWidget extends StatelessWidget {
  const DoctorSegmentWidget({
    super.key,
    required this.doctors,
    required this.onPressedDoctorCard,
  });

  final List<Doctor> doctors;
  final void Function(Doctor doctor) onPressedDoctorCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputSearchWidget(
          controller: TextEditingController(),
          hint: LocaleKeys.text_search.tr(),
          suffixIcon: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Assets.icons.line.slider.svg(
              width: BaseSize.w20,
              height: BaseSize.w20,
              colorFilter: BaseColor.neutral.shade50.filterSrcIn,
            ),
            onPressed: () {
              // showDoctorFilterBottomSheet(
              //   context: context,
              //   onPressedSubmitButton: () {},
              // );
            },
          ),
        ),
        Gap.h16,
        // TODO: When integrate hospital
        // ...doctors.map((doctor) {
        //   return Padding(
        //     padding: EdgeInsets.only(bottom: BaseSize.h12),
        //     child: DoctorListItemWidget(
        //         name: doctor['name'],
        //         onTap: () => context.pushNamed(AppRoute.doctorDetail),
        //         hospitals: doctor['location'],
        //         specialist: doctor['specialist'],
        //         image: doctor['image']),
        //   );
        // }).toList()
      ],
    );
  }
}
