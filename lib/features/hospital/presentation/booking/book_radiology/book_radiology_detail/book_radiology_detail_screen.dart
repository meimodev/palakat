import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

import 'widgets/widgets.dart';

// TODO: REMOVE WHEN WANT TO INTEGRATE
String _category = "CT Scan";
String _name = "CT Scan Upper Abdomen (Non Contrast)";
String _price = "Rp. 3.804.000";
String _information =
    "CT scan examination of the upper abdomen and the organs. This examination is useful for detecting abnormalities such as tumors in the abdomen";
String _termsAndCondition =
    "The patient has correctly chosen the package for examination and the package cannot be changed once payment has been made";
List<String> _preparation = [
  "use > 1 element string for preparation with bullet point",
];

class BookRadiologyDetailScreen extends ConsumerWidget {
  const BookRadiologyDetailScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = ref.read(DoctorListControllerProvider.notifier);
    // final state = ref.watch(DoctorListControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_detailPackage.tr(),
        actions: [
          GestureDetector(
            child: Assets.icons.line.share.svg(
              width: BaseSize.w24,
              height: BaseSize.w24,
            ),
            onTap: () => Share.share(title: "title", text: "text"),
          ),
        ],
      ),
      child: BookPackageDetailWidget(
        category: _category,
        name: _name,
        price: _price,
        information: _information,
        preparation: _preparation,
        termsAndCondition: _termsAndCondition,
        onPressedBookNow: () =>
            context.pushNamed(AppRoute.bookRadiologyChooseSchedule),
      ),
    );
  }
}
