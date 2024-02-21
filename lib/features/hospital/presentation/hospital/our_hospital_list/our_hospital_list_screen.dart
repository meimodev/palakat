import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/hospital/domain/hospital_list_item.dart';
import 'package:halo_hermina/features/hospital/presentation/hospital/our_hospital_list/widgets/widgets.dart';

List<HospitalListItem> ourHospitals = [
  HospitalListItem(
    name: "Hermina Kemayoran",
    location: "DKI Jakarta",
    imageUrl: "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e",
    distance: "2.3 Km",
  ),
  HospitalListItem(
    name: "Hermina Kemayoran",
    location: "DKI Jakarta",
    imageUrl: "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e",
    distance: "12.1 Km",
  ),
  HospitalListItem(
    name: "Hermina Kemayoran",
    location: "DKI Jakarta",
    imageUrl: "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e",
    distance: "13.5 Km",
  ),
  HospitalListItem(
    name: "Hermina Kemayoran",
    location: "DKI Jakarta",
    imageUrl: "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e",
    distance: "10 Km",
  ),
  HospitalListItem(
    name: "Hermina Kemayoran",
    location: "DKI Jakarta",
    imageUrl: "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e",
    distance: "10 Km",
  ),
  HospitalListItem(
    name: "Hermina Kemayoran",
    location: "DKI Jakarta",
    imageUrl: "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e",
    distance: "10 Km",
  ),
  HospitalListItem(
    name: "Hermina Kemayoran",
    location: "DKI Jakarta",
    imageUrl: "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e",
    distance: "10 Km",
  ),
];

class OurHospitalListScreen extends ConsumerWidget {
  const OurHospitalListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_ourHospital.tr(),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Assets.icons.line.search
                .svg(width: BaseSize.w24, height: BaseSize.w24),
          ),
        ],
      ),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: ourHospitals.length,
        padding: horizontalPadding,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(
            top: BaseSize.customHeight(20),
          ),
          child: OurHospitalListItemWidget(
            item: ourHospitals[index],
            onPressedItem: (value) =>
                context.pushNamed(AppRoute.ourHospitalDetail),
          ),
        ),
      ),
    );
  }
}
