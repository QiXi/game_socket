import '../schema.dart';

typedef GSS = GameSocketSchema;

class GameSocketSchema extends Schema {
  static final GameSocketSchema _instance = GameSocketSchema._();

  GameSocketSchema._();

  factory GameSocketSchema() => _instance;

  @override
  int get code => 0;

  @override
  int get version => 0;

  // bool (properties or event as a binary flag)
  static const int reserved_bool = 0; // maybe udp
  static const int utf8 = 1; // reserved for UTF-8
  static const int connect = 2;
  static const int disconnect = 3;
  static const int handshake = 4;
  static const int ping = 5;
  static const int pong = 6;
  static const int error = 7; //
  @override
  int get boolCount => 8;

  // int8
  static const int value_int8 = 0; // reserved int8
  static const int value = 1; // reserved
  static const int errorCode = value; // alias for value
  static const int pingInterval = 2; // reserved
  @override
  int get int8Count => 3;

  // int16
  static const int value_int16 = 3; // reserved int16
  @override
  int get int16Count => 1;

  // int32
  static const int value_int32 = 4; // reserved int32
  static const int time = 5; //
  @override
  int get int32Count => 2;

  // string
  static const int message = 0;
  static const int errorMessage = message; // alias message
  static const int data = 1;
  static const int name = 2;
  static const int token = 3;
  static const int reconnectionToken = 4; // reserved
  static const int key = 5; // reserved
  @override
  int get stringsCount => 6;

  @override
  bool get includedBytes => false;

  @override
  String toString() {
    return 'GameSocketSchema{$code.$version, boolCount:$boolCount intCount:$intCount, stringsCount:$stringsCount [$hashCode]}';
  }
}
