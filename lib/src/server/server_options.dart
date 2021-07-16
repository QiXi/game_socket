import '../../protocol.dart';

class ServerOptions {
  static final ServerOptions _default = ServerOptions()
    ..addSchema(GameSocketSchema())
    ..addSchema(RoomSchema());

  bool _locked;
  int port;
  bool supportRawData = false;
  int maxIncomingPacketSize = 2048;
  int maxSessionIdleTime = 60; // seconds
  bool closeSocketOnError = false;
  bool sendRoomEvents = true;
  int connectionTimeout; // ms

  final Schema mainSchema = GameSocketSchema();
  final List<Schema?> _schemas = List.filled(256, null);

  factory ServerOptions.byDefault() {
    return _default..lock();
  }

  ServerOptions({this.port = 3103, this.connectionTimeout = 45000}) : _locked = false;

  Schema? addSchema(Schema schema) {
    _schemas[schema.code] = schema;
  }

  Schema? getSchema(int code, int version) {
    return _schemas[code];
  }

  void lock() {
    _locked = true;
  }

  @override
  String toString() {
    return 'Options{ port:$port raw:$supportRawData closeOnError:$closeSocketOnError }';
  }
}
