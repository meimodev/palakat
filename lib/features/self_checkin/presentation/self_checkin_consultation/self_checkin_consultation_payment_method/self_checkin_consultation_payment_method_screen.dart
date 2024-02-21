import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

import 'widget/widget.dart';

const _htmlDataTermAndCondition = r"""
<body>
    <p>I hereby declare that:</p>
    <ol>
        <li>I have received complete drug information from the doctor</li>
        <li>I have no allergies from the prescribed medication</li>
        <li>The medicine is in accordance with my therapeutic needs</li>
        <li>The medicine I received had the correct patient identity, the correct dosage of the drug, the correct name of the drug, the correct time to take the drug, and the correct method of administration.</li>
    </ol>
    <p>If there is a discrepancy in the future, it will be my personal responsibility and not the responsibility of the Hospital.</p>
</body>
""";

class SelfCheckInConsultationPaymentMethodScreen extends ConsumerWidget {
  const SelfCheckInConsultationPaymentMethodScreen({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      selfCheckInConsultationPaymentMethodControllerProvider,
    );
    final controller = ref.watch(
      selfCheckInConsultationPaymentMethodControllerProvider.notifier,
    );

    return ScaffoldWidget(
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_paymentMethod.tr(),
      ),
      child: PaymentMethodWidget(
        total: state.total,
        serviceFee: state.serviceFee,
        selectedPaymentMethod: state.selectedPaymentMethod,
        onChangedPaymentMethod: controller.onChangedPaymentMethod,
        htmlDataTermAndCondition: _htmlDataTermAndCondition,
        onPressedAgree: () {
          if (state.selectedPaymentMethod == PaymentMethod.cashier) {

            context.popUntilNamedWithResult(
              targetRouteName: AppRoute.selfCheckInConsultationVirtualQueue,
            );
            return;
          }

          context.pushNamed(AppRoute.bookVaccinePaymentComplete);
        },
        onChangedTermsAndConditionCheck: (bool checked) {},
        onPressedTermsAndConditionText: () {},
      ),
    );
  }
}
