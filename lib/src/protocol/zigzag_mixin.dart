import 'package:meta/meta.dart';

mixin ZigZag {
  @protected
  int zigzagEncode(int i) => (i >> 31) ^ (i << 1);

  @protected
  int zigzagDecode(int i) => (i >> 1) ^ -(i & 1);
}
