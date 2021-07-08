import 'dart:io';

import 'package:uuid/uuid.dart';

import 'emitter.dart';
import 'engine_event.dart';
import 'engine_socket.dart';
import 'server_events.dart';
import 'typedef.dart';

const _uuid = Uuid();

class EngineServer extends Emitter {
  ServerSocket? server;
  final Map<SocketId, EngineSocket> _clients = {};

  EngineServer();

  void listen(address, int port) {
    if (server != null) {
      return;
    }
    ServerSocket.bind(address, port).then((ServerSocket socket) {
      server = socket;
      server!.listen(_onData, onError: _onError, onDone: _onDone);
    });
  }

  void _onData(Socket socket) {
    var socketId = _uuid.v4().replaceAll('-', '');
    var engineSocket = EngineSocket(socket, socketId)..onOpen();
    _clients[socketId] = engineSocket;
    engineSocket.once(Engine.close, (_) => {_clients.remove(socketId)});
    emit(Engine.connection, engineSocket);
  }

  void _onError(error, StackTrace trace) {
    emit(ServerEvent.error, error);
  }

  void _onDone() {
    emit(ServerEvent.close);
  }

  void shutdown() {
    _clients.clear();
    server?.close();
  }
}
