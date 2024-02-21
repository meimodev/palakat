import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

extension XString on String {
  DateTime? get toDateTime {
    return DateTime.tryParse(this);
  }

  // DateTime? toFormattedDate({String format = "dd/mm/yyyy"}) {
  //   //TODO not implemented, using jiffy
  //   return DateFormat(format).parse(this);
  // }

  String replaceVar(Map<String, dynamic> variables) {
    return replaceAllMapped(
      RegExp(r'{([^}]+)}'),
      (Match match) {
        final key = match.group(1);
        if (variables.containsKey(key)) {
          return variables[key].toString();
        }
        final secondKey = match.group(0);
        if (variables.containsKey(secondKey)) {
          return variables[secondKey].toString();
        }

        return '';
      },
    );
  }

  String get maskPhone {
    if (length < 7) {
      return this;
    }

    String middle = '*' * (length - 6);

    return '${substring(0, 2)} $middle ${substring(length - 4)}';
  }

  String get thousandToString {
    return replaceAll(',', '');
  }

  double? get thousandToDouble {
    return double.tryParse(replaceAll(',', ''));
  }
  //
  // String get slashDate {
  //   return toDateTime?.slashDate ?? '-';
  // }

  String get slashSpace {
    return replaceAll("/", " / ");
  }

  // String? get yyyMMdd {
  //   try {
  //     var inputFormat = DateFormat('dd/MM/yyyy');
  //     var inputDate = inputFormat.parse(this);
  //     return inputDate.yyyMMdd;
  //   } catch (_) {}
  //   return null;
  // }

  // String get mmmDdYy {
  //   var inputFormat = DateFormat('mmm dd, yy');
  //   var inputDate = inputFormat.parse(this);
  //
  //   return inputDate.mmmddyyy;
  // }

  // String get mMddyyy {
  //   var inputFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
  //   var inputDate = inputFormat.parse(this);
  //
  //   return inputDate.mMddyyy;
  // }

  String get toSnakeCase {
    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAllMapped(exp, (Match m) => ('_${m.group(0)}'))
        .toLowerCase();
  }

  String get camelToSentence {
    return replaceAllMapped(RegExp(r'^([a-z])|[A-Z]'),
        (Match m) => m[1] == null ? " ${m[0]}" : m[1]!.toUpperCase());
  }

  String get capitalizeSnakeCaseToTitle {
    return replaceAll('_', ' ').toLowerCase().capitalizeEachWord;
  }

  String get capitalizeEachWord {
    final words = split(" ");
    String formattedWord = "";
    for (var word in words) {
      if (word.length == 1) {
        formattedWord += word.toUpperCase();
      } else {
        formattedWord += (word[0].toUpperCase() + word.substring(1));
      }
      formattedWord += " ";
    }

    return formattedWord.trim();
  }

  String get capitalizeAll => toUpperCase();

  String get toCamelCase {
    return toLowerCase().replaceAllMapped(
        RegExp(
            r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
        (Match match) {
      return "${match[0]![0].toUpperCase()}${match[0]!.substring(1).toLowerCase()}";
    }).replaceAll(RegExp(r'(_|-)+'), ' ');
  }

  num? get toNumber => num.tryParse(replaceAll(RegExp(r"[^\d.]+"), ''));

  // LanguageKey get languageKey {
  //   if (this == LanguageKey.id.name) {
  //     return LanguageKey.id;
  //   }
  //   return LanguageKey.en;
  // }

  String get partiallyObscured {
    return replaceRange(3, length - 3, "******");
  }



  List<String> get explodeByComma {
    return split(",").toList();
  }

  bool containLists(List<String> list) {
    for (String element in list) {
      if (contains(element)) {
        return true;
      }
    }

    return false;
  }
}

extension XNullableString on String? {
  bool isNullOrEmpty() => !isNotNull() || this == '';

  String get valueOrDash => isNullOrEmpty() == false ? this ?? '-' : '-';
}
