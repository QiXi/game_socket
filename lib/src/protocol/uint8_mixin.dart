import 'dart:convert' show utf8;
import 'dart:typed_data' show Uint8List;

mixin InsertUint8 {
  int insertInt(Uint8List buffer, int offset, int bytes, int element) {
    var index = offset + bytes - 1;
    buffer[index] = element;
    for (var i = 1; i < bytes; i++) {
      buffer[index - i] = element >> (i * 8);
    }
    return offset + bytes;
  }

  int insertInt8(Uint8List buffer, int offset, int element) {
    buffer[offset] = element;
    return offset + 1;
  }

  int insertInt16(Uint8List buffer, int offset, int element) {
    buffer[offset++] = element >> 8;
    buffer[offset++] = element;
    return offset;
  }

  int insertString(Uint8List buffer, int offset, String element) {
    buffer[offset++] = element.length;
    buffer.setAll(offset, element.codeUnits);
    return offset += element.length;
  }

  int insertUtf8String(Uint8List buffer, int offset, String element) {
    var value = utf8.encode(element);
    buffer[offset++] = value.length;
    buffer.setAll(offset, value);
    return offset += value.length;
  }

  int insertUint8List(Uint8List buffer, int offset, Uint8List element) {
    buffer.setAll(offset, element);
    return offset += element.length;
  }
}

mixin ExtractUint8 {
  int extractInt(Uint8List buffer, int offset, int bytes) {
    var element = buffer[offset++];
    for (var i = 1; i < bytes; i++) {
      element <<= 8;
      element |= buffer[offset++];
    }
    return element;
  }

  String extractString(Uint8List buffer, int offset, int bytes) {
    return String.fromCharCodes(buffer, offset, offset + bytes);
  }

  Uint8List extractUint8List(Uint8List buffer, int offset, int bytes) {
    return buffer.sublist(offset, offset + bytes);
  }
}
