import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/localization/localization.dart';

enum AppointmentGuaranteeType {
  @JsonValue("PERSONAL")
  personal,
  @JsonValue("INSURANCE")
  insurance
}

extension XAppointmentGuaranteeType on AppointmentGuaranteeType {
  String get label {
    switch (this) {
      case AppointmentGuaranteeType.personal:
        return LocaleKeys.text_personal.tr();
      case AppointmentGuaranteeType.insurance:
        return LocaleKeys.text_insurance.tr();
    }
  }
}
