import 'dart:typed_data';

class Protocol {
  static const int magic = 126;
  static const int dot = 46;
  static const int bytesPerHeader = 5; // + "/"
  static const int namespace = 47;

  static bool checkHeader(Uint8List data, int offset) {
    if ((offset + bytesPerHeader) >= data.length) return false;
    final magicStart = data[offset];
    final dotMagic = data[offset + 2];
    final ns = data[offset + 5];
    return (magicStart == magic && dotMagic == dot && ns == namespace);
  }
}
