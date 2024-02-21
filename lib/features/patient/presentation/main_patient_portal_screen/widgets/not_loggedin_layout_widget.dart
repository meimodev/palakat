import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';


class NotLoggedInLayoutWidget extends StatelessWidget {
  const NotLoggedInLayoutWidget({
    super.key,
    required this.onTapLoginButton,
  });

  final void Function() onTapLoginButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.text_loginToSeeYourPatientPortal.tr(),
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
