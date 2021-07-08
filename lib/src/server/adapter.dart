import 'dart:core';

import 'package:meta/meta.dart';

import '../engine/typedef.dart';
import '../protocol/message.dart';
import 'game_client.dart';
import 'namespace.dart';

abstract class Adapter /*extends Emitter */ {
  @protected
  final Namespace namespace;
  @protected
  final Map<String, Set<GameClient>> socketsByRoom = {};
  @protected
  final Map<SocketId, Set<String>> roomsBySocketId = {};

  Adapter(this.namespace) : super();

  void broadcast(Message message,
      {Set<String>? rooms, Set<SocketId>? exclude, SocketId? excludeOne});

  void broadcastToRoom(Message message, String room, {SocketId? exclude});

  void broadcastQueue(List<Message> queue, String room, {SocketId? exclude});

  void add(String room, GameClient socket);

  void remove(String room, GameClient socket);

  @protected
  Iterator<GameClient>? listClients(String room);

  @protected
  Iterator<String>? listRooms(SocketId socketId);
}

abstract class AdapterFactory {
  Adapter createAdapter(Namespace namespace);
}
