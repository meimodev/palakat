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

String _category = "Service B";
String _name = "Transcutaneous electrical nerve stimulation (TENS) therapy";
String _price = "Rp 249.000";
String _discountPrice = "Rp 300.000";
String _information =
    "It is a technique wherein a small battery-driven device is used to send low-grade current through the electrodes placed on the skin surface. A TENS device temporarily relieves the pain of the affected area.";
String _termsAndCondition =
    "The patient has correctly chosen the package for examination and the package cannot be changed once payment has been made";
List<String> _preparation = [
  "No preparation required",
];

class BookPhysiotherapyDetailScreen extends ConsumerWidget {
  const BookPhysiotherapyDetailScreen({
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
        discountPrice: _discountPrice,
        information: _information,
        preparation: _preparation,
        termsAndCondition: _termsAndCondition,
        onPressedBookNow: () =>
            context.pushNamed(AppRoute.bookPhysiotherapyChooseSchedule),
      ),
    );
  }
}
