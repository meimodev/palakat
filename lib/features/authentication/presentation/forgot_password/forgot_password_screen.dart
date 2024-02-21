import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(forgotPasswordControllerProvider(context).notifier);
    final state = ref.watch(forgotPasswordControllerProvider(context));

    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      appBar: const AppBarWidget(
        backgroundColor: Colors.transparent,
        backIconColor: BaseColor.primary4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: horizontalPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap.h24,
                  Text(
                    LocaleKeys.text_forgotPassword.tr(),
                    style: TypographyTheme.heading2Bold
                        .fontColor(BaseColor.primary4),
                  ),
                  Gap.h12,
                  Text(
                    LocaleKeys.text_enterEmailReset.tr(),
                    style: TypographyTheme.textLRegular
                        .fontColor(BaseColor.neutral.shade60),
                  ),
                  Gap.h48,
                  InputFormWidget(
                    controller: controller.emailController,
                    hintText: LocaleKeys.text_email.tr(),
                    hasIconState: false,
                    validator:
                        ValidationBuilder(label: LocaleKeys.text_email.tr())
                            .required()
                            .email()
                            .build(),
                    label: LocaleKeys.text_email.tr(),
                    keyboardType: TextInputType.emailAddress,
                    hasBorderState: false,
                    onChanged: (_) => controller.clearError("email"),
                    error: state.errors['email'],
                  ),
                  Gap.h20,
                ],
              ),
            ),
          ),
          SizedBox(
            child: Container(
              padding: horizontalPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(1),
                    offset: const Offset(-1, -2),
                    blurRadius: 9,
                    spreadRadius: -10,
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: BaseSize.h28,
                  top: BaseSize.h16,
                ),
                child: ButtonWidget.primary(
                  color: BaseColor.primary3,
                  overlayColor: BaseColor.white.withOpacity(.5),
                  isShrink: true,
                  isLoading: state.valid.isLoading,
                  text: LocaleKeys.text_resetPassword.tr(),
                  onTap: () => controller.onSubmit(context),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
