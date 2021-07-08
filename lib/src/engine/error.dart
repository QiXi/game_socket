class ErrorCode {
  static const int reserved = 0;
  static const int invalidNamespace = 1;
  static const int alreadyConnected = 2;
}

class ErrorString {
  static const String unsupportedRaw = 'Unsupported raw data';
  static const String unsupportedSchema = 'Unsupported schema';
  static const String decode = 'Decryption error';
  static const String largeSize = 'Incoming request size too large';
}
