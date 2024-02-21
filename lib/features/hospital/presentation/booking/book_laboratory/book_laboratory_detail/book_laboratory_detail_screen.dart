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

String _category = "Blood";
String _name = "Blood Sugar 2 Hours After Eating";
String _price = "Rp 260.000";
String _information =
    "Test to measure blood sugar levels 2 hours after eating, this test is used to detect the efficacy of drugs given after eating. This test is important for detecting diabetes, and monitoring treatment for diabetes patients.";
String _termsAndCondition =
    "The patient has correctly chosen the package for examination and the package cannot be changed once payment has been made";
List<String> _preparation = [
  "This test is generally carried out by taking a blood sample using a syringe from an arm vein",
  "Blood samples will be taken 2 hours after eating",
];

class BookLaboratoryDetailScreen extends ConsumerWidget {
  const BookLaboratoryDetailScreen({
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
            context.pushNamed(AppRoute.bookLaboratoryChooseSchedule),
      ),
    );
  }
}
