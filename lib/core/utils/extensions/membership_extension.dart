import 'package:palakat/core/constants/enums/enums.dart';
import 'package:palakat/core/models/membership.dart';
import 'package:palakat/core/utils/extensions/account_extension.dart';

extension XMembership on Membership {
  Bipra? get bipra {
    if (account == null) {
      return null;
    }

    if (account!.married) {
      if (account!.gender == Gender.male) {
        return Bipra.fathers;
      }
      if (account!.gender == Gender.female) {
        return Bipra.mothers;
      }
    }

    // Unmarried: determine by age groups
    final years = account!.ageYears;
    if (years < 12) return Bipra.kids;
    if (years < 18) return Bipra.teens;
    return Bipra.youths;
  }
}
