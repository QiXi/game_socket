import '../packet.dart';
import 'room_schema.dart';

class RoomPacket extends Packet {
  RoomPacket() : super(RoomSchema());

  bool get createRoom => isEnabled(RoomSchema.createRoom);

  bool get deleteRoom => isEnabled(RoomSchema.deleteRoom);

  bool get joinRoom => isEnabled(RoomSchema.joinRoom);

  bool get joinRoomError => isEnabled(RoomSchema.joinRoomError);

  bool get leaveRoom => isEnabled(RoomSchema.leaveRoom);

  bool get userEnterRoom => isEnabled(RoomSchema.userEnterRoom);

  bool get userExitRoom => isEnabled(RoomSchema.userExitRoom);

  bool get event => isEnabled(RoomSchema.event);

  int get errorCode => getInt(RoomSchema.errorCode);

  int get playerId => getInt(RoomSchema.playerId);

  String? get roomName => getString(RoomSchema.roomName);

  String? get message => getString(RoomSchema.message);

  String? get errorMessage => getString(RoomSchema.errorMessage);

  String? get playerName => getString(RoomSchema.playerName);

  String? get roomToLeave => getString(RoomSchema.roomToLeave);

  String? get eventName => getString(RoomSchema.eventName);
}
