import '../../protocol.dart';

class Handshake extends GameSocketMessage {
  Handshake({required String namespace, required String token, String? reconnectToken})
      : super(namespace) {
    enable(GSS.handshake);
    putString(GSS.token, token);
    putInt(GSS.pingInterval, 30);
    if (reconnectToken != null) {
      putString(GSS.reconnectionToken, reconnectToken);
    }
  }
}

class DisconnectClient extends GameSocketMessage {
  DisconnectClient({required String namespace, String? message}) : super(namespace) {
    enable(GSS.disconnect);
    if (message != null) {
      putString(GSS.message, message);
    }
  }
}

class JoinRoom extends RoomMessage {
  JoinRoom(String roomName, {required String namespace, String? playerName, int? playerId})
      : super(namespace, roomName) {
    enable(RoomSchema.joinRoom);
    if (playerName != null) {
      putString(RoomSchema.playerName, playerName);
    }
    if (playerId != null) {
      putInt(RoomSchema.playerId, playerId);
    }
  }
}

class JoinRoomError extends RoomMessage {
  JoinRoomError(String roomName, {required String namespace, required String message})
      : super(namespace, roomName) {
    this
      ..enable(RoomSchema.joinRoomError)
      ..putString(RoomSchema.message, message);
  }
}

class LeaveRoom extends RoomMessage {
  LeaveRoom(String roomName, {required String namespace}) : super(namespace, roomName) {
    enable(RoomSchema.leaveRoom);
  }
}

class UserEnterRoom extends RoomMessage {
  UserEnterRoom(String roomName, {required String namespace, String? playerName, int? playerId})
      : super(namespace, roomName) {
    enable(RoomSchema.userEnterRoom);
    if (playerName != null) {
      putString(RoomSchema.playerName, playerName);
    }
    if (playerId != null) {
      putInt(RoomSchema.playerId, playerId);
    }
  }
}

class UserExitRoom extends UserEnterRoom {
  UserExitRoom(String roomName, {required String namespace, String? playerName, int? playerId})
      : super(roomName, namespace: namespace, playerName: playerName, playerId: playerId) {
    enable(RoomSchema.userExitRoom);
  }
}

class KickUser extends GameSocketMessage {
  int delay;

  KickUser({required String message, this.delay = 0}) : super('') {
    putString(GSS.message, message);
  }
}
