import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'widgets/widgets.dart';

// TODO: REMOVE WHEN WANT TO INTEGRATE
List<BookServiceModel> _serviceList = [
  BookServiceModel(
    category: "CT Scan",
    name: "CT Scan Upper Abdomen",
    locations: "RSH Kemayoran, RSH Podomoro, 1+",
    price: "Rp. 2.000.000",
  ),
  BookServiceModel(
      category: "CT Scan",
      name: "CT Scan Brain",
      locations: "RSH Podomoro",
      price: "Rp. 10.000.000",
      discountPrice: "Rp. 15.000.000"),
  BookServiceModel(
    category: "Rontgen",
    name: "Rontgen Product 1",
    locations: "RSH Kemayoran, RSH Podomoro, 1+",
    price: "Rp. 9.000.000",
  ),
  BookServiceModel(
    category: "MRI / MRA",
    name: "Service for MRI / MRA",
    locations: "RSH Kemayoran, RSH Podomoro, 1+",
    price: "Rp. 2.000.000",
  ),
  BookServiceModel(
    category: "Rontgen",
    name: "Service for Rontgen",
    locations: "RSH Kemayoran, RSH Podomoro, 1+",
    price: "Rp. 100.000.000",
    discountPrice: "Rp. 900.000.000",
  ),
];

List<String> _serviceListCategories =
    _serviceList.map((e) => e.category).toSet().toList();

final List<String> _services = [
  "CT Scan",
  "MRI / MRA",
  "Rontgen / X-Ray",
  "USG",
];

final List<String> _hospitals = [
  "RSH Bogor",
  "RSH Daan Mogot",
  "RSH Grand Wisata",
  "RSH Kemayoran",
  "RSH Periuk Tanggerang",
  "RSH Podomoro",
  "RSH Serpong",
  "RSH Tanggerang",
];

class BookRadiologyListScreen extends ConsumerWidget {
  const BookRadiologyListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = ref.read(DoctorListControllerProvider.notifier);
    // final state = ref.watch(DoctorListControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      appBar: AppBarWidget(
        backIconColor: BaseColor.primary3,
        titleColor: BaseColor.primary3,
        backgroundColor: Colors.transparent,
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_radiology.tr(),
        actions: [
          // BottomSheetFilterWidget(
          //   hospitals: _hospitals,
          //   services: _services,
          //   maxPrice: 1000000,
          //   showGenderOption: true,
          //   onPressedSubmit: (
          //     List<String> service,
          //     List<String> hospital,
          //     Gender? gender,
          //     RangeValues priceRange,
          //   ) {
          //     print("service $service "
          //         "hospital $hospital"
          //         "gender $gender "
          //         "priceRange $priceRange");
          //   },
          // ),
          Gap.w16,
          BottomSheetSortWidget(
            onSelectedSort: (String value) {
              print(value);
            },
          ),
          Gap.w16,
          GestureDetector(
            child: Assets.icons.line.search.svg(
              width: BaseSize.w24,
              height: BaseSize.w24,
              colorFilter: BaseColor.primary3.filterSrcIn,
            ),
            onTap: () {},
          ),
        ],
      ),
      child: BookListScreenWidget(
        categories: _serviceListCategories,
        services: _serviceList,
        onChangedHorizontalFilter: (String? filter) {
          print("on selected filter $filter");
        },
        onTapListItem: () {
          context.pushNamed(AppRoute.bookRadiologyDetail);
        },
      ),
    );
  }
}
