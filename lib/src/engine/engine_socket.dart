import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'emitter.dart';
import 'engine_event.dart';
import 'typedef.dart';

class EngineSocket extends Emitter {
  final Socket _socket;
  final SocketId socketId;
  ReadyState readyState;
  int readBytes = 0;
  int writtenBytes = 0;
  late DateTime lastActivityTime;

  EngineSocket(this._socket, this.socketId)
      : readyState = ReadyState.connecting {
    lastActivityTime = DateTime.now();
    _socket.listen(_onData, onError: _onError, onDone: _onDone);
  }

  int get port => _socket.port;

  InternetAddress get address => _socket.address;

  Socket getConnection() => _socket;

  @internal
  void onOpen() {
    readyState = ReadyState.open;
    emit(Engine.open, _socket.address);
  }

  void _onData(Uint8List data) {
    lastActivityTime = DateTime.now();
    readBytes += data.length;
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
    writtenBytes += data.length;
    lastActivityTime = DateTime.now();
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
    return 'EngineSocket{ $socketId, ${_socket.address.address}:${_socket.port} state:$readyState}';
  }
}
