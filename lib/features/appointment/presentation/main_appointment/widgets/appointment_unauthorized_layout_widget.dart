import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class AppointmentUnauthorizedLayoutWidget extends StatelessWidget {
  const AppointmentUnauthorizedLayoutWidget({
    super.key,
    required this.onTapLoginButton,
  });

  final void Function() onTapLoginButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: horizontalPadding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.chatBoxOnly.image(),
            Gap.h28,
            Text(
              LocaleKeys.text_loginToSeeYourAppointmentHistory.tr(),
              style: TypographyTheme.textLRegular.toNeutral60,
            ),
            Gap.h28,
            ButtonWidget.primary(
              text: LocaleKeys.text_login.tr(),
              onTap: onTapLoginButton,
            ),
          ],
        ),
      ),
    );
  }
}
