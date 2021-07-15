import 'dart:typed_data';

import '../message.dart';
import 'room_schema.dart';

class RoomMessage extends Message {
  RoomMessage(String namespace, String roomName) : super(RoomSchema(), namespace) {
    putString(RoomSchema.roomName, roomName);
  }
}

class JoinRoomRequest extends RoomMessage {
  JoinRoomRequest(String roomName, {String namespace = '/', String? roomToLeave})
      : super(namespace, roomName) {
    enable(RoomSchema.joinRoom);
    if (roomToLeave != null) {
      putString(RoomSchema.roomToLeave, roomToLeave);
    }
  }
}

class LeaveRoomRequest extends RoomMessage {
  LeaveRoomRequest(String roomName, {String namespace = '/'}) : super(namespace, roomName) {
    enable(RoomSchema.leaveRoom);
  }
}

class CreateRoomRequest extends JoinRoomRequest {
  CreateRoomRequest(String roomName,
      {String namespace = '/', bool joinAfterCreation = true, String? roomToLeave})
      : super(roomName, namespace: namespace, roomToLeave: roomToLeave) {
    this
      ..enable(RoomSchema.createRoom)
      ..putBool(RoomSchema.joinRoom, joinAfterCreation);
  }
}

class RoomEvent extends RoomMessage {
  RoomEvent(String targetRoom,
      {required String namespace, required String event, String? message, List<int>? payload})
      : super(namespace, targetRoom) {
    enable(RoomSchema.event);
    putString(RoomSchema.eventName, event);
    if (message != null) {
      putString(RoomSchema.message, message);
    }
    if (payload != null) {
      payloadBytes = Uint8List.fromList(payload);
    }
  }
}
