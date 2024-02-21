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

String _category = "Influenza";
String _name = "Influenza 4 Strain Vaccine";
String _price = "Rp 350.000";
String _information =
    "Influenza vaccine is a vaccine that can protect you from flu. This vaccine should be given once a year. If this disease attacks the respiratory tract, symptoms that appear can be a dry cough, fever, headache, runny nose, muscle aches, and weakness.";
String _termsAndCondition =
    "The patient has correctly chosen the package for examination and the package cannot be changed once payment has been made";
List<String> _preparation = [
  "Valid for ages 6 months to 65 years",
  "This vaccine is recommended to be done regularly every year to keep the vaccine's protective power normal",
  "Not sick (cough and runny nose)",
];

class BookVaccineDetailScreen extends ConsumerWidget {
  const BookVaccineDetailScreen({
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
            context.pushNamed(AppRoute.bookVaccineChooseSchedule),
      ),
    );
  }
}
