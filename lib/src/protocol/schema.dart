abstract class Schema {
  static const int bitPerByte = 8;

  int get code;

  int get version;

  int get bytesPerMask => (maxProperties / bitPerByte).ceil();

  int get boolCount;

  int get bytesPerBoolMask => (boolCount / bitPerByte).ceil();

  int get int8Count;

  int get int16Count;

  int get int32Count;

  int get intCount => int8Count + int16Count + int32Count;

  int get stringsCount;

  bool get includedBytes;

  int get maxProperties {
    var count = intCount + stringsCount;
    if (includedBytes) count += 1;
    return count;
  }
}

abstract class SimpleSchema extends Schema {
  @override
  int get boolCount => 0;

  @override
  int get int8Count => 0;

  @override
  int get int16Count => 0;

  @override
  int get int32Count => 0;

  @override
  int get stringsCount => 0;

  @override
  bool get includedBytes => false;
}
