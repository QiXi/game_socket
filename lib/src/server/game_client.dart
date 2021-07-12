import 'dart:core';
import 'dart:io';

import 'package:meta/meta.dart';

import '../../protocol.dart';
import '../engine/emitter.dart';
import '../engine/event.dart';
import '../engine/typedef.dart';
import 'adapter.dart';
import 'game_namespace.dart';
import 'namespace.dart';
import 'server_client.dart';
import 'server_responses.dart';

class GameClient extends Emitter {
  final GameNamespace _namespace;
  final ServerClient _parent;
  final Adapter _adapter;
  final Set<String> _joinedRooms;
  bool _connected;

  GameClient(this._namespace, this._parent)
      : _adapter = _namespace.adapter,
        _connected = true,
        _joinedRooms = {};

  Namespace get namespace => _namespace;

  SocketId get id => _parent.socketId;

  /// Returns the current state of the connection.
  ReadyState get readyState => _parent.readyState;

  /// The remote [InternetAddress] connected to by this socket.
  InternetAddress get remoteAddress => _parent.getConnection().remoteAddress;

  /// The numeric address of the host.
  String get ipAddress => remoteAddress.address;

  bool get isConnected => _connected;

  bool isJoinedInRoom(String room) => _joinedRooms.contains(room);

  Set<String> get joinedRooms => _joinedRooms;

  Duration getIdleTime() => _parent.getIdleTime();

  /// Joins a room.
  void join(String room) {
    if (!_joinedRooms.contains(room)) {
      _joinedRooms.add(room);
      _adapter.add(room, this);
    }
  }

  /// Joins a rooms.
  void joinTo(Set<String> rooms) {
    if (rooms.isNotEmpty) {
      for (var room in rooms) {
        if (_joinedRooms.add(room)) {
          _adapter.add(room, this);
        }
      }
    }
  }

  /// Leaves a room.
  void leave(String room) {
    if (_joinedRooms.contains(room)) {
      _joinedRooms.remove(room);
      _adapter.remove(room, this);
    }
  }

  /// Leave all rooms.
  void leaveFrom(Set<String> rooms) {
    if (rooms.isNotEmpty) {
      for (var room in rooms) {
        if (_joinedRooms.remove(room)) {
          _adapter.remove(room, this);
        }
      }
    }
  }

  /// Removes the socket from all rooms.
  void leaveAllRooms() {
    for (var room in _joinedRooms) {
      _adapter.remove(room, this);
    }
    _joinedRooms.clear();
  }

  /// Targets a room when emitting.
  Namespace to(String room) => _namespace..to(room);

  /// Excludes a room when emitting.
  Namespace except(String room) => _namespace..except(room);

  /// Broadcasting message to rooms.
  void broadcast(Message message, [Set<String>? rooms, SocketId? exclude]) {
    message.namespace = _namespace.name;
    namespace.broadcast(message, rooms: rooms, exclude: exclude);
  }

  /// Broadcasting event to room.
  void broadcastRoomEvent(String event, String room, {SocketId? exclude, dynamic data}) {
    namespace.broadcastRoomEvent(event, room, data: data, exclude: exclude);
  }

  /// Sending message to client.
  void send(Message message) {
    message.namespace = _namespace.name;
    _parent.sendMessage(message);
  }

  void sendRaw(List<int> data) {
    _parent.send(data);
  }

  /// Disconnect this socket.
  /// Optionally, close the underlying connection.
  void disconnect(bool close, String reason) {
    if (_connected) {
      if (close) {
        _parent.disconnect(reason);
      } else {
        send(DisconnectClient(namespace: _namespace.name));
        onClose(reason);
      }
    }
  }

  @internal
  void onConnect() {
    _namespace.addConnected(id);
    send(Handshake(namespace: _namespace.name, token: id));
    join(id);
  }

  @internal
  void onDisconnect() {
    onClose(ClientDisconnectionReason.normal);
  }

  @internal
  void onPacket(Packet packet) {
    emit(Event.packet, packet);
  }

  @internal
  void onEvent(RoomPacket packet) {
    var event = packet.eventName;
    var data = packet.payloadBytes ?? packet.getString(RoomSchema.message);
    if (event != null) {
      emit(event, data);
    }
  }

  @internal
  void onError(String error) {
    emit(Event.error, error);
  }

  @internal
  void onClose(String reason) {
    if (_connected) {
      emit(Event.disconnecting, [namespace.name, reason]);
      leaveAllRooms();
      _namespace.remove(this);
      _parent.remove(this);
      _connected = false;
      _namespace.removeConnected(id);
      emit(Event.disconnect, [namespace.name, reason]);
    }
  }

  @override
  String toString() {
    return 'GameClient{ $id $readyState [$hashCode]}';
  }
}
