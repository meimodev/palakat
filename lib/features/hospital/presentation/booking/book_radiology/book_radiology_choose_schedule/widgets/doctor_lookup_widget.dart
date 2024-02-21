import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/hospital/domain/doctor.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorLookupWidget extends ConsumerWidget {
  const DoctorLookupWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(bookVaccineChooseScheduleControllerProvider.notifier);

    return Container();

    //   return Autocomplete<Doctor>(
    //     optionsBuilder: (TextEditingValue textEditingValue) async {
    //       controller.setSearchValue(textEditingValue.text);
    //       final Iterable<Doctor> options =
    //           await _DummyAPI.search(textEditingValue.text);

    //       return options;
    //     },
    //     fieldViewBuilder:
    //         (context, textEditingController, focusNode, onFieldSubmitted) {
    //       return TextField(
    //         controller: textEditingController,
    //         focusNode: focusNode,
    //         onEditingComplete: onFieldSubmitted,
    //         decoration: InputDecoration(
    //           prefixIcon: IconButton(
    //               onPressed: () {},
    //               icon: Assets.icons.line.search.svg(
    //                 width: 20.0,
    //                 height: 20.0,
    //                 colorFilter: BaseColor.neutral.shade40.filterSrcIn,
    //               )),
    //           hintText: LocaleKeys.text_search.tr(),
    //           hintStyle: TypographyTheme.textLRegular
    //               .fontColor(BaseColor.neutral.shade50),
    //           enabledBorder: UnderlineInputBorder(
    //               borderRadius: BorderRadius.circular(12),
    //               borderSide:
    //                   BorderSide(color: BaseColor.neutral.shade30, width: 1)),
    //         ),
    //       );
    //     },
    //     optionsViewBuilder: (context, onSelected, options) {
    //       return Padding(
    //         padding: EdgeInsets.only(right: BaseSize.w28),
    //         child: Material(
    //             child: Container(
    //           decoration: const BoxDecoration(
    //             color: BaseColor.white,
    //           ),
    //           child: ListView.separated(
    //               padding: EdgeInsets.zero,
    //               itemCount: options.length,
    //               separatorBuilder: (_, __) => Gap.h4,
    //               itemBuilder: (BuildContext context, int index) {
    //                 final doctor = options.elementAt(index);
    //                 return DoctorListItemWidget(
    //                   name: doctor.name,
    //                   onTap: () => onSelected(doctor),
    //                   specialist: doctor.specialist,
    //                   image: doctor.image,
    //                 );
    //               }),
    //         )),
    //       );
    //     },
    //     onSelected: (Doctor selection) {
    //       debugPrint(selection.name);
    //     },
    //     displayStringForOption: (doctor) => doctor.name,
    //   );
  }
}
