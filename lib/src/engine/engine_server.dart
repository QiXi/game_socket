import 'dart:io' show ServerSocket, Socket;

import 'emitter.dart';
import 'engine_event.dart';
import 'engine_socket.dart';
import 'typedef.dart';

class EngineServer extends Emitter {
  ServerSocket? server;
  final Map<SocketId, EngineSocket> _clients = {};

  EngineServer();

  void listen(address, int port) async {
    if (server == null) {
      server = await ServerSocket.bind(address, port);
      server!.listen(_onData, onError: _onError, onDone: _onDone);
    }
  }

  void _onData(Socket socket) {
    var engineSocket = EngineSocket(socket)..onOpen();
    var socketId = engineSocket.session.socketId;
    _clients[socketId] = engineSocket;
    engineSocket.once(Engine.close, (_) => {_clients.remove(socketId)});
    emit(Engine.connection, engineSocket);
  }

  void _onError(error, StackTrace trace) {
    emit(Engine.error, error);
  }

  void _onDone() {
    emit(Engine.close);
  }

  void shutdown() {
    _clients.clear();
    server?.close();
  }
}
