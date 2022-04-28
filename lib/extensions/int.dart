import 'package:date_picker/extensions/string.dart';

extension IntExtension on int {
  String leadingZero(int count) {
    final stringInt = toString();

    return stringInt.length > count
        ? stringInt
        : "${"0".repeat(count - stringInt.length)}$stringInt";
  }
}
