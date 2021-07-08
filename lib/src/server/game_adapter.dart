import '../engine/server_events.dart';
import '../engine/typedef.dart';
import '../protocol/message.dart';
import '../server/server_responses.dart';
import 'adapter.dart';
import 'game_client.dart';
import 'namespace.dart';

class GameAdapter extends Adapter {
  static final Set<SocketId> _emptyExclusion = {};
  bool sendRoomEvents;

  GameAdapter(Namespace namespace, this.sendRoomEvents) : super(namespace);

  @override
  void broadcast(Message message,
      {Set<String>? rooms, Set<SocketId>? exclude, SocketId? excludeOne}) {
    final excluded = (exclude == null) ? _emptyExclusion : exclude;
    if (excludeOne != null) {
      excluded.add(excludeOne);
    }
    if (rooms != null && rooms.isNotEmpty) {
      final selectedIds = <SocketId>{};
      final connectedSockets = namespace.connectedSockets;
      for (var room in rooms) {
        if (socketsByRoom.containsKey(room)) {
          final sockets = socketsByRoom[room];
          for (var socket in sockets!) {
            final socketId = socket.id;
            if (!excluded.contains(socketId) &&
                !selectedIds.contains(socketId) &&
                connectedSockets.contains(socketId)) {
              selectedIds.add(socketId);
              socket.send(message);
            }
          }
        }
      }
    } else {
      for (var socketId in roomsBySocketId.keys) {
        if (!excluded.contains(socketId)) {
          final socket = namespace.getClient(socketId);
          if (socket != null) {
            socket.send(message);
          }
        }
      }
    }
    _emptyExclusion.clear();
  }

  @override
  void broadcastToRoom(Message message, String room, {SocketId? exclude}) {
    if (socketsByRoom.containsKey(room)) {
      final sockets = socketsByRoom[room];
      final connectedSockets = namespace.connectedSockets;
      for (var socket in sockets!) {
        final socketId = socket.id;
        if ((exclude != socketId) && connectedSockets.contains(socketId)) {
          socket.send(message);
        }
      }
    }
  }

  @override
  void broadcastQueue(List<Message> queue, String room, {SocketId? exclude}) {
    if (socketsByRoom.containsKey(room)) {
      final sockets = socketsByRoom[room];
      final connectedSockets = namespace.connectedSockets;
      for (var socket in sockets!) {
        final socketId = socket.id;
        if ((exclude != socketId) && connectedSockets.contains(socketId)) {
          for (var message in queue) {
            socket.send(message);
          }
        }
      }
    }
  }

  @override
  void add(String room, GameClient socket) {
    var socketId = socket.id;
    if (socketsByRoom.containsKey(room)) {
      socketsByRoom[room]!.add(socket);
    } else {
      socketsByRoom[room] = {socket};
      namespace.emit(ServerEvent.createRoom, room);
    }
    if (!roomsBySocketId.containsKey(socketId)) {
      roomsBySocketId[socketId] = {};
    }
    roomsBySocketId[socketId]!.add(room);
    namespace.emit(ServerEvent.joinRoom, [room, socketId]);
    if (sendRoomEvents) {
      socket.send(JoinRoom(room, namespace: namespace.name));
    }
  }

  @override
  void remove(String room, GameClient socket) {
    if (roomsBySocketId[socket.id]?.remove(room) == true) {
      namespace.emit(ServerEvent.leaveRoom, [room, socket.id]);
      if (sendRoomEvents) {
        socket.send(LeaveRoom(room, namespace: namespace.name));
      }
    }
    if (roomsBySocketId[socket.id]?.isEmpty == true) {
      roomsBySocketId.remove(socket.id);
    }
    socketsByRoom[room]?.remove(socket.id);
    if (socketsByRoom[room]?.isEmpty == true) {
      socketsByRoom.remove(room);
      namespace.emit(ServerEvent.deleteRoom, room);
    }
  }

  @override
  Iterator<GameClient>? listClients(String room) {
    return socketsByRoom[room]?.iterator;
  }

  @override
  Iterator<String>? listRooms(SocketId socketId) {
    return roomsBySocketId[socketId]?.iterator;
  }
}
