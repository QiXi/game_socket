import 'dart:typed_data' show Uint8List;

import 'message_size.dart';
import 'packet.dart';
import 'uint8_mixin.dart';

const PacketDecoder packetDecoder = PacketDecoder();

class PacketDecoder with ExtractUint8 {
  const PacketDecoder();

  int decode(Packet packet, Uint8List buffer, int offset) {
    offset++; // magic
    packet.schemaCode = buffer[offset++];
    offset++; //dot
    packet.schemaVersion = buffer[offset++];
    var namespaceSize = extractInt(buffer, offset++, 1);
    packet.namespace = extractString(buffer, offset, namespaceSize);
    offset += namespaceSize;
    return decodePacket(packet, buffer, offset);
  }

  int decodePacket(Packet packet, Uint8List buffer, int offset) {
    final schema = packet.schema;
    var bitmask = packet.bitMask = extractInt(buffer, offset, schema.bytesPerMask);
    offset += schema.bytesPerMask;
    final bytesPerBoolMask = schema.bytesPerBoolMask;
    if (bytesPerBoolMask > 0) {
      packet.boolMask = extractInt(buffer, offset, bytesPerBoolMask);
      offset += bytesPerBoolMask;
    }
    var idx = 1;
    final propertiesCount = schema.maxProperties;
    var intCount = schema.intCount;
    for (var id = 0; id < intCount; id++) {
      if (boolFromMask(bitmask, propertiesCount, idx)) {
        var numSize = getSizeFromId(id, schema);
        packet.putUInt(id, extractInt(buffer, offset, numSize));
        offset += numSize;
      }
      idx++;
    }
    for (var id = 0; id < schema.stringsCount; id++) {
      if (boolFromMask(bitmask, propertiesCount, idx)) {
        var length = extractInt(buffer, offset, 1);
        offset++;
        packet.putString(id, extractString(buffer, offset, length));
        offset += length;
      }
      idx++;
    }
    if (schema.includedBytes) {
      if (boolFromMask(bitmask, propertiesCount, idx)) {
        var length = buffer.length - offset; //TODO len
        packet.payloadBytes = extractUint8List(buffer, offset, length);
        offset += length;
      }
      idx++;
    }
    return offset;
  }

  bool boolFromMask(int mask, int propertiesCount, int idx) {
    return ((mask >> (propertiesCount - idx)) & 1) == 1;
  }
}
