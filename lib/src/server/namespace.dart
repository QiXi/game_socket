import '../engine/emitter.dart';
import '../engine/typedef.dart';
import '../protocol/message.dart';
import 'adapter.dart';
import 'game_client.dart';
import 'game_socket_server.dart';

abstract class Namespace extends Emitter {
  final String name;
  final GameSocketServer server;
  late final Adapter adapter;

  Namespace(this.name, this.server) {
    adapter = server.createAdapter(this);
  }

  Set<SocketId> get connectedSockets;

  GameClient? getClient(SocketId id);

  /// Broadcast message to one or many rooms.
  void broadcast(Message message, {Set<String>? rooms, SocketId? exclude});

  /// Broadcast message queue to room.
  void broadcastQueue(List<Message> queue, String room, {SocketId? exclude});

  /// Broadcast event to room.
  void broadcastRoomEvent(String event, String room,
      {SocketId? exclude, dynamic data});
}
