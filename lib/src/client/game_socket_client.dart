import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../client.dart';
import '../engine/emitter.dart';
import '../engine/engine_event.dart';
import '../engine/engine_socket.dart';
import '../engine/typedef.dart';
import 'avg_ping.dart';
import 'client_options.dart';

class GameSocketClient extends Emitter {
  final ClientOptions _options;
  EngineSocket? _engine;
  var _forcedClose = false;
  var reconnectAttempts = 0;
  dynamic host = 'localhost';
  int port = 3103;
  String namespace = '/';
  Duration _pingInterval = Duration(seconds: 0);
  final AvgPing ping = AvgPing();
  Timer? _pingTimer;
  bool waitingPong = false;

  GameSocketClient({ClientOptions? options}) : _options = options ?? ClientOptions();

  ClientOptions getOptions() => _options;

  ReadyState get state => _engine?.readyState ?? ReadyState.closed;

  int get readBytes => _engine?.stat.readBytes ?? 0;

  int get writtenBytes => _engine?.stat.writtenBytes ?? 0;

  /// The [InternetAddress] used to connect this socket.
  InternetAddress? get address => _engine?.address;

  SocketStat? get statistic => _engine?.stat;

  /// A TCP connection between two sockets.
  /// [host] can either be a [String] or an [InternetAddress].
  void connect(host, int port, {String namespace = '/'}) {
    this.host = host;
    this.port = port;
    this.namespace = namespace;
    _forcedClose = false;
    Socket.connect(host, port, timeout: _options.connectTimeout).then((Socket socket) {
      bind(EngineSocket(socket, 'this'));
      _engine!.onOpen();
    }).catchError((e) {
      print('Unable to connect: $e');
      emit(Event.connectError, e);
    });
  }

  @internal
  void bind(EngineSocket engine) {
    _engine = engine;
    engine.on(Engine.open, (address) => onOpen(address));
    engine.on(Engine.data, (data) => onData(data));
    engine.on(Engine.error, (error) => onError(error));
    engine.on(Engine.closing, (_) => onClosing());
    engine.on(Engine.close, (_) => onClose(_forcedClose));
  }

  /// Send a message.
  void sendMessage(Message message) {
    if (state == ReadyState.open) {
      message.namespace ??= namespace;
      var rawMessage = messageEncoder.encode(message, message.schema);
      _engine!.send(rawMessage);
      _engine!.stat.addWrittenPacket();
      emit(Event.send, message);
    }
  }

  /// Send a [Uint8List] data.
  void send(Uint8List data) {
    if (state == ReadyState.open) {
      _engine!.send(data);
    }
  }

  /// Disconnect the client.
  void close() {
    _forcedClose = true;
    if (state == ReadyState.open) {
      _engine!.close();
    }
  }

  @protected
  void onOpen(InternetAddress address) {
    reconnectAttempts = 0;
    emit(Event.open, address);
  }

  @protected
  void onData(Uint8List data) {
    var offset = 0;
    if (!Protocol.checkHeader(data, offset)) {
      onRaw(data);
    } else {
      do {
        final code = data[offset + 1];
        final version = data[offset + 3];
        var schema = _options.getSchema(code, version);
        if (schema == null || schema.version != version) {
          onError('${ErrorString.unsupportedSchema} $code.$version');
          break;
        } else {
          var packet = onCreatePacket(code, version, schema);
          try {
            offset = packetDecoder.decode(packet, data, offset);
          } catch (e) {
            onError('${ErrorString.decode} $e');
            break;
          } finally {
            onDecoded(packet);
          }
        }
      } while (Protocol.checkHeader(data, offset));
    }
  }

  @protected
  void onRaw(Uint8List data) {
    if (_options.supportRawData) {
      emit(Event.raw, data);
    } else {
      onError(ErrorString.unsupportedRaw);
    }
  }

  @protected
  void onError(Object error) {
    emit(Event.error, error);
  }

  @protected
  void onClosing() {
    _pingTimer?.cancel();
    emit(Event.closing);
  }

  @protected
  void onClose(bool forced) {
    if (forced) {
      emit(Event.close, forced);
    } else {
      if (reconnectAttempts < _options.maxReconnectAttempts) {
        reconnectAttempts++;
        connect(host, port);
      } else {
        emit(Event.close, forced);
      }
    }
  }

  @protected
  Packet onCreatePacket(int code, int version, Schema schema) {
    if (code == GSS().code) {
      return GameSocketPacket();
    } else if (code == RoomSchema().code) {
      return RoomPacket();
    } else {
      return Packet(schema);
    }
  }

  @protected
  void onDecoded(Packet packet) {
    _engine?.stat.addReadPacket();
    if (packet is GameSocketPacket) {
      onGameSocketPacket(packet);
    } else if (packet is RoomPacket) {
      onRoomPacket(packet);
    } else {
      onPacket(packet);
    }
  }

  @protected
  void onPacket(Packet packet) {
    if (packet.namespace != namespace) {
      return;
    }
    emit(Event.packet, packet);
  }

  @protected
  void onGameSocketPacket(GameSocketPacket packet) {
    if (packet.ping) {
      sendMessage(Pong(packet.time));
      emit(Event.ping);
    } else if (packet.pong) {
      onPongPacket(packet);
    }
    // connection
    else if (packet.handshake) {
      emit(Event.handshake, packet);
      pingInterval = Duration(seconds: packet.pingInterval);
    } else if (packet.disconnect) {
      emit(Event.disconnect);
    }
    // other
    else {
      onPacket(packet);
    }
  }

  @protected
  void onPongPacket(GameSocketPacket packet) {
    waitingPong = false;
    var now = DateTime.now().millisecondsSinceEpoch % maxInt32;
    var time = now - packet.time;
    ping.update(time);
    emit(Event.pong, [time, ping.time]);
    if (_options.disconnectOnHighPing && ping.time > _options.limitHighPing) {
      close();
    }
  }

  @protected
  void onRoomPacket(RoomPacket packet) {
    emit(Event.roomPacket, packet);
  }

  set pingInterval(Duration interval) {
    _pingTimer?.cancel();
    _pingInterval = interval;
    if (_pingInterval.inSeconds == 0) return;
    _pingTimer = Timer.periodic(interval, (timer) {
      if (waitingPong) {
        // No pong received.
        timer.cancel();
        close();
      } else {
        waitingPong = true;
        sendMessage(Ping());
      }
    });
  }
}
