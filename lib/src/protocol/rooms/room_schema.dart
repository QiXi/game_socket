import '../schema.dart';

class RoomSchema extends SimpleSchema {
  static final RoomSchema _instance = RoomSchema._();

  RoomSchema._();

  factory RoomSchema() => _instance;

  @override
  int get code => 1;

  @override
  int get version => 0;

  // bool (properties or event as a binary flag)
  static const int reserved_bool = 0; // maybe udp
  static const int utf8 = 1; // reserved for UTF-8
  static const int createRoom = 2;
  static const int deleteRoom = 3;
  static const int joinRoom = 4;
  static const int joinRoomError = 5;
  static const int leaveRoom = 6;
  static const int userEnterRoom = 7;
  static const int userExitRoom = 8;
  static const int event = 9; //
  @override
  int get boolCount => 10;

  // int8
  static const int reserved_int8 = 0; // reserved int8
  static const int errorCode = 1; //
  @override
  int get int8Count => 2;

  // int16
  static const int playerId = 2; //
  @override
  int get int16Count => 1;

  // string
  static const int roomName = 0;
  static const int message = 1;
  static const int errorMessage = message; // alias message
  static const int playerName = 2;
  static const int roomToLeave = 3;
  static const int key = 4;
  static const int eventName = 5; //
  @override
  int get stringsCount => 6;

  @override
  bool get includedBytes => true;

  @override
  String toString() {
    return 'RoomSchema{ $code.$version, boolCount:$boolCount intCount:$intCount, stringsCount:$stringsCount [$hashCode]}';
  }
}
