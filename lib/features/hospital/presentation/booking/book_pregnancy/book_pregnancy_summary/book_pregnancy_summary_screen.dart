import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

//Dummy Data
String _hospitalName = "RSH Kemayoran";
String _schedule = "Thu, 16 Mar 2023 | 13:30 - 14:00";
String _package = "Booster Vitamin C + Multivitamin";
String _service = "Beauty & Personal Care";

class BookPregnancySummaryScreen extends ConsumerWidget {
  const BookPregnancySummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = ref.watch(choosePatientControllerProvider.notifier);
    // final state = ref.watch(choosePatientControllerProvider);
    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_appointmentSummary.tr(),
      ),
      child: BookSummaryWidget(
        hospital: _hospitalName,
        dateTime: _schedule,
        package: _package,
        service: _service,
        // onSelectedPatient: (name, gender, dob, phone, registered) {
        //   print("$name $gender $dob $phone $registered");
        // },
        // onSelectedPaymentType: (type) {
        //   print(type.name);
        // },
        onPressedConfirm: () {
          context.pushNamed(AppRoute.bookPregnancyGeneralConsent);
        },
      ),
    );
  }
}
