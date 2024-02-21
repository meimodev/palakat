import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/domain.dart';

List<BookServiceModel> _serviceList = [
  BookServiceModel(
    category: "Beauty & Personal Care",
    name: "Booster Vitamin C + Multivitamin",
    locations: "RSH Kemayoran, RSH Podomoro, 1+",
    price: "Rp 260.000",
  ),
  BookServiceModel(
    category: "Screening",
    name: "Blood Sugar Screening",
    locations: "RSH Podomoro",
    price: "Rp 249.000",
    discountPrice: "Rp 300.000",
  ),
  BookServiceModel(
    category: "Beauty & Personal Care",
    name: "Aquapure Serum",
    locations: "RSH Kemayoran, RSH Podomoro, 1+",
    price: "Rp 260.000",
  ),
  BookServiceModel(
    category: "Screening",
    name: "Liver Function Screening",
    locations: "RSH Kemayoran, RSH Podomoro, 1+",
    price: "Rp 690.000",
    discountPrice: "Rp 749.000",
  ),
  BookServiceModel(
    category: "Screening",
    name: "Simple Breast Cancer Screening",
    locations: "RSH Kemayoran, RSH Podomoro, 1+",
    price: "Rp 355.000",
  ),
];

List<String> _serviceListCategories =
    _serviceList.map((e) => e.category).toSet().toList();

final List<String> _services = [
  "Beauty & Personal Care",
  "Screening",
  "Dental Wellness",
  "General Check Up",
  "Health & Fitness",
  "Premarital Check Up",
  "Holiday Check Up",
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

class BookMcuListScreen extends ConsumerWidget {
  const BookMcuListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      appBar: AppBarWidget(
        backIconColor: BaseColor.primary3,
        titleColor: BaseColor.primary3,
        backgroundColor: Colors.transparent,
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_medicalCheckUp.tr(),
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
          context.pushNamed(AppRoute.bookMcuDetail);
        },
      ),
    );
  }
}
