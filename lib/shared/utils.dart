
import 'package:jiffy/jiffy.dart';

extension StringExtension on String {
  String cleanPhone() {
    trim();
    return contains('+62') ? replaceFirst('+62', '0') : this;
  }
}

extension DateTimeExtension on DateTime {
  String get dayEEEE {
    return Jiffy(this).format("EEEE");
  }

  String get monthM {
    return Jiffy(this).format("M");
  }

  String get monthMMM {
    return Jiffy(this).format("MMM");
  }
  String get monthMMMM {
    return Jiffy(this).format("MMMM");
  }

  String get timeHHmm {
    return Jiffy(this).format("HH:mm");
  }

  String get yeary {
    return Jiffy(this).format("y");
  }

  String get dated {
    return Jiffy(this).format("d");
  }
  String format(String format){
    return Jiffy(this).format(format);
  }
}
