import 'dart:math';

import '../protocol/zigzag_mixin.dart';
import 'message.dart';

mixin Radians implements ZigZag, MessageBody {
  static const double twoPi = pi * 2;
  static const double step = (256 * 256) / 2 / twoPi;

  double getRadians(int id) {
    if (id >= 0 && id < schema.intCount) {
      var int = zigzagDecode(intList[id]);
      return int / step;
    } else {
      return 0;
    }
  }

  void putRadians(int id, double value) {
    intList[id] = zigzagEncode(((value /*% twoPi*/) * step).toInt());
  }
}
