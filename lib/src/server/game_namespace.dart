import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../server.dart';
import '../engine/typedef.dart';
import 'game_client.dart';
import 'game_socket_server.dart';
import 'namespace.dart';
import 'server_client.dart';

class GameNamespace extends Namespace {
  final Map<SocketId, GameClient> _sockets = {};
  final Set<SocketId> _connectedSockets = {};
  final Set<String> _targetRooms = {};

  GameNamespace(String name, GameSocketServer server) : super(name, server);

  @override
  Set<SocketId> get connectedSockets => _connectedSockets;

  @override
  GameClient? getClient(SocketId id) => _sockets[id];

  /// Targets a room when emitting.
  Namespace to(String room) {
    _targetRooms.add(room);
    return this;
  }

  /// Excludes a room when emitting.
  Namespace except(String room) {
    _targetRooms.remove(room);
    return this;
  }

  @override
  void emit(String event, [dynamic data]) {
    if (_targetRooms.isNotEmpty) {
      broadcastRoomEvent(event, _targetRooms.first);
      _targetRooms.clear();
    }
    super.emit(event, data);
  }

  /// Broadcast message to one or many rooms.
  @override
  void broadcast(Message message, {Set<String>? rooms, SocketId? exclude}) {
    message.namespace = name;
    adapter.broadcast(message, rooms: rooms ?? _targetRooms, excludeOne: exclude);
  }

  /// Broadcast a list of messages to a room.
  @override
  void broadcastList(List<Message> list, String room, {SocketId? exclude}) {
    for (var message in list) {
      message.namespace = name;
    }
    adapter.broadcastList(list, room, exclude: exclude);
  }

  /// Broadcast event to room.
  /// data as either a List<int> or String.
  @override
  void broadcastRoomEvent(String event, String room, {SocketId? exclude, dynamic data}) {
    var eventMessage = RoomEvent(room, event: event, namespace: name);
    if (data is List<int>) {
      eventMessage.payloadBytes = Uint8List.fromList(data);
    } else if (data is String) {
      eventMessage.putString(RoomSchema.message, data);
    }
    adapter.broadcastToRoom(eventMessage, room, exclude: exclude);
  }

  @internal
  GameClient connectClient(ServerClient client) {
    final socket = GameClient(this, client);
    emit(ServerEvent.connection, socket);
    if (client.readyState == ReadyState.open) {
      _sockets[socket.id] = socket;
      socket.onConnect();
      emit(ServerEvent.connect, [name, socket.id]);
    }
    return socket;
  }

  @internal
  void remove(GameClient socket) => _sockets.remove(socket.id);

  @internal
  void addConnected(SocketId id) => _connectedSockets.add(id);

  @internal
  void removeConnected(SocketId id) => _connectedSockets.remove(id);
}
