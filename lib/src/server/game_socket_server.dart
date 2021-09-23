import 'dart:async';
import 'dart:io' show InternetAddress;

import '../../server.dart';
import '../engine/engine_event.dart';
import '../engine/engine_server.dart';
import '../engine/engine_socket.dart';
import '../protocol/schema.dart';
import '../server/game_adapter.dart';
import 'adapter.dart';
import 'game_client.dart';
import 'game_namespace.dart';
import 'namespace.dart';
import 'server_client.dart';
import 'server_options.dart';

class GameSocketServer {
  final EngineServer _engine;
  final ServerOptions _options;
  late final GameNamespace _mainSpace;
  final Map<String, GameNamespace> _namespaces = {};
  late final Timer? _timer;
  late int maxIdleTime; // seconds

  GameSocketServer({EngineServer? engine, ServerOptions? options})
      : _engine = engine ?? EngineServer(),
        _options = options ?? ServerOptions.byDefault() {
    _options.lock();
    _mainSpace = of('/');
    maxIdleTime = _options.maxSessionIdleTime;
    _engine.on(Engine.connection, (socket) => _onConnection(socket));
    _timer = Timer.periodic(Duration(seconds: 60), _onTick);
  }

  /// The port used by this socket.
  int? get port => _engine.server?.port;

  /// The address used by this socket.
  InternetAddress? get address => _engine.server?.address;

  ServerOptions getOptions() => _options;

  Schema? getSchema(int code, int version) => _options.getSchema(code, version);

  Adapter createAdapter(Namespace namespace) {
    return GameAdapter(namespace, _options.sendRoomEvents);
  }

  void listen([dynamic address, int? port]) {
    print('listen ${address ?? ':' ?? port ?? ''} $_options');
    _engine.listen(address ?? InternetAddress.anyIPv4, port ?? _options.port);
  }

  void _onConnection(EngineSocket socket) {
    ServerClient(this, socket).connectTo('/');
  }

  bool hasNamespace(String namespace) {
    if (namespace[0] != '/') {
      print('use "/" in /$namespace');
      return false;
    }
    return _namespaces.containsKey(namespace);
  }

  /// Create namespace.
  GameNamespace of(String namespace) {
    if (namespace[0] != '/') {
      namespace = '/' + namespace;
    }
    var nsp = _namespaces[namespace];
    nsp ??= _namespaces[namespace] = GameNamespace(namespace, this);
    return nsp;
  }

  Namespace to(String room) => _mainSpace.to(room);

  // emitter
  void emit(event, data) => _mainSpace.emit(event, data);

  void on(event, handler) => _mainSpace.on(event, handler);

  void once(event, handler) => _mainSpace.once(event, handler);

  void off(event, handler) => _mainSpace.off(event, handler);

  void offAll() => _mainSpace.offAll();

  void _onTick(Timer timer) {
    if (maxIdleTime > 0) {
      var idleClients = <GameClient>[];
      for (var nsp in _namespaces.values) {
        for (var socketId in nsp.connectedSockets) {
          var socket = nsp.getClient(socketId);
          if (socket != null && socket.getIdleTime().inSeconds > maxIdleTime) {
            idleClients.add(socket);
          }
        }
      }
      for (var client in idleClients) {
        client.disconnect(true, ClientDisconnectionReason.idle);
      }
    }
  }
}
