import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScanQuickResponseCodeScreen extends StatelessWidget {
  const ScanQuickResponseCodeScreen({
    super.key,
    required this.appointmentSerial,
  });
  final String appointmentSerial;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      useSafeArea: true,
      appBar: AppBarWidget(
        backgroundColor: BaseColor.transparent,
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_scanBarcode.tr(),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.customWidth(35),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: BaseSize.customHeight(360),
                child: QrImageView(
                  data: appointmentSerial,
                  version: QrVersions.auto,
                ),
              ),
              Text(
                LocaleKeys.text_pleaseVisitOurFrontOfficeToScanYourBarcode.tr(),
                style: TypographyTheme.textLRegular.toNeutral60,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
