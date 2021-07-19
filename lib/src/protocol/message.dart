import 'dart:typed_data' show Uint8List;

import '../protocol/radian_mixin.dart';
import 'schema.dart';
import 'zigzag_mixin.dart';

class Message with ZigZag, MessageBody, Radians {
  @override
  final Schema schema;
  String namespace;
  final Map<int, String> stringList;
  @override
  final List<int> intList;
  int? bytesPerMessage;
  int boolMask = 0;
  Uint8List? payloadBytes;
  Uint8List? raw;

  Message(this.schema, [this.namespace = '/'])
      : stringList = {},
        intList = List.filled(schema.intCount, 0);

  String getNamespace() => namespace;

  bool isEnabled(int id) => ((boolMask >> id) & 0x1) == 1;

  void enable(int id) => boolMask |= 1 << id;

  void disable(int id) => boolMask ^= 1 << id;

  bool getBool(int id) => ((boolMask >> id) & 0x1) == 1;

  void putBool(int id, bool value) {
    return (value) ? enable(id) : disable(id);
  }

  bool containsInt(int id) => id >= 0 && id < schema.intCount && intList[id] != 0;

  int getInt(int id) {
    return (id >= 0 && id < schema.intCount) ? zigzagDecode(intList[id]) : 0;
  }

  int getUInt(int id) {
    return (id >= 0 && id < schema.intCount) ? intList[id] : 0;
  }

  void putInt(int id, int value) => intList[id] = zigzagEncode(value);

  void putUInt(int id, int value) => intList[id] = value;

  double getSingle(int id) => intList[id] / 255;

  void putSingle(int id, double value) {
    intList[id] = (value * 255).clamp(0, 255).toInt();
  }

  bool containsString(int id) => stringList.containsKey(id);

  String? getString(int id) => stringList[id];

  void putString(int id, String value) => stringList[id] = value;

  bool containsPayload() => payloadBytes != null;

  void putPayload(Uint8List data) => payloadBytes = data;

  @override
  String toString() {
    return 'Message{~${schema.code}.${schema.version} $namespace, '
        'boolMask:$boolMask, int:$intList, string:$stringList ${payloadBytes ?? ''}}';
  }
}

mixin MessageBody {
  Schema get schema;

  List<int> get intList;
}
