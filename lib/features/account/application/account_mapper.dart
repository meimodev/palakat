import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';

class AccountMapper {
  static AccountSetting mapToAccountSetting(AccountSettingData? response) {
    if (response == null) {
      return AccountSetting(
        enableBiometric: false,
        language: defaultLanguage.name,
        authenticatedPatientPortal: false,
      );
    }

    return AccountSetting(
      enableBiometric: response.enableBiometric ?? false,
      language: response.language ?? defaultLanguage.name,
      authenticatedPatientPortal: response.authenticatedPatientPortal ?? false,
    );
  }

  static AutocompleteAddress mapToAutocompleteAddress(
    AutocompleteResponse response,
  ) {
    return AutocompleteAddress(
      addressLabel: response.formatted?.mainText ?? "",
      address: response.formatted?.secondaryText ?? "",
      fullAddress: response.description,
    );
  }
}
