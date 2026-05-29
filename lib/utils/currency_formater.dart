import 'package:intl/intl.dart';

class CurrencyFormater {
  static final oCcy = NumberFormat("#,##0.00", "en_US");

  static String convert(dynamic number) {
    if (number.runtimeType == int || number.runtimeType == double) {
      return oCcy.format(number);
    }
    return "0";
  }
}
