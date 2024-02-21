import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/patient/presentation/patient_portal_activation/widgets/widgets.dart';

import 'widget.dart';

class PaymentMethodWidget extends StatelessWidget {
  const PaymentMethodWidget({
    super.key,
    required this.onChangedPaymentMethod,
    required this.total,
    required this.serviceFee,
    required this.htmlDataTermAndCondition,
    required this.onPressedAgree,
    required this.onChangedTermsAndConditionCheck,
    required this.onPressedTermsAndConditionText,
    required this.selectedPaymentMethod,
  });

  final void Function(PaymentMethod paymentMethod) onChangedPaymentMethod;
  final int total;
  final int serviceFee;
  final PaymentMethod selectedPaymentMethod;

  final String htmlDataTermAndCondition;
  final void Function() onPressedAgree;
  final void Function(bool checked) onChangedTermsAndConditionCheck;
  final void Function() onPressedTermsAndConditionText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaymentMethodSelectionCardWidget<PaymentMethod>(
                  title: LocaleKeys.text_payAtCashier.tr(),
                  useCardWidget: true,
                  onChangedValue: onChangedPaymentMethod,
                  radioIdentifierValue: PaymentMethod.cashier,
                  groupValue: selectedPaymentMethod,
                  image: Assets.images.money,
                ),
                Gap.h12,
                CardWidget(
                  content: [
                    Text(
                      LocaleKeys.text_virtualAccount.tr(),
                      style: TypographyTheme.textLSemiBold.toNeutral80,
                    ),
                    Gap.h24,
                    PaymentMethodSelectionCardWidget<PaymentMethod>(
                      onChangedValue: onChangedPaymentMethod,
                      radioIdentifierValue: PaymentMethod.virtualAccountBCA,
                      groupValue: selectedPaymentMethod,
                      title: "${LocaleKeys.text_virtualAccount.tr()} BCA",
                      image: Assets.images.vaBca,
                    ),
                    Divider(
                      thickness: 1,
                      color: BaseColor.neutral.shade10,
                    ),
                    PaymentMethodSelectionCardWidget<PaymentMethod>(
                      onChangedValue: onChangedPaymentMethod,
                      radioIdentifierValue: PaymentMethod.virtualAccountMandiri,
                      groupValue: selectedPaymentMethod,
                      title: "${LocaleKeys.text_virtualAccount.tr()} Mandiri",
                      image: Assets.images.vaMandiri,
                    ),
                    Divider(
                      thickness: 1,
                      color: BaseColor.neutral.shade10,
                    ),
                    PaymentMethodSelectionCardWidget<PaymentMethod>(
                      onChangedValue: onChangedPaymentMethod,
                      radioIdentifierValue: PaymentMethod.virtualAccountBNI,
                      groupValue: selectedPaymentMethod,
                      title: "${LocaleKeys.text_virtualAccount.tr()} BNI",
                      image: Assets.images.vaBni,
                    ),
                  ],
                ),
                Gap.h12,
                CardWidget(
                  content: [
                    Text(
                      LocaleKeys.text_paymentSummary.tr(),
                      style: TypographyTheme.textLSemiBold.toNeutral80,
                    ),
                    Gap.h12,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleKeys.text_total.tr(),
                          style: TypographyTheme.textMRegular.toNeutral70,
                        ),
                        Text(
                          total.toRupiah,
                          style: TypographyTheme.textMRegular.toNeutral70,
                        ),
                      ],
                    ),
                    selectedPaymentMethod == PaymentMethod.cashier
                        ? const SizedBox()
                        : Gap.h12,
                    selectedPaymentMethod == PaymentMethod.cashier
                        ? const SizedBox()
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleKeys.text_serviceFee.tr(),
                          style: TypographyTheme.textMRegular.toNeutral70,
                        ),
                        Text(
                          serviceFee.toRupiah,
                          style: TypographyTheme.textMRegular.toNeutral70,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        BottomActionWrapper(
          actionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.text_totalPayment.tr(),
                      style: TypographyTheme.textMRegular.toNeutral60,
                    ),
                    Text(
                      (total + serviceFee).toRupiah,
                      style: TypographyTheme.textLSemiBold.toNeutral90,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ButtonWidget.primary(
                  buttonSize: ButtonSize.medium,
                  text: LocaleKeys.text_pay.tr(),
                  isShrink: true,
                  onTap: () {
                    showTermsAndConditionDialog(
                      context,
                      htmlDataTermsAndCondition: htmlDataTermAndCondition,
                      onPressedAgree: onPressedAgree,
                      onChangedCheck: onChangedTermsAndConditionCheck,
                      onTapTermsAndCondition: onPressedTermsAndConditionText,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
