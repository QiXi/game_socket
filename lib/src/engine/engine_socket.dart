import 'dart:io' show InternetAddress, Socket;
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'emitter.dart';
import 'engine_event.dart';
import 'session.dart';
import 'typedef.dart';

class EngineSocket extends Emitter {
  final Socket _socket;
  ReadyState readyState;
  final Session session;

  EngineSocket(this._socket)
      : readyState = ReadyState.connecting,
        session = Session(_socket.address, _socket.port) {
    _socket.listen(_onData, onError: _onError, onDone: _onDone);
  }

  Socket getConnection() => _socket;

  @internal
  void onOpen() {
    readyState = ReadyState.open;
    emit(Engine.open, _socket.address);
  }

  void _onData(Uint8List data) {
    session.lastActivityTime = DateTime.now();
    session.readBytes += data.length;
    emit(Engine.data, data);
  }

  void _onError(Object error) {
    emit(Engine.error, error);
  }

  void _onDone() {
    readyState = ReadyState.closed;
    emit(Engine.close);
  }

  void send(List<int> data) {
    if (readyState == ReadyState.open) {
      _socket.add(data);
    }
    session.writtenBytes += data.length;
    session.lastActivityTime = DateTime.now();
  }

  void close() {
    if (readyState == ReadyState.open) {
      readyState = ReadyState.closing;
      emit(Engine.closing);
      _socket.close();
    }
  }

  @override
  String toString() {
    return 'EngineSocket{ ${session.socketId}, ${_socket.address.address}:${_socket.port} state:$readyState}';
  }
}
