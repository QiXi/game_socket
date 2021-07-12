import 'dart:typed_data' show Uint8List;

import 'message.dart';
import 'message_size.dart';
import 'protocol.dart';
import 'schema.dart';
import 'uint8_mixin.dart';

const MessageEncoder messageEncoder = MessageEncoder();

class MessageEncoder with InsertUint8 {
  const MessageEncoder();

  Uint8List encode(Message message, Schema schema) {
    message.bytesPerMessage ?? computeMessageSize(message, schema);
    final buffer = Uint8List(message.bytesPerMessage!);
    var offset = 0;
    buffer[offset++] = Protocol.magic;
    buffer[offset++] = schema.code;
    buffer[offset++] = Protocol.dot;
    buffer[offset++] = schema.version;
    offset = insertString(buffer, offset, message.namespace ?? '/');
    encodeMessage(buffer, offset, message, schema);
    return buffer;
  }

  void encodeMessage(
      Uint8List buffer, int offset, Message message, Schema schema) {
    final bitmaskOffset = offset;
    var bitmask = 0;
    offset += schema.bytesPerMask; // place for a mask
    final bytesPerBoolMask = schema.bytesPerBoolMask;
    if (bytesPerBoolMask > 0) {
      offset = insertInt(buffer, offset, bytesPerBoolMask, message.boolMask);
    }
    for (var id = 0; id < schema.intCount; id++) {
      if (message.containsInt(id)) {
        var numSize = getSizeFromId(id, schema);
        offset = insertInt(buffer, offset, numSize, message.getUInt(id));
        bitmask |= 1;
      }
      bitmask <<= 1;
    }
    for (var id = 0; id < schema.stringsCount; id++) {
      if (message.containsString(id)) {
        offset = insertString(buffer, offset, message.getString(id)!);
        bitmask |= 1;
      }
      bitmask <<= 1;
    }
    if (schema.includedBytes) {
      if (message.containsPayload()) {
        offset = insertUint8List(buffer, offset, message.payloadBytes!);
        bitmask |= 1;
      }
      //bitmask <<= 1;
    } else {
      bitmask >>= 1;
    }
    insertInt(buffer, bitmaskOffset, schema.bytesPerMask, bitmask);
  }
}
