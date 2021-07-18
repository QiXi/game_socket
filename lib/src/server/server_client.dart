import 'dart:io' show Socket;
import 'dart:typed_data' show Uint8List;

import 'package:meta/meta.dart';

import '../../protocol.dart';
import '../../server.dart';
import '../engine/engine_event.dart';
import '../engine/engine_socket.dart';
import '../engine/typedef.dart';
import 'game_client.dart';
import 'game_socket_server.dart';

class ServerClient {
  final GameSocketServer _server;
  final EngineSocket _socket;
  final Map<SocketId, GameClient> _clientById = {};
  final Map<String, GameClient> _clientByNamespace = {};
  final PacketFactory packetFactory;
  final int maxIncomingPacketSize;

  ServerClient(this._server, this._socket)
      : packetFactory = _server.getOptions().packetFactory,
        maxIncomingPacketSize = _server.getOptions().maxIncomingPacketSize {
    _socket.on(Engine.data, (data) => _onData(data));
    _socket.on(Engine.error, (data) => _onEngineError(data));
    _socket.on(Engine.close, (_) => _onClose(ClientDisconnectionReason.unknown));
  }

  SocketId get socketId => _socket.socketId;

  ReadyState get readyState => _socket.readyState;

  Socket getConnection() => _socket.getConnection();

  SocketStat get statistic => _socket.stat;

  void sendMessage(Message message) {
    if (_socket.readyState == ReadyState.open) {
      if (message.raw == null) {
        var rawMessage = messageEncoder.encode(message, message.schema);
        message.raw = rawMessage;
        _socket.send(rawMessage);
        _socket.stat.addWrittenPacket();
      } else {
        _socket.send(message.raw!);
      }
    }
  }

  void send(List<int> data) {
    if (_socket.readyState == ReadyState.open) {
      _socket.send(data);
    }
  }

  void _onData(Uint8List data) {
    var offset = 0;
    if (!Protocol.checkHeader(data, offset)) {
      _onRaw(data);
    } else if (data.length > maxIncomingPacketSize) {
      _onError('${ErrorString.largeSize} $_socket');
    } else {
      do {
        final code = data[offset + 1];
        final version = data[offset + 3];
        var schema = _server.getSchema(code, version);
        if (schema == null || schema.version != version) {
          _onError('${ErrorString.unsupportedSchema} $code.$version');
          break;
        } else {
          var packet = packetFactory.createPacket(schema);
          try {
            offset = packetDecoder.decode(packet, data, offset);
          } catch (e) {
            _onError('${ErrorString.decode} $e');
            break;
          } finally {
            _onDecoded(packet);
          }
        }
      } while (Protocol.checkHeader(data, offset));
    }
  }

  void _onEngineError(Object e) {
    _onError('${ErrorString.internalError} $e');
  }

  void _onError(String error) {
    for (var socket in _clientById.values) {
      socket.onError(error);
    }
    final options = _server.getOptions();
    if (options.closeSocketOnError) {
      _socket.close();
    }
  }

  void _onClose(String reason) {
    _destroy();
    for (var i = _clientById.length - 1; i >= 0; i--) {
      var client = _clientById.values.elementAt(i);
      client.onClose(reason);
    }
    _clientById.clear();
    _clientByNamespace.clear();
  }

  void _onRaw(Uint8List data) {
    final options = _server.getOptions();
    if (options.supportRawData) {
      _server.emit(ServerEvent.raw, data);
    } else {
      _onError(ErrorString.unsupportedRaw);
    }
  }

  void _onDecoded(Packet packet) {
    _socket.stat.addReadPacket();
    if (packet is GameSocketPacket) {
      _onGameSocketPacket(packet);
    } else {
      var client = _clientByNamespace[packet.namespace];
      if (client == null) {
        print('no GameClient for namespace "${packet.namespace}"');
        return;
      }
      if (packet is RoomPacket) {
        onRoomPacket(client, packet);
      } else {
        client.onPacket(packet);
      }
    }
  }

  void _onGameSocketPacket(GameSocketPacket packet) {
    if (packet.connect) {
      connectTo(packet.namespace); // packet.data
    } else if (packet.ping) {
      sendMessage(Pong(packet.time));
    } else if (packet.pong) {
      //TODO
    } else {
      var client = _clientByNamespace[packet.namespace];
      if (client == null) {
        print('no GameClient for namespace "${packet.namespace}"');
        return;
      }
      // Disconnect
      else if (packet.disconnect) {
        client.onDisconnect();
      }
      // other
      else {
        client.onPacket(packet);
      }
    }
  }

  @protected
  void onRoomPacket(GameClient client, RoomPacket packet) {
    // Joins a room
    if (packet.joinRoom || packet.createRoom) {
      //TODO create
      var roomName = packet.roomName;
      var roomToLeave = packet.roomToLeave;
      if (roomToLeave != null) client.leave(roomToLeave);
      if (roomName != null) client.join(roomName);
    }
    // Leaves a room
    else if (packet.leaveRoom) {
      var roomName = packet.roomName;
      if (roomName != null) client.leave(roomName);
    }
    // Event
    else if (packet.event) {
      client.onEvent(packet);
    }
    // other
    else {
      client.onPacket(packet);
    }
  }

  @internal
  void connectTo(String namespace) {
    if (_server.hasNamespace(namespace)) {
      _doConnect(namespace);
    } else {
      sendMessage(ErrorMessage(ErrorCode.invalidNamespace, ''));
    }
  }

  void _doConnect(String namespace) {
    final nsp = _server.of(namespace);
    if (!nsp.connectedSockets.contains(socketId)) {
      final socket = nsp.connectClient(this);
      _clientById[socket.id] = socket;
      _clientByNamespace[namespace] = socket;
    } else {
      sendMessage(ErrorMessage(ErrorCode.alreadyConnected, ''));
    }
  }

  @internal
  void remove(GameClient client) {
    _clientById.remove(client.id);
    _clientByNamespace.remove(client.namespace.name);
  }

  @internal
  void disconnect(String reason) {
    for (var i = _clientById.length - 1; i >= 0; i--) {
      var client = _clientById.values.elementAt(i);
      client.disconnect(false, reason);
    }
    _clientById.clear();
    _clientByNamespace.clear();
    _close();
  }

  void _close() {
    if (_socket.readyState == ReadyState.open) {
      _socket.close();
      _onClose(ClientDisconnectionReason.normal);
    }
  }

  void _destroy() {
    _socket.offAll();
  }

  Duration getIdleTime() => DateTime.now().difference(_socket.lastActivityTime);

  @override
  String toString() {
    return 'ServerClient{ ${_socket.socketId} [$hashCode]}';
  }
}
